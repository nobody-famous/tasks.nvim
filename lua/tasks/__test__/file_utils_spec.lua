local utils = dofile('lua/tasks/file_utils.lua')

describe('File utils tests', function()
    local run_test = function(paths, validate, read_ok)
        if read_ok == nil then
            read_ok = true
        end

        local file_data = '{}'
        local file_obj = {
            read = function(_, read_mode)
                assert(read_mode == '*a')
                return file_data
            end
        }
        local vim = {
            fs = {
                find = function(path_list, _)
                    for _, path in ipairs(paths) do
                        if path_list[1] == path then
                            return path_list
                        end
                    end

                    return nil
                end
            }
        }

        local io = {
            open = function(name)
                if read_ok and name == 'tasks.json' then
                    return file_obj
                else
                    return nil
                end
            end
        }

        local data = utils.parse_file(vim, io)

        validate(data)
    end

    it('Parse file', function()
        run_test({ '.git', '.vscode', 'tasks.json' }, function(data)
            assert(data ~= nil)
        end)

        run_test({ '.git', '.vscode', 'tasks.json' }, function(data)
            assert(data == nil)
        end, false)

        run_test({ '.git', '.vscode' }, function(data)
            assert(data == nil)
        end)

        run_test({ '.git', 'tasks.json' }, function(data)
            assert(data == nil)
        end)

        run_test({ 'tasks.json' }, function(data)
            assert(data == nil)
        end)
    end)
end)
