local M = { } -- module definition

local _debugLevel = 0

local _epsilon = 'ε'

local function _insertConfigurationToSet (configSet, state, remainingInput, stack)
    local key = state .. '\0' .. remainingInput .. '\0' .. stack
    configSet[key] = {
        ["state"] = state,
        ["remainingInput"] = remainingInput,
        ["stack"] = stack
    }
    return key
end

local function _configurationSetHasAnAcceptedConfiguration (configSet, finalStates)
    for _,config in pairs(configSet) do
        if config.remainingInput == '' and config.stack == '' and finalStates[config.state] then
            return true
        end
    end
    return false
end

local function _configurationToString (config)
    local input = config.remainingInput ~= '' and config.remainingInput or _epsilon
    local stack = config.stack ~= '' and config.stack or _epsilon
    return '(' .. config.state .. "," .. input .. ',' .. stack .. ')'
end

local function _transitionToString (transition)
    local in1 = transition[1][2] ~= '' and transition[1][2] or _epsilon
    local st1 = transition[1][3] ~= '' and transition[1][3] or _epsilon
    local st2 = transition[2][2] ~= '' and transition[2][2] or _epsilon
    return '((' .. transition[1][1] .. ',' .. in1 .. ',' .. st1 .. '),(' .. transition[2][1] .. ',' .. st2 .. '))'
end

function M.NewAcceptor (delta, q0, Z, F)
    return function (originalInput, maxSteps)
        maxSteps = maxSteps or 999

        -- build a set out of the final state array, for convenience.
        local finalStateSet = { }
        for _,v in ipairs(F) do
            finalStateSet[v] = true
        end

        -- keep track of all the current configurations (since PDAs are non-deterministic)
        -- this set begins with only the initial state in it.
        local currentConfigurationSet = { }
        _insertConfigurationToSet(currentConfigurationSet, q0, originalInput, Z)

        local numSteps = 0

        -- if any possible configuration is in a final state with no more input or stack, then the computation is accepted.
        while not _configurationSetHasAnAcceptedConfiguration(currentConfigurationSet, finalStateSet) do
            if numSteps > maxSteps then
                return false, "Computation not accepted within " .. maxSteps .. " steps"
            end

            -- must find the set of configurations possible after 1 more step
            local nextConfigurationSet = { }
            for _,config in pairs(currentConfigurationSet) do
                if _debugLevel >= 1 then
                    print("Checking for transitions from configuration " .. _configurationToString(config))
                end

                -- check each transition for each configuration to see if it allows a transition to a new configuration
                for _,transition in pairs(delta) do
                    -- check if the input tape matches
                    local inputMatch = config.remainingInput:match('^' .. transition[1][2])
                    -- check if the stack's top matches
                    local stackMatch = config.stack:match('^' .. transition[1][3])
                    -- if they all match, then we found a new configuration
                    if config.state == transition[1][1] and inputMatch and stackMatch then
                        local newInput = config.remainingInput:sub(#inputMatch + 1)
                        local newStack = transition[2][2] .. config.stack:sub(#stackMatch + 1)
                        
                        local nextConfigKey = _insertConfigurationToSet(nextConfigurationSet, transition[2][1], newInput, newStack)

                        if _debugLevel >= 1 then
                            print("Found a match with transition " .. _transitionToString(transition) .. " to configuration " .. _configurationToString(nextConfigurationSet[nextConfigKey]))
                        end
                    else
                        if _debugLevel >= 2 then
                            print("There was no match on transition " .. _transitionToString(transition))
                        end
                    end
                end
            end

            if _debugLevel >= 1 then
                print("Found a new set of configurations:")
                for _,config in pairs(nextConfigurationSet) do
                    print(_configurationToString(config))
                end
            end

            currentConfigurationSet = nextConfigurationSet
            numSteps = numSteps + 1
        end

        -- computation was accepted
        return true, "Computation accepted after " .. numSteps .. " steps"
    end
end

return M
