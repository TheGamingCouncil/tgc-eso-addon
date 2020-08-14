function TGC.SetTrackerMenu( optionsData )
  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Core",
    controls = {
      {
        type = "checkbox",
        name = "Disable",
        tooltip = "Disables the set tracker icons.",
        getFunc = function() return TGC.db.setData.options.core.disabled end,
        setFunc = function(newValue)
          TGC.db.setData.options.core.disabled = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setData.options.core.disabled,
      }, {
        type = "checkbox",
        name = "Non Set Junk",
        tooltip = "Marks any equipment that is not in a set as junk.",
        getFunc = function() return TGC.db.setData.options.core.junkNonSets end,
        setFunc = function(newValue)
          TGC.db.setData.options.core.junkNonSets = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setData.options.core.junkNonSets,
      }, {
        type = "checkbox",
        name = "Low Level Junk",
        tooltip = "Marks any set that is below CP 160 as junk.",
        getFunc = function() return TGC.db.setData.options.core.junkLowLevel end,
        setFunc = function(newValue)
          TGC.db.setData.options.core.junkLowLevel = newValue
          TGC.UpdateInventories()
        end,
        width = "full",
        default = TGC.db.setData.options.core.junkLowLevel,
      }
    }
  }
  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Environment",
    controls = {
      {
        type = "checkbox",
        name = "PvE",
        tooltip = "Check to offer information on PvE gear, uncheck to mark all PvE gear as trash.",
        getFunc = function() return TGC.db.setData.options.environment.pveType end,
        setFunc = function(newValue)
          TGC.db.setData.options.environment.pveType = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.environment.pveType,
      }, {
        type = "checkbox",
        name = "PvP",
        tooltip = "Check to offer information on PvP gear, uncheck to mark all PvP gear as trash.",
        getFunc = function() return TGC.db.setData.options.environment.pvpType end,
        setFunc = function(newValue)
          TGC.db.setData.options.environment.pvpType = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.environment.pvpType,
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
        tooltip = "Disables the role based trash marking.",
        getFunc = function() return TGC.db.setData.options.role.disabled end,
        setFunc = function(newValue)
          TGC.db.setData.options.role.disabled = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.role.disabled,
      }, {
        type = "checkbox",
        name = "Tank",
        tooltip = "Check to offer information on tanking gear, uncheck to mark all tank gear as trash.",
        getFunc = function() return TGC.db.setData.options.role.tankRole end,
        setFunc = function(newValue)
          TGC.db.setData.options.role.tankRole = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.role.tankRole,
      }, {
        type = "checkbox",
        name = "Healer",
        tooltip = "Check to offer information on healing gear, uncheck to mark all healer gear as trash.",
        getFunc = function() return TGC.db.setData.options.role.healRole end,
        setFunc = function(newValue)
          TGC.db.setData.options.role.healRole = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.role.healRole,
      }, {
        type = "checkbox",
        name = "Magic DPS",
        tooltip = "Check to offer information on magic dps gear, uncheck to mark all magic dps gear as trash.",
        getFunc = function() return TGC.db.setData.options.role.magDpsRole end,
        setFunc = function(newValue)
          TGC.db.setData.options.role.magDpsRole = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.role.magDpsRole,
      }, {
        type = "checkbox",
        name = "Stamina DPS",
        tooltip = "Check to offer information on stamina dps gear, uncheck to mark all stamina dps gear as trash.",
        getFunc = function() return TGC.db.setData.options.role.stamDpsRole end,
        setFunc = function(newValue)
          TGC.db.setData.options.role.stamDpsRole = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.role.stamDpsRole,
      }, {
        type = "checkbox",
        name = "Other",
        tooltip = "Check to offer information on other build type gear, uncheck to mark all other build type gear as trash.",
        getFunc = function() return TGC.db.setData.options.role.otherRole end,
        setFunc = function(newValue)
          TGC.db.setData.options.role.otherRole = newValue
        end,
        width = "full",
        default = TGC.db.setData.options.role.otherRole,
      }
    }
  }
end