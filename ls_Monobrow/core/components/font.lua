local _, addon = ...
local C, D, L = addon.C, addon.D, addon.L
addon.Font = {}

-- Lua
local _G = getfenv(0)
local m_ceil = _G.math.ceil
local next = _G.next
local t_insert = _G.table.insert

-- Mine
local LSM = LibStub("LibSharedMedia-3.0")

local alphabets = {"roman", "korean", "simplifiedchinese", "traditionalchinese", "russian"}

local defaultAlphabet = "roman"
local locale = GetLocale()
if locale == "koKR" then
	defaultAlphabet = "korean"
elseif locale == "zhCN" then
	defaultAlphabet = "simplifiedchinese"
elseif locale == "zhTW" then
	defaultAlphabet = "traditionalchinese"
elseif locale == "ruRU" then
	defaultAlphabet = "russian"
end

local fontData = {}

function addon.Font:Create()
	-- ! don't use font:CopyFontObject(sourceFont)
	local members = {}
	for _, alphabet in next, alphabets do
		local alphabetFont = GameFontHighlight:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			local file, height, flags = alphabetFont:GetFont()
			t_insert(members, {
				alphabet = alphabet,
				file = file,
				height = height,
				flags = flags,
			})

			fontData[alphabet] = {
				file = file,
				height = m_ceil(height),
				isDefault = alphabet == defaultAlphabet,
			}
		end
	end

	-- each alphabet has unique height, preserve it
	local defaultHeight = fontData[defaultAlphabet].height
	for alphabet, data in next, fontData do
		if alphabet ~= defaultAlphabet then
			data.heightDelta = data.height - defaultHeight
		else
			data.heightDelta = 0
		end
	end

	local font = CreateFontFamily("LSMonobrowFont", members)
	local newSize = addon:GetDefaultLayout().font.size -- fonts are created before LEM properly loads
	local newOutline = C.db.profile.font.outline and "OUTLINE" or ""
	local newShadow = C.db.profile.font.shadow

	for _, alphabet in next, alphabets do
		local alphabetFont = font:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			alphabetFont:SetFont(
				fontData[alphabet].isDefault and LSM:Fetch("font", C.db.profile.font.name) or fontData[alphabet].file,
				newSize + fontData[alphabet].heightDelta,
				newOutline
			)

			alphabetFont:SetShadowColor(0, 0, 0, 1)

			if newShadow then
				alphabetFont:SetShadowOffset(1, -1)
			else
				alphabetFont:SetShadowOffset(0, 0)
			end
		end
	end

	font:SetJustifyH("CENTER")
	font:SetJustifyV("MIDDLE")
end

function addon.Font:Update()
	local newSize = addon:GetLayout().font.size
	local newOutline = C.db.profile.font.outline and "OUTLINE" or ""
	local newShadow = C.db.profile.font.shadow

	for _, alphabet in next, alphabets do
		local alphabetFont = LSMonobrowFont:GetFontObjectForAlphabet(alphabet)
		if alphabetFont then
			alphabetFont:SetFont(
				fontData[alphabet].isDefault and LSM:Fetch("font", C.db.profile.font.name) or fontData[alphabet].file,
				newSize + fontData[alphabet].heightDelta,
				newOutline
			)

			if newShadow then
				alphabetFont:SetShadowOffset(1, -1)
			else
				alphabetFont:SetShadowOffset(0, 0)
			end
		end
	end

	LSMonobrowFont:SetJustifyH("CENTER")
	LSMonobrowFont:SetJustifyV("MIDDLE")
end
