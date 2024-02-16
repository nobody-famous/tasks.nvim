local file_utils = require('tasks.file_utils')

local M = {}

function M.substitute(str, utils_lib)
    utils_lib = utils_lib or file_utils

    local vars = M._find_var_ranges(str)
    if #vars == 0 then
        return str
    end

    local parts = {}
    local splits = M._get_splits(str, vars)
    for index, split in ipairs(splits) do
        table.insert(parts, split)
        if vars[index] ~= nil then
            local s = vars[index].open + 2
            local e = vars[index].close - 1
            local name = string.sub(str, s, e)

            table.insert(parts, M._replace(name, utils_lib))
        end
    end

    return table.concat(parts)
end

function M._replace(name, utils_lib)
    if name == 'workspaceFolder' then
        return utils_lib.find_proj_root(vim)
    end

    return ""
end

function M._get_splits(str, vars)
    local splits = {}
    local first = 1
    local next = nil

    for _, var in ipairs(vars) do
        next = var.open - 1

        table.insert(splits, string.sub(str, first, next))
        first = var.close + 1
    end

    table.insert(splits, string.sub(str, first))

    return splits
end

function M._find_var_ranges(str)
    local vars = {}
    local index = 1

    repeat
        local open, close = M._find_next_var(str, index)

        if open ~= nil and close ~= nil then
            table.insert(vars, { open = open, close = close })
            index = close + 1
        end
    until open == nil or close == nil

    return vars
end

function M._find_next_var(str, index)
    local open = string.find(str, '${', index, true)
    if open == nil then
        return nil
    end

    local close = string.find(str, '}', open + 2, true)
    if close == nil then
        return nil
    end

    return open, close
end

return M
