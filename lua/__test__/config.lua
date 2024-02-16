local path = os.getenv('PLENARY_PATH')

if path == nil then
    print('PLENARY_PATH not set, exiting')
    return
end

vim.opt.runtimepath:append(path)

vim.cmd(
    [[runtime! plugin/plenary.vim]]
)
