local M = {}

function M.is_valid(data)
    local version = data['version']
    local tasks = data['tasks']

    if version ~= '2.0.0' or type(tasks) ~= 'table' then
        return false
    end

    return true
end

function M.get_entries(data)
    if not M.is_valid(data) then
        return {}
    end

    local entries = {}

    for _, item in ipairs(data['tasks']) do
        if M._check_entry(item) then
            table.insert(entries, item)
        end
    end

    return entries
end

function M._check_entry(item)
    return type(item['label']) == 'string'
end

return M
