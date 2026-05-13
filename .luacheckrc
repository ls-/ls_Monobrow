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
	"111/LS.*", -- Setting an undefined global variable starting with LS
	"112/LS.*", -- Mutating an undefined global variable starting with LS
	"113/LS.*", -- Accessing an undefined global variable starting with LS
	"211/_G", -- Unused local variable _G
	"211/C",  -- Unused local variable C
	"211/D",  -- Unused local variable D
	"211/L",  -- Unused local variable L
	"432", -- Shadowing an upvalue argument
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
	"C_NeighborhoodInitiative",
	"C_PerksActivities",
	"C_PetBattles",
	"C_PvP",
	"C_QuestLog",
	"C_Reputation",
	"C_Timer",
	"ColorMixin",
	"CreateAbbreviateConfig",
	"CreateFontFamily",
	"CreateFrame",
	"EncounterJournal",
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
	"HousingDashboardFrame",
	"InCombatLockdown",
	"IsControlKeyDown",
	"IsInActiveWorldPVP",
	"IsMacClient",
	"IsMetaKeyDown",
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
	"SecondsToTime",
	"Settings",
	"SettingsPanel",
	"SetWatchingHonorAsXP",
	"SOUNDKIT",
	"StatusTrackingBarManager",
	"tContains",
	"tDeleteItem",
	"UIParent",
	"UnitExists",
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
