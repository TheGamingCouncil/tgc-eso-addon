function TGC.SetupHistoryScans()
  TGC.personalInvites = {}
  TGC.NewScan()
end

function TGC.ScanLoop()
  TGC.NewScan()
  zo_callLater(function() TGC.ScanLoop() end, 15000)
end

function TGC.NewScan()
  RequestGuildHistoryCategoryNewest(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  zo_callLater(function() TGC.ScanHistory() end, 10000)
end

function TGC.MapEventsToMemory()
  local scanTime = TGC.rosterDb.lastScan
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
    if eventTimeStamp > TGC.rosterDb.lastScan and ( theEvent.eventType == 1 or theEvent.eventType == 7 or theEvent.eventType == 8 or theEvent.eventType == 12 ) then
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
      TGC.rosterDb.priorMembers[k] = { eventType = 8 }
      historyRemovals[k] = v
    end
  end

  for k, v in pairs(historyRemovals) do
    historyMembers[k] = nil
  end
  TGC.rosterDb.lastScan = scanTime
end

function TGC.MapEventToMemory( historyMembers, eventData )
  if eventData.eventType == 1 then
    -- Invitation
    if TGC.personalInvites[eventData.invitee] then
      TGC.personalInvites[eventData.invitee] = nil
    end

    if TGC.rosterDb.priorMembers[eventData.invitee] then
      TGC.rosterDb.priorMembers[eventData.invitee] = nil
    end
    
    if not TGC.guildMembers[eventData.invitee] then
      TGC.rosterDb.invitedMembers[eventData.invitee] = eventData
      table.insert(TGC.rosterDb.invitedHistory, eventData )
    end
  elseif eventData.eventType == 7 then
    -- Join
    if TGC.rosterDb.invitedMembers[eventData.member] then
      TGC.rosterDb.invitedMembers[eventData.member] = nil
    end
    if TGC.rosterDb.priorMembers[eventData.member] then
      TGC.rosterDb.priorMembers[eventData.member] = nil
    end
    historyMembers[eventData.member] = eventData
  elseif eventData.eventType == 8 then
    -- Drop
    if historyMembers[eventData.member] then
      historyMembers[eventData.member] = nil
    end
    TGC.rosterDb.priorMembers[eventData.member] = eventData
  elseif eventData.eventType == 12 then
    -- Kicked
    if historyMembers[eventData.invitee] then
      historyMembers[eventData.invitee] = nil
    end
    TGC.rosterDb.priorMembers[eventData.invitee] = eventData
  end
end

function TGC.ScanHistory( oldNumberOfEvents, badLoads )

  badLoads = badLoads or 0
  oldNumberOfEvents = oldNumberOfEvents or 0

  local numberOfEvents = GetNumGuildEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
  local _, secondsLast = GetGuildEventInfo(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER, numberOfEvents)

  local maxSecondsLast = 60 * 60 * 24 * 7 * 3
  local lastEventTimeStamp = GetTimeStamp() - secondsLast
  if numberOfEvents > 0 then
    if numberOfEvents > oldNumberOfEvents then badLoads = 0 else badLoads = badLoads + 1 end
    if TGC.firstScan and DoesGuildHistoryCategoryHaveMoreEvents(TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER)
      and badLoads < 10 and lastEventTimeStamp > TGC.rosterDb.lastScan and ( TGC.db.options.guildOptions.scanHistory or secondsLast < maxSecondsLast ) then
      RequestGuildHistoryCategoryOlder( TGC.guildId, GUILD_HISTORY_GENERAL_ROSTER )
      zo_callLater(function() TGC.ScanHistory(numberOfEvents, badLoads) end, 10000)
    else
      if TGC.firstScan then
        TGC.firstScan = false
        TGC.ScanLoop()
      end
      TGC.MapEventsToMemory()
      TGC.lastScanEvents = numberOfEvents
    end
  end

end