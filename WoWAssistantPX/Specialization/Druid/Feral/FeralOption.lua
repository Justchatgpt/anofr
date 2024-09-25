--界面
local FeralOptionSavesFrame = CreateFrame("Frame")


FeralSwitchStatus = CreateFrame("Frame", "FeralSwitchStatus", UIParent)
FeralSwitchStatus:SetWidth(20)
FeralSwitchStatus:SetHeight(20)
FeralSwitchStatus:SetPoint("BOTTOM", -1, 240)
FeralSwitchStatus:SetFrameStrata("MEDIUM")
FeralSwitchStatus:CreateFontString("FeralSwitchStatusText", "ARTWORK", "GameFontHighlight")
FeralSwitchStatusText:SetFont(STANDARD_TEXT_FONT, 100)
FeralSwitchStatusText:SetPoint("CENTER", 0, 0)
FeralSwitchStatusText:SetTextColor(1, 0, 0)
FeralSwitchStatusText:SetText(".")
FeralSwitchStatusText:Hide()


Feral_DeBug = Feral_DeBug or CreateFrame("Frame", "Feral_DeBug", UIParent)
Feral_DeBug:SetWidth(30)
Feral_DeBug:SetHeight(30)
Feral_DeBug:SetPoint("CENTER", 0, -100)
Feral_DeBug:SetFrameStrata("MEDIUM")

Feral_DeBugSpellIcon = CreateFrame("Frame", "Feral_DeBugSpellIcon", Feral_DeBug)
Feral_DeBugSpellIcon:SetPoint("CENTER", Feral_DeBug, "CENTER", 0, 0)
Feral_DeBugSpellIcon:SetSize(30, 30)
Feral_DeBugSpellIcon.Texture = Feral_DeBugSpellIcon:CreateTexture(nil, "BORDER")
Feral_DeBugSpellIcon.Texture:SetAllPoints(true)
Feral_DeBugSpellIcon.Texture:SetAlpha(0.75)

Feral_DeBugEnemyCount = Feral_DeBugSpellIcon:CreateFontString("Feral_DeBugEnemyCount", "ARTWORK", "GameFontHighlight")
Feral_DeBugEnemyCount:SetFont(STANDARD_TEXT_FONT, 20)
Feral_DeBugEnemyCount:SetPoint("CENTER", Feral_DeBugSpellIcon, "CENTER", 0, 0)
Feral_DeBugEnemyCount:SetTextColor(1, 1, 1)
Feral_DeBugEnemyCount:Hide()

function FeralOptionSavesFrame:GetDefault()
	return {
		FeralOption_Attack_AutoBerserk = true, 
		FeralOption_Attack_AutoAccessories = true, 
		FeralOption_Attack_AutoCovenant = true, 
		FeralOption_Attack_AutoIronbark = true, 
		FeralOption_TargetFilter = 2, 
		FeralOption_Auras_ClearCurse = true, 
		FeralOption_Auras_ClearPoison = true, 
		FeralOption_Auras_ClearMouseover = false, 
		FeralOption_Auras_ClearEnrage = false, 
		FeralOption_Other_ShowDebug = true, 
		FeralOption_Other_AutoRebirth = false, 
		FeralOption_Auras_AutoInterrupt = false, 
		FeralOption_Other_ClearRoot = true, 
		TraversalObjectInterval = 0.5,
		FeralOption_XSVV = DA_GetAddOnMetadata("WoWAssistantPX", "X-SVV"), 
	}
end
FeralSaves = FeralOptionSavesFrame:GetDefault()

local _G = getfenv(0)

local FeralOption = CreateFrame("Frame", "FeralOption", UIParent, "BackdropTemplate")
FeralOption:Hide()
tinsert(UISpecialFrames, "FeralOption")


Text_Feral_Option_Reset_StaticPopup_text = "确定重置设置?"
Text_Feral_Clear_Cache_StaticPopup_button1 = "确定"
Text_Feral_Clear_Cache_StaticPopup_button2 = "取消"
FeralOption.locStr = {
	["FeralOption_Reset"] = "重置", 
	["FeralOptions"] = "魔兽小助手PX v"..DA_GetAddOnMetadata("WoWAssistantPX","Version"), 
	["FeralOption_Attack"] = "输出设置:", 
	["FeralOption_Attack_AutoBerserk"] = "使用狂暴化身", 
	["FeralOption_Attack_AutoAccessories"] = "使用饰品", 
	["FeralOption_Attack_AutoCovenant"] = "使用万灵", 
	["FeralOption_Attack_AutoIronbark"] = "开启保命", 
	["FeralOption_Auras"] = "状态设置:", 
	["FeralOption_Auras_ClearCurse"] = "驱散诅咒", 
	["FeralOption_Auras_ClearPoison"] = "驱散中毒", 
	["FeralOption_Auras_ClearMouseover"] = "强驱鼠标指向", 
	["FeralOption_Auras_ClearEnrage"] = "解除激怒", 
	["FeralOption_TargetFilter"] = "目标设置:", 
	["FeralOption_TraversalObjectInterval"] = "扫描目标间隔:", 
	["FeralOption_TraversalObjectIntervalSecond"] = "秒", 
	["FeralOption_Other"] = "其他设置:", 
	["FeralOption_Other_ShowDebug"] = "显示状态", 
	["FeralOption_Other_AutoRebirth"] = "使用战复", 
	["FeralOption_Auras_AutoInterrupt"] = "开启打断", 
	["FeralOption_Other_ClearRoot"] = "解除定身", 
}


function FeralOption:Init()
	-- 尺寸
	self:SetWidth(495); self:SetHeight(180);
	self:SetPoint("CENTER", 0, 0)
	self:SetFrameStrata("MEDIUM")
	self:SetToplevel(true)
	self:SetMovable(true)
	self:SetClampedToScreen(true)
	self:SetAlpha(0.85)

	-- 背景
	self:SetBackdrop( {
	  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
	  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", tile = true, tileSize = 16, edgeSize = 16, 
	  insets = { left = 5, right = 5, top = 5, bottom = 5 }
	});
	self:SetBackdropColor(0, 0, 0)

	-- 拖动
	self:EnableMouse(true)
	self:RegisterForDrag("LeftButton")
	self:SetScript("OnDragStart", function(self) self:StartMoving() end)
	self:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)

	-- 标题
	self:CreateFontString("FeralOptionTitle", "ARTWORK", "GameFontHighlight")
	FeralOptionTitle:SetPoint("TOPLEFT", 10, -10)
	FeralOptionTitle:SetTextColor(0, 1, 0)
	FeralOptionTitle:SetText(self.locStr["FeralOptions"])

	-- 按钮
	FeralOption:InitButtons()
	
	-- 输出设置Title
	self:CreateFontString("FeralOptionDpsFrameTitle", "ARTWORK", "GameFontHighlight")
	FeralOptionDpsFrameTitle:SetPoint("TOPLEFT", 15, -40)
	FeralOptionDpsFrameTitle:SetText(self.locStr["FeralOption_Attack"])

	-- 状态设置Title
	self:CreateFontString("FeralOptionAurasTitle", "ARTWORK", "GameFontHighlight")
	FeralOptionAurasTitle:SetPoint("TOPLEFT", 130, -40)
	FeralOptionAurasTitle:SetText(self.locStr["FeralOption_Auras"])

	-- 目标设置Title
	self:CreateFontString("FeralOptionTargetFilterTitle", "ARTWORK", "GameFontHighlight")
	FeralOptionTargetFilterTitle:SetPoint("TOPLEFT", 240, -40)
	FeralOptionTargetFilterTitle:SetText(self.locStr["FeralOption_TargetFilter"])

	-- 扫描目标间隔
	self:CreateFontString("FeralOptionTraversalObjectIntervalTitle", "ARTWORK", "GameFontHighlight")
	FeralOptionTraversalObjectIntervalTitle:SetPoint("TOPLEFT", 240, -120)
	FeralOptionTraversalObjectIntervalTitle:SetText(self.locStr["FeralOption_TraversalObjectInterval"])

	-- 其它设置Title
	self:CreateFontString("FeralOptionOtherTitle", "ARTWORK", "GameFontHighlight")
	FeralOptionOtherTitle:SetPoint("TOPLEFT", 370, -40)
	FeralOptionOtherTitle:SetText(self.locStr["FeralOption_Other"])

	-- 读取选项
	FeralOption:LoadOptions()

	StaticPopupDialogs["Feral_OPTION_RESET"] = {
		text = Text_Feral_Option_Reset_StaticPopup_text, 
		button1 = Text_Feral_Clear_Cache_StaticPopup_button1, 
		button2 = Text_Feral_Clear_Cache_StaticPopup_button2, 
		timeout = 0, 
		whileDead = 1, 
		hideOnEscape = 1, 
		multiple = 1, 
	}
	-- 完成
	self.ready = 1
end

function FeralOption:InitButtons()
	if not FeralOptionFeralOptionTargetFilter then
		CreateFrame("Button", "FeralOptionFeralOptionTargetFilter", FeralOption, "UIDropDownMenuTemplate")
	end
	FeralOptionFeralOptionTargetFilter:ClearAllPoints()
	FeralOptionFeralOptionTargetFilter:SetPoint("TOPLEFT", FeralOption, "TOPLEFT", 220, -65)
	FeralOptionFeralOptionTargetFilterItems = {
		"智能选择", 
		"手动选择", 
		"所有目标", 
	}
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, self:GetID())
		if self:GetID() == 1 then
			FeralSaves.FeralOption_TargetFilter = 1
		elseif self:GetID() == 2 then
			FeralSaves.FeralOption_TargetFilter = 2
		elseif self:GetID() == 3 then
			FeralSaves.FeralOption_TargetFilter = 3
		end
	end
	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in pairs(FeralOptionFeralOptionTargetFilterItems) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(FeralOptionFeralOptionTargetFilter, initialize)
	UIDropDownMenu_SetWidth(FeralOptionFeralOptionTargetFilter, 90);
	UIDropDownMenu_SetButtonWidth(FeralOptionFeralOptionTargetFilter, 89)
	UIDropDownMenu_JustifyText(FeralOptionFeralOptionTargetFilter, "CENTER")
	-- 下拉菜单
	
	self.Buttons = {
		-- 关闭 Butons
		{name="Close", type="Button", inherits="UIPanelCloseButton", 
			point="TOPRIGHT", func = function() FeralOption:Hide() end, }, 
		{name="Reset", type="Button", inherits="UIPanelButtonTemplate", 
			width=70, height=20, text = self.locStr["FeralOption_Reset"], 
			point="TOPRIGHT", x=-28, y=-6, func = FeralOption.Reset}, 
	
		-- 输出设置 Buttons
		{name="FeralOption_Attack_AutoBerserk", type="CheckButton", var="FeralOption_Attack_AutoBerserk", width=25, height=25, 
			point="TOPLEFT", x=10, y=-65}, 
		{name="FeralOption_Attack_AutoAccessories", type="CheckButton", var="FeralOption_Attack_AutoAccessories", width=25, height=25, 
			point="TOP", relative="FeralOption_Attack_AutoBerserk", rpoint="BOTTOM", }, 
		{name="FeralOption_Attack_AutoCovenant", type="CheckButton", var="FeralOption_Attack_AutoCovenant", width=25, height=25, 
			point="TOP", relative="FeralOption_Attack_AutoAccessories", rpoint="BOTTOM", }, 
		{name="FeralOption_Attack_AutoIronbark", type="CheckButton", var="FeralOption_Attack_AutoIronbark", width=25, height=25, 
			point="TOP", relative="FeralOption_Attack_AutoCovenant", rpoint="BOTTOM", }, 
			
		-- 状态设置 Buttons
		{name="FeralOption_Auras_ClearCurse", type="CheckButton", var="FeralOption_Auras_ClearCurse", width=25, height=25, 
			point="TOPLEFT", x=125, y=-65}, 
		{name="FeralOption_Auras_ClearPoison", type="CheckButton", var="FeralOption_Auras_ClearPoison", width=25, height=25, 
			point="TOP", relative="FeralOption_Auras_ClearCurse", rpoint="BOTTOM", }, 
		{name="FeralOption_Auras_ClearMouseover", type="CheckButton", var="FeralOption_Auras_ClearMouseover", width=25, height=25, 
			point="TOP", relative="FeralOption_Auras_ClearPoison", rpoint="BOTTOM", }, 
		{name="FeralOption_Auras_ClearEnrage", type="CheckButton", var="FeralOption_Auras_ClearEnrage", width=25, height=25, 
			point="TOP", relative="FeralOption_Auras_ClearMouseover", rpoint="BOTTOM", }, 
			
		{name="FeralOption_TraversalObjectIntervalSecond", type="EditBox", width=40, height=20, var="TraversalObjectInterval", 
			point="TOPLEFT", x=245, y=-140}, 
			
		-- 其它设置 Buttons
		{name="FeralOption_Other_ShowDebug", type="CheckButton", var="FeralOption_Other_ShowDebug", width=25, height=25, 
			point="TOPLEFT", x=365, y=-65}, 
		{name="FeralOption_Other_AutoRebirth", type="CheckButton", var="FeralOption_Other_AutoRebirth", width=25, height=25, 
			point="TOP", relative="FeralOption_Other_ShowDebug", rpoint="BOTTOM", }, 
		{name="FeralOption_Auras_AutoInterrupt", type="CheckButton", var="FeralOption_Auras_AutoInterrupt", width=25, height=25, 
			point="TOP", relative="FeralOption_Other_AutoRebirth", rpoint="BOTTOM", }, 
		{name="FeralOption_Other_ClearRoot", type="CheckButton", var="FeralOption_Other_ClearRoot", width=25, height=25, 
			point="TOP", relative="FeralOption_Auras_AutoInterrupt", rpoint="BOTTOM", }, 
	}

	local button, text, name, value
	for key, value in ipairs(FeralOption.Buttons) do
		-- pre settings
		if value.type == "CheckButton" then
			value.inherits = "UICheckButtonTemplate"
		elseif value.type == "EditBox" then
			value.inherits = "InputBoxTemplate"
		end

		-- creations
		button = CreateFrame(value.type, "FeralOption"..value.name, FeralOption, value.inherits)

		if value.type == "CheckButton" then
			text = button:CreateFontString(button:GetName().."Text", "ARTWORK", "GameFontNormal")
			text:SetPoint("LEFT", button, "RIGHT")
			button:SetFontString(text)
		elseif value.type == "EditBox" then
			text = button:CreateFontString(button:GetName().."Text", "ARTWORK", "GameFontNormal")
			text:SetPoint("LEFT", button, "RIGHT", 5, 0)
			button.text = text
		end

		-- setup
		button:SetID(key)
		if value.width then
			button:SetWidth(value.width)
		end
		if value.height then
			button:SetHeight(value.height)
		end
		if value.point then
			if value.relative then
				value.relative = "FeralOption"..value.relative
			end
			button:SetPoint(value.point, value.relative or FeralOption, value.rpoint or value.point, value.x or 0, value.y or 0)
		end
		if value.text then
			if button.text then
				button.text:SetText(value.text)
			else
				button:SetText(value.text)
			end
		end

		-- post settings
		if value.type == "Button" then
			if value.text then button:SetText(value.text) end
			if value.func then button:SetScript("OnClick", value.func) end
		elseif value.type == "CheckButton" then
			if not value.text then button:SetText(self.locStr[value.name]) end
			if value.func then
				button:SetScript("OnClick", value.func)
			else
				button:SetScript("OnClick", FeralOption.OnCheckButtonClicked)
			end
		elseif value.type == "EditBox" then
			button:SetAutoFocus(false)
			if not value.text then button.text:SetText(self.locStr[value.name]) end
			if value.func then
				button:SetScript("OnEnterPressed", value.func)
			else
				button:SetScript("OnEnterPressed", FeralOption.OnEditBoxEnterPressed)
				button:SetScript("OnTextChanged", FeralOption.OnEditBoxTextChanged)
			end
			button:SetScript("OnEscapePressed", button.ClearFocus)
		end
	end
end

local value, isChecked

function FeralOption:Reset()
	StaticPopupDialogs["Feral_OPTION_RESET"].OnAccept = function()
		FeralSaves = FeralOptionSavesFrame:GetDefault()
		FeralOption:LoadOptions()
	end
	StaticPopup_Show("Feral_OPTION_RESET")
end

function FeralOption:OnCheckButtonClicked()
	isChecked = self:GetChecked()
	if isChecked then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
	value = FeralOption.Buttons[self:GetID()]
	if value.var then
		if isChecked then
			FeralSaves[value.var] = true
		else
			FeralSaves[value.var] = false
		end
	end
end

function FeralOption:OnEditBoxEnterPressed()
	local num = self:GetText()
	if not num then return end
	--num = tonumber(num)
	if not num then return end
	value = FeralOption.Buttons[self:GetID()]
	FeralSaves[value.var] = num
	self:ClearFocus()
end

function FeralOption:OnEditBoxTextChanged()
	local num = self:GetText()
	if not num then return end
	--num = tonumber(num)
	if not num then return end
	value = FeralOption.Buttons[self:GetID()]
	FeralSaves[value.var] = num
end

function FeralOption:LoadOptions()
	local button
	for key, value in ipairs(FeralOption.Buttons) do
		button = _G["FeralOption"..value.name]
		if value.type == "CheckButton" then
			if value.var then
				button:SetChecked(FeralSaves[value.var])
			end
		elseif value.type == "EditBox" then
			if not FeralSaves[value.var] then
				FeralSaves.TraversalObjectInterval = ""
			end
			button:SetText(FeralSaves[value.var])
		end
	end
	UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, FeralSaves.FeralOption_TargetFilter)
	FeralOptionFeralOptionTargetFilterText:SetText(FeralOptionFeralOptionTargetFilterItems[FeralSaves.FeralOption_TargetFilter])
end

FeralOption:RegisterEvent("PLAYER_LOGIN")
FeralOption:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
FeralOption:SetScript("OnEvent", function(self, event)
	if not FeralSaves.FeralOption_XSVV or FeralSaves.FeralOption_XSVV ~= DA_GetAddOnMetadata("WoWAssistantPX", "X-SVV") then --插件更新后自动重置为默认设置
		FeralSaves = FeralOptionSavesFrame:GetDefault()
	end
	
	if DA_GetSpecialization() ~= 103 or FeralNoteShowIng then return end
	
	WoWAssistantNoteDate = WoWAssistantNoteDate or time()
	if time() - WoWAssistantNoteDate > 86400 or time() - WoWAssistantNoteDate == 0 then --每24小时提示一次使用说明
		FeralNoteShowIng = 1
		C_Timer.After(7.5, function()
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."使用说明: ")
			if GetBindingKey("WoWAssistant_Config") then
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."打开设置菜单: "..GetBindingKey("WoWAssistant_Config"))
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."打开设置菜单: 无")
			end
			if GetBindingKey("WoWAssistant_Start") then
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."启动: "..GetBindingKey("WoWAssistant_Start"))
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."启动: 无")
			end
			if GetBindingKey("WoWAssistant_Stop") then
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."停止: "..GetBindingKey("WoWAssistant_Stop"))
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."停止: 无")
			end
			if GetBindingKey("WoWAssistant_Replace") then
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."切换目标设置: "..GetBindingKey("WoWAssistant_Replace"))
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."切换目标设置: 无")
			end
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."提示: 按键可在按键设置中自行更改")
			FeralNoteShowIng = nil
		end)
		WoWAssistantNoteDate = time()
	end
end)