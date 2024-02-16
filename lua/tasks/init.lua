local FileUtils = require('tasks.file_utils')
local M = {}

function M.get_tasks(utils_lib)
    utils_lib = utils_lib or FileUtils

    local data = utils_lib.parse_file()

    if data ~= nil then
        return data.tasks
    end
end

return M
