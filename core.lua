local eXPeritia = CreateFrame("Frame", "eXPeritia", UIParent)

--[[ #############################
	Default configuration
############################## ]]

--local useDefaults = true	-- Uncomment for lua-config
local defaults = {
	['Width'] = 640,
	['Height'] = 30,
	['Color'] = { r = .9, g = .5, b = 0 },
	['ClassColors'] = true,
	['Topleft'] = 6,
	['Topright'] = 2,
	['Bottomleft'] = 5,
	['Bottomright'] = 4,
	['fadeIn'] = 0.2,
	['fadeOut'] = 10,
	['noFade'] = true,
}
eXPeritia:SetPoint("TOP", UIParent, "TOP", 0, -100) -- initial position

--[[ #############################
	Initialization
############################## ]]
local _G = getfenv(0)
local optionValues = {}
eXPeritia:SetMovable(true)

local font = CreateFont("eXPeritiaFont")
font:SetFontObject(GameFontHighlightSmall)
font:SetShadowOffset(1, -1)

local indMain = eXPeritia:CreateTexture(nil, "OVERLAY")
local indAlt1 = eXPeritia:CreateTexture(nil, "OVERLAY")
local indAlt2 = eXPeritia:CreateTexture(nil, "OVERLAY")
indMain:SetWidth(1)
indAlt1:SetWidth(1)
indAlt2:SetWidth(1)

local textMain = eXPeritia:CreateFontString(nil, "OVERLAY")
textMain:SetPoint("LEFT", indMain, "RIGHT", 10, 0)
textMain:SetFontObject("eXPeritiaFont")
local textTR = eXPeritia:CreateFontString(nil, "OVERLAY")
textTR:SetPoint("BOTTOMRIGHT", eXPeritia, "TOPRIGHT")
textTR:SetFontObject(font)
local textTL = eXPeritia:CreateFontString(nil, "OVERLAY")
textTL:SetPoint("BOTTOMLEFT", eXPeritia, "TOPLEFT")
textTL:SetFontObject(font)
local textBR = eXPeritia:CreateFontString(nil, "OVERLAY")
textBR:SetPoint("TOPRIGHT", eXPeritia, "BOTTOMRIGHT")
textBR:SetFontObject(font)
local textBL = eXPeritia:CreateFontString(nil, "OVERLAY")
textBL:SetPoint("TOPLEFT", eXPeritia, "BOTTOMLEFT")
textBL:SetFontObject(font)

local bgleft = eXPeritia:CreateTexture(nil, "BACKGROUND")
bgleft:SetTexture([[Interface\AddOns\eXPeritia\bg-left]])
bgleft:SetPoint("TOPLEFT", -4, 0)
bgleft:SetPoint("BOTTOMRIGHT", eXPeritia, "BOTTOM", 0, 0)
 
local bgright = eXPeritia:CreateTexture(nil, "BACKGROUND")
bgright:SetTexture([[Interface\AddOns\eXPeritia\bg-right]])
bgright:SetPoint("TOPRIGHT", 4, 0)
bgright:SetPoint("BOTTOMLEFT", eXPeritia, "BOTTOM", 0, 0)

local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

local defaults = {
	['Width'] = 640,
	['Height'] = 30,
	['Color'] = { r = .9, g = .5, b = 0 },
	['ClassColors'] = true,
	['Topleft'] = 6,
	['Topright'] = 2,
	['Bottomleft'] = 5,
	['Bottomright'] = 4,
	['fadeIn'] = 0.2,
	['fadeOut'] = 10,
	['noFade'] = nil,
}

--[[ #############################
	Helper functions
############################## ]]

function eXPeritia:Enter() if(self.fadeInfo) then UIFrameFadeRemoveFrame(self) end self:SetAlpha(1) end
function eXPeritia:Leave() if(not eXPeritia.forceShown) then self:SetAlpha(0) end end

local fadeOut = { mode = "OUT", timeToFade = 10 }
local StartFadingOut = function()
	fadeOut.fadeTimer = 0
	UIFrameFade(eXPeritia, fadeOut)
end
local fadeIn = { mode = "IN", timeToFade = 0.2 }

function eXPeritia:Move(ind, percent)
	ind:ClearAllPoints()
	ind:SetPoint("TOPLEFT", eXPeritiaDB.Width*percent, 0)
end

local function LargeValue(value)
	if(value > 999 or value < -999) then
		return string.format("|cffffffff%.0f|rk", value / 1e3)
	else
		return "|cffffffff"..value.."|r"
	end
end
--[[ #############################
	Options
############################## ]]

function eXPeritia:VARIABLES_LOADED()
	eXPeritiaDB = not useDefaults and eXPeritiaDB or defaults
	defaults = nil
	
	self:ApplyOptions()
	self:ApplyColor()
	self:ApplyDimensions()
	
	self:SetAlpha(eXPeritiaDB.noFade and 1 or 0)
end

function eXPeritia:PLAYER_ENTERING_WORLD()
	self.noFade = true
	self:PLAYER_XP_UPDATE()
	self.noFade = nil
end

function eXPeritia:ApplyColor(db)
	db = db or eXPeritiaDB
	local color = db.ClassColor and classColor or db.Color
	indMain:SetTexture(color.r, color.g, color.b)
	indAlt1:SetTexture(color.r, color.g, color.b)
	indAlt2:SetTexture(color.r, color.g, color.b)
	font:SetTextColor(color.r, color.g, color.b)
end

function eXPeritia:ApplyDimensions(db)
	db = db or eXPeritiaDB
	self:SetWidth(db.Width)
	self:SetHeight(db.Height)
	indMain:SetHeight(db.Height)
	indAlt1:SetHeight(db.Height/3)
	indAlt2:SetHeight(db.Height/3)
end

function eXPeritia:ApplyOptions(db)
	db = db or eXPeritiaDB
	self:SetScript("OnEnter", db.MouseOver and not db.noFade and eXPeritia.Enter or nil)
	self:SetScript("OnLeave", db.MouseOver and not db.noFade and eXPeritia.Leave or nil)
	self:EnableMouse(db.MouseOver and not db.noFade)
	
	fadeIn.timeToFade = db.fadeIn or 0.2
	fadeOut.timeToFade = db.fadeOut or 10
end

--[[ #############################
	Update functions
############################## ]]
local lastXP, lastRep, lastRepName

function eXPeritia:UpdateText(db)
	db = db or eXPeritiaDB
	textTL:SetText(optionValues[db["Topleft"]])
	textTR:SetText(optionValues[db["Topright"]])
	textBL:SetText(optionValues[db["Bottomleft"]])
	textBR:SetText(optionValues[db["Bottomright"]])
end

function eXPeritia:Flash()
	if(self.noFade or eXPeritiaDB.noFade) then return nil end

	if(self:GetAlpha() == 0) then
		fadeIn.fadeTimer = 0
		fadeIn.finishedFunc = StartFadingOut
		UIFrameFade(self, fadeIn)
	end
end

function eXPeritia:PLAYER_XP_UPDATE()
	local min, max, rest = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	self:Move(indMain, min/max)
	if(rest and rest > 0 and (min+rest) <= max) then
		indAlt1:Show()
		self:Move(indAlt1, (min+rest)/max)
	else
		indAlt1:Hide()
	end
	optionValues[6] = (rest and rest > 0 and format("|cffffffff%.0f|r%% rest", rest/max*100)) or ""

	textMain:SetFormattedText("|cffffffff%.1f|r%%", min/max*100)
	optionValues[2] = LargeValue(min-max)
	optionValues[3] = LargeValue(min)
	optionValues[5] = format("|cffffffff%.1f|rbars", min/max*20-20)

	if(lastXP and lastXP ~= min) then
		indAlt2:Show()
		self:Move(indAlt2, lastXP/max)
		optionValues[4] = format("|cffffffff%.0f|rx", (max-min)/(min-lastXP))
	else
		indAlt2:Hide()
	optionValues[4] = ""
	end
	lastXP = min
	
	self:UpdateText()
	
	return self:Flash()
end
eXPeritia.PLAYER_LEVEL_UP = eXPeritia.PLAYER_XP_UPDATE

function eXPeritia:UPDATE_FACTION()
	local name, standing, min, max, value = GetWatchedFactionInfo()
	if(not name) then return nil end
	max, min = (max-min), (value-min)

	if(not lastRep) then
		lastRepName = name
		lastRep = min
		return nil
	end

	if(lastRepName == name and lastRep ~= min) then
		indAlt2:Show()
		self:Move(indAlt2, lastRep/max)
		optionValues[4] = format("|cffffffff%.0f|rx", (max-min)/(min-lastRep))
	elseif(lastRepName ~= name) then
		optionValues[4] = ""
		indAlt2:Hide()
	else
		return nil
	end
	lastRepName = name
	lastRep = min
	
	self:Move(indMain, min/max)
	indAlt1:Hide()

	optionValues[6] = format("|cffffffff%s|r (|cffffffff%s|r)", name, _G['FACTION_STANDING_LABEL'..standing])
	
	textMain:SetFormattedText("|cffffffff%.1f|r%%", min/max*100)
	optionValues[2] = LargeValue(min-max)
	optionValues[3] = LargeValue(min)
	optionValues[5] = format("|cffffffff%.1f|rbars", min/max*20-20)
	
	self:UpdateText()

	return self:Flash()
end

eXPeritia:SetScript("OnEvent", function(self, event, ...) self[event](self, event, ...) end)
eXPeritia:RegisterEvent("PLAYER_XP_UPDATE")
eXPeritia:RegisterEvent('UPDATE_FACTION')
eXPeritia:RegisterEvent("PLAYER_LEVEL_UP")
eXPeritia:RegisterEvent("VARIABLES_LOADED")
eXPeritia:RegisterEvent("PLAYER_ENTERING_WORLD")

SlashCmdList['EXPERITIA'] = function(msg)
	if(msg == "hide" or (msg == "toggle" and eXPeritia:IsShown())) then
		return eXPeritia:SetAlpha(0)
	elseif(msg == "show" or msg == "toggle") then
		return	eXPeritia:SetAlpha(1)
	elseif(msg == "flash") then
		eXPeritia:Flash()
	elseif(eXPeritia.config) then
		InterfaceOptionsFrame_OpenToCategory("eXPeritia")
	end
end
SLASH_EXPERITIA1 = '/exp'
SLASH_EXPERITIA2 = '/experitia'
