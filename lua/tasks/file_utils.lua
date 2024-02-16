local JC = require('jsonc')
local M = {}

function M.parse_file(vim_obj, iolib)
    vim_obj = vim_obj or vim
    iolib = iolib or io

    local task_file = M._find_tasks_file(vim_obj)
    if task_file == nil then
        return nil
    end

    local json = M._read_tasks_file(task_file, iolib)
    local ok, data = JC.parse(json)

    if not ok then
        return nil
    end

    return data
end

function M.find_proj_root(vim_obj)
    local proj_dir = vim_obj.fs.find({ '.git' }, { upward = true, type = "directory", limit = 1 })
    if proj_dir ~= nil and #proj_dir > 0 then
        return vim.fn.fnamemodify(proj_dir[1], ':h')
    else
        return nil
    end
end

function M._find_tasks_file(vim_obj)
    local proj_dir = M.find_proj_root(vim_obj)
    if proj_dir == nil or #proj_dir == 0 then
        return nil
    end

    local vscode_dir = vim_obj.fs.find({ '.vscode' }, { path = proj_dir .. '/../', type = "directory", limit = 1 })
    if vscode_dir == nil or #vscode_dir == 0 then
        return nil
    end

    local task_file = vim_obj.fs.find({ 'tasks.json' }, { path = vscode_dir[1], type = "file", limit = 1 })
    if task_file == nil or #task_file == 0 then
        return nil
    end

    return task_file[1]
end

function M._read_tasks_file(task_file, iolib)
    local file = iolib.open(task_file, "r")
    if file == nil then
        return nil
    end

    return file:read("*a")
end

return M
