local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Segment = {}

-- Lua
local _G = getfenv(0)

-- Mine
local ARTIFACT_LEVEL_TEMPLATE = _G.ARTIFACTS_NUM_PURCHASED_RANKS:gsub("%%d", "|cffffffff%%d|r")
local HONOR_TEMPLATE = _G.LFG_LIST_HONOR_LEVEL_CURRENT_PVP:gsub("%%d", "|cffffffff%%d|r")
local RENOWN_PLUS = _G.LANDING_PAGE_RENOWN_LABEL .. "+"
local REPUTATION_TEMPLATE = _G.SUBTITLE_FORMAT -- because of language specific ":" and "："

local segment_base_proto = {}
do
	function segment_base_proto:SetSmoothStatusBarColor(r, g, b, a)
		local color = self.ColorAnim.color
		a = a or 1

		if color.r == r and color.g == g and color.b == b and color.a == a then return end

		color.r, color.g, color.b, color.a = self:GetStatusBarColor()
		self.ColorAnim.Anim:SetStartColor(color)

		color.r, color.g, color.b, color.a = r, g, b, a
		self.ColorAnim.Anim:SetEndColor(color)

		self.ColorAnim:Play()
	end
end

local segment_ext_proto = {
	valueTemplate = "",
}
do
	function segment_ext_proto:GetTooltipPoint()
		local quadrant = "UNKNOWN"

		local x, y = self:GetCenter()
		if x and y then
			local screenWidth = UIParent:GetRight()
			local screenHeight = UIParent:GetTop()
			local screenLeft = screenWidth / 3
			local screenRight = screenWidth * 2 / 3

			if y >= screenHeight * 2 / 3 then
				if x <= screenLeft then
					quadrant = "TOPLEFT"
				elseif x >= screenRight then
					quadrant = "TOPRIGHT"
				else
					quadrant = "TOP"
				end
			elseif y <= screenHeight / 3 then
				if x <= screenLeft then
					quadrant = "BOTTOMLEFT"
				elseif x >= screenRight then
					quadrant = "BOTTOMRIGHT"
				else
					quadrant = "BOTTOM"
				end
			else
				if x <= screenLeft then
					quadrant = "LEFT"
				elseif x >= screenRight then
					quadrant = "RIGHT"
				else
					quadrant = "CENTER"
				end
			end
		end

		local p, rP, sign = "BOTTOMLEFT", "TOPLEFT", 1
		if quadrant == "TOPLEFT" or quadrant == "TOP" or quadrant == "TOPRIGHT" then
			p, rP, sign = "TOPLEFT", "BOTTOMLEFT", -1
		end

		return p, rP, sign
	end

	function segment_ext_proto:OnEnter()
		if self.tooltipInfo then
			local p, rP, sign = self:GetTooltipPoint()

			GameTooltip:SetOwner(self, "ANCHOR_NONE")
			GameTooltip:SetPoint(p, self, rP, 0, sign * 2)
			GameTooltip:AddLine(self.tooltipInfo.header, 1, 1, 1)
			GameTooltip:AddLine(self.tooltipInfo.line1)

			if self.tooltipInfo.line2 then
				GameTooltip:AddLine(self.tooltipInfo.line2)
			end

			if self.tooltipInfo.line3 then
				GameTooltip:AddLine(self.tooltipInfo.line3)
			end

			GameTooltip:Show()
		end

		if not self:IsTextLocked() then
			self:FadeInText()
		end
	end

	function segment_ext_proto:OnLeave()
		GameTooltip:Hide()

		if not self:IsTextLocked() then
			self:FadeOutText()
		end
	end

	function segment_ext_proto:Update(cur, max, bonus, color)
		self:SetSmoothStatusBarColor(color:GetRGBA(1))

		self.Extension:SetSmoothStatusBarColor(color:GetRGBA(0.4))

		if self.cur ~= cur or self.max ~= max then
			self:SetValue(cur / max, Enum.StatusBarInterpolation.ExponentialEaseOut)
			self:UpdateText(cur, max)

			self.cur = cur
			self.max = max
		end

		if self.bonus ~= bonus then
			if bonus and bonus > 0 then
				if cur + bonus > max then
					bonus = max - cur
				end

				self.Extension:SetValue(bonus / max, Enum.StatusBarInterpolation.ExponentialEaseOut)
			else
				self.Extension:SetValue(0, Enum.StatusBarInterpolation.ExponentialEaseOut)
			end

			self.bonus = bonus
		end
	end

	function segment_ext_proto:UpdateAzerite(item)
		local cur, max = C_AzeriteItem.GetAzeriteItemXPInfo(item)
		local level = C_AzeriteItem.GetPowerLevel(item)

		self.tooltipInfo = {
			header = _G.WORLD_QUEST_REWARD_FILTERS_ARTIFACT_POWER,
			line1 = ARTIFACT_LEVEL_TEMPLATE:format(level),
		}

		self:Update(cur, max, 0, ITEM_QUALITY_COLORS[6].color)
	end

	function segment_ext_proto:UpdateXP()
		local cur, max = UnitXP("player"), UnitXPMax("player")
		local bonus = GetXPExhaustion() or 0

		-- all xp values are 0 during the initial update
		if max == 0 then
			max = 1
		end

		self.tooltipInfo = {
			header = _G.XP,
			line1 = L["LEVEL_TOOLTIP"]:format(UnitLevel("player")),
		}

		if bonus > 0 then
			self.tooltipInfo.line2 = L["BONUS_XP_TOOLTIP"]:format(BreakUpLargeNumbers(bonus))
		else
			self.tooltipInfo.line2 = nil
		end

		self:Update(cur, max, bonus, bonus > 0 and C.db.global.colors.xp[1] or C.db.global.colors.xp[2])
	end

	function segment_ext_proto:UpdateHonor()
		local cur, max = UnitHonor("player"), UnitHonorMax("player")

		self.tooltipInfo = {
			header = _G.HONOR,
			line1 = HONOR_TEMPLATE:format(UnitHonorLevel("player")),
		}

		self:Update(cur, max, 0, C.db.global.colors.faction[UnitFactionGroup("player")])
	end

	function segment_ext_proto:UpdateReputation(name, standing, repMin, repMax, repCur, factionID)
		local repTextLevel = GetText("FACTION_STANDING_LABEL" .. standing, UnitSex("player"))
		local repInfo = C_GossipInfo.GetFriendshipReputation(factionID)
		local isParagon = C_Reputation.IsFactionParagonForCurrentPlayer(factionID)
		local isMajor = C_Reputation.IsMajorFaction(factionID)
		local isFriendship = repInfo and repInfo.friendshipFactionID > 0
		local rewardQuestID, hasRewardPending
		local cur, max

		-- any faction can be paragon as in you keep earning more rep to unlock extra rewards
		if isParagon then
			cur, max, rewardQuestID, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
			cur = cur % max

			if hasRewardPending then
				cur = cur + max
			end

			if isMajor then
				standing = 9
				repTextLevel = RENOWN_PLUS
			elseif isFriendship then
				repTextLevel = repInfo.reaction .. "+"
			else
				repTextLevel = repTextLevel .. "+"
			end
		elseif isMajor then
			repInfo = C_MajorFactions.GetMajorFactionData(factionID)

			if C_MajorFactions.HasMaximumRenown(factionID) then
				max, cur = 1, 1
			else
				max, cur = repInfo.renownLevelThreshold, repInfo.renownReputationEarned
			end

			standing = 9
			repTextLevel = _G.RENOWN_LEVEL_LABEL:format(repInfo.renownLevel)
		elseif isFriendship then
			if repInfo.nextThreshold then
				max, cur = repInfo.nextThreshold - repInfo.reactionThreshold, repInfo.standing - repInfo.reactionThreshold
			else
				max, cur = 1, 1
			end

			standing = 5
			repTextLevel = repInfo.reaction
		else
			if standing ~= MAX_REPUTATION_REACTION then
				max, cur = repMax - repMin, repCur - repMin
			else
				max, cur = 1, 1
			end
		end

		self.tooltipInfo = {
			header = _G.REPUTATION,
			line1 = REPUTATION_TEMPLATE:format(name, C.db.global.colors.reaction[standing]:WrapTextInColorCode(repTextLevel)),
		}

		if hasRewardPending then
			local text = GetQuestLogCompletionText(C_QuestLog.GetLogIndexForQuestID(rewardQuestID))
			if text and text ~= "" then
				self.tooltipInfo.line3 = text
			end
		else
			self.tooltipInfo.line3 = nil
		end

		self:Update(cur, max, 0, C.db.global.colors.reaction[standing])
	end

	function segment_ext_proto:UpdateHouseXP(data)
		local level = data.houseLevel
		local cur = data.houseFavor
		local min = C_Housing.GetHouseLevelFavorForLevel(level)
		local max = C_Housing.GetHouseLevelFavorForLevel(level + 1)

		-- at level 0, all values are 0, but you're promted to upgrade anyway
		if max == 0 then
			cur = 1
			max = 1
		end

		self.tooltipInfo = {
			header = _G.HOUSING_DASHBOARD_NEIGHBORHOOD_FAVOR_LABEL,
		}

		if data.houseName then
			self.tooltipInfo.line1 = data.houseName
			self.tooltipInfo.line2 = L["LEVEL_TOOLTIP"]:format(level)
		else
			self.tooltipInfo.line1 = L["LEVEL_TOOLTIP"]:format(level)
		end

		if cur >= max then
			self.tooltipInfo.line3 = _G.HOUSING_DASHBOARD_VISIT_NPC
		end

		self:Update(cur - min, max - min, 0, C.db.global.colors.house)
	end

	function segment_ext_proto:UpdatePetXP(i, level)
		local name = C_PetBattles.GetName(1, i)
		local rarity = C_PetBattles.GetBreedQuality(1, i)
		local cur, max = C_PetBattles.GetXP(1, i)

		self.tooltipInfo = {
			header = ITEM_QUALITY_COLORS[rarity].color:WrapTextInColorCode(name),
			line1 = L["LEVEL_TOOLTIP"]:format(level),
		}

		self:Update(cur, max, 0, C.db.global.colors.xp[2])
	end

	function segment_ext_proto:UpdateDummy()
		self.tooltipInfo = nil

		self:Update(100, 300, 150, C.db.global.colors.xp[1])
	end

	function segment_ext_proto:UpdateText(cur, max)
		cur = cur or self.cur or 1
		max = max or self.max or 1

		if cur == 1 and max == 1 then
			self.Text:SetText(nil)
		else
			self.Text:SetFormattedText(self.valueTemplate, addon:AbbreviateNumbers(cur), addon:AbbreviateNumbers(max), addon:NumberToPerc(cur, max))
		end
	end

	function segment_ext_proto:LockText(isLocked)
		if self.textLocked ~= isLocked then
			self.textLocked = isLocked
			self.Text.FadeIn:Stop()
			self.Text.FadeOut:Stop()
			self.Text:SetAlpha(isLocked and 1 or 0)
		end
	end

	function segment_ext_proto:IsTextLocked()
		return self.textLocked
	end

	function segment_ext_proto:SetValueTemplate(template)
		self.valueTemplate = template

		self:UpdateText(self.cur, self.max)
	end

	function segment_ext_proto:FadeInText()
		if self.Text.FadeOut:IsPlaying() then
			self.Text.FadeOut:Stop()
		end

		self.Text.FadeIn.Anim:SetFromAlpha(self.Text:GetAlpha())
		self.Text.FadeIn:Play()
	end

	function segment_ext_proto:FadeOutText()
		if self.Text:GetAlpha() > 0 then
			self.Text.FadeOut:Play()
		end
	end

	function segment_ext_proto:UpdateTextures()
		self:SetStatusBarTexture(LibStub("LibSharedMedia-3.0"):Fetch("statusbar", C.db.profile.texture.name))

		self.Extension:SetStatusBarTexture(LibStub("LibSharedMedia-3.0"):Fetch("statusbar", C.db.profile.texture.name))
	end
end

function addon.Segment:Create(bar, i, textParent, textureParent)
	local segment = Mixin(CreateFrame("StatusBar", "$parentSegment" .. i, bar), segment_base_proto, segment_ext_proto)
	segment:SetFrameLevel(bar:GetFrameLevel() + 1)
	segment:SetStatusBarTexture(LibStub("LibSharedMedia-3.0"):Fetch("statusbar", C.db.profile.texture.name))
	segment:SetStatusBarColor(1, 1, 1, 0)
	segment:SetMinMaxValues(0, 1)
	segment:SetHitRectInsets(0, 0, -4, -4)
	segment:SetPoint("TOP", 0, 0)
	segment:SetPoint("BOTTOM", 0, 0)
	segment:SetClipsChildren(true)
	segment:SetFlattensRenderLayers(true)
	segment:SetScript("OnEnter", segment.OnEnter)
	segment:SetScript("OnLeave", segment.OnLeave)

	segment.Texture = segment:GetStatusBarTexture()
	segment.Texture:SetSnapToPixelGrid(false)
	segment.Texture:SetTexelSnappingBias(0)

	local ag = segment.Texture:CreateAnimationGroup()
	ag.color = {a = 1}
	segment.ColorAnim = ag

	local anim = ag:CreateAnimation("VertexColor")
	anim:SetDuration(0.125)
	ag.Anim = anim

	local ext = Mixin(CreateFrame("StatusBar", nil, segment), segment_base_proto)
	ext:SetFrameLevel(segment:GetFrameLevel())
	ext:SetStatusBarTexture(LibStub("LibSharedMedia-3.0"):Fetch("statusbar", C.db.profile.texture.name))
	ext:SetStatusBarColor(1, 1, 1, 0)
	ext:SetMinMaxValues(0, 1)
	ext:SetFlattensRenderLayers(true)
	ext:SetPoint("TOPLEFT", segment.Texture, "TOPRIGHT")
	ext:SetPoint("BOTTOMLEFT", segment.Texture, "BOTTOMRIGHT")
	segment.Extension = ext

	ext.Texture = ext:GetStatusBarTexture()
	ext.Texture:SetSnapToPixelGrid(false)
	ext.Texture:SetTexelSnappingBias(0)

	ag = ext.Texture:CreateAnimationGroup()
	ext.ColorAnim = ag

	anim = ag:CreateAnimation("VertexColor")
	anim:SetDuration(0.125)
	ag.color = {a = 1}
	ag.Anim = anim

	local text = textParent:CreateFontString(nil, "OVERLAY", "LSMonobrowFont")
	text:SetWordWrap(false)
	text:SetAllPoints(segment)
	text:SetAlpha(0)
	segment.Text = text

	ag = text:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	text.FadeIn = ag

	anim = ag:CreateAnimation("Alpha")
	anim:SetDuration(0.125)
	anim:SetToAlpha(1)
	ag.Anim = anim

	ag = text:CreateAnimationGroup()
	ag:SetToFinalAlpha(true)
	text.FadeOut = ag

	anim = ag:CreateAnimation("Alpha")
	anim:SetStartDelay(0.25)
	anim:SetDuration(0.25)
	anim:SetFromAlpha(1)
	anim:SetToAlpha(0)
	ag.Anim = anim

	local sep = textureParent:CreateTexture(nil, "ARTWORK", nil, -7)
	sep:SetTexture("Interface\\AddOns\\ls_Monobrow\\assets\\bar-sep", "REPEAT", "REPEAT")
	sep:SetVertTile(true)
	sep:SetTexCoord(2 / 16, 14 / 16, 0 / 8, 8 / 8)
	sep:SetSize(12 / 2, 0)
	sep:SetPoint("TOP", 0, 0)
	sep:SetPoint("BOTTOM", 0, 0)
	sep:SetPoint("LEFT", segment, "RIGHT", -2, 0)
	sep:Hide()
	segment.Sep = sep

	return segment
end
