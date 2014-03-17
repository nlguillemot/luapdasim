local M = { } -- module definition

local _debugLevel = 0

local _epsilon = 'ε'

local function _arrayToSet (a)
    local s = { }
    for k,v in ipairs(a) do
        s[v] = true
    end
    return s
end

local function _setIterator (s)
    local key = nil
    return function ()
        repeat
            local k,v = next(s, key)
            key = k
        until key == nil or v
        return key
    end
end

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

local function _areTwoConfigurationSetsEquivalent (config1, config2)
    local config1keys = { }
    for configKey,_ in pairs(config1) do
        config1keys[#config1keys + 1] = configKey
    end

    local config2keys = { }
    for configKey,_ in pairs(config2) do
        config2keys[#config2keys + 1] = configKey
    end

    -- they can only be the same if they have the same length
    if #config1keys == #config2keys then
        table.sort(config1keys)
        table.sort(config2keys)
        local allTheSame = true
        for i = 1, #config1keys do
            if config1keys[i] ~= config2keys[i] then
                allTheSame = false
                break
            end
        end

        if allTheSame then
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
    return function (originalInput)
        -- build a set out of the final state array, for convenience.
        local finalStateSet = _arrayToSet(F)

        -- keep track of all the current configurations (since PDAs are non-deterministic)
        -- this set begins with only the initial state in it.
        local currentConfigurationSet = { }
        _insertConfigurationToSet(currentConfigurationSet, q0, originalInput, Z)

        local pastConfigurationSets = { }

        -- if any possible configuration is in a final state with no more input or stack, then the computation is accepted.
        while not _configurationSetHasAnAcceptedConfiguration(currentConfigurationSet, finalStateSet) do
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

            pastConfigurationSets[#pastConfigurationSets + 1] = currentConfigurationSet

            -- check if we're stuck in a loop of seeing the same configurations
            for _,configurationSet in ipairs(pastConfigurationSets) do
                if _areTwoConfigurationSetsEquivalent(configurationSet, nextConfigurationSet) then
                    return false
                end
            end

            currentConfigurationSet = nextConfigurationSet
        end

        -- computation was accepted
        return true
    end
end

return M
