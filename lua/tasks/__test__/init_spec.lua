local tasks = dofile('lua/tasks/init.lua')

describe('Tasks tests', function()
    local function run_test(fake_tasks, validate)
        local utils = {
            parse_file = function()
                return { tasks = fake_tasks }
            end
        }
        local data = tasks.get_tasks(utils)
        validate(data)
    end

    it('Get tasks', function()
        run_test({}, function(data) assert(data ~= nil) end)
        run_test(nil, function(data) assert(data == nil) end)
    end)
end)
