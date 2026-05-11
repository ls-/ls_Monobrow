local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)

-- Mine
function addon:Modernize(data, name, key)
	if not data.version then return end

	if key == "profile" then
		--> 120005.03
		if data.version < 12000503 then
			if data.layouts then
				data.layouts["*"] = nil
			end

			data.version = 12000503
		end
	end
end
