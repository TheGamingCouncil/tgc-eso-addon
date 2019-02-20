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
    local askMessage = math.random(1, table.getn(TGC.db.options.guildOptions.randomMessages))
    StartChatInput(TGC.db.options.guildOptions.randomMessages[askMessage], CHAT_CHANNEL_WHISPER, name)
  end
end