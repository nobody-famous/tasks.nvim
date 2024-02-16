local cmd = dofile('lua/tasks/command.lua')

describe('Command tests', function()
    it('Invalid spec', function()
        assert(cmd.from_spec({}) == nil)
        assert(cmd.from_spec({ label = 'foo' }) == nil)
        assert(cmd.from_spec({ type = 'bar' }) == nil)
    end)

    it('Args', function()
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', args = {} }) ~= nil)
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', args = { 'foo', 'bar' } }) ~= nil)
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', args = { foo = 'bar' } }) == nil)

        local result = cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', args = { 'foo', 'baz' } })
        assert(result.cmd[1] == 'bar')
        assert(result.cmd[2] == 'foo')
        assert(result.cmd[3] == 'baz')
    end)

    it('Options', function()
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', options = { cwd = "baz" } }) ~= nil)
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', options = { cwd = 1234 } }) == nil)
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', options = { env = { foo = 'bar' } } }) ~=
            nil)
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', options = { env = "baz" } }) == nil)
        assert(cmd.from_spec({ label = 'foo', type = 'shell', command = 'bar', options = { env = { 'foo', 'bar' } } }) ==
            nil)
    end)

    describe('Toggle window', function()
        local buf_id = 5
        local win_id = 10
        local term_id = 20
        local win_buf_id = nil
        local set_win_id = nil
        local set_buf_id = nil
        local close_win_id = nil
        local term_buf_id = nil

        local function reset()
            buf_id = 5
            win_id = 10
            term_id = 20
            win_buf_id = nil
            set_win_id = nil
            set_buf_id = nil
            close_win_id = nil
            term_buf_id = nil
        end

        local function run_test(validate, opts)
            opts = opts or {}

            local fake_api = {
                nvim_list_wins = function() return opts.fake_wins_list or {} end,
                nvim_open_term = function(id)
                    term_buf_id = id
                    return opts.term_id or term_id
                end,
                nvim_win_set_buf = function(a, b)
                    set_win_id = a
                    set_buf_id = b
                    return nil
                end,
                nvim_create_buf = function() return opts.buf_id or buf_id end,
                nvim_open_win = function(id)
                    win_buf_id = id
                    return win_id
                end,
                nvim_win_close = function(id)
                    close_win_id = id
                end
            }

            reset()

            cmd.toggle({ api = fake_api })
            validate()
        end

        it('Show window', function()
            run_test(function()
                assert(win_buf_id == buf_id)
                assert(set_win_id == win_id)
                assert(set_buf_id == buf_id)
                assert(term_buf_id == buf_id)
                assert(close_win_id == nil)
            end)
        end)

        it('Hide window', function()
            cmd._win_id = win_id

            run_test(function()
                    assert(win_buf_id == nil)
                    assert(set_win_id == nil)
                    assert(set_buf_id == nil)
                    assert(term_buf_id == nil)
                    assert(close_win_id == win_id)
                end,
                { fake_wins_list = { win_id } }
            )
        end)
    end)
end)
