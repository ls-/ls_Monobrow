local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Bar = {}

-- Lua
local _G = getfenv(0)
local m_floor = _G.math.floor
local next = _G.next
local unpack = _G.unpack

-- Mine
local MAX_SEGMENTS = 5
local CUR_MAX_PERC_VALUE_TEMPLATE = "%s / %s (%.1f%%)"
local CUR_MAX_VALUE_TEMPLATE = "%s / %s"

local houseInfoCache = {}

local bar_proto = {}

do
	local layouts = {}

	local function round(v)
		return m_floor(v + 0.5)
	end

	function bar_proto:CalcLayout(width, spacing, numSegs)
		if not layouts[width] then
			layouts[width] = {}
		end

		if layouts[width][numSegs] then
			return
		else
			layouts[width][numSegs] = {}
		end

		local layout = layouts[width][numSegs]

		width = width - spacing * (numSegs - 1)
		local segSize = width / numSegs

		if segSize % 1 == 0 then
			for i = 1, numSegs do
				layout[i] = segSize
			end
		else
			local numOddSegs = numSegs % 2 == 0 and 2 or 1
			local numNormalSegs = numSegs - numOddSegs
			segSize = round(segSize)

			for i = 1, numNormalSegs do
				layout[i] = segSize
				layout[numSegs + 1 - i] = segSize
			end

			segSize = (width - segSize * numNormalSegs) / numOddSegs

			for i = 1, numOddSegs do
				layout[numNormalSegs / 2 + i] = segSize
			end
		end
	end

	function bar_proto:ForEach(method, ...)
		for i = 1, MAX_SEGMENTS do
			if self[i][method] then
				self[i][method](self[i], ...)
			end
		end
	end

	function bar_proto:UpdateTextFormat(format)
		if format == "NUM" then
			self:ForEach("SetValueTemplate", CUR_MAX_VALUE_TEMPLATE)
		elseif format == "NUM_PERC" then
			self:ForEach("SetValueTemplate", CUR_MAX_PERC_VALUE_TEMPLATE)
		end
	end

	function bar_proto:UpdateTextVisibility(isLocked)
		self:ForEach("LockText", isLocked)
	end

	function bar_proto:UpdateTextures()
		self:ForEach("UpdateTextures")
	end

	function bar_proto:UpdateSize(width, height)
		for i = 1, MAX_SEGMENTS do
			self:CalcLayout(width, 2, i)
		end

		PixelUtil.SetSize(self, width, height)

		self.width = width
		self.height = height
		self.layout = layouts[width]
		self.total = nil

		self:UpdateSegments()
	end

	function bar_proto:UpdateSegments()
		if self.isEditing then
			self[1]:UpdateDummy()
			self[1]:SetWidth(self.layout[1][1])
			self[1].Extension:SetWidth(self.layout[1][1])

			for i = 2, MAX_SEGMENTS do
				self[i]:SetWidth(0.0001)
				self[i]:SetValue(0)

				self[i].Extension:SetWidth(0.0001)
				self[i].Extension:SetValue(0)

				self[i].Sep:Hide()

				self[i].cur = nil
				self[i].max = nil
				self[i].bonus = nil
				self[i].tooltipInfo = nil
			end

			self:Show()

			self.total = nil

			return
		end

		local index = 0

		if not (C_PetBattles.IsInBattle() or UnitInVehicle("player")) then
			-- XP
			if not IsXPUserDisabled() and not IsPlayerAtEffectiveMaxLevel() then
				index = index + 1

				self[index]:UpdateXP()
			end

			-- House Favour
			local guid = C_Housing.GetTrackedHouseGuid()
			if guid and houseInfoCache[guid] and houseInfoCache[guid].houseLevel then
				index = index + 1

				self[index]:UpdateHouseXP(houseInfoCache[guid])
			end

			-- Honour
			if IsWatchingHonorAsXP() or C_PvP.IsActiveBattlefield() or IsInActiveWorldPVP() then
				index = index + 1

				self[index]:UpdateHonor()
			end

			-- Reputation
			local data = C_Reputation.GetWatchedFactionData()
			if data then
				index = index + 1

				self[index]:UpdateReputation(data.name, data.reaction, data.currentReactionThreshold, data.nextReactionThreshold, data.currentStanding, data.factionID)
			end

			-- Azerite
			if not C_AzeriteItem.IsAzeriteItemAtMaxLevel() then
				local azeriteItem = C_AzeriteItem.FindActiveAzeriteItem()
				if azeriteItem and azeriteItem:IsEquipmentSlot() and C_AzeriteItem.IsAzeriteItemEnabled(azeriteItem) then
					index = index + 1

					self[index]:UpdateAzerite(azeriteItem)
				end
			end
		end

		if self.total ~= index then
			for i = 1, MAX_SEGMENTS do
				if i <= index then
					PixelUtil.SetWidth(self[i], self.layout[index][i])
					PixelUtil.SetWidth(self[i].Extension, self.layout[index][i])
				else
					self[i]:SetWidth(0.0001)
					self[i]:SetValue(0)

					self[i].Extension:SetWidth(0.0001)
					self[i].Extension:SetValue(0)

					self[i].cur = nil
					self[i].max = nil
					self[i].bonus = nil
					self[i].tooltipInfo = nil
				end
			end

			for i = 1, MAX_SEGMENTS do
				if i < index then
					self[i].Sep:Show()
				else
					self[i].Sep:Hide()
				end
			end

			-- ! FADE!
			if index == 0 then
				self:Hide()
			else
				self:Show()
			end

			self.total = index
		end
	end

	local deferredUpdate, timer

	function bar_proto:OnEvent(event, ...)
		if not deferredUpdate then
			deferredUpdate = function()
				self:UpdateSegments()

				timer = nil
			end
		end

		if event == "PLAYER_EQUIPMENT_CHANGED" then
			local slot = ...
			if slot == Enum.InventoryType.IndexNeckType then
				if not timer then
					timer = C_Timer.NewTimer(0.1, deferredUpdate)
				end
			end
		elseif event == "HOUSE_LEVEL_FAVOR_UPDATED" then
			local info = ...
			houseInfoCache[info.houseGUID] = houseInfoCache[info.houseGUID] or {}
			houseInfoCache[info.houseGUID].houseLevel = info.houseLevel
			houseInfoCache[info.houseGUID].houseFavor = info.houseFavor

			if not timer then
				timer = C_Timer.NewTimer(0.1, deferredUpdate)
			end
		elseif event == "PLAYER_HOUSE_LIST_UPDATED" then
			local info = ...
			for _, data in next, info do
				houseInfoCache[data.houseGUID] = houseInfoCache[data.houseGUID] or {}
				houseInfoCache[data.houseGUID].houseName = data.houseName
			end

			local guid = C_Housing.GetTrackedHouseGuid()
			if guid and houseInfoCache[guid].houseLevel and not timer then
				timer = C_Timer.NewTimer(0.1, deferredUpdate)
			end
		elseif event == "TRACKED_HOUSE_CHANGED" then
			local guid = ...
			if not guid then
				if not timer then
					timer = C_Timer.NewTimer(0.1, deferredUpdate)
				end
			else
				C_Housing.GetCurrentHouseLevelFavor(guid)
			end
		else
			if not timer then
				timer = C_Timer.NewTimer(0.1, deferredUpdate)
			end
		end
	end

	function bar_proto:OnSizeChanged()
		for i = 2, MAX_SEGMENTS do
			PixelUtil.SetPoint(self[i], "LEFT", self[i - 1], "RIGHT", 2, 0)
		end
	end
end

function addon.Bar:Create()
	local bar = Mixin(CreateFrame("Frame", "LSMonobrow", UIParent), bar_proto)

	local textureParent = CreateFrame("Frame", nil, bar)
	textureParent:SetAllPoints()
	textureParent:SetFrameLevel(bar:GetFrameLevel() + 3)
	bar.TextureParent = textureParent

	local textParent = CreateFrame("Frame", nil, bar)
	textParent:SetAllPoints()
	textParent:SetFrameLevel(bar:GetFrameLevel() + 5)
	bar.TextParent = textParent

	local bg = bar:CreateTexture(nil, "ARTWORK")
	bg:SetColorTexture(0.3, 0.3, 0.3, 0.5)
	bg:SetAllPoints()

	bar.Border = addon.Border:Create(textureParent)

	for i = 1, MAX_SEGMENTS do
		bar[i] = addon.Segment:Create(bar, i, textParent, textureParent)

		if i == 1 then
			PixelUtil.SetPoint(bar[i], "LEFT", bar, "LEFT", 0, 0)
		else
			PixelUtil.SetPoint(bar[i], "LEFT", bar[i - 1], "RIGHT", 2, 0)
		end
	end

	bar:SetScript("OnEvent", bar.OnEvent)
	bar:SetScript("OnSizeChanged", bar.OnSizeChanged)

	-- all
	bar:RegisterEvent("PLAYER_UPDATE_RESTING")
	bar:RegisterEvent("UPDATE_EXHAUSTION")
	-- honour
	bar:RegisterEvent("HONOR_XP_UPDATE")
	bar:RegisterEvent("ZONE_CHANGED")
	bar:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	-- artefact
	-- bar:RegisterEvent("ARTIFACT_XP_UPDATE")
	-- bar:RegisterUnitEvent("UNIT_INVENTORY_CHANGED", "player")
	-- azerite
	bar:RegisterEvent("AZERITE_ITEM_EXPERIENCE_CHANGED")
	bar:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	-- xp
	bar:RegisterEvent("DISABLE_XP_GAIN")
	bar:RegisterEvent("ENABLE_XP_GAIN")
	bar:RegisterEvent("PLAYER_LEVEL_UP")
	bar:RegisterEvent("PLAYER_XP_UPDATE")
	bar:RegisterEvent("UPDATE_EXPANSION_LEVEL")
	-- rep
	bar:RegisterEvent("UPDATE_FACTION")
	-- house xp
	bar:RegisterEvent("HOUSE_LEVEL_FAVOR_UPDATED")
	bar:RegisterEvent("PLAYER_HOUSE_LIST_UPDATED")
	bar:RegisterEvent("TRACKED_HOUSE_CHANGED")
	-- state / visibility
	bar:RegisterEvent("PET_BATTLE_CLOSE")
	bar:RegisterEvent("PET_BATTLE_OPENING_START")
	bar:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", "player")
	bar:RegisterUnitEvent("UNIT_EXITED_VEHICLE", "player")

	return bar
end

function addon.Bar:UpdateFading()
	addon.Fader:Unwatch(LSMonobrow)

	local config = addon:GetLayout()
	if config.fade.enabled then
		addon.Fader:Watch(LSMonobrow, config.fade.min_alpha)
	end
end

function addon.Bar:UpdateBorderTexture()
	local borderData = D.global.borders[C.db.profile.border.type]

	LSMonobrow.Border:SetTexture(borderData.texture)
	LSMonobrow.Border:SetSize(borderData.size)
	LSMonobrow.Border:SetOffset(borderData.offset)
end

function addon.Bar:UpdateBorderColor()
	local color = C.db.profile.border.color

	LSMonobrow.Border:SetVertexColor(color.r, color.g, color.b, color.a)

	for i = 1, MAX_SEGMENTS do
		LSMonobrow[i].Sep:SetVertexColor(color.r, color.g, color.b, color.a)
	end
end
