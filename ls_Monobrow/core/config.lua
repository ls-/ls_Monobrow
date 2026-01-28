local addonName, addon = ...
local C, D, L = addon.C, addon.D, addon.L

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local m_floor = _G.math.floor
local m_random = _G.math.random
local next = _G.next
local s_format = _G.string.format

-- Mine
local LEM = LibStub("LibEditMode-ls", true) or LibStub("LibEditMode")

-- move these elsehwere
local CL_LINK = "https://github.com/ls-/ls_Monobrow/blob/master/CHANGELOG.md"
local CURSE_LINK = "https://www.curseforge.com/wow/addons/ls-monobrow"
local DISCORD_LINK = "https://discord.gg/7QcJgQkDYD"
local GITHUB_LINK = "https://github.com/ls-/ls_Monobrow"
local WAGO_LINK = "https://addons.wago.io/addons/ls-monobrow"

local showLinkCopyPopup
do
	local function getStatusMessage()
		local num = m_random(1, 100)
		if num == 27 then
			return "The Cake is a Lie"
		else
			return L["LINK_COPY_SUCCESS"]
		end
	end

	local link = ""

	local popup = CreateFrame("Frame", nil, UIParent)
	popup:Hide()
	popup:SetPoint("CENTER", UIParent, "CENTER")
	popup:SetSize(384, 78)
	popup:EnableMouse(true)
	popup:SetFrameStrata("TOOLTIP")
	popup:SetFixedFrameStrata(true)
	popup:SetFrameLevel(100)
	popup:SetFixedFrameLevel(true)
	popup:EnableKeyboard(true)

	local border = CreateFrame("Frame", nil, popup, "DialogBorderTranslucentTemplate")
	border:SetAllPoints(popup)

	local editBox = CreateFrame("EditBox", nil, popup, "InputBoxTemplate")
	editBox:SetHeight(32)
	editBox:SetPoint("TOPLEFT", 22, -10)
	editBox:SetPoint("TOPRIGHT", -16, -10)
	editBox:EnableKeyboard(true)
	editBox:SetScript("OnChar", function(self)
		self:SetText(link)
		self:HighlightText()
	end)
	editBox:SetScript("OnMouseUp", function(self)
		self:HighlightText()
	end)
	editBox:SetScript("OnEscapePressed", function()
		popup:Hide()
	end)
	editBox:SetScript("OnEnterPressed", function()
		popup:Hide()
	end)
	editBox:SetScript("OnKeyUp", function(_, key)
		if IsControlKeyDown() and (key == "C" or key == "X") then
			ActionStatus:DisplayMessage(getStatusMessage())

			popup:Hide()
		end
	end)

	local button = CreateFrame("Button", nil, popup, "UIPanelButtonNoTooltipTemplate")
	button:SetText(_G.CLOSE)
	button:SetSize(90, 22)
	button:SetPoint("BOTTOM", 0, 16)
	button:SetScript("OnClick", function()
		popup:Hide()
	end)

	popup:SetScript("OnHide", function()
		link = ""
		editBox:SetText(link)
	end)
	popup:SetScript("OnShow", function()
		editBox:SetText(link)
		editBox:SetFocus()
		editBox:HighlightText()
	end)

	function showLinkCopyPopup(text)
		popup:Hide()
		link = text
		popup:Show()
	end
end

function addon:CreateEditModeConfig()
	local function onPositionChanged(_, layoutName, point, x, y)
		C.db.profile.layouts[layoutName].point.point = point
		C.db.profile.layouts[layoutName].point.x = x
		C.db.profile.layouts[layoutName].point.y = y
	end

	LEM:AddFrame(LSMonobrow, onPositionChanged, D.profile.layouts["*"].point, L["LS_MONOBROW"])

	LEM:RegisterCallback("layout", function(layoutName)
		-- AceDB takes care of layout table duplication
		local layout = C.db.profile.layouts[layoutName]

		LSMonobrow:UpdateSize(layout.width, layout.height)
		LSMonobrow:ClearAllPoints()
		LSMonobrow:SetPoint(layout.point.point, layout.point.x, layout.point.y)
		LSMonobrow:UpdateTextFormat(layout.text.format)
		LSMonobrow:UpdateTextVisibility(layout.text.always_show)

		addon.Bar:UpdateFading()
	end)

	LEM:RegisterCallback("create", function(newLayoutName, _, sourceLayoutName)
		if sourceLayoutName then
			addon:CopyTable(C.db.profile.layouts[sourceLayoutName], C.db.profile.layouts[newLayoutName])
		end
	end)

	LEM:RegisterCallback("delete", function(oldLayoutName)
		C.db.profile.layouts[oldLayoutName] = nil
	end)

	LEM:RegisterCallback("rename", function(oldLayoutName, newLayoutName)
		addon:CopyTable(C.db.profile.layouts[oldLayoutName], C.db.profile.layouts[newLayoutName])

		C.db.profile.layouts[oldLayoutName] = nil
	end)

	LEM:RegisterCallback("enter", function()
		LSMonobrow.isEditing = true

		LSMonobrow:UpdateSegments()
	end)

	LEM:RegisterCallback("exit", function()
		LSMonobrow.isEditing = false

		LSMonobrow:UpdateSegments()
	end)

	LEM:AddFrameSettings(LSMonobrow, {
		{
			name = _G.HUD_EDIT_MODE_SETTING_CHAT_FRAME_WIDTH,
			kind = LEM.SettingType.Slider,
			default = D.profile.layouts["*"].width,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].width
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].width ~= value then
					C.db.profile.layouts[layoutName].width = value

					LSMonobrow:UpdateSize(value, C.db.profile.layouts[layoutName].height)
				end
			end,
			minValue = 384,
			maxValue = m_ceil(GetScreenWidth()),
			valueStep = 2,
		},
		{
			name = _G.HUD_EDIT_MODE_SETTING_CHAT_FRAME_HEIGHT,
			kind = LEM.SettingType.Slider,
			default = D.profile.layouts["*"].height,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].height
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].height ~= value then
					C.db.profile.layouts[layoutName].height = value

					LSMonobrow:UpdateSize(C.db.profile.layouts[layoutName].width, value)
				end
			end,
			minValue = 8,
			maxValue = 32,
			valueStep = 2,
		},
		{
			name = _G.LOCALE_TEXT_LABEL,
			kind = LEM.SettingType.Divider,
			hidden = function()
				return not C.db.global.settings.text
			end,
		},
		{
			name = _G.HUD_EDIT_MODE_SETTING_MINIMAP_SIZE,
			kind = LEM.SettingType.Slider,
			hidden = function()
				return not C.db.global.settings.text
			end,
			default = D.profile.layouts["*"].font.size,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].font.size
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].font.size ~= value then
					C.db.profile.layouts[layoutName].font.size = value

					addon.Font:Update()
				end
			end,
			minValue = 8,
			maxValue = 32,
			valueStep = 1,
		},
		{
			name = _G.FORMATTING,
			kind = LEM.SettingType.Dropdown,
			hidden = function()
				return not C.db.global.settings.text
			end,
			default = D.profile.layouts["*"].text.format,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].text.format
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].text.format ~= value then
					C.db.profile.layouts[layoutName].text.format = value

					LSMonobrow:UpdateTextFormat(value)
				end
			end,
			values = {
				{
					isRadio = true,
					text = L["NUMBERS"],
					value = "NUM",
				},
				{
					isRadio = true,
					text = L["NUMBERS_PERCENTAGE"],
					value = "NUM_PERC",
				},
			},
		},
		{
			name = _G.BATTLEFIELD_MINIMAP_SHOW_ALWAYS,
			kind = LEM.SettingType.Checkbox,
			hidden = function()
				return not C.db.global.settings.text
			end,
			default = D.profile.layouts["*"].text.always_show,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].text.always_show
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].text.always_show ~= value then
					C.db.profile.layouts[layoutName].text.always_show = value

					LSMonobrow:UpdateTextVisibility(value)
				end
			end,
		},
		{
			name = "DNT Text Settings Expander",
			kind = LEM.SettingType.Expander,
			expandedLabel = L["COLLAPSE_OPTIONS"],
			collapsedLabel = _G.LOCALE_TEXT_LABEL,
			appendArrow = true,
			default = function()
				return D.global.settings.text
			end,
			get = function()
				return C.db.global.settings.text
			end,
			set = function(_, value)
				C.db.global.settings.text = value
			end,
		},
		{
			name = L["FADING"],
			kind = LEM.SettingType.Divider,
			hidden = function()
				return not C.db.global.settings.fade
			end,
		},
		{
			name = _G.ENABLE,
			kind = LEM.SettingType.Checkbox,
			hidden = function()
				return not C.db.global.settings.fade
			end,
			default = D.profile.layouts["*"].fade.enabled,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].fade.enabled
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].fade.enabled ~= value then
					C.db.profile.layouts[layoutName].fade.enabled = value

					addon.Bar:UpdateFading()
				end
			end,
		},
		{
			name = L["MIN_ALPHA"],
			kind = LEM.SettingType.Slider,
			disabled = function(layoutName)
				return not C.db.profile.layouts[layoutName].fade.enabled
			end,
			hidden = function()
				return not C.db.global.settings.fade
			end,
			default = D.profile.layouts["*"].fade.min_alpha,
			get = function(layoutName)
				return C.db.profile.layouts[layoutName].fade.min_alpha
			end,
			set = function(layoutName, value)
				if C.db.profile.layouts[layoutName].fade.min_alpha ~= value then
					C.db.profile.layouts[layoutName].fade.min_alpha = value

					addon.Bar:UpdateFading()
				end
			end,
			formatter = function(value)
				return _G.PERCENTAGE_STRING:format(value * 100)
			end,
			minValue = 0,
			maxValue = 0.75,
			valueStep = 0.05,
		},
		{
			name = "DNT Fade Settings Expander",
			kind = LEM.SettingType.Expander,
			expandedLabel = L["COLLAPSE_OPTIONS"],
			collapsedLabel = L["FADING"],
			appendArrow = true,
			default = function()
				return D.global.settings.fade
			end,
			get = function()
				return C.db.global.settings.fade
			end,
			set = function(_, value)
				C.db.global.settings.fade = value
			end,
		},
	})

	LEM:AddFrameSettingsButtons(LSMonobrow, {
		{
			text =_G.ADVANCED_OPTIONS,
			click = function()
				addon:OpenAceConfig()
			end,
		},
	})

	addon:RegisterEvent("DISPLAY_SIZE_CHANGED", function()
		local settings = LEM.internal:GetFrameSettings(LSMonobrow)
		settings[1].maxValue = m_ceil(GetScreenWidth())
	end)
end

do
	local header_proto = {}

	do
		function header_proto:OnHyperlinkClick(hyperlink)
			showLinkCopyPopup(hyperlink)
		end
	end

	local function createHeader(parent, text)
		local header = Mixin(CreateFrame("Frame", nil, parent, "InlineHyperlinkFrameTemplate"), header_proto)
		header:SetHeight(50)
		header:SetScript("OnHyperlinkClick", header.OnHyperlinkClick)

		local title = header:CreateFontString(nil, "ARTWORK", "GameFontHighlightHuge")
		title:SetPoint("TOPLEFT", 7, -22)
		title:SetText(text)

		local divider = header:CreateTexture(nil, "ARTWORK")
		divider:SetAtlas("Options_HorizontalDivider", true)
		divider:SetPoint("TOP", 0, -50)

		return header
	end

	local button_proto = {}

	do
		function button_proto:OnEnter()
			self.Icon:SetScale(1.1)

			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:AddLine(self.tooltip)
			GameTooltip:Show()
		end

		function button_proto:OnLeave()
			self.Icon:SetScale(1)

			GameTooltip:Hide()
		end

		function button_proto:OnClick()
			showLinkCopyPopup(self.link)
		end
	end

	local container_proto = {
		numChildren = 0,
	}

	do
		function container_proto:AddButton(texture, tooltip, link)
			self.numChildren = self.numChildren + 1
			self.spacing = m_floor(580 / (self.numChildren + 1))

			local button = Mixin(CreateFrame("Button", nil, self), button_proto)
			button:SetSize(64, 64)
			button:SetScript("OnEnter", button.OnEnter)
			button:SetScript("OnLeave", button.OnLeave)
			button:SetScript("OnClick", button.OnClick)
			button.layoutIndex = self.numChildren

			local icon = button:CreateTexture(nil, "ARTWORK")
			icon:SetPoint("CENTER")
			icon:SetSize(48, 48)
			icon:SetTexture(texture)
			button.Icon = icon

			button.tooltip = tooltip
			button.link = link
		end
	end

	function addon:CreateBlizzConfig()
		local panel = CreateFrame("Frame", "LSMonobrowConfigPanel")
		panel:Hide()

		local versionText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		versionText:SetPoint("TOPRIGHT", -2, 4)
		versionText:SetTextColor(0.4, 0.4, 0.4)
		versionText:SetText(addon.VER.string)

		-- UIPanelButtonTemplate
		local configButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
		configButton:SetText(_G.ADVANCED_OPTIONS)
		configButton:SetWidth(configButton:GetTextWidth() + 18)
		configButton:SetPoint("TOPRIGHT", -36, -16)
		configButton:SetScript("OnClick", function()
			addon:OpenAceConfig()
		end)

		local supportHeader = createHeader(panel, L["SUPPORT_FEEDBACK"])
		supportHeader:SetPoint("TOPLEFT")
		supportHeader:SetPoint("TOPRIGHT")

		local supportContainer = Mixin(CreateFrame("Frame", nil, panel, "HorizontalLayoutFrame"), container_proto)
		supportContainer:SetPoint("TOP", supportHeader, "BOTTOM", 0, -4)

		supportContainer:AddButton("Interface\\AddOns\\ls_Monobrow\\assets\\discord-64", L["DISCORD"], DISCORD_LINK)
		supportContainer:AddButton("Interface\\AddOns\\ls_Monobrow\\assets\\github-64", L["GITHUB"], GITHUB_LINK)

		local downloadHeader = createHeader(panel, L["DOWNLOADS"])
		downloadHeader:SetPoint("TOP", supportContainer, "BOTTOM", 0, 8)
		downloadHeader:SetPoint("LEFT")
		downloadHeader:SetPoint("RIGHT")

		local downloadContainer = Mixin(CreateFrame("Frame", nil, panel, "HorizontalLayoutFrame"), container_proto)
		downloadContainer:SetPoint("TOP", downloadHeader, "BOTTOM", 0, -4)

		-- downloadContainer:AddButton("Interface\\AddOns\\ls_Monobrow\\assets\\mmoui-64", L["WOWINTERFACE"])
		downloadContainer:AddButton("Interface\\AddOns\\ls_Monobrow\\assets\\curseforge-64", L["CURSEFORGE"], CURSE_LINK)
		downloadContainer:AddButton("Interface\\AddOns\\ls_Monobrow\\assets\\wago-64", L["WAGO"], WAGO_LINK)

		local changelogHeader = createHeader(panel, s_format("%s |H%s|h[|c%s%s|r]|h",  L["CHANGELOG"], CL_LINK, D.global.colors.addon:GetHex(), L["CHANGELOG_FULL"]))
		changelogHeader:SetPoint("TOP", downloadContainer, "BOTTOM", 0, 8)
		changelogHeader:SetPoint("LEFT")
		changelogHeader:SetPoint("RIGHT")

		-- recreation of "ScrollingFontTemplate"
		local changelog = Mixin(CreateFrame("Frame", nil, panel), ScrollingFontMixin)
		changelog:SetPoint("TOPLEFT", changelogHeader, "BOTTOMLEFT", 6, -8)
		changelog:SetPoint("BOTTOMRIGHT", changelogHeader, "BOTTOMRIGHT", -38, -192)
		changelog:SetScript("OnSizeChanged", changelog.OnSizeChanged)
		changelog.fontName = "GameFontHighlight"

		local border = CreateFrame("Frame", nil, changelog, "FloatingBorderedFrame")
		border:SetPoint("TOPLEFT")
		border:SetPoint("BOTTOMRIGHT", 20, 0)
		border:SetUsingParentLevel(true)

		for _, region in next, {border:GetRegions()} do
			region:SetVertexColor(0, 0, 0, 0.3)
		end

		local scrollBox = CreateFrame("Frame", nil, changelog, "WowScrollBox")
		scrollBox:SetAllPoints()
		changelog.ScrollBox = scrollBox

		local fontStringContainer = CreateFrame("Frame", nil, scrollBox)
		fontStringContainer:SetHeight(1)
		fontStringContainer.scrollable = true
		scrollBox.FontStringContainer = fontStringContainer

		local fontString = fontStringContainer:CreateFontString(nil, "ARTWORK")
		fontString:SetPoint("TOPLEFT")
		fontString:SetNonSpaceWrap(true)
		fontString:SetJustifyH("LEFT")
		fontString:SetJustifyV("TOP")
		fontStringContainer.FontString = fontString

		local scrollBar = CreateFrame("EventFrame", nil, panel, "MinimalScrollBar")
		scrollBar:SetPoint("TOPLEFT", scrollBox, "TOPRIGHT", 6, 0)
		scrollBar:SetPoint("BOTTOMLEFT", scrollBox, "BOTTOMRIGHT", 6, -3)
		scrollBar:SetHideIfUnscrollable(true)
		changelog.ScrollBar = scrollBar

		ScrollUtil.RegisterScrollBoxWithScrollBar(scrollBox, scrollBar)

		changelog:OnLoad()
		changelog:SetText(addon.CHANGELOG)

		supportContainer:MarkDirty()

		local category = Settings.RegisterCanvasLayoutCategory(panel, L["LS_MONOBROW"])

		Settings.RegisterAddOnCategory(category)

		function addon:OpenBlizzConfig()
			Settings.OpenToCategory(category:GetID())
		end
	end

end

do
	local function createSpacer(order)
		return {
			order = order,
			type = "description",
			name = " ",
		}
	end

	function addon:CreateAceConfig()
		C.options = {
			type = "group",
			name = s_format("%s |cffcacaca(%s)|r", L["LS_MONOBROW"], addon.VER.string),
			args = {
				general = {
					order = 1,
					type = "group",
					name = "",
					-- name = _G.GENERAL_LABEL,
					inline = true,
					args = {
						texture = {
							order = 1,
							type = "select",
							name = L["TEXTURE"],
							width = 1.25,
							dialogControl = "LSM30_Statusbar",
							values = LibStub("LibSharedMedia-3.0"):HashTable("statusbar"),
							get = function()
								return LibStub("LibSharedMedia-3.0"):IsValid("statusbar", C.db.profile.texture.name) and C.db.profile.texture.name or LibStub("LibSharedMedia-3.0"):GetDefault("statusbar")
							end,
							set = function(_, value)
								if C.db.profile.texture.name ~= value then
									C.db.profile.texture.name = value

									LSMonobrow:UpdateTextures()
								end
							end,
						},
						spacer_1 = createSpacer(10),
						border = {
							order = 11,
							type = "group",
							inline = true,
							name = _G.EMBLEM_BORDER,
							args = {
								type = {
									order = 1,
									type = "select",
									name = _G.NAME,
									width = 1.25,
									values = addon:GetBorderList(),
									get = function()
										return C.db.profile.border.type
									end,
									set = function(_, value)
										if C.db.profile.border.type ~= value then
											C.db.profile.border.type = value

											addon.Bar:UpdateBorderTexture()
										end
									end,
								},
								color = {
									order = 2,
									type = "color",
									name = _G.COLOR,
									hasAlpha = true,
									get = function()
										local color = C.db.profile.border.color
										return color.r, color.g, color.b, color.a
									end,
									set = function(_, r, g, b, a)
										if r ~= nil then
											local color = C.db.profile.border.color
											if color.r ~= r or color.g ~= g or color.g ~= b or color.a ~= a then
												color.r, color.g, color.b, color.a = r, g, b, a

												addon.Bar:UpdateBorderColor()
											end
										end
									end,
								}
							},
						},
						spacer_2 = createSpacer(20),
						font = {
							order = 21,
							type = "group",
							inline = true,
							name = L["FONT"],
							get = function(info)
								return C.db.profile.font[info[#info]]
							end,
							set = function(info, value)
								if C.db.profile.font[info[#info]] ~= value then
									C.db.profile.font[info[#info]] = value

									addon.Font:Update()
								end
							end,
							args = {
								name = {
									order = 1,
									type = "select",
									name = _G.NAME,
									width = 1.25,
									dialogControl = "LSM30_Font",
									values = LibStub("LibSharedMedia-3.0"):HashTable("font"),
									get = function()
										return LibStub("LibSharedMedia-3.0"):IsValid("font", C.db.profile.font.name) and C.db.profile.font.name or LibStub("LibSharedMedia-3.0"):GetDefault("font")
									end,
								},
								outline = {
									order = 2,
									type = "toggle",
									name = L["OUTLINE"],
								},
								shadow = {
									order = 3,
									type = "toggle",
									name = L["SHADOW"],
								},
							},
						},
					},
				},
			},
		}

		LibStub("AceConfig-3.0"):RegisterOptionsTable(addonName, C.options)

		function addon:OpenAceConfig()
			if not InCombatLockdown() then
				HideUIPanel(SettingsPanel)
			end

			LibStub("AceConfigDialog-3.0"):Open(addonName)
		end
	end
end
