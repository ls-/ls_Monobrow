local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local ipairs = _G.ipairs

-- Mine
local LEM = LibStub("LibEditMode-ls", true) or LibStub("LibEditMode")

function addon:GetLayout()
	return C.db.profile.layouts[LEM:GetActiveLayoutName() or "Modern"]
end

function addon:GetDefaultLayout()
	return C.db.profile.layouts["*"]
end

function addon:GetBorderList()
	local t = {}
	for i, data in ipairs(D.global.borders) do
		t[i] = data.name
	end

	return t
end

local function rgb(...)
	return addon:CreateColor(...)
end

D.global = {
	colors = {
		addon = rgb(31, 206, 203), -- #1FCECB (Crayola Robin's Egg Blue)
		faction = {
			-- Alliance = rgb(0, 173, 240), -- #00ADF0 (Blizzard Colour)
			Alliance = rgb(64, 84, 202), -- #4054CA (7.5PB 4/16)
			-- Horde = rgb(255, 41, 52), -- #FF2934 (Blizzard Colour)
			Horde = rgb(231, 53, 42), -- #E7352A (7.5R 5/16)
			Neutral = rgb(233, 232, 231) -- #E9E8E7 (N9)
		},
		honor = rgb(255, 77, 35), -- #FF4D23 (Blizzard Colour)
		house = rgb(217, 181, 111), -- #D9B56F (Blizzard Colour)
		reaction = {
			-- hated
			[1] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			-- hostile
			[2] = rgb(220, 68, 54), -- #DC4436 (7.5R 5/14)
			-- unfriendly
			[3] = rgb(230, 118, 47), -- #E6762F (2.5YR 6/12)
			-- neutral
			[4] = rgb(246, 196, 66), -- #F6C442 (2.5Y 8/10)
			-- friendly
			[5] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- honored
			[6] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- revered
			[7] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- exalted
			[8] = rgb(46, 172, 52), -- #2EAC34 (10GY 6/12)
			-- renown, fake
			[9] = rgb(0, 191, 243), -- #00BFF3 (Blizzard Colour)
		},
		xp = {
			-- rested
			[1] = rgb(0, 99, 224), -- #0063E0 (Blizzard Colour)
			-- normal
			[2] = rgb(148, 0, 140), -- #94008C (Blizzard Colour)
		},
		travel_points = rgb(9, 165, 187), -- #09A5BB (Average of the Bar Texture)
		endeavor = rgb(75, 93, 27), -- #4b5d1b (Based on the Endevour Task Flag)
	},
	borders = {
		[1] = {
			name = "LS Thin",
			texture = "Interface\\AddOns\\ls_Monobrow\\assets\\bar-border-thin",
			offset = -4,
			size = 16,
		},
		[2] = {
			name = "ElvUI 1px",
			texture = {1, 1, 1},
			offset = 0,
			size = 1,
		},
		[3] = {
			name = "ElvUI 2px",
			texture = {1, 1, 1},
			offset = 0,
			size = 2,
		},
	},
	settings = { -- used by expanders
		text = false,
		fade = false,
	},
}

D.profile = {
	font = {
		name = LibStub("LibSharedMedia-3.0"):GetDefault("font"), -- "Friz Quadrata TT"
		shadow = true,
		outline = false,
	},
	texture = {
		name = LibStub("LibSharedMedia-3.0"):GetDefault("statusbar"), -- "Blizzard"
	},
	border = {
		type = 1,
		color = {r = 1, g = 1, b = 1, a = 1},
	},
	layouts = {
		["*"] = {
			width = 560,
			height = 12,
			font = {
				size = 12,
			},
			text = {
				format = "NUM", -- NUM_PERC
				always_show = false,
			},
			fade = {
				enabled = false,
				combat = false,
				target = false,
				min_alpha = 0.25,
			},
			point = {point = "BOTTOM", x = 0, y = 4},
		},
	},
}

D.char = {
	travel_points = false,
	endeavor = false,
}
