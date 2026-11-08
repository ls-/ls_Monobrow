-- Contributors:

local _, addon = ...
local L = addon.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "ruRU" then return end

L["BONUS_XP_TOOLTIP"] = "Дополнительный опыт: |cffffffff%s|r"
L["CHANGELOG"] = "Список изменений"
L["CHANGELOG_FULL"] = "Полный"
L["COLLAPSE_OPTIONS"] = "Свернуть настройки"
L["COPY_LAYOUT_DESC"] = "Скопировать настройки из другого макета в активный макет."
L["DELETE_LAYOUT_DESC"] = "Удалить настройки другого макета."
L["DOWNLOADS"] = "Загрузки"
L["EXPORT"] = "Экспорт"
L["FADING"] = "Затухание"
L["FADING_COMBAT_DESC"] = "Появляться при начале боя."
L["FADING_TARGET_DESC"] = "Появляться при выборе цели."
L["FONT"] = "Шрифт"
L["IMPORT_INSTRUCTIONS"] = "Импортируемая информация макета будет привязана к активному в настоящее время макету."
L["LAYOUT"] = "Макет"
L["LAYOUTS"] = "Макеты"
L["LAYOUTS_DESC"] = [=[Здесь вы можете сбросить, скопировать и удалить настройки, привязанные к вашим макетам.
Обратите внимание, что вся эта информация хранится в вашем активном профиле.]=]
L["LEVEL_TOOLTIP"] = "Уровень: |cffffffff%d|r"
L["LINK_COPY_SUCCESS"] = "Ссылка скопирована в буфер обмена."
L["MIN_ALPHA"] = "Мин. прозрачность"
L["NUMBERS"] = "Числа"
L["NUMBERS_PERCENTAGE"] = "Числа и процент"
L["OUTLINE"] = "Контур"
L["PROFILE_AND_LAYOUT"] = "Профиль и макет"
L["RESET_LAYOUT"] = "Сбросить |cffffffff\"%s\"|r"
L["RESET_LAYOUT_DESC"] = "Сбросить настройки активного макета по умолчанию."
L["SHADOW"] = "Тень"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffffЗажмите Shift и щелкните|r, чтобы показывать как панель опыта."
L["SUPPORT_FEEDBACK"] = "Поддержка и обратная связь"
L["TEXTURE"] = "Текстура"
