-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
TGC = {}

-- This isn't strictly necessary, but we'll use this string later when registering events.
-- Better to define it in a single place rather than retyping the same string.
TGC.name = "TGC"
TGC.addon = "TGC"
TGC.guildName = "The Gaming Council"
TGC.guildId = 0
TGC.guildMembers = {}
TGC.personalInvites = {}
TGC.randomAskMessages = {
  "Hi, are you looking for a social/trials guild by chance? ^.^",
  "Hi, are you looking for a guild by chance? :)",
  "Hi, are you looking for a social and trials guild by chance? :)"
};
local savedVars
local TGCGuildVarDefaults = {
  lastScan = 0,
  invitedMembers = {},
  priorMembers = {}
}
TGC.lastScanEvents = 0
TGC.firstScan = true

local backgroundToggle = true
  
-- Next we create a function that will initialize our addon
function TGC:Initialize()
  -- ...but we don't have anything to initialize yet. We'll come back to this.
end
  
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function TGC.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == TGC.name then
    TGC:Initialize()
  end

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

  savedVars = ZO_SavedVars:NewAccountWide("TGC_SavedVariables", 3, nil, TGCGuildVarDefaults )
  RequestGuildHistoryCategoryNewest(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  TGCIndicatorBG:SetAlpha(0)
  EVENT_MANAGER:UnregisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED)
  TGC.GetGuildMembers()
  TGC.ScanLoop();
  --TGC.ScanHistory();

  --
  -- this scene controls the hud when the recticle is active
  --local hudScene = SCENE_MANAGER:GetScene( "hud" )
  --hudScene:AddFragment( yourFragment )
  
  -- this scene controls the hud when the mouse is active ( after you hit the '.' key )
  --local hudUIScene = Scene_MANAGER:GetScene( "hudui" )
  --hudUIScene:AddFragment( yourFragment )
  --GetGuildId( num )
 -- GetGuildName(guildID)
  --GetNumGuildEvents(guildID, GUILD_HISTORY_STORE)
end

function TGC.GetGuildMembers()
  if( TGC.guildId ~= 0 ) then
    local members = GetNumGuildMembers(TGC.guildId)
    for member=1, members do
      local player, _, rank = GetGuildMemberInfo(TGC.guildId,member)
      TGC.guildMembers[player] = { rank = TGC.GetGuildRankName( rank ) }
    end
  end
end

function TGC.ScanHistory( oldNumberOfEvents, badLoads )

  badLoads = badLoads or 0
  oldNumberOfEvents = oldNumberOfEvents or 0

  local numberOfEvents = GetNumGuildEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local _, secondsLast = GetGuildEventInfo(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER, numberOfEvents)

  local lastEventTimeStamp = GetTimeStamp() - secondsLast
  if numberOfEvents > 0 then
    if numberOfEvents > oldNumberOfEvents then badLoads = 0 else badLoads = badLoads + 1 end
    if TGC.firstScan and DoesGuildHistoryCategoryHaveMoreEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER) and badLoads < 10 and lastEventTimeStamp > savedVars.lastScan then
      RequestGuildHistoryCategoryOlder( TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER )
      zo_callLater(function() TGC.ScanHistory(numberOfEvents, badLoads) end, 1500)
    else
      TGC.firstScan = false
      TGC.MapEventsToMemory()
      TGC.lastScanEvents = numberOfEvents
    end
  end

end

function TGC.GuildStatus( player )
  local inGuild = player and TGC and TGC.guildMembers and TGC.guildMembers[player]

  if inGuild then
    return "The Gaming Council - " .. TGC.guildMembers[player].rank
  elseif TGC.personalInvites[player] then
    return "Personally Invited"
  elseif savedVars.priorMembers[player] then
    if savedVars.priorMembers[player].eventType == 12 then
      return "Kicked Guild Member"
    else
      return "Prior Guild Member"
    end
  elseif savedVars.invitedMembers[player] then
    return "Previously Invited"
  else
    return "No Guild Status"
  end
end

function TGC.OnTargetChange(eventCode)
  local unitTag = "reticleover"
  local type = GetUnitType(unitTag)
  if type == UNIT_TYPE_PLAYER then
    local name = GetUnitName(unitTag)
    local player = GetUnitDisplayName(unitTag)
    
    TGCIndicatorName:SetText(name)
    TGCIndicatorStatus:SetText(TGC.GuildStatus( player ))
  else
    TGCIndicatorName:SetText("")
    TGCIndicatorStatus:SetText("")
  end
  
end

function TGC.GuildInvite()
  if IsUnitPlayer("reticleover") then
    local unitTag = "reticleover"
    local name = GetUnitNameHighlightedByReticle()
    GuildInvite(TGC.guildId, name)
    local player = GetUnitDisplayName(unitTag)
    TGC.personalInvites[player] = {}
    d( "Attempted to invite " .. player )
  end
end

function TGC.GuildAsk()
  if IsUnitPlayer("reticleover") then
    local name = GetUnitNameHighlightedByReticle()
    local askMessage = math.random(1, table.getn(TGC.randomAskMessages))
    StartChatInput(TGC.randomAskMessages[askMessage], CHAT_CHANNEL_WHISPER, name)
  end
end

function TGC.GetGuildRankName( rankIndex )
  if rankIndex == 1 then
    return "Guildmaster"
  elseif rankIndex == 4 then
    return "Officer"
  elseif rankIndex == 8 then
    return "Member"
  else
    return GetGuildRankCustomName( TGC.guildId, rankIndex )
  end
end

function TGC.Debug()
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

function TGC.ScanLoop()
  TGC.NewScan()
  zo_callLater(function() TGC.ScanLoop() end, 15000)
end

function TGC.NewScan()
  RequestGuildHistoryCategoryNewest(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  zo_callLater(function() TGC.ScanHistory() end, 1000)
end

function TGC.MapEventsToMemory()
  local scanTime = savedVars.lastScan
  local numberOfEvents = GetNumGuildEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local currentEvent = TGC.lastScanEvents + 1
  local eventTimeStamp = GetTimeStamp()
  local eventMap = {}
  while currentEvent <= numberOfEvents do
    local theEvent = {}
    theEvent.eventType, theEvent.secondsSince, theEvent.member, theEvent.invitee = GetGuildEventInfo(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER, currentEvent)
    eventTimeStamp = GetTimeStamp() - theEvent.secondsSince
    
    if scanTime < eventTimeStamp then
      scanTime = eventTimeStamp
    end

    theEvent.timeStamp = eventTimeStamp
    theEvent.secondsSince = nil
    if eventTimeStamp > savedVars.lastScan and ( theEvent.eventType == 1 or theEvent.eventType == 7 or theEvent.eventType == 8 or theEvent.eventType == 12 ) then
      table.insert( eventMap, theEvent )
    end
    currentEvent = currentEvent + 1
  end
  
  local historyMembers = {}
  for i = #eventMap, 1, -1 do
    local eventData = eventMap[i]
    TGC.MapEventToMemory( historyMembers, eventData )
  end

  local historyRemovals = {}
  for k, v in pairs(historyMembers) do
    if not TGC.guildMembers[k] then
      savedVars.priorMembers[k] = { eventType = 8 }
      historyRemovals[k] = v
    end
  end

  for k, v in pairs(historyRemovals) do
    historyMembers[k] = nil
  end
  savedVars.lastScan = scanTime
end

function TGC.MapEventToMemory( historyMembers, eventData )
  if eventData.eventType == 1 then
    -- Invitation
    if TGC.personalInvites[eventData.invitee] then
      TGC.personalInvites[eventData.invitee] = nil
    end

    if savedVars.priorMembers[eventData.invitee] then
      savedVars.priorMembers[eventData.invitee] = nil
    end
    
    if not TGC.guildMembers[eventData.invitee] then
      savedVars.invitedMembers[eventData.invitee] = eventData
    end
  elseif eventData.eventType == 7 then
    -- Join
    if savedVars.invitedMembers[eventData.member] then
      savedVars.invitedMembers[eventData.member] = nil
    end
    if savedVars.priorMembers[eventData.member] then
      savedVars.priorMembers[eventData.member] = nil
    end
    historyMembers[eventData.member] = eventData
  elseif eventData.eventType == 8 then
    -- Drop
    if historyMembers[eventData.member] then
      historyMembers[eventData.member] = nil
    end
    savedVars.priorMembers[eventData.member] = eventData
  elseif eventData.eventType == 12 then
    -- Kicked
    if historyMembers[eventData.invitee] then
      historyMembers[eventData.invitee] = nil
    end
    savedVars.priorMembers[eventData.invitee] = eventData
  end
end

function TGC.OnGuildMemberAdded( eventCode, guildId, displayName )
  if guildId == TGC.guildId then
    if savedVars.invitedMembers[displayName] then
      savedVars.invitedMembers[displayName] = nil
    end
    TGC.GetGuildMembers()
  end
end

function TGC.OnGuildMemberRemoved( eventCode, guildId, displayName, characterName )
  if guildId == TGC.guildId then
    TGC.guildMembers[displayName] = nil
    TGC.NewScan()
  end
end
   
-- Finally, we'll register our event handler function to be called when the proper event occurs.
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_RETICLE_TARGET_CHANGED, TGC.OnTargetChange)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_ADD_ON_LOADED, TGC.OnAddOnLoaded)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_GUILD_MEMBER_ADDED, TGC.OnGuildMemberAdded)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_GUILD_MEMBER_REMOVED, TGC.OnGuildMemberRemoved)