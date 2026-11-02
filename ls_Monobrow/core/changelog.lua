local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
addon.CHANGELOG = [[
- The bar should now be properly shown upon entering Edit Mode.
- Added a dialog for more precise position controls while in Edit Mode. It's not pixel-perfect yet tho.
]]
