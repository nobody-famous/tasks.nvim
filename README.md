# tasks.nvim
Run VSCode tasks in Neovim

# Configuration
Using lazy.nvim,
```
return {
    'nobody-famous/tasks.nvim',

    config = function()
        vim.keymap.set({ 'n', 'x' }, '<leader>tk', require('tasks.command').kill)
        vim.keymap.set({ 'n', 'x' }, '<leader>`', require('tasks.command').toggle)
        vim.keymap.set({ 'n', 'i', 'x' }, '<A-S-r>', require('tasks.picker').run_task, {})
    end
}
```
The `kill` command terminates the running task.
The `toggle` command shows/hides the task buffer in a split window.
