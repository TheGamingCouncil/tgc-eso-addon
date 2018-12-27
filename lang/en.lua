local strings = {
	SI_BINDING_NAME_TGC_DEBUG = "Debug",
	SI_BINDING_NAME_TGC_GUILD_INVITE = "Guild Auto Invite",
	SI_BINDING_NAME_TGC_GUILD_ASK = "Guild Recuit Wisper",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end
