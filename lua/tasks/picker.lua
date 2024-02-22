local tasks = require('tasks')
local cmd = require('tasks.command')
local _, pickers = pcall(require, 'telescope.pickers')
local _, finders = pcall(require, 'telescope.finders')
local _, conf = pcall(require, 'telescope.config')
local _, actions = pcall(require, 'telescope.actions')
local _, state = pcall(require, 'telescope.actions.state')
local M = {}

function M.initialize()
    M._tasks_map = {}
    M._task_labels = {}
end

M.initialize()

function M.run_task(tasks_lib, cmd_lib, pickers_lib, finders_lib, conf_lib)
    tasks_lib = tasks_lib or tasks
    cmd_lib = cmd_lib or cmd
    pickers_lib = pickers_lib or pickers
    finders_lib = finders_lib or finders
    conf_lib = conf_lib or conf

    local task_items = tasks_lib.get_tasks()

    if task_items == nil then
        return
    end

    M._populate_map(task_items)
    M._update_labels(task_items)

    local picker = pickers_lib.new({}, {
        prompt_title = 'Tasks',
        finder = finders_lib.new_table({
            results = M._task_labels,
        }),
        sorter = conf_lib.values.generic_sorter({}),
        attach_mappings = function(bufnr)
            actions.select_default:replace(function()
                actions.close(bufnr)
                local item = state.get_selected_entry()
                M.select_task(item['index'], cmd_lib)
            end)
            return true
        end
    })

    picker:find()
end

function M.select_task(index, cmd_lib)
    cmd_lib = cmd_lib or cmd

    if M._task_labels[index] == nil then
        return
    end

    local label = M._to_front(index)
    local item = M._tasks_map[label]
    local to_run = cmd_lib.from_spec(item)

    cmd_lib.run(to_run)
end

function M._to_front(index)
    local item = M._task_labels[index]

    table.remove(M._task_labels, index)
    table.insert(M._task_labels, 1, item)

    return item
end

function M._update_labels(items)
    M._remove_deleted_labels(items)
    M._add_new_labels(items)
end

function M._remove_deleted_labels(items)
    local new_labels = {}

    for _, v in ipairs(M._task_labels) do
        local found = false

        for _, item in pairs(items) do
            if item['label'] == v then
                found = true
            end
        end

        if found then
            table.insert(new_labels, v)
        end
    end

    M._task_labels = new_labels
end

function M._add_new_labels(items)
    for _, item in pairs(items) do
        local found = false

        for _, v in ipairs(M._task_labels) do
            if item['label'] == v then
                found = true
            end
        end

        if not found then
            table.insert(M._task_labels, item['label'])
        end
    end
end

function M._populate_map(items)
    for _, task in ipairs(items) do
        M._tasks_map[task['label']] = task
    end
end

return M
