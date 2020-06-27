function TGC.LoadDatabase()
  local TGCGuildVarDefaults = {
    guildName = "The Gaming Council",
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
      },
      mapFlags = {
        homePreviewsZone = false,
        homePreviews = false,
        ownedHomes = true,
        dungeons = true,
        trials = true,
        waypoints = true
      },
      optionFlags = {
        hideMapHomePreview = true,
        hideMapDungeons = false
      }
    }
  }

  local TGCGuildRosterDefaults = {
    lastScan = 0,
    invitedMembers = {},
    invitedHistory = {},
    priorMembers = {},
  }

  local TGCGearDB = {
    sets = {},
    builds = {}
  }

  TGC.rosterDb = ZO_SavedVars:NewAccountWide("TGC_SavedRosterData", 2, nil, TGCGuildRosterDefaults )
  TGC.db = ZO_SavedVars:NewAccountWide("TGC_SavedVariables", 7, nil, TGCGuildVarDefaults )
  TGC.gearDb = ZO_SavedVars:NewAccountWide("TGC_SavedGear", 1, nil, TGCSetDB )
end