std = "none"
max_line_length = false
max_comment_line_length = 120
self = false

exclude_files = {
	".luacheckrc",
	"ls_Monobrow/embeds/",
}

ignore = {
	-- "111",
	-- "112",
	-- "122",
	"211/_G", -- Unused local variable _G
	"211/C",  -- Unused local variable C
	"211/D",  -- Unused local variable D
	"211/L",  -- Unused local variable L
}

globals = {
	-- Lua
	"getfenv",
	"print",

	-- Mine
	"LS_MONOBROW_GLOBAL_CONFIG",
	"LSMonobrow",
	"LSMonobrowFont",
}

read_globals = {
	"AbbreviateNumbers",
	"ActionStatus",
	"AddonCompartmentFrame",
	"BreakUpLargeNumbers",
	"C_AddOns",
	"C_AzeriteItem",
	"C_ColorUtil",
	"C_GossipInfo",
	"C_Housing",
	"C_MajorFactions",
	"C_PetBattles",
	"C_PvP",
	"C_QuestLog",
	"C_Reputation",
	"C_Timer",
	"ColorMixin",
	"CreateAbbreviateConfig",
	"CreateFontFamily",
	"CreateFrame",
	"Enum",
	"EventUtil",
	"GameFontHighlight",
	"GameTooltip",
	"GetLocale",
	"GetQuestLogCompletionText",
	"GetScreenWidth",
	"GetText",
	"GetXPExhaustion",
	"HideUIPanel",
	"InCombatLockdown",
	"IsControlKeyDown",
	"IsInActiveWorldPVP",
	"IsPlayerAtEffectiveMaxLevel",
	"IsShiftKeyDown",
	"IsWatchingHonorAsXP",
	"IsXPUserDisabled",
	"ITEM_QUALITY_COLORS",
	"LibStub",
	"MainStatusTrackingBarContainer",
	"MAX_REPUTATION_REACTION",
	"Mixin",
	"PixelUtil",
	"PlaySound",
	"PVPQueueFrame",
	"ReputationFrame",
	"ScrollingFontMixin",
	"ScrollUtil",
	"SecondaryStatusTrackingBarContainer",
	"Settings",
	"SettingsPanel",
	"SetWatchingHonorAsXP",
	"StatusTrackingBarManager",
	"tContains",
	"tDeleteItem",
	"UIParent",
	"UnitFactionGroup",
	"UnitHonor",
	"UnitHonorLevel",
	"UnitHonorMax",
	"UnitInVehicle",
	"UnitLevel",
	"UnitSex",
	"UnitXP",
	"UnitXPMax",
}
