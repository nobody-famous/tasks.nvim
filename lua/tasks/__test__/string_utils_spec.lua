local utils = dofile('lua/tasks/string_utils.lua')

describe('String utils tests', function()
    describe('Substitute', function()
        it('No vars', function()
            assert(utils.substitute('a b c') == 'a b c')
        end)

        it('One var', function()
            local fake_utils = {
                find_proj_root = function() return '/proj/root' end
            }

            assert(utils.substitute('${workspaceFolder}/a', fake_utils) == '/proj/root/a')
            assert(utils.substitute('${workspaceFolder}/a/${foo}', fake_utils) == '/proj/root/a/')
        end)
    end)
end)
