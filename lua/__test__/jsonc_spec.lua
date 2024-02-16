local JC = dofile('lua/jsonc.lua')

describe('jsonc tests', function()
    it('Parse json ok', function()
        local ok, data = JC.parse(
            [[
                {
                    "a":"b"
                }
            ]]
        )

        assert(ok)
        assert(data['a'] == 'b')
    end)

    it('Parse json trailing comma', function()
        local ok, data = JC.parse(
            [[ { "a":"b", } ]]
        )

        assert(ok)
        assert(data['a'] == 'b')
    end)

    it('Parse json comment', function()
        local ok, data = JC.parse(
            [[
                {
                    // This is a comment
                    "a":"b",
                }
            ]]
        )

        assert(ok)
        assert(data['a'] == 'b')
    end)

    it('Parse invalid json', function()
        local ok, _ = JC.parse(
            [[ { // This is a comment "a":"b", } ]]
        )

        assert(not ok)
    end)
end)
