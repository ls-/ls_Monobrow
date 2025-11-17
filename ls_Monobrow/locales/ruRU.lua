-- Contributors:

local _, addon = ...
local L = addon.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "ruRU" then return end

L["BONUS_XP_TOOLTIP"] = "Дополнительный опыт: |cffffffff%s|r"
L["CHANGELOG"] = "Список изменений"
L["CHANGELOG_FULL"] = "Полный"
L["DOWNLOADS"] = "Загрузки"
L["FADING"] = "Затухание"
L["FONT"] = "Шрифт"
L["LEVEL_TOOLTIP"] = "Уровень: |cffffffff%d|r"
L["LINK_COPY_SUCCESS"] = "Ссылка скопирована в буфер обмена."
L["MIN_ALPHA"] = "Мин. прозрачность"
L["NUMBERS"] = "Числа"
L["NUMBERS_PERCENTAGE"] = "Числа и процент"
L["OUTLINE"] = "Контур"
L["SHADOW"] = "Тень"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffЗажмите Shift и щелкните|r, чтобы показывать как панель опыта."
L["SUPPORT_FEEDBACK"] = "Поддержка и обратная связь"
L["TEXTURE"] = "Текстура"
