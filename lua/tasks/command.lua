local utils = require('tasks.string_utils')

local M = {}

M._buf_id = nil
M._win_id = nil
M._term_id = nil
M._proc = nil

function M.from_spec(spec, vim_obj, utils_lib)
    vim_obj = vim_obj or vim
    utils_lib = utils_lib or utils

    if not M._validate_spec(spec) then
        return nil
    end

    local os_spec = M._get_os_spec(spec, vim_obj)
    if os_spec ~= nil then
        if not M._validate_os_spec(os_spec) then
            return nil
        end

        M._merge_spec(spec, os_spec)
    end

    return {
        cmd = M._create_command(spec, utils_lib),
        opts = M._create_opts(spec, vim_obj, utils_lib)
    }
end

function M.run(to_run, vim_obj)
    vim_obj = vim_obj or vim

    if M._proc ~= nil then
        return
    end

    if not M._window_exists(vim_obj) then
        M._show_win(vim_obj)
    end

    M._send_data(string.format('\n** Running %s\n', vim_obj.inspect(to_run.cmd)), vim_obj)

    M._proc = vim_obj.system(
        to_run.cmd,
        {
            cwd = to_run.opts.cwd,
            env = to_run.opts.env,
            text = true,
            stdout = function(_, data) M._send_data(data, vim_obj) end,
            stderr = function(_, data) M._send_data(data, vim_obj) end,
        },
        function()
            M._proc = nil
            M._send_data('\n\n** Exited\n', vim_obj)
        end
    )
end

function M.toggle(vim_obj)
    vim_obj = vim_obj or vim

    if M._window_exists(vim_obj) then
        vim_obj.api.nvim_win_close(M._win_id, true)
    else
        M._show_win(vim_obj)
    end
end

function M._create_command(spec, utils_lib)
    local cmd_values = { utils_lib.substitute(spec.command) }

    if spec.args ~= nil then
        local args = M._substitute_vars(spec.args)

        for _, arg in ipairs(args) do
            table.insert(cmd_values, arg)
        end
    end

    return cmd_values
end

function M._create_opts(spec, vim_obj, utils_lib)
    if type(spec.options) ~= 'table' then
        return {}
    end

    local opts = {}

    if type(spec.options.cwd) == 'string' then
        opts.cwd = utils_lib.substitute(spec.options.cwd)
    else
        opts.cwd = vim_obj.loop.cwd()
    end

    if type(spec.options.env) == 'table' then
        opts.env = {}

        for k, v in pairs(spec.options.env) do
            opts.env[k] = utils_lib.substitute(v)
        end
    end

    return opts
end

function M._substitute_vars(strs)
    local out = {}

    for _, str in ipairs(strs) do
        table.insert(out, utils.substitute(str))
    end

    return out
end

function M._show_win(vim_obj)
    M._check_for_buf(vim_obj)
    M._check_for_term(vim_obj)
    M._check_for_win(vim_obj)
    M._attach_buf(vim_obj)
    M._jump_to_end(vim_obj)
end

function M._attach_buf(vim_obj)
    vim_obj.api.nvim_win_set_buf(M._win_id, M._buf_id)
end

function M.kill()
    if M._proc == nil then
        return
    end

    M._proc:kill(9)
end

function M._validate_spec(spec)
    return type(spec) == 'table'
        and type(spec.label) == 'string'
        and M._validate_type(spec)
        and (spec.args == nil or M._validate_args(spec.args))
        and (spec.options == nil or M._validate_options(spec.options))
end

function M._validate_os_spec(spec)
    return type(spec) == 'table'
        and (spec.args == nil or M._validate_args(spec.args))
        and (spec.options == nil or M._validate_options(spec.options))
end

function M._validate_type(spec)
    return spec.type == 'shell' and type(spec.command) == 'string'
end

function M._validate_args(spec_args)
    if type(spec_args) ~= 'table' then
        return false
    end

    for k, v in pairs(spec_args) do
        if type(k) ~= 'number' or type(v) ~= 'string' then
            return false
        end
    end

    return true
end

function M._validate_options(spec_opts)
    return type(spec_opts) == 'table'
        and (spec_opts.cwd == nil or type(spec_opts.cwd) == 'string')
        and (spec_opts.env == nil or M._validate_env(spec_opts.env))
end

function M._validate_env(opts_env)
    if type(opts_env) ~= 'table' then
        return false
    end

    for k, v in pairs(opts_env) do
        if type(k) ~= 'string' or type(v) ~= 'string' then
            return false
        end
    end

    return true
end

function M._get_os_spec(spec, vim_obj)
    if vim_obj.fn.has('linux') == 1 and spec.linux ~= nil then
        return spec.linux
    elseif (vim_obj.fn.has('win32') == 1 or vim_obj.fn.has('win64') == 1) and spec.windows ~= nil then
        return spec.windows
    elseif vim_obj.fn.has('osx') == 1 and spec.osx ~= nil then
        return spec.osx
    end

    return nil
end

function M._merge_spec(to, from)
    if from.options ~= nil then
        if to.options == nil then
            to.options = {}
        end

        for k, v in pairs(from.options) do
            to.options[k] = v
        end
    end

    if from.args ~= nil then
        to.args = from.args
    end
end

function M._send_data(data, vim_obj)
    if data == nil then
        return
    end

    vim.schedule(function()
        vim_obj.api.nvim_chan_send(M._term_id, data)
    end
    )
end

function M._jump_to_end(vim_obj)
    local count = vim_obj.api.nvim_buf_line_count(M._buf_id)
    vim_obj.api.nvim_win_set_cursor(M._win_id, { count, 1 })
end

function M._check_for_buf(vim_obj)
    if M._buf_id ~= nil then
        return
    end

    M._buf_id = vim_obj.api.nvim_create_buf(true, true)
end

function M._check_for_win(vim_obj)
    if M._window_exists(vim_obj) then
        return
    end

    M._win_id = vim_obj.api.nvim_open_win(M._buf_id, false, { split = 'right' })
end

function M._check_for_term(vim_obj)
    if M._term_id ~= nil then
        return
    end

    M._term_id = vim_obj.api.nvim_open_term(M._buf_id, {})
end

function M._window_exists(vim_obj)
    local windows = vim_obj.api.nvim_list_wins()

    for _, win_id in ipairs(windows) do
        if win_id == M._win_id then
            return true
        end
    end

    return false
end

return M
