if(not eXPeritia or not LibStub) then return nil end

local tempDB

local about = LibStub("tekKonfig-AboutPanel").new(nil, "eXPeritia")

local appearance = CreateFrame("Frame", nil, UIParent)
appearance.name = "Appearance"
appearance.parent = "eXPeritia"
InterfaceOptions_AddCategory(appearance)

local settings = CreateFrame("Frame", nil, UIParent)
settings.name = "Settings"
settings.parent = "eXPeritia"
InterfaceOptions_AddCategory(settings)

eXPeritia:SetScript("OnDragStart", eXPeritia.StartMoving)
eXPeritia:SetScript("OnDragStop", eXPeritia.StopMovingOrSizing)
 
appearance:SetScript("OnShow", function(self)
	if(not InterfaceOptionsFrame:IsShown()) then return nil end

	local info = {notCheckable = true}
	local optionTypes = {
		"None",
		"Missing",
		"Gained",
		"Gains to next level",
		"Needed Blizz bars",
		"Rested / Faction",
	}
	local function UpdateWidthHeight(self)
		tempDB.Height = appearance.height:GetValue()
		tempDB.Width = appearance.width:GetValue()
		eXPeritia:ApplyDimensions(tempDB)
		self.val:SetFormattedText("%.0f", self:GetValue())
	end
	
	local function UpdateTextValue(dropdown, self, option)
		self.text:SetText(optionTypes[option])
		tempDB[self.label] = option
		eXPeritia:UpdateText(tempDB)
	end
	
	local function AddButton(frame, text, option)
		info.text = text
		info.arg1 = frame
		info.arg2 = option
		info.func = UpdateTextValue
		UIDropDownMenu_AddButton(info)
	end
	local function CreateDropdown(frameType)
		local dropdown, text = LibStub("tekKonfig-Dropdown").new(self, frameType.." text")
		dropdown.text = text
		dropdown.label = frameType
		UIDropDownMenu_Initialize(dropdown, function()
			for i, text in pairs(optionTypes) do
				AddButton(dropdown, optionTypes[i], i)
			end
		end)
		return dropdown
	end
 
	local title, subtitle = LibStub("tekKonfig-Heading").new(self, "eXPeritia - Appearance", "Configure texts, size and colors of eXPeritia.")
 
	local width, _, cont = LibStub("tekKonfig-Slider").new(self, "Width", 100, 2000, "TOPLEFT", subtitle, "BOTTOMLEFT", 0, -10)
	width.val = width:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	width.val:SetPoint("TOP", width, "BOTTOM", 0, 3)
	width:SetScript("OnValueChanged", UpdateWidthHeight)
	cont:SetWidth(300)
	self.width = width
 
	local height, _, cont = LibStub("tekKonfig-Slider").new(self, "Height", 5, 100, "TOPLEFT", width, "BOTTOMLEFT", 0, -20)
	height.val = height:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	height.val:SetPoint("TOP", height, "BOTTOM", 0, 3)
	height:SetScript("OnValueChanged", UpdateWidthHeight)
	cont:SetWidth(300)
	self.height = height
 
	local color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
	color = format("|cff%02x%02x%02x", color.r*255, color.g*255, color.b*255)
 
	local classcolor = LibStub("tekKonfig-Checkbox").new(self, 26, color.."Class|r colored", "TOPLEFT", height, "BOTTOMLEFT", 0, -40)
	classcolor:SetScript("OnClick", function(self)
		tempDB.ClassColor = self:GetChecked()
		eXPeritia:ApplyColor(tempDB)
	end)
	self.classColor = classcolor

	self.topleft = CreateDropdown("Topleft")
	self.topleft:SetPoint("TOPLEFT", classcolor, "BOTTOMLEFT", 0, -40)
	self.topright = CreateDropdown("Topright")
	self.topright:SetPoint("TOPLEFT", self.topleft, "TOPRIGHT", 10, 0)
	self.bottomleft = CreateDropdown("Bottomleft")
	self.bottomleft:SetPoint("TOP", self.topleft, "BOTTOM", 0, -20)
	self.bottomright = CreateDropdown("Bottomright")
	self.bottomright:SetPoint("TOPLEFT", self.bottomleft, "TOPRIGHT", 10, 0)
	
	self.okay = function()
		if(tempDB) then
			eXPeritiaDB = tempDB
			tempDB = nil
		end
	end
	
	self.cancel = function() tempDB = nil end
 
	local function OnShow(self)
		tempDB = {}
		for k,v in pairs(eXPeritiaDB) do tempDB[k] = v end

		self.classColor:SetChecked(eXPeritiaDB.ClassColor)
		self.width:SetValue(eXPeritiaDB.Width)
		self.height:SetValue(eXPeritiaDB.Height)
		
		self.topleft.text:SetText(optionTypes[eXPeritiaDB['Topleft']])
		self.topright.text:SetText(optionTypes[eXPeritiaDB['Topright']])
		self.bottomleft.text:SetText(optionTypes[eXPeritiaDB['Bottomleft']])
		self.bottomright.text:SetText(optionTypes[eXPeritiaDB['Bottomright']])
		
		eXPeritia:ApplyOptions()
		eXPeritia:ApplyDimensions()
		eXPeritia:ApplyColor()
		eXPeritia:UpdateText()
		
		eXPeritia:Enter()
		eXPeritia:EnableMouse(true)
		eXPeritia:RegisterForDrag("LeftButton", "RightButton")
		eXPeritia.noFade = true
	end
	self:SetScript("OnShow", OnShow)
	self:SetScript("OnHide", function(self)
		if(not eXPeritiaDB.noFade) then eXPeritia:SetAlpha(0) end
		eXPeritia:ApplyOptions()
		eXPeritia:ApplyDimensions()
		eXPeritia:ApplyColor()
		eXPeritia:UpdateText()
		eXPeritia:RegisterForDrag(nil)
		eXPeritia.noFade = nil
	end)

	OnShow(self)
end)

settings:SetScript("OnShow", function(self)
	if(not InterfaceOptionsFrame:IsShown()) then return nil end

	local function UpdateSliderValue(self) self.val:SetFormattedText("%.1f", self:GetValue()) end
 
	local title, subtitle = LibStub("tekKonfig-Heading").new(self, "eXPeritia - Settings", "Allows you to configure when to show or hide eXPeritia")
	
	local mouseover = LibStub("tekKonfig-Checkbox").new(self, 26, "Show on mouseover", "TOPLEFT", subtitle, "BOTTOMLEFT", -10)
	
	local noFade = LibStub("tekKonfig-Checkbox").new(self, 26, "Always visible", "TOPLEFT", mouseover, "BOTTOMLEFT")
	
	local fadeIn, _, cont = LibStub("tekKonfig-Slider").new(self, "Seconds to fade in", 0, 60, "TOPLEFT", mouseover, "BOTTOMLEFT", 0, -60)
	fadeIn.val = fadeIn:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	fadeIn.val:SetPoint("TOP", fadeIn, "BOTTOM", 0, 3)
	cont:SetWidth(300)
	fadeIn:SetScript("OnValueChanged", UpdateSliderValue)
	
	local fadeOut, _, cont = LibStub("tekKonfig-Slider").new(self, "Seconds to fade out", 0, 60, "TOP", fadeIn, "BOTTOM", 0, -20)
	fadeOut.val = fadeOut:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	fadeOut.val:SetPoint("TOP", fadeOut, "BOTTOM", 0, 3)
	cont:SetWidth(300)
	fadeOut:SetScript("OnValueChanged", UpdateSliderValue)
	
	self.okay = function()
		eXPeritiaDB.MouseOver = mouseover:GetChecked()
		eXPeritiaDB.noFade = noFade:GetChecked()
		eXPeritiaDB.fadeIn = fadeIn:GetValue()
		eXPeritiaDB.fadeOut = fadeOut:GetValue()
	end
 
	local function OnShow(self)
		mouseover:SetChecked(eXPeritiaDB.MouseOver)
		noFade:SetChecked(eXPeritiaDB.noFade)
		fadeIn:SetValue(eXPeritiaDB.fadeIn or 0.2)
		fadeOut:SetValue(eXPeritiaDB.fadeOut or 10)
		
		eXPeritia:ApplyOptions()
		eXPeritia:ApplyDimensions()
		eXPeritia:ApplyColor()
		eXPeritia:UpdateText()
		
		eXPeritia:Enter()
		eXPeritia:EnableMouse(true)
		eXPeritia:RegisterForDrag("LeftButton", "RightButton")
		eXPeritia.noFade = true
	end
	self:SetScript("OnShow", OnShow)
	self:SetScript("OnHide", function(self)
		if(not eXPeritiaDB.noFade) then eXPeritia:SetAlpha(0) end
		eXPeritia:ApplyOptions()
		eXPeritia:ApplyDimensions()
		eXPeritia:ApplyColor()
		eXPeritia:UpdateText()
		eXPeritia:RegisterForDrag(nil)
		eXPeritia.noFade = nil
	end)
 
	OnShow(self)
end)

eXPeritia.config = true
