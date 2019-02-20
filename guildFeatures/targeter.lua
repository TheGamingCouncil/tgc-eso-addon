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

function TGC.GuildStatus( player )
  local inGuild = player and TGC and TGC.guildMembers and TGC.guildMembers[player]

  if inGuild then
    return "The Gaming Council - " .. TGC.guildMembers[player].rank
  elseif TGC.personalInvites[player] then
    return "Personally Invited"
  elseif TGC.db.priorMembers[player] then
    if TGC.db.priorMembers[player].eventType == 12 then
      return "Kicked Guild Member"
    else
      return "Prior Guild Member"
    end
  elseif TGC.db.invitedMembers[player] then
    return "Previously Invited"
  else
    return "No Guild Status"
  end
end

EVENT_MANAGER:RegisterForEvent(TGC.addon, EVENT_RETICLE_TARGET_CHANGED, TGC.OnTargetChange)