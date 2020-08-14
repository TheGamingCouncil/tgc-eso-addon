function TGC.QOLMenu( optionsData )
  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Map Icons",
    controls = {
      {
        type = "checkbox",
        name = "Home Previews",
        tooltip = "Show icons on map for home previews(not bought) on the world map.",
        getFunc = function() return TGC.db.default.options.mapFlags.homePreviews end,
        setFunc = function(newValue)
          TGC.db.default.options.mapFlags.homePreviews = newValue
        end,
        width = "full",
        default = TGC.db.default.options.mapFlags.homePreviews,
      },
      --{
      --  type = "checkbox",
      --  name = "Home Previews - Zone",
      --  tooltip = "Show icons on map for home previews(not bought) on the zone map.",
      --  getFunc = function() return TGC.db.options.mapFlags.homePreviewsZone end,
      --  setFunc = function(newValue)
      --    TGC.db.options.mapFlags.homePreviewsZone = newValue
      --  end,
      --  width = "full",
      --  default = TGC.db.options.mapFlags.homePreviewsZone,
      --},
      {
        type = "checkbox",
        name = "Owned Homes",
        tooltip = "Show icons on map for homes already bought on the world map.",
        getFunc = function() return TGC.db.default.options.mapFlags.ownedHomes end,
        setFunc = function(newValue)
          TGC.db.default.options.mapFlags.ownedHomes = newValue
        end,
        width = "full",
        default = TGC.db.default.options.mapFlags.ownedHomes,
      },
      {
        type = "checkbox",
        name = "Dungeons",
        tooltip = "Show icons on map for dungones on the world map.",
        getFunc = function() return TGC.db.default.options.mapFlags.dungeons end,
        setFunc = function(newValue)
          TGC.db.default.options.mapFlags.dungeons = newValue
        end,
        width = "full",
        default = TGC.db.default.options.mapFlags.dungeons,
      },
      {
        type = "checkbox",
        name = "Trials",
        tooltip = "Show icons on map for trials on the world map.",
        getFunc = function() return TGC.db.default.options.mapFlags.trials end,
        setFunc = function(newValue)
          TGC.db.default.options.mapFlags.trials = newValue
        end,
        width = "full",
        default = TGC.db.default.options.mapFlags.trials,
      },
      {
        type = "checkbox",
        name = "Wayshines",
        tooltip = "Show icons on map for wayshines on the world map.",
        getFunc = function() return TGC.db.default.options.mapFlags.waypoints end,
        setFunc = function(newValue)
          TGC.db.default.options.mapFlags.waypoints = newValue
        end,
        width = "full",
        default = TGC.db.default.options.mapFlags.waypoints,
      }
    }
  }
end