function TGC.SetTrackerMenu( optionsData )
  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Core",
    controls = {
      {
        type = "checkbox",
        name = "Disable",
        tooltip = "Disables the set tracker icons.",
        getFunc = function() return TGC.db.setOptions.core.disabled end,
        setFunc = function(newValue)
          TGC.db.setOptions.core.disabled = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.core.disabled,
      }, {
        type = "checkbox",
        name = "Non Set Junk",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Marks any equipment that is not in a set as junk.",
        getFunc = function() return TGC.db.setOptions.core.junkNonSets end,
        setFunc = function(newValue)
          TGC.db.setOptions.core.junkNonSets = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.core.junkNonSets,
      }, {
        type = "checkbox",
        name = "Low Level Junk",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Marks any set that is below CP 160 as junk.",
        getFunc = function() return TGC.db.setOptions.core.junkLowLevel end,
        setFunc = function(newValue)
          TGC.db.setOptions.core.junkLowLevel = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.core.junkLowLevel,
      }, {
        type = "checkbox",
        name = "Mark Guided Sets as Trash",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Marks any set that only have guides and no builds as trash.",
        getFunc = function() return TGC.db.setOptions.core.trashGuides end,
        setFunc = function(newValue)
          TGC.db.setOptions.core.trashGuides = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.core.trashGuides,
      }, {
        type = "checkbox",
        name = "Show Builds",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Adds builds to the tooltip for equipment if builds exist.",
        getFunc = function() return TGC.db.setOptions.core.showBuilds end,
        setFunc = function(newValue)
          TGC.db.setOptions.core.showBuilds = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.core.showBuilds,
      }
    }
  }
  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Environment",
    controls = {
      {
        type = "checkbox",
        name = "Disable",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Disables the environment based trash marking.",
        getFunc = function() return TGC.db.setOptions.environment.disabled or TGC.db.setOptions.environment.disabled end,
        setFunc = function(newValue)
          TGC.db.setOptions.environment.disabled = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.environment.disabled,
      }, {
        type = "checkbox",
        name = "PvE",
        disabled = function() return TGC.db.setOptions.environment.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on PvE gear, uncheck to mark all PvE gear as trash.",
        getFunc = function() return TGC.db.setOptions.environment.pve end,
        setFunc = function(newValue)
          TGC.db.setOptions.environment.pve = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.environment.pve,
      }, {
        type = "checkbox",
        name = "PvP",
        disabled = function() return TGC.db.setOptions.environment.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on PvP gear, uncheck to mark all PvP gear as trash.",
        getFunc = function() return TGC.db.setOptions.environment.pvp end,
        setFunc = function(newValue)
          TGC.db.setOptions.environment.pvp = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.environment.pvp,
      }
    }
  }

  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Role",
    controls = {
      {
        type = "checkbox",
        name = "Disable",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Disables the role based trash marking.",
        getFunc = function() return TGC.db.setOptions.role.disabled end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.disabled = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.disabled,
      }, {
        type = "checkbox",
        name = "Tank",
        disabled = function() return TGC.db.setOptions.role.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on tanking gear, uncheck to mark all tank gear as trash.",
        getFunc = function() return TGC.db.setOptions.role.tank end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.tankRole = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.tank,
      }, {
        type = "checkbox",
        name = "Healer",
        disabled = function() return TGC.db.setOptions.role.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on healing gear, uncheck to mark all healer gear as trash.",
        getFunc = function() return TGC.db.setOptions.role.heal end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.heal = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.heal,
      }, {
        type = "checkbox",
        name = "Magic DPS",
        disabled = function() return TGC.db.setOptions.role.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on magic dps gear, uncheck to mark all magic dps gear as trash.",
        getFunc = function() return TGC.db.setOptions.role.mag end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.mag = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.mag,
      }, {
        type = "checkbox",
        name = "Stamina DPS",
        disabled = function() return TGC.db.setOptions.role.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on stamina dps gear, uncheck to mark all stamina dps gear as trash.",
        getFunc = function() return TGC.db.setOptions.role.stam end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.stam = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.stam,
      }, {
        type = "checkbox",
        name = "Support",
        disabled = function() return TGC.db.setOptions.role.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on support build type gear, uncheck to mark all support build type gear as trash.",
        getFunc = function() return TGC.db.setOptions.role.support end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.support = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.support,
      }, {
        type = "checkbox",
        name = "Other",
        disabled = function() return TGC.db.setOptions.role.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on other build type gear, uncheck to mark all other build type gear as trash.",
        getFunc = function() return TGC.db.setOptions.role.other end,
        setFunc = function(newValue)
          TGC.db.setOptions.role.other = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.role.other,
      }
    }
  }

  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Class",
    controls = {
      {
        type = "checkbox",
        name = "Disable",
        disabled = function() return TGC.db.setOptions.core.disabled end,
        tooltip = "Disables the class based trash marking.",
        getFunc = function() return TGC.db.setOptions.class.disabled end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.disabled = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.disabled,
      }, {
        type = "checkbox",
        name = "DragonKnight",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on DragonKnight gear, uncheck to mark all DragonKnight gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.dk end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.dk = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.dk,
      }, {
        type = "checkbox",
        name = "NightBlade",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on NightBlade gear, uncheck to mark all healer NightBlade as trash.",
        getFunc = function() return TGC.db.setOptions.class.blade end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.blade = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.blade,
      }, {
        type = "checkbox",
        name = "Sorcerer",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on Sorcerer gear, uncheck to mark all Sorcerer gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.sorc end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.sorc = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.sorc,
      }, {
        type = "checkbox",
        name = "Templar",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on Templar gear, uncheck to mark all Templar gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.plar end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.plar = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.plar,
      }, {
        type = "checkbox",
        name = "Warden",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on Warden build type gear, uncheck to mark all Warden build type gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.den end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.den = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.den,
      }, {
        type = "checkbox",
        name = "Necromancer",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on Necromancer build type gear, uncheck to mark all Necromancer build type gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.cro end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.cro = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.cro,
      }, {
        type = "checkbox",
        name = "WereWolf",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on WereWolf build type gear, uncheck to mark all WereWolf build type gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.wolf end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.wolf = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.wolf,
      }, {
        type = "checkbox",
        name = "Vampire",
        disabled = function() return TGC.db.setOptions.class.disabled or TGC.db.setOptions.core.disabled end,
        tooltip = "Check to offer information on Vampire build type gear, uncheck to mark all Vampire build type gear as trash.",
        getFunc = function() return TGC.db.setOptions.class.vamp end,
        setFunc = function(newValue)
          TGC.db.setOptions.class.vamp = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setOptions.class.vamp,
      }
    }
  }
end