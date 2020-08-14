local LAM = LibStub("LibAddonMenu-2.0")

function TGC.MenuHeader( title, optionsData )
  local spacer = {
    type = "description",
    title = nil,
    text = "",
  }
  optionsData[#optionsData + 1] = spacer
  optionsData[#optionsData + 1] = {
    type = "header",
    name = ZO_HIGHLIGHT_TEXT:Colorize(zo_strformat("<<Z:1>>", title)),
    width = "full",
  }
end

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

  TGC.MenuHeader( "Guild Features", optionsData )
  TGC.GuildFeatureMenu( optionsData )

  TGC.MenuHeader( "Quality of Life", optionsData )
  TGC.QOLMenu( optionsData )

  TGC.MenuHeader( "Set Tracker", optionsData )
  TGC.SetTrackerMenu( optionsData )

  LAM:RegisterOptionControls("TheGamingCouncilOptions", optionsData)

end