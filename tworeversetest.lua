local testing = require "tworeversetester"

badDelta = {
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
badq0 = 's'
Z = ''
F = { 'v' }

goodDelta = {
    { { 'S',  '', ''  }, { 's', 'A' } },
    { { 's', '0', ''  }, { 's', '0' } },
    { { 's', '1', ''  }, { 's', '1' } },
    { { 's',  '', ''  }, { 't', ''  } },
    { { 't', '0', '0' }, { 't', ''  } },
    { { 't', '1', '1' }, { 't', ''  } },
    { { 't',  '', 'A' }, { 'u', ''  } },
    { { 'u', '0', ''  }, { 'u', '0' } },
    { { 'u', '1', ''  }, { 'u', '1' } },
    { { 'u',  '', ''  }, { 'v', ''  } },
    { { 'v', '0', '0' }, { 'v', ''  } },
    { { 'v', '1', '1' }, { 'v', ''  } }
}
goodq0 = 'S'

badTester = testing.NewPDATester(badDelta, badq0, Z, F)
goodTester = testing.NewPDATester(goodDelta, goodq0, Z, F)

print("Testing bad PDA")
print("Fails (if any): " .. table.concat(badTester(10),", "))

print("Testing good PDA")
print("Fails (if any): " .. table.concat(goodTester(10),", "))
