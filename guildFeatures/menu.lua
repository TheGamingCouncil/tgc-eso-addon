local function leaderBoardGuildControl( guildId, guildName )
  return {
    type = "checkbox",
    name = guildName,
    tooltip = "Track " .. guildName .. " for Recruiting Leader Board.",
    getFunc = function() return TGC.db.roster.options.guilds[guildId] end,
    setFunc = function(newValue)
      TGC.db.roster.options.guilds[guildId] = newValue
    end,
    width = "full",
    default = TGC.db.roster.options.guilds[guildId],
    requiresReload = true
  }
end

function TGC.GuildFeatureMenu( optionsData )
  local leaderBoardControls = {}

  for i=1,5 do
    local guildId = GetGuildId( i )
    local guildName = GetGuildName( guildId )
    if( guildId ~= 0 ) then
      leaderBoardControls[#leaderBoardControls + 1] = leaderBoardGuildControl( guildId, guildName )
    end
  end

  optionsData[#optionsData + 1] = {
    type = "submenu",
    name = "Recruiting Leader Boards",
    controls = leaderBoardControls
  }
end