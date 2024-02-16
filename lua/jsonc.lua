local M = {}

function M.parse(json)
    local ok = false
    local result = nil
    local keep_going = true

    while keep_going do
        local comma_index = nil
        local comment_index = nil

        ok, result = pcall(function()
            return vim.json.decode(json, { luanil = { object = true, array = true } })
        end)

        if not ok then
            _, _, comma_index = M._get_comma_index(json, result)
            _, _, comment_index = M._get_comment_index(json, result)
        end

        if comma_index ~= nil then
            json = M._remove_char(json, comma_index)
        elseif comment_index ~= nil then
            json = M._remove_comment(json, comment_index)
        else
            keep_going = false
        end
    end

    return ok, result
end

function M._get_comma_index(data, str)
    local s, e, index = string.find(str, "T_OBJ_END at character (%d+)")

    if index == nil then
        return nil
    end

    index = tonumber(index)
    if index == nil then
        return nil
    end

    index = index - 1
    while index > 1 and string.sub(data, index, index):match("%s") ~= nil do
        index = index - 1
    end

    if string.sub(data, index, index) ~= ',' then
        return nil
    end

    return s, e, index
end

function M._get_comment_index(data, err_msg)
    local s, e, ndx = string.find(err_msg, "invalid token at character (%d+)")

    if ndx ~= nil and string.sub(data, ndx, ndx + 1) == "//" then
        return s, e, ndx
    else
        return nil
    end
end

function M._remove_char(data, index)
    local before = string.sub(data, 1, index - 1)
    local after = string.sub(data, index + 1)

    return before .. after
end

function M._remove_comment(data, index)
    local before = string.sub(data, 1, index - 1)
    local after = string.sub(data, index)
    local eol_index = string.find(after, "\n")

    if eol_index ~= nil then
        after = string.sub(after, eol_index + 1)
        return before .. after
    end

    return before
end

return M
