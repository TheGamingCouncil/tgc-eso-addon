function TGC.LoadDatabase()
  local TGCGuildVarDefaults = {
    options = {
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
    options = {
      guilds = {}
    },
    guildData = {}
  }

  local TGCSetDataDefaults = {
    options = {
      core = {
        disabled = false,
        junkNonSets = true,
        junkLowLevel = true
      },
      environment = {
        pvpType = true,
        pveType = true
      },
      role = {
        tankRole = true,
        stamDpsRole = true,
        magDpsRole = true,
        healRole = true,
        otherRole = true,
        disabled = false
      }
    },
    setOverrides = {},
    customBuilds = {}
  }

  TGC.db = {
    roster = ZO_SavedVars:NewAccountWide("TGC_SavedRosterData", 4, nil, TGCGuildRosterDefaults ),
    default = ZO_SavedVars:NewAccountWide("TGC_SavedVariables", 8, nil, TGCGuildVarDefaults ),
    setData = ZO_SavedVars:NewAccountWide("TGC_SavedSetData", 3, nil, TGCSetDataDefaults )
  }
end