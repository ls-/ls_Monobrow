local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
L["LS_MONOBROW"] = ("LS: |c%sMonobrow|r"):format(D.global.colors.addon:GetHex())
L["CURSEFORGE"] = "CurseForge"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["WAGO"] = "Wago"
L["WOWINTERFACE"] = "WoWInterface"
L["INFO"] = D.global.colors.addon:WrapTextInColorCode(_G.INFO)
L["AC_TOOLTIP"] = ("|c%1$sClick:|r %2$s\n|c%1$sShift Click:|r %3$s"):format(D.global.colors.addon:GetHex(), _G.GAMEMENU_OPTIONS, _G.ADVANCED_OPTIONS)

-- Require translation
L["BONUS_XP_TOOLTIP"] = "Bonus XP: |cffffffff%s|r"
L["CHANGELOG"] = "Changelog"
L["CHANGELOG_FULL"] = "Full"
L["COLLAPSE_OPTIONS"] = "Collapse Options"
L["DOWNLOADS"] = "Downloads"
L["FADING_COMBAT_DESC"] = "Fade in on entering combat."
L["FADING_TARGET_DESC"] = "Fade in on acquiring a target."
L["FADING"] = "Fading"
L["FONT"] = "Font"
L["LEVEL_TOOLTIP"] = "Level: |cffffffff%d|r"
L["LINK_COPY_SUCCESS"] = "Link Copied to Clipboard"
L["MIN_ALPHA"] = "Min Alpha"
L["NUMBERS"] = "Numbers"
L["NUMBERS_PERCENTAGE"] = "Numbers & Percentage"
L["OUTLINE"] = "Outline"
L["SHADOW"] = "Shadow"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffShift click|r to show as experience bar."
L["SUPPORT_FEEDBACK"] = "Support & Feedback"
L["TEXTURE"] = "Texture"
