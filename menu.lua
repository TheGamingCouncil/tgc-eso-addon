local LAM = LibStub("LibAddonMenu-2.0")

function TGC.CreateMenu()

  local panelData = {
    type = "panel",
		name = "The Gaming Council",
		displayName = ZO_HIGHLIGHT_TEXT:Colorize("The Gaming Council"),
		author = "alexdragian",
		version = TGC.version,
		slashCommand = "/tgc",
		website = "http://tgcguild.com",
		registerForRefresh = true,
		registerForDefaults = true
  }

  TGC.LAMPanel = LAM:RegisterAddonPanel("TheGamingCouncilOptions", panelData)

  local optionsData = {}

  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Guild Recuriting",
    controls = {
      {
        type = "checkbox",
        name = "Enable History Scanner",
        tooltip = "History scanner looks up the history from the start of the guild to see who has been a member before.\n\nWarning this hits the ESO API and can disconnect you if you have other addons that do the same, like master merchant.",
        getFunc = function() return TGC.db.options.guildOptions.scanHistory end,
        setFunc = function(newValue)
          TGC.db.options.guildOptions.scanHistory = newValue
        end,
        width = "full",
        default = TGC.db.options.guildOptions.scanHistory,
      }
    }
  }

  LAM:RegisterOptionControls("TheGamingCouncilOptions", optionsData)

end