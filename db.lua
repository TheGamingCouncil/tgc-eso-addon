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

  local TGCSetOptionsDefaults = {
    core = {
      disabled = false,
      junkNonSets = true,
      junkLowLevel = true,
      trashGuides = false,
      showBuilds = true
    },
    environment = {
      disabled = false,
      pvp = true,
      pve = true
    },
    role = {
      disabled = false,
      tank = true,
      stam = true,
      mag = true,
      heal = true,
      support = true,
      other = true
    },
    class = {
      disabled = false,
      dk = true,
      blade = true,
      sorc = true,
      plar = true,
      den = true,
      cro = true
    }
  };

  local TGCSetDataDefaults = {
    setOverrides = {},
    customBuilds = {}
  }

  TGC.db = {
    roster = ZO_SavedVars:NewAccountWide("TGC_SavedRosterData", 4, nil, TGCGuildRosterDefaults ),
    default = ZO_SavedVars:NewAccountWide("TGC_SavedVariables", 8, nil, TGCGuildVarDefaults ),
    setData = ZO_SavedVars:NewAccountWide("TGC_SavedSetData", 4, nil, TGCSetDataDefaults ),
    setOptions = ZO_SavedVars:NewAccountWide("TGC_SavedSetOptions", 3, nil, TGCSetOptionsDefaults ),
  }
end