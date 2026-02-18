local addonName, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local next = _G.next
local tonumber = _G.tonumber

-- Mine
addon.VER = {}
addon.VER.string = C_AddOns.GetAddOnMetadata(addonName, "Version")
addon.VER.number = tonumber(addon.VER.string:gsub("%D", ""), nil)

local function shutdownCallback()
	C.db.profile.version = addon.VER.number
end

addon:RegisterEvent("ADDON_LOADED", function(arg)
	if arg ~= addonName then return end

	if LS_MONOBROW_GLOBAL_CONFIG then
		if LS_MONOBROW_GLOBAL_CONFIG.profiles then
			for profile, data in next, LS_MONOBROW_GLOBAL_CONFIG.profiles do
				addon:Modernize(data, profile, "profile")
			end
		end
	end

	C.db = LibStub("AceDB-3.0"):New("LS_MONOBROW_GLOBAL_CONFIG", D, true)
	C.db:RegisterCallback("OnProfileShutdown", shutdownCallback)
	C.db:RegisterCallback("OnDatabaseShutdown", shutdownCallback)

	addon.Font:Create()

	local bar = addon.Bar:Create()

	addon.Bar:UpdateFading()
	addon.Bar:UpdateBorderTexture()
	addon.Bar:UpdateBorderColor()

	addon:CreateEditModeConfig()
	addon:CreateAceConfig()
	addon:CreateBlizzConfig()

	AddonCompartmentFrame:RegisterAddon({
		text = L["LS_MONOBROW"],
		icon = "Interface\\AddOns\\ls_Monobrow\\assets\\logo-32",
		func = function()
			if IsShiftKeyDown() then
				addon:OpenAceConfig()
			else
				addon:OpenBlizzConfig()
			end
		end,
		funcOnEnter = function(button)
			GameTooltip:SetOwner(button, "ANCHOR_BOTTOMRIGHT")
			GameTooltip:AddLine(L["AC_TOOLTIP"], 1, 1, 1)
			GameTooltip:Show()
		end,
		funcOnLeave = function()
			GameTooltip:Hide()
		end,
	})

	-- cleanup
	local function hideBar(object, skipEvents)
	if not object then return end

		addon:ForceHide(object, skipEvents)

		if object.system then
			addon:PurgeKey(object, "isShownExternal")
		end
	end

	hideBar(StatusTrackingBarManager)
	hideBar(MainStatusTrackingBarContainer)
	hideBar(SecondaryStatusTrackingBarContainer)

	addon:RegisterEvent("PLAYER_LOGIN", function()
		addon.Font:Update()

		-- to fetch and cache the tracked house data
		local guid = C_Housing.GetTrackedHouseGuid()
		if guid then
			C_Housing.GetCurrentHouseLevelFavor(guid)
		end

		-- Honour & Rep Hooks
		-- this way I'm able to show honour and reputation bars simultaneously, in the default UI enabling honour tracking
		-- resets faction tracking
		local isHonorBarHooked = false

		EventUtil.ContinueOnAddOnLoaded("Blizzard_PVPUI", function()
			if not isHonorBarHooked then
				for _, panel in next, {"CasualPanel", "RatedPanel", "TrainingGroundsPanel"} do
					PVPQueueFrame.HonorInset[panel].HonorLevelDisplay:SetScript("OnMouseUp", function()
						if IsShiftKeyDown() then
							if IsWatchingHonorAsXP() then
								PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
								SetWatchingHonorAsXP(false)
							else
								PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
								SetWatchingHonorAsXP(true)
							end

							bar:UpdateSegments()
						end
					end)

					PVPQueueFrame.HonorInset[panel].HonorLevelDisplay:HookScript("OnEnter", function()
						GameTooltip:AddLine(" ")
						GameTooltip:AddLine(L["SHIFT_CLICK_TO_SHOW_AS_XP"])
						GameTooltip:Show()
					end)

					PVPQueueFrame.HonorInset[panel].HonorLevelDisplay:HookScript("OnLeave", function()
						GameTooltip:Hide()
					end)
				end

				isHonorBarHooked = true
			end
		end)

		ReputationFrame.ReputationDetailFrame.WatchFactionCheckbox:SetScript("OnClick", function(self)
			if self:GetChecked() then
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				C_Reputation.SetWatchedFactionByIndex(C_Reputation.GetSelectedFaction())
			else
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
				C_Reputation.SetWatchedFactionByIndex(0)
			end

			bar:UpdateSegments()
		end)

		local function createWatchButton(parent)
			local button = CreateFrame("CheckButton", "$parentWatchButton", parent, "UICheckButtonArtTemplate")
			button:SetSize(21, 21)

			local label = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
			label:SetPoint("RIGHT", button, "LEFT", 0, 0)
			label:SetText(_G.MAJOR_FACTION_WATCH_FACTION_BUTTON_LABEL)
			label:SetJustifyH("LEFT")
			button.Label = label

			return button
		end

		EventUtil.ContinueOnAddOnLoaded("Blizzard_EncounterJournal", function()
			local button = createWatchButton(EncounterJournal.MonthlyActivitiesFrame.ThresholdContainer)
			button:SetPoint("BOTTOMRIGHT", EncounterJournal.MonthlyActivitiesFrame.ThresholdContainer.ThresholdBar, "TOPRIGHT", 0, 0)
			button:SetScript("OnShow", function(self)
				self:SetChecked(C.db.char.travel_points)
			end)
			button:SetScript("OnClick", function(self)
				C.db.char.travel_points = not C.db.char.travel_points
				self:GetChecked(C.db.char.travel_points)

				if self:GetChecked() then
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				else
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
				end

				bar:UpdateSegments()
			end)
		end)

		EventUtil.ContinueOnAddOnLoaded("Blizzard_HousingDashboard", function()
			local button = createWatchButton(HousingDashboardFrame.HouseInfoContent.ContentFrame.InitiativesFrame.InitiativeSetFrame)
			button:SetPoint("BOTTOMRIGHT", HousingDashboardFrame.HouseInfoContent.ContentFrame.InitiativesFrame.InitiativeSetFrame.ProgressBar, "TOPRIGHT", 0, 0)
			button:SetScript("OnShow", function(self)
				self:SetChecked(C.db.char.endeavor)
			end)
			button:SetScript("OnClick", function(self)
				C.db.char.endeavor = not C.db.char.endeavor
				self:GetChecked(C.db.char.endeavor)

				if self:GetChecked() then
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				else
					PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
				end

				bar:UpdateSegments()
			end)
		end)
	end)
end)
