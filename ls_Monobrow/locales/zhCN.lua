-- Contributors: 【NGA】阿思儡

local _, addon = ...
local L = addon.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "zhCN" then return end

-- 需要翻译的文本
L["BONUS_XP_TOOLTIP"] = "额外经验值: |cffffffff%s|r"
L["CHANGELOG"] = "更新日志"
L["CHANGELOG_FULL"] = "完整日志"
L["COLLAPSE_OPTIONS"] = "折叠设置项"
L["DOWNLOADS"] = "下载"
L["FADING_COMBAT_DESC"] = "进入战斗时渐入显示"
L["FADING_TARGET_DESC"] = "获得目标时渐入显示"
L["FADING"] = "渐隐效果"
L["FONT"] = "字体"
L["LEVEL_TOOLTIP"] = "等级: |cffffffff%d|r"
L["LINK_COPY_SUCCESS"] = "链接已复制到剪贴板"
L["MIN_ALPHA"] = "最小透明度"
L["NUMBERS"] = "纯数字显示"
L["NUMBERS_PERCENTAGE"] = "数字+百分比显示"
L["OUTLINE"] = "描边效果"
L["SHADOW"] = "阴影效果"
L["SHIFT_CLICK_TO_SHOW_AS_XP"] = "|cffffffff按住Shift点击|r 切换为经验条显示"
L["SUPPORT_FEEDBACK"] = "支持与反馈"
L["TEXTURE"] = "纹理样式"
