local entry = dofile('lua/tasks/entry.lua')

describe('Task Entry tests', function()
    it('is_valid', function()
        assert(entry.is_valid({ version = '2.0.0', tasks = {} }))
        assert(not entry.is_valid({ tasks = {} }))
        assert(not entry.is_valid({ version = '2.0.0' }))
    end)

    local function test_entries(tasks, exp_count)
        assert(#entry.get_entries({ version = '2.0.0', tasks = tasks }) == exp_count)
    end

    it('get_entries', function()
        test_entries({ { label = 'foo', type = "shell" } }, 1)
        test_entries({ { foo = 'bar' }, { label = 'foo', type = "shell" } }, 1)
        test_entries({ { label = 'foo', type = "shell" }, { label = 'bar' } }, 2)
    end)
end)
