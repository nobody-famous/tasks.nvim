local picker = dofile('lua/tasks/picker.lua')

describe('Picker tests', function()
    local function get_labels(task_data)
        local fake_tasks = {
            get_tasks = function()
                return task_data
            end
        }
        local fake_cmd = {
            run = function()
            end
        }
        local fake_pickers = {
            new = function()
                return { find = function() end }
            end
        }
        local fake_conf = {
            values = { generic_sorter = function() end }
        }

        local labels = nil
        local fake_finders = {
            new_table = function(data)
                labels = data.results
            end
        }

        picker.run_task(fake_tasks, fake_cmd, fake_pickers, fake_finders, fake_conf)

        return labels
    end

    local function check_list(expected, actual)
        assert(expected ~= nil and actual ~= nil and #expected == #actual)

        for i, v in ipairs(expected) do
            assert(actual[i] == v)
        end
    end

    it('Labels test', function()
        picker.initialize()

        check_list(
            { 'Foo', 'Bar' },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
            })
        )

        check_list(
            { 'Foo', 'Bar' },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
            })
        )

        check_list(
            { 'Bar' },
            get_labels({
                { label = 'Bar' },
            })
        )

        check_list(
            { 'Bar', 'Foo' },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
            })
        )

        check_list(
            {},
            get_labels({})
        )
    end)

    it('Select task test', function()
        local fake_cmd = {
            from_spec = function() end,
            run = function() end,
        }

        picker.initialize()

        check_list(
            { 'Foo', 'Bar', 'Baz' },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
                { label = 'Baz' },
            })
        )

        picker.select_task(1, fake_cmd)
        check_list(
            { 'Foo', 'Bar', 'Baz', },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
                { label = 'Baz' },
            })
        )

        picker.select_task(2, fake_cmd)
        check_list(
            { 'Bar', 'Foo', 'Baz', },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
                { label = 'Baz' },
            })
        )

        picker.select_task(3, fake_cmd)
        check_list(
            { 'Baz', 'Bar', 'Foo', },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
                { label = 'Baz' },
            })
        )

        picker.select_task(5, fake_cmd)
        check_list(
            { 'Baz', 'Bar', 'Foo', },
            get_labels({
                { label = 'Foo' },
                { label = 'Bar' },
                { label = 'Baz' },
            })
        )
    end)
end)
