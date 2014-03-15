local pdasim = require "pdasim"

Q = { 's', 't', 'u', 'v' }
Sigma = { '0', '1' }
Gamma = { '0', '1' }
delta = {
    { { 's', '0', ''  }, { 's', '0' } },
    { { 's', '1', ''  }, { 's', '1' } },
    { { 's',  '', ''  }, { 't', ''  } },
    { { 't', '0', '0' }, { 't', ''  } },
    { { 't', '1', '1' }, { 't', ''  } },
    { { 't',  '', ''  }, { 'u', ''  } },
    { { 'u', '0', ''  }, { 'u', '0' } },
    { { 'u', '1', ''  }, { 'u', '1' } },
    { { 'u',  '', ''  }, { 'v', ''  } },
    { { 'v', '0', '0' }, { 'v', ''  } },
    { { 'v', '1', '1' }, { 'v', ''  } }
}
q0 = 's'
Z = ''
F = { 'v' }

acceptor = pdasim.NewAcceptor(Q, Sigma, Gamma, delta, q0, Z, F)

tests = { '', '00', '11', '01', '010', '0110' }

for _,test in ipairs(tests) do
    local result = acceptor(test)
    local status = result and 'accepted' or 'not accepted'
    print('\"' .. test .. '\"' .. ' was ' .. status)
end

print("Now type in some of your own tests...")
while true do
    local line = io.read("*l")
    if line == nil then break end
    local result = acceptor(line)
    local status = result and 'accepted' or 'not accepted'
    print('\"' .. line .. '\"' .. ' was ' .. status)
end
