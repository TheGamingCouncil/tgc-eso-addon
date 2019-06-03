function TGC.GetGuildMembers()
  if( TGC.guildId ~= 0 ) then
    local members = GetNumGuildMembers(TGC.guildId)
    for member=1, members do
      local player, _, rank = GetGuildMemberInfo(TGC.guildId,member)
      TGC.guildMembers[player] = { rank = TGC.GetGuildRankName( rank ), memberIndex = member }
    end
  end
end

function TGC.OnGuildMemberAdded( eventCode, guildId, displayName )
  if guildId == TGC.guildId then
    if TGC.rosterDb.invitedMembers[displayName] then
      TGC.rosterDb.invitedMembers[displayName] = nil
    end
    TGC.GetGuildMembers()
  end
end

function TGC.OnGuildMemberRemoved( eventCode, guildId, displayName, characterName )
  if guildId == TGC.guildId then
    TGC.guildMembers[displayName] = nil
  end
end

EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_GUILD_MEMBER_ADDED, TGC.OnGuildMemberAdded)
EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_GUILD_MEMBER_REMOVED, TGC.OnGuildMemberRemoved)