local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
addon.CHANGELOG = [[
- Added 12.0.7 support.
- Slightly reworked Neighborhood Initiatives. The bar now shows the actual amount of contributions instead of normalised values provided by Blizz.
]]
