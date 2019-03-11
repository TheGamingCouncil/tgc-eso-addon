function TGC.LoadDatabase()
  local TGCGuildVarDefaults = {
    lastScan = 0,
    invitedMembers = {},
    priorMembers = {},
    guildEvents = {
      signupList = {},
      eventList = {}
    },
    inventories = {
      chests = {},
      characters = {},
      bank = {}
    },
    options = {
      guildOptions = {
        randomMessages = {
          "Hi, are you looking for a social/trials guild by chance? ^.^",
          "Hi, are you looking for a guild by chance? :)",
          "Hi, are you looking for a social and trials guild by chance? :)"
        },
        scanHistory = false
      },
      setTracker = {
        tankRole = true,
        stamDpsRole = true,
        magDpsRole = true,
        healRole = true,
        supportRole = true,
        pvpType = true,
        pveType = true,
        duplicateCount = 2,
        onlyCorrectTrait = false
      }
    }
  }
  TGC.db = ZO_SavedVars:NewAccountWide("TGC_SavedVariables", 5, nil, TGCGuildVarDefaults )
end