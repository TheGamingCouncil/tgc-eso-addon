-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
TGC = {}

local LMM = LibStub("LibMainMenu")

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
TGC.name = "TGC"
TGC.addon = "TGC"
TGC.guildName = "The Gaming Council"
TGC.version = "0.0.1"
TGC.guildId = 0
TGC.guildMembers = {}
TGC.personalInvites = {}
TGC.lastScanEvents = 0
TGC.firstScan = true

local backgroundToggle = true

-- Next we create a function that will initialize our addon
function TGC:Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
  TGC.LoadDatabase()

  TGC.CreateMenu()

  for i=1,5 do
    if GetGuildName( i ) == TGC.guildName then
      TGC.guildId = i
    end
  end

  SLASH_COMMANDS["/tgc-toggle-background"] = function (extra)
    if backgroundToggle == true then
      backgroundToggle = false
      TGCIndicatorBG:SetAlpha(1)
    else
      backgroundToggle = true
      TGCIndicatorBG:SetAlpha(0)
    end
  end

  
  RequestGuildHistoryCategoryNewest(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  TGCIndicatorBG:SetAlpha(0)
  EVENT_MANAGER:UnregisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED)
  TGC.GetGuildMembers()
  if TGC.db.options.guildOptions.scanHistory then
    TGC.ScanLoop();
  end
end
  
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function TGC.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == TGC.name then
    TGC:Initialize()
  end
end

function TGC.OnGuildMemberNoteChanged( eventCode, guildId, displayName, note )
  if guildId == TGC.guildId then
    
    --d( displayName )
    --d( note )
    if note:sub( 1, 3 ) == "tgc" then
      local bss = ByteStream:NewFromStream( note )
      local obj = bss:GetOutput()
      --d( obj )
    end
  end
end

function TGC.Debug()
  -- TGCB.Debug()
  --GetAddOnManager():RequestAddOnSavedVariablesPrioritySave( "pChat" )
  --d(7 << 1)
  --d( "test start" )
  --CHAT_SYSTEM:SetChannel( CHAT_CHANNEL_GUILD2 )
  --CHAT_SYSTEM:AddMessage("Something something")
  --ReloadUI("ingame")
  --SetGuildMemberNote(number guildId, number memberIndex, string note)
  --local questName = GetJournalQuestInfo( 2 )
  --local zoneName, _, zoneIndex = GetJournalQuestLocationInfo( 2 )
  --d( "Name " .. questName )
  --d( "Zone " .. zoneName .. _ .. " " .. zoneIndex )
  --TGC.NewScan()
  --local theEvent = {}
  --theEvent.eventType, theEvent.secondsSince, theEvent.member, theEvent.invitee = GetGuildEventInfo(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER, 31)
  --d( theEvent )
  --local numEvents = GetNumGuildEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  --d( numEvents )
  -- d( TGCIndicator )
  -- local theEvent = {}
  -- theEvent.eventType, theEvent.secsSince, theEvent.member, theEvent.invitee = GetGuildEventInfo(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER, 1)
end
   
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED, TGC.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_GUILD_MEMBER_NOTE_CHANGED, TGC.OnGuildMemberNoteChanged)