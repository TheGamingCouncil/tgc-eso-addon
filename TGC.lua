-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
TGC = {
  enums = {}
}

local LMM2 = LibStub("LibMainMenu-2.0")

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
TGC.name = "TGC"
TGC.addon = "TGC"
TGC.version = "0.0.5"
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

  
  RequestGuildHistoryCategoryNewest(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
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

local LN = LibStub:GetLibrary("LibNotifications")
TGC.LN_provider = LN:CreateProvider()

function TGC.OnPlayerActivated()
  TGC.SetGuild()
  local function removeNotification(provider, data)
    t = provider.notifications
    j = data.notificationId
    -- Loop through table starting at index
    for i=j, #t do
      -- Replace current element with next element
      t[i] = t[i+1]
      -- Update index in data
      if i<#t then
        t[i].notificationId = i
      end
    end
    provider:UpdateNotifications()
  end
  -- Callback functions
  local function acceptCallback(data)
    removeNotification(TGC.LN_provider, data)
  end
  local function declineCallback(data)
    removeNotification(TGC.LN_provider, data)
  end
  -- Custom notification info
  local msg = {
    dataType = NOTIFICATIONS_ALERT_DATA,-- NOTIFICATIONS_REQUEST_DATA,
    secsSinceRequest = ZO_NormalizeSecondsSince(0),
    note = "Please update The Gaming Concil Addon, visit tgcguild.com and download the latist version.",
    message = "The Gaming Concil Addon is out of date.",
    heading = "TGC Update",
    texture = "EsoUI/Art/Notifications/Gamepad/gp_notification_cs.dds",
    shortDisplayText = "Short",
    controlsOwnSounds = false,
    keyboardAcceptCallback = acceptCallback,
    keybaordDeclineCallback = declineCallback,
    gamepadAcceptCallback = acceptCallback,
    gamepadDeclineCallback = declineCallback,
    -- Custom keys
    notificationId = #TGC.LN_provider.notifications + 1,
  }
  -- Add custom notification
  local guildMotd = GetGuildMotD( TGC.guildId )
  local startFind = string.find(guildMotd, "av[", 0, true)
  local endFind = string.find(guildMotd, "]", startFind, true )


  local version = string.sub( guildMotd, startFind + 3, endFind - 1)

  if not ( TGC.version == version ) then
    table.insert(TGC.LN_provider.notifications, msg)
    TGC.LN_provider:UpdateNotifications()
  end

end

function TGC.Debug()
  -- StartChatInput( ZO_LinkHandler_CreateLink( "@alexdragian", nil, DISPLAY_NAME_LINK_TYPE, "@alexdragian" ), CHAT_CHANNEL_WHISPER, "@Chance_25")
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
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_PLAYER_ACTIVATED, TGC.OnPlayerActivated)