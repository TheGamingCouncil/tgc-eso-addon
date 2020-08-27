function TGC.SetupHistoryScans()
  TGC.NewScan( 1 )
end

local function trimHistory( guildId )
  if( TGC.db.roster.guildData[guildId] == nil ) then
    TGC.db.roster.guildData[guildId] = {
      lastScan = 0,
      inviteHistory = {},
      priorMembers = {}
    }
  else
    local trimList = {}
    local maxSecondsLast = 60 * 60 * 24 * 7 * 3
    --trim saved list
    for k, v in ipairs(TGC.db.roster.guildData[guildId].inviteHistory) do 
      if TGC.db.roster.guildData[guildId].inviteHistory[k].timeStamp > GetTimeStamp() - maxSecondsLast then
        table.insert( trimList, TGC.db.roster.guildData[guildId].inviteHistory[k] )
      end
    end
  
    TGC.db.roster.guildData[guildId].inviteHistory = trimList
  end
end

function TGC.NewScan( guildIndex )
  local guilds = TGC.guildList or TGC.GetGuilds()
  if guilds[guildIndex] ~= nil then
    local guildId = guilds[guildIndex]
    trimHistory( guildId )
    TGC.ScanHistory( guildId, guildIndex + 1 )
  else
    zo_callLater(function() TGC.SetupHistoryScans() end, 60 * 1000)
  end
end

function TGC.PrepGuildEvents( guildId )
  local numberOfEvents = GetNumGuildEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local allEvents = {};
  local currentEvent = 1
  while currentEvent <= numberOfEvents do
    local theEvent = {}
    theEvent.eventType, theEvent.secondsSince, theEvent.member, theEvent.invitee = GetGuildEventInfo(guildId, GUILD_HISTORY_GENERAL_ROSTER, currentEvent)
    allEvents[currentEvent] = theEvent
    currentEvent = currentEvent + 1
  end

  table.sort(allEvents, function (k1, k2) return k1.secondsSince < k2.secondsSince end )

  return allEvents
end

function TGC.ScanHistory( guildId, nextGuildIndex, oldNumberOfEvents, badLoads )
  badLoads = badLoads or 0
  oldNumberOfEvents = oldNumberOfEvents or 0

  local allEvents = TGC.PrepGuildEvents( guildId )
  local secondsLast = allEvents[#allEvents].secondsSince

  local maxSecondsLast = 60 * 60 * 24 * 7 * 3
  local lastEventTimeStamp = GetTimeStamp() - secondsLast
  if #allEvents > 0 then
    if DoesGuildHistoryCategoryHaveMoreEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER)
     and badLoads < 10 and lastEventTimeStamp > TGC.db.roster.guildData[guildId].lastScan
     and secondsLast < maxSecondsLast then
      badLoads = TGC.Roe3ScanRequestMoreEvents( guildId, badLoads )
      zo_callLater(function() TGC.ScanHistory(guildId, nextGuildIndex, #allEvents, badLoads) end, 5000)
    else
      TGC.MapEventsToMemory( allEvents, guildId )
      TGC.NewScan( nextGuildIndex )
    end
  end
end

function TGC.Roe3ScanRequestMoreEvents( guildId, badLoads )
  if DoesGuildHistoryCategoryHaveOutstandingRequest(guildId, GUILD_HISTORY_GENERAL_ROSTER) then
    return 0
  elseif IsGuildHistoryCategoryRequestQueued(guildId, GUILD_HISTORY_GENERAL_ROSTER) then
    return 0
  elseif RequestMoreGuildHistoryCategoryEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER, true) then
    return 0
  else
    return badLoads + 1
  end
end

function TGC.MapEventsToMemory( allEvents, guildId )
  local scanTime = TGC.db.roster.guildData[guildId].lastScan
  local numberOfEvents = GetNumGuildEvents(guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local currentEvent = 1
  local eventTimeStamp = GetTimeStamp()
  local eventMap = {}
  while currentEvent <= #allEvents do
    local theEvent = allEvents[currentEvent]
    eventTimeStamp = GetTimeStamp() - theEvent.secondsSince
    
    if scanTime < eventTimeStamp then
      scanTime = eventTimeStamp
    end

    theEvent.timeStamp = eventTimeStamp
    theEvent.secondsSince = nil
    if eventTimeStamp > TGC.db.roster.guildData[guildId].lastScan then
      if theEvent.eventType == 1 then
        table.insert( eventMap, theEvent )
      elseif theEvent.eventType == 8 then
        TGC.db.roster.guildData[guildId].priorMembers[theEvent.member] = theEvent
      elseif theEvent.eventType == 12 then
        TGC.db.roster.guildData[guildId].priorMembers[theEvent.invitee] = theEvent
      end
    end
    currentEvent = currentEvent + 1
  end
  
  for i = #eventMap, 1, -1 do
    table.insert(TGC.db.roster.guildData[guildId].inviteHistory, eventMap[i])
  end

  TGC.db.roster.guildData[guildId].lastScan = scanTime
end