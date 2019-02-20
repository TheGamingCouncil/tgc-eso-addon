function TGC.LoadDatabase()
  local TGCGuildVarDefaults = {
    lastScan = 0,
    invitedMembers = {},
    priorMembers = {},
    guildEvents = {
      signupList = {},
      eventList = {}
    },
    options = {
      guildOptions = {
        randomMessages = {
          "Hi, are you looking for a social/trials guild by chance? ^.^",
          "Hi, are you looking for a guild by chance? :)",
          "Hi, are you looking for a social and trials guild by chance? :)"
        },
        scanHistory = false
      }
    }
  }
  TGC.db = ZO_SavedVars:NewAccountWide("TGC_SavedVariables", 4, nil, TGCGuildVarDefaults )
end