local _, addon = ...

-- Lua
local _G = getfenv(0)
local error = _G.error
local issecurevariable = _G.issecurevariable
local next= _G.next
local pcall = _G.pcall
local s_format = _G.string.format
local t_insert = _G.table.insert
local tonumber = _G.tonumber
local type = _G.type

-- Mine
local C, D, L = {}, {}, {}
addon.C, addon.D, addon.L = C, D, L

------------
-- EVENTS --
------------

do
	local oneTimeEvents = {ADDON_LOADED = false, PLAYER_LOGIN = false}
	local registeredEvents = {}

	local dispatcher = CreateFrame("Frame", "LSMonobrowEventFrame")
	dispatcher:SetScript("OnEvent", function(_, event, ...)
		for _, func in next, registeredEvents[event] do
			func(...)
		end

		if oneTimeEvents[event] == false then
			oneTimeEvents[event] = true
		end
	end)

	function addon:RegisterEvent(event, func)
		if oneTimeEvents[event] then
			error(s_format("Failed to register for '%s' event, already fired!", event), 3)
		end

		if not func or type(func) ~= "function" then
			error(s_format("Failed to register for '%s' event, no handler!", event), 3)
		end

		if not registeredEvents[event] then
			registeredEvents[event] = {}

			dispatcher:RegisterEvent(event)
		end

		if not tContains(registeredEvents[event], func) then
			t_insert(registeredEvents[event], func)
		end
	end

	function addon:UnregisterEvent(event, func)
		local funcs = registeredEvents[event]
		if funcs then
			tDeleteItem(funcs, func)

			if #funcs == 0 then
				dispatcher:UnregisterEvent(event)
			end
		end
	end
end

-------------
-- COLOURS --
-------------

do
	local color_proto = {}

	function color_proto:GetHex()
		return self.hex
	end

	-- override ColorMixin:GetRGBA
	function color_proto:GetRGBA(a)
		return self.r, self.g, self.b, a or self.a
	end

	function addon:CreateColor(r, g, b, a)
		if r > 1 or g > 1 or b > 1 then
			r, g, b = r / 255, g / 255, b / 255
		end

		-- do not override SetRGBA, so calculate hex separately
		local color = Mixin({}, ColorMixin, color_proto)
		color:SetRGBA(r, g, b, a)

		color.hex = C_ColorUtil.GenerateTextColorCode(color)

		return color
	end
end

------------
-- TABLES --
------------

function addon:CopyTable(src, dest, ignore)
	if type(dest) ~= "table" then
		dest = {}
	end

	for k, v in next, src do
		if not ignore or not ignore[k] then
			if type(v) == "table" then
				dest[k] = self:CopyTable(v, dest[k])
			else
				dest[k] = v
			end
		end
	end

	return dest
end

-----------
-- MATHS --
-----------

function addon:NumberToPerc(v1, v2)
	return (v1 and v2) and v1 / v2 * 100 or nil
end

do
	local abbrevData = {
		breakpointData = {
			{
				breakpoint = 1e9,
				abbreviation = "THIRD_NUMBER_CAP_NO_SPACE", -- 1e9
				significandDivisor = 1e8,
				fractionDivisor = 10,
			},
			{
				breakpoint = 1e6,
				abbreviation = "SECOND_NUMBER_CAP_NO_SPACE", -- 1e6
				significandDivisor = 1e5,
				fractionDivisor = 10,
			},
			{
				breakpoint = 1e5,
				abbreviation = "FIRST_NUMBER_CAP_NO_SPACE", -- 1e3
				significandDivisor = 100,
				fractionDivisor = 10,
			},
		}
	}

	local locale = GetLocale()
	if locale == "koKR" or locale == "zhCN" or locale == "zhTW" then
		abbrevData.breakpointData = {
			{
				breakpoint = 1e8,
				abbreviation = "SECOND_NUMBER_CAP_NO_SPACE", -- 1e8
				significandDivisor = 1e7,
				fractionDivisor = 10,
			},
			{
				breakpoint = 1e6,
				abbreviation = "FIRST_NUMBER_CAP_NO_SPACE", -- 1e4
				significandDivisor = 1e3,
				fractionDivisor = 10,
			},
		}
	end

	abbrevData.config = CreateAbbreviateConfig(abbrevData.breakpointData)
	abbrevData.breakpointData = nil

	-- behaves like ALN, but actually works
	function addon:AbbreviateNumbers(value)
		local str = AbbreviateNumbers(value, abbrevData)
		local num = tonumber(str)

		return num and BreakUpLargeNumbers(num) or str
	end
end

----------
-- MISC --
----------

function addon:PurgeKey(t, k)
	t[k] = nil

	local c = -42
	repeat
		if t[c] == nil then
			t[c] = nil
		end

		c = c - 1
	until issecurevariable(t, k)
end

do
	local hiddenFrame = CreateFrame("Frame", nil, UIParent)
	hiddenFrame:Hide()

	function addon:ForceHide(object)
		if not object then return end

		-- EditMode bs
		if object.HideBase then
			object:HideBase(true)
		else
			object:Hide(true)
		end

		if object.EnableMouse then
			object:EnableMouse(false)
		end

		if object.UnregisterAllEvents then
			object:UnregisterAllEvents()
			object:SetAttribute("statehidden", true)
		end

		if object.SetUserPlaced then
			pcall(object.SetUserPlaced, object, true)
			pcall(object.SetDontSavePosition, object, true)
		end

		object:SetParent(hiddenFrame)
	end
end
