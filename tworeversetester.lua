local M = { }
local pdasim = require "pdasim"

local function binaryStrings (N)
    local function binaryStringsR (a, i)
        if i > N then
            coroutine.yield(table.concat(a))
        else
            a[i] = '0'
            binaryStringsR(a, i + 1)
            a[i] = '1'
            binaryStringsR(a, i + 1)
        end
    end
    return coroutine.wrap(function() binaryStringsR({ }, 1) end)
end

local function isuuRvvR (s)
    if #s % 2 ~= 0 then
        return false
    end

    for ulength = 0, #s / 2 do
        local vlength = (#s - ulength * 2) / 2
        local u = s:sub(1, ulength)
        local ur = s:sub(ulength + 1, ulength * 2)
        local v = s:sub(ulength * 2 + 1, ulength * 2 + vlength)
        local vr = s:sub(ulength * 2 + vlength + 1, -1)
        if u == ur:reverse() and v == vr:reverse() then
            return true
        end
    end

    return false
end

function M.NewPDATester(delta, q0, Z, F)
    local acceptor = pdasim.NewAcceptor(delta, q0, Z, F)
    local fails = { }

    return function (maxLength, maxSteps)
        for testLength = 0, maxLength do
            for test in binaryStrings(testLength) do
                local result = acceptor(test, maxSteps)
                if result ~= isuuRvvR(test) then
                    fails[#fails + 1] = test
                end
            end
        end
        return fails
    end
end

return M
