-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
TGC = {
  enums = {}
}

local LMM2 = LibStub("LibMainMenu-2.0")

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
TGC.name = "TGC"
TGC.addon = "TGC"
TGC.version = "0.0.13"
TGC.guildId = 0
TGC.guildMembers = {}
TGC.personalInvites = {}
TGC.lastScanEvents = 0
TGC.firstScan = true

local backgroundToggle = true

function TGC.SetGuild()
  if TGC.guildId == 0 then
    for i=1,5 do
      guildId = GetGuildId( i )
      if GetGuildName( guildId ) == TGC.guildName then
        TGC.guildId = guildId
      else
      end
    end
  end
end

-- Next we create a function that will initialize our addon
function TGC:Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
  TGC.LoadDatabase()

  TGC.guildName = TGC.db.guildName

  TGC.CreateMenu()

  TGC.SetGuild()

  SLASH_COMMANDS["/tgc-toggle-background"] = function (extra)
    if backgroundToggle == true then
      backgroundToggle = false
      TGCIndicatorBG:SetAlpha(1)
    else
      backgroundToggle = true
      TGCIndicatorBG:SetAlpha(0)
    end
  end

  RequestMoreGuildHistoryCategoryEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  TGCIndicatorBG:SetAlpha(0)
  EVENT_MANAGER:UnregisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED)
  TGC.GetGuildMembers()
  TGC.SetupHistoryScans()


  TGC.SetTrackerBagHook()
  LMM2:Init()
  TGC.SetGuildTabHook( LMM2 )
end
  
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function TGC.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == TGC.name then
    TGC:Initialize()
  end
end

function TGC.OnPlayerActivated()
  TGC.SetGuild()
end

function TGC.Debug()
  
end
   
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED, TGC.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_PLAYER_ACTIVATED, TGC.OnPlayerActivated)