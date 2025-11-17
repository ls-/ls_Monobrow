local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Fader = {}

-- Lua
local _G = getfenv(0)
local next = _G.next

-- Mine
local function clamp(v)
	if v > 1 then
		return 1
	elseif v < 0 then
		return 0
	end

	return v
end

local function outCubic(t, b, c, d)
	t = t / d - 1
	return clamp(c * (t ^ 3 + 1) + b)
end

local FADE_IN = 1
local FADE_OUT = -1
local DURATION = 0.25
local OUT_DELAY = 1

local fader = CreateFrame("Frame", "LSMonobrowFader")
local fadeObjects = {}
local add, remove

local function fader_OnUpdate(_, elapsed)
	for object, data in next, fadeObjects do
		data.fadeTimer = data.fadeTimer + elapsed
		if data.fadeTimer > 0 then
			data.initAlpha = data.initAlpha or object:GetAlpha()

			object:SetAlpha(outCubic(data.fadeTimer, data.initAlpha, data.finalAlpha - data.initAlpha, data.duration))

			if data.fadeTimer >= data.duration then
				remove(object)

				object:SetAlpha(data.finalAlpha)
			end
		end
	end
end

function add(mode, object, delay, duration, toAlpha)
	local initAlpha = object:GetAlpha()
	local finalAlpha = mode == FADE_IN and 1 or toAlpha

	if delay == 0 and (duration == 0 or initAlpha == finalAlpha) then
		return
	end

	fadeObjects[object] = {
		mode = mode,
		fadeTimer = -delay,
		-- initAlpha = initAlpha,
		finalAlpha = finalAlpha,
		duration = duration,
	}

	if not fader:GetScript("OnUpdate") then
		fader:SetScript("OnUpdate", fader_OnUpdate)
	end
end

function remove(object)
	fadeObjects[object] = nil

	if not next(fadeObjects) then
		fader:SetScript("OnUpdate", nil)
	end
end

local hoverer = CreateFrame("Frame", "LSMonobrowHoverer")
local hoverObjects = {}

local function hoverer_OnUpdate()
	for object, state in next, hoverObjects do
		if object:IsShown() then
			local isMouseOver = object:IsMouseOver(4, -4, -4, 4)
			-- fading in is the priority
			if isMouseOver ~= state.isMouseOver and (isMouseOver or not fadeObjects[object]) then
				hoverObjects[object].isMouseOver = isMouseOver

				if isMouseOver then
					remove(object)
					add(FADE_IN, object, 0, DURATION * (1 - object:GetAlpha()))
				else
					add(FADE_OUT, object, OUT_DELAY, DURATION, state.minAlpha)
				end
			end
		end
	end
end

function addon.Fader:Watch(object, minAlpha)
	hoverObjects[object] = {
		isMouseOver = true,
		minAlpha = minAlpha
	}

	if not hoverer:GetScript("OnUpdate") then
		hoverer:SetScript("OnUpdate", hoverer_OnUpdate)
	end
end

function addon.Fader:Unwatch(object)
	hoverObjects[object] = nil

	remove(object)
	add(FADE_IN, object, 0, DURATION * (1 - object:GetAlpha()))

	if not next(hoverObjects) then
		hoverer:SetScript("OnUpdate", nil)
	end
end
