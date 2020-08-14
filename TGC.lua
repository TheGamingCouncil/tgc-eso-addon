TGC = {
  enums = {},
  name = "TGC",
  addon = "TGC",
  version = "0.0.15"
}

local LMM2 = LibStub("LibMainMenu-2.0")

local backgroundToggle = true

function TGC.GetGuilds()
  local guilds = {};
  for guild = 1, GetNumGuilds() do
    guildId = GetGuildId( guild )
    if TGC.db.roster.options.guilds[guildId] then
      guilds[#guilds + 1] = guildId
    end
  end

  TGC.guildList = guilds
  return guilds
end

function TGC:Initialize()
  TGC.LoadDatabase()

  TGC.CreateMenu()

  EVENT_MANAGER:UnregisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED)
  
  TGC.SetupHistoryScans()
  TGC.SetTrackerBagHook()

  LMM2:Init()

  TGC.SetGuildTabHook( LMM2 )
end
  

function TGC.OnAddOnLoaded(event, addonName)
  if addonName == TGC.name then
    TGC:Initialize()
  end
end

function TGC.OnPlayerActivated()
  -- Player is now active --
end

function TGC.Debug()
  TGC.db.roster.guildData = {}
end

EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED, TGC.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_PLAYER_ACTIVATED, TGC.OnPlayerActivated)