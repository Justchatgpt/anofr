--界面
local BalanceSavesFrame = CreateFrame("Frame")


BalanceSwitchStatus = CreateFrame("Frame", "BalanceSwitchStatus", UIParent)
BalanceSwitchStatus:SetWidth(20)
BalanceSwitchStatus:SetHeight(20)
BalanceSwitchStatus:SetPoint("BOTTOM", -1, 240)
BalanceSwitchStatus:SetFrameStrata("MEDIUM")
BalanceSwitchStatus:CreateFontString("BalanceSwitchStatusText", "ARTWORK", "GameFontHighlight")
BalanceSwitchStatusText:SetFont(STANDARD_TEXT_FONT, 100)
BalanceSwitchStatusText:SetPoint("CENTER", 0, 0)
BalanceSwitchStatusText:SetTextColor(1, 0, 0)
BalanceSwitchStatusText:SetText(".")
BalanceSwitchStatusText:Hide()


Balance_DeBug = Balance_DeBug or CreateFrame("Frame", "Balance_DeBug", UIParent)
Balance_DeBug:SetWidth(30)
Balance_DeBug:SetHeight(30)
Balance_DeBug:SetPoint("CENTER", 0, -100)
Balance_DeBug:SetFrameStrata("MEDIUM")

Balance_DeBugSpellIcon = CreateFrame("Frame", "Balance_DeBugSpellIcon", Balance_DeBug)
Balance_DeBugSpellIcon:SetPoint("CENTER", Balance_DeBug, "CENTER", 0, 0)
Balance_DeBugSpellIcon:SetSize(30, 30)
Balance_DeBugSpellIcon.Texture = Balance_DeBugSpellIcon:CreateTexture(nil, "BORDER")
Balance_DeBugSpellIcon.Texture:SetAllPoints(true)
Balance_DeBugSpellIcon.Texture:SetAlpha(0.75)

Balance_DeBugEnemyCount = Balance_DeBugSpellIcon:CreateFontString("Balance_DeBugEnemyCount", "ARTWORK", "GameFontHighlight")
Balance_DeBugEnemyCount:SetFont(STANDARD_TEXT_FONT, 20)
Balance_DeBugEnemyCount:SetPoint("CENTER", Balance_DeBugSpellIcon, "CENTER", 0, 0)
Balance_DeBugEnemyCount:SetTextColor(1, 1, 1)
Balance_DeBugEnemyCount:Hide()

function BalanceSavesFrame:GetDefault()
	return {
		BalanceOption_Attack_AutoCelestialAlignment = true, 
		BalanceOption_Attack_AutoAccessories = true, 
		BalanceOption_Attack_AutoCovenant = true, 
		BalanceOption_Attack_AutoIronbark = true, 
		BalanceOption_Auras_ClearCurse = true, 
		BalanceOption_Auras_ClearPoison = true, 
		BalanceOption_Auras_ClearMouseover = false, 
		BalanceOption_Auras_ClearEnrage = false, 
		BalanceOption_TargetFilter = 2, 
		BalanceOption_Other_ShowDebug = true, 
		BalanceOption_Other_AutoRebirth = false, 
		BalanceOption_Auras_AutoInterrupt = false, 
		BalanceOption_Other_ClearRoot = true, 
		TraversalObjectInterval = 0.5,
		BalanceOption_XSVV = DA_GetAddOnMetadata("WoWAssistantPX", "X-SVV"), 
	}
end
BalanceSaves = BalanceSavesFrame:GetDefault()

local _G = getfenv(0)

local BalanceOption = CreateFrame("Frame", "BalanceOption", UIParent, "BackdropTemplate")
BalanceOption:Hide()
tinsert(UISpecialFrames, "BalanceOption")


Text_Balance_Option_Reset_StaticPopup_text = "确定重置设置?"
Text_Balance_Clear_Cache_StaticPopup_button1 = "确定"
Text_Balance_Clear_Cache_StaticPopup_button2 = "取消"
BalanceOption.locStr = {
	["BalanceOption_Reset"] = "重置", 
	["BalanceOptions"] = "魔兽小助手 v"..DA_GetAddOnMetadata("WoWAssistantPX","Version"), 
	["BalanceOption_Attack"] = "输出设置:", 
	["BalanceOption_Attack_AutoCelestialAlignment"] = "使用超凡化身", 
	["BalanceOption_Attack_AutoAccessories"] = "使用饰品", 
	["BalanceOption_Attack_AutoCovenant"] = "使用万灵", 
	["BalanceOption_Attack_AutoIronbark"] = "开启保命", 
	["BalanceOption_Auras"] = "状态设置:", 
	["BalanceOption_Auras_ClearCurse"] = "驱散诅咒", 
	["BalanceOption_Auras_ClearPoison"] = "驱散中毒", 
	["BalanceOption_Auras_ClearMouseover"] = "强驱鼠标指向", 
	["BalanceOption_Auras_ClearEnrage"] = "解除激怒", 
	["BalanceOption_TargetFilter"] = "目标设置:", 
	["BalanceOption_TraversalObjectInterval"] = "扫描目标间隔:", 
	["BalanceOption_TraversalObjectIntervalSecond"] = "秒", 
	["BalanceOption_Other"] = "其他设置:", 
	["BalanceOption_Other_ShowDebug"] = "显示状态", 
	["BalanceOption_Other_AutoRebirth"] = "使用战复", 
	["BalanceOption_Auras_AutoInterrupt"] = "开启打断", 
	["BalanceOption_Other_ClearRoot"] = "解除定身", 
}


function BalanceOption:Init()
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
	self:CreateFontString("BalanceOptionTitle", "ARTWORK", "GameFontHighlight")
	BalanceOptionTitle:SetPoint("TOPLEFT", 10, -10)
	BalanceOptionTitle:SetTextColor(0, 1, 0)
	BalanceOptionTitle:SetText(self.locStr["BalanceOptions"])

	-- 按钮
	BalanceOption:InitButtons()
	
	-- 输出设置Title
	self:CreateFontString("BalanceOptionDpsFrameTitle", "ARTWORK", "GameFontHighlight")
	BalanceOptionDpsFrameTitle:SetPoint("TOPLEFT", 15, -40)
	BalanceOptionDpsFrameTitle:SetText(self.locStr["BalanceOption_Attack"])

	-- 状态设置Title
	self:CreateFontString("BalanceOptionAurasTitle", "ARTWORK", "GameFontHighlight")
	BalanceOptionAurasTitle:SetPoint("TOPLEFT", 130, -40)
	BalanceOptionAurasTitle:SetText(self.locStr["BalanceOption_Auras"])

	-- 目标设置Title
	self:CreateFontString("BalanceOptionTargetFilterTitle", "ARTWORK", "GameFontHighlight")
	BalanceOptionTargetFilterTitle:SetPoint("TOPLEFT", 240, -40)
	BalanceOptionTargetFilterTitle:SetText(self.locStr["BalanceOption_TargetFilter"])

	-- 扫描目标间隔
	self:CreateFontString("BalanceOptionTraversalObjectIntervalTitle", "ARTWORK", "GameFontHighlight")
	BalanceOptionTraversalObjectIntervalTitle:SetPoint("TOPLEFT", 240, -120)
	BalanceOptionTraversalObjectIntervalTitle:SetText(self.locStr["BalanceOption_TraversalObjectInterval"])

	-- 其它设置Title
	self:CreateFontString("BalanceOptionOtherTitle", "ARTWORK", "GameFontHighlight")
	BalanceOptionOtherTitle:SetPoint("TOPLEFT", 370, -40)
	BalanceOptionOtherTitle:SetText(self.locStr["BalanceOption_Other"])

	-- 读取选项
	BalanceOption:LoadOptions()

	StaticPopupDialogs["Balance_OPTION_RESET"] = {
		text = Text_Balance_Option_Reset_StaticPopup_text, 
		button1 = Text_Balance_Clear_Cache_StaticPopup_button1, 
		button2 = Text_Balance_Clear_Cache_StaticPopup_button2, 
		timeout = 0, 
		whileDead = 1, 
		hideOnEscape = 1, 
		multiple = 1, 
	}
	-- 完成
	self.ready = 1
end

function BalanceOption:InitButtons()
	if not BalanceOptionBalanceOptionTargetFilter then
		CreateFrame("Button", "BalanceOptionBalanceOptionTargetFilter", BalanceOption, "UIDropDownMenuTemplate")
	end
	BalanceOptionBalanceOptionTargetFilter:ClearAllPoints()
	BalanceOptionBalanceOptionTargetFilter:SetPoint("TOPLEFT", BalanceOption, "TOPLEFT", 220, -65)
	BalanceOptionBalanceOptionTargetFilterItems = {
		"智能选择", 
		"手动选择", 
		"所有目标", 
	}
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, self:GetID())
		if self:GetID() == 1 then
			BalanceSaves.BalanceOption_TargetFilter = 1
		elseif self:GetID() == 2 then
			BalanceSaves.BalanceOption_TargetFilter = 2
		elseif self:GetID() == 3 then
			BalanceSaves.BalanceOption_TargetFilter = 3
		end
	end
	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in pairs(BalanceOptionBalanceOptionTargetFilterItems) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(BalanceOptionBalanceOptionTargetFilter, initialize)
	UIDropDownMenu_SetWidth(BalanceOptionBalanceOptionTargetFilter, 90);
	UIDropDownMenu_SetButtonWidth(BalanceOptionBalanceOptionTargetFilter, 89)
	UIDropDownMenu_JustifyText(BalanceOptionBalanceOptionTargetFilter, "CENTER")
	-- 下拉菜单
	
	self.Buttons = {
		-- 关闭 Butons
		{name="Close", type="Button", inherits="UIPanelCloseButton", 
			point="TOPRIGHT", func = function() BalanceOption:Hide() end, }, 
		{name="Reset", type="Button", inherits="UIPanelButtonTemplate", 
			width=70, height=20, text = self.locStr["BalanceOption_Reset"], 
			point="TOPRIGHT", x=-28, y=-6, func = BalanceOption.Reset}, 
	
		-- 输出设置 Buttons
		{name="BalanceOption_Attack_AutoCelestialAlignment", type="CheckButton", var="BalanceOption_Attack_AutoCelestialAlignment", width=25, height=25, 
			point="TOPLEFT", x=10, y=-65}, 
		{name="BalanceOption_Attack_AutoAccessories", type="CheckButton", var="BalanceOption_Attack_AutoAccessories", width=25, height=25, 
			point="TOP", relative="BalanceOption_Attack_AutoCelestialAlignment", rpoint="BOTTOM", }, 
		{name="BalanceOption_Attack_AutoCovenant", type="CheckButton", var="BalanceOption_Attack_AutoCovenant", width=25, height=25, 
			point="TOP", relative="BalanceOption_Attack_AutoAccessories", rpoint="BOTTOM", }, 
		{name="BalanceOption_Attack_AutoIronbark", type="CheckButton", var="BalanceOption_Attack_AutoIronbark", width=25, height=25, 
			point="TOP", relative="BalanceOption_Attack_AutoCovenant", rpoint="BOTTOM", }, 
			
		-- 状态设置 Buttons
		{name="BalanceOption_Auras_ClearCurse", type="CheckButton", var="BalanceOption_Auras_ClearCurse", width=25, height=25, 
			point="TOPLEFT", x=125, y=-65}, 
		{name="BalanceOption_Auras_ClearPoison", type="CheckButton", var="BalanceOption_Auras_ClearPoison", width=25, height=25, 
			point="TOP", relative="BalanceOption_Auras_ClearCurse", rpoint="BOTTOM", }, 
		{name="BalanceOption_Auras_ClearMouseover", type="CheckButton", var="BalanceOption_Auras_ClearMouseover", width=25, height=25, 
			point="TOP", relative="BalanceOption_Auras_ClearPoison", rpoint="BOTTOM", }, 
		{name="BalanceOption_Auras_ClearEnrage", type="CheckButton", var="BalanceOption_Auras_ClearEnrage", width=25, height=25, 
			point="TOP", relative="BalanceOption_Auras_ClearMouseover", rpoint="BOTTOM", }, 
			
		{name="BalanceOption_TraversalObjectIntervalSecond", type="EditBox", width=40, height=20, var="TraversalObjectInterval", 
			point="TOPLEFT", x=245, y=-140}, 
			
		-- 其它设置 Buttons
		{name="BalanceOption_Other_ShowDebug", type="CheckButton", var="BalanceOption_Other_ShowDebug", width=25, height=25, 
			point="TOPLEFT", x=365, y=-65}, 
		{name="BalanceOption_Other_AutoRebirth", type="CheckButton", var="BalanceOption_Other_AutoRebirth", width=25, height=25, 
			point="TOP", relative="BalanceOption_Other_ShowDebug", rpoint="BOTTOM", }, 
		{name="BalanceOption_Auras_AutoInterrupt", type="CheckButton", var="BalanceOption_Auras_AutoInterrupt", width=25, height=25, 
			point="TOP", relative="BalanceOption_Other_AutoRebirth", rpoint="BOTTOM", }, 
		{name="BalanceOption_Other_ClearRoot", type="CheckButton", var="BalanceOption_Other_ClearRoot", width=25, height=25, 
			point="TOP", relative="BalanceOption_Auras_AutoInterrupt", rpoint="BOTTOM", }, 
	}

	local button, text, name, value
	for key, value in ipairs(BalanceOption.Buttons) do
		-- pre settings
		if value.type == "CheckButton" then
			value.inherits = "UICheckButtonTemplate"
		elseif value.type == "EditBox" then
			value.inherits = "InputBoxTemplate"
		end

		-- creations
		button = CreateFrame(value.type, "BalanceOption"..value.name, BalanceOption, value.inherits)

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
				value.relative = "BalanceOption"..value.relative
			end
			button:SetPoint(value.point, value.relative or BalanceOption, value.rpoint or value.point, value.x or 0, value.y or 0)
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
				button:SetScript("OnClick", BalanceOption.OnCheckButtonClicked)
			end
		elseif value.type == "EditBox" then
			button:SetAutoFocus(false)
			if not value.text then button.text:SetText(self.locStr[value.name]) end
			if value.func then
				button:SetScript("OnEnterPressed", value.func)
			else
				button:SetScript("OnEnterPressed", BalanceOption.OnEditBoxEnterPressed)
				button:SetScript("OnTextChanged", BalanceOption.OnEditBoxTextChanged)
			end
			button:SetScript("OnEscapePressed", button.ClearFocus)
		end
	end
end

local value, isChecked

function BalanceOption:Reset()
	StaticPopupDialogs["Balance_OPTION_RESET"].OnAccept = function()
		BalanceSaves = BalanceSavesFrame:GetDefault()
		BalanceOption:LoadOptions()
	end
	StaticPopup_Show("Balance_OPTION_RESET")
end

function BalanceOption:OnCheckButtonClicked()
	isChecked = self:GetChecked()
	if isChecked then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
	value = BalanceOption.Buttons[self:GetID()]
	if value.var then
		if isChecked then
			BalanceSaves[value.var] = true
		else
			BalanceSaves[value.var] = false
		end
	end
end

function BalanceOption:OnEditBoxEnterPressed()
	local num = self:GetText()
	if not num then return end
	--num = tonumber(num)
	if not num then return end
	value = BalanceOption.Buttons[self:GetID()]
	BalanceSaves[value.var] = num
	self:ClearFocus()
end

function BalanceOption:OnEditBoxTextChanged()
	local num = self:GetText()
	if not num then return end
	--num = tonumber(num)
	if not num then return end
	value = BalanceOption.Buttons[self:GetID()]
	BalanceSaves[value.var] = num
end

function BalanceOption:LoadOptions()
	local button
	for key, value in ipairs(BalanceOption.Buttons) do
		button = _G["BalanceOption"..value.name]
		if value.type == "CheckButton" then
			if value.var then
				button:SetChecked(BalanceSaves[value.var])
			end
		elseif value.type == "EditBox" then
			if not BalanceSaves[value.var] then
				BalanceSaves.TraversalObjectInterval = ""
			end
			button:SetText(BalanceSaves[value.var])
		end
	end
	UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, BalanceSaves.BalanceOption_TargetFilter)
	BalanceOptionBalanceOptionTargetFilterText:SetText(BalanceOptionBalanceOptionTargetFilterItems[BalanceSaves.BalanceOption_TargetFilter])
end

BalanceOption:RegisterEvent("PLAYER_LOGIN")
BalanceOption:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
BalanceOption:SetScript("OnEvent", function(self, event)
	if not BalanceSaves.BalanceOption_XSVV or BalanceSaves.BalanceOption_XSVV ~= DA_GetAddOnMetadata("WoWAssistantPX", "X-SVV") then --插件更新后自动重置为默认设置
		BalanceSaves = BalanceSavesFrame:GetDefault()
	end
	
	if DA_GetSpecialization() ~= 102 or BalanceNoteShowIng then return end
	
	WoWAssistantNoteDate = WoWAssistantNoteDate or time()
	if time() - WoWAssistantNoteDate > 86400 or time() - WoWAssistantNoteDate == 0 then --每24小时提示一次使用说明
		BalanceNoteShowIng = 1
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
			BalanceNoteShowIng = nil
		end)
		WoWAssistantNoteDate = time()
	end
end)