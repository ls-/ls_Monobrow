local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
addon.CHANGELOG = [[
- Added proper handling of Edit Mode layout copying, removal, an deletion.
- Reduced the min width to 384px.
- Fixed an issue where the monobar wouldn't hide itself while in a vehicle or during a pet battle.
]]
