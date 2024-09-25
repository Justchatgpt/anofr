--界面
local RestorationOptionSavesFrame = CreateFrame("Frame")


RestorationSwitchStatus = CreateFrame("Frame", "RestorationSwitchStatus", UIParent)
RestorationSwitchStatus:SetWidth(20)
RestorationSwitchStatus:SetHeight(20)
RestorationSwitchStatus:SetPoint("BOTTOM", -1, 240)
RestorationSwitchStatus:SetFrameStrata("MEDIUM")
RestorationSwitchStatus:CreateFontString("RestorationSwitchStatusText", "ARTWORK", "GameFontHighlight")
RestorationSwitchStatusText:SetFont(STANDARD_TEXT_FONT, 100)
RestorationSwitchStatusText:SetPoint("CENTER", 0, 0)
RestorationSwitchStatusText:SetTextColor(1, 0, 0)
RestorationSwitchStatusText:SetText(".")
RestorationSwitchStatusText:Hide()


Restoration_DeBug = Restoration_DeBug or CreateFrame("Frame", "Restoration_DeBug", UIParent)
Restoration_DeBug:SetWidth(30)
Restoration_DeBug:SetHeight(30)
Restoration_DeBug:SetPoint("CENTER", 0, -100)
Restoration_DeBug:SetFrameStrata("MEDIUM")

Restoration_DeBugSpellIcon = CreateFrame("Frame", "Restoration_DeBugSpellIcon", Restoration_DeBug)
Restoration_DeBugSpellIcon:SetPoint("CENTER", Restoration_DeBug, "CENTER", 0, 0)
Restoration_DeBugSpellIcon:SetSize(30, 30)
Restoration_DeBugSpellIcon.Texture = Restoration_DeBugSpellIcon:CreateTexture(nil, "BORDER")
Restoration_DeBugSpellIcon.Texture:SetAllPoints(true)
Restoration_DeBugSpellIcon.Texture:SetAlpha(0.75)

Restoration_DeBugEnemyCount = Restoration_DeBugSpellIcon:CreateFontString("Restoration_DeBugEnemyCount", "ARTWORK", "GameFontHighlight")
Restoration_DeBugEnemyCount:SetFont(STANDARD_TEXT_FONT, 20)
Restoration_DeBugEnemyCount:SetPoint("CENTER", Restoration_DeBugSpellIcon, "CENTER", 0, 0)
Restoration_DeBugEnemyCount:SetTextColor(1, 1, 1)
Restoration_DeBugEnemyCount:Hide()

function RestorationOptionSavesFrame:GetDefault()
	return {
		RestorationOption_Heals_HealTank = false, 
		RestorationOption_Heals_AutoIronbark = true, 
		RestorationOption_Heals_AutoTranquility = true, 
		RestorationOption_Heals_AutoIncarnationTreeofLife = true, 
		RestorationOption_Heals_AutoCovenant = true, 
		RestorationOption_Heals_DBMWillRejuvenation = true, 
		RestorationOption_Heals_DynamicHealOfBoss = true, 
		RestorationOption_Heals_AllRejuvenation = false, 
		RestorationOption_Heals_AutoEfflorescence = true, 
		RestorationOption_Auras_ClearEnrage = true, 
		RestorationOption_Effect = 2, 
		RestorationOption_Auras_ClearCurse = true, 
		RestorationOption_Auras_ClearMagic = true, 
		RestorationOption_Auras_ClearPoison = true, 
		RestorationOption_Auras_ClearMouseover = false, 
		RestorationOption_Other_NoRange = false, 
		RestorationOption_Other_Dead = false, 
		RestorationOption_Other_AutoDPS = true, 
		RestorationOption_Other_ShowCastlInfo = true, 
		RestorationOption_Other_AutoRebirth = false, 
		RestorationOption_Other_ClearRoot = true, 
		TraversalHealthInterval = 0.05, 
		RestorationOption_XSVV = DA_GetAddOnMetadata("WoWAssistantPX", "X-SVV"), 
	}
end
RestorationSaves = RestorationOptionSavesFrame:GetDefault()

local _G = getfenv(0)

local RestorationOption = CreateFrame("Frame", "RestorationOption", UIParent, "BackdropTemplate")
RestorationOption:Hide()
tinsert(UISpecialFrames, "RestorationOption")


Text_Restoration_Option_Reset_StaticPopup_text = "确定重置设置?"
Text_Restoration_Clear_Cache_StaticPopup_button1 = "确定"
Text_Restoration_Clear_Cache_StaticPopup_button2 = "取消"
RestorationOption.locStr = {
	["RestorationOption_Reset"] = "重置", 
	["RestorationOptions"] = "魔兽小助手PX v"..DA_GetAddOnMetadata("WoWAssistantPX","Version"), 
	["RestorationOption_Heals"] = "治疗设置:", 
	["RestorationOption_Heals_HealTank"] = "刷坦模式", 
	["RestorationOption_Heals_AutoIronbark"] = "开启减伤", 
	["RestorationOption_Heals_AutoTranquility"] = "使用宁静", 
	["RestorationOption_Heals_AutoIncarnationTreeofLife"] = "使用化身", 
	["RestorationOption_Heals_AutoCovenant"] = "使用万灵", 
	["RestorationOption_Heals_DBMWillRejuvenation"] = "预铺回春", 
	["RestorationOption_Heals_DynamicHealOfBoss"] = "动态控蓝", 
	["RestorationOption_Heals_AllRejuvenation"] = "全团回春", 
	["RestorationOption_Heals_AutoEfflorescence"] = "使用百花", 
	["RestorationOption_Auras_ClearEnrage"] = "解除激怒", 
	["RestorationOption_Effect"] = "效能设置:", 
	["RestorationOption_Auras"] = "状态设置:", 
	["RestorationOption_Auras_ClearCurse"] = "驱散诅咒", 
	["RestorationOption_Auras_ClearMagic"] = "驱散魔法", 
	["RestorationOption_Auras_ClearPoison"] = "驱散中毒", 
	["RestorationOption_Auras_ClearMouseover"] = "强驱鼠标指向", 
	["RestorationOption_Other"] = "其他设置:", 
	["RestorationOption_Other_NoRange"] = "距离报警", 
	["RestorationOption_Other_Dead"] = "阵亡报警", 
	["RestorationOption_Other_AutoDPS"] = "DPS输出", 
	["RestorationOption_Other_ShowCastlInfo"] = "显示状态", 
	["RestorationOption_Other_AutoRebirth"] = "使用战复", 
	["RestorationOption_Other_ClearRoot"] = "解除定身", 
	["RestorationOption_TraversalHealthInterval"] = "扫描血量间隔:", 
	["RestorationOption_TraversalHealthIntervalSecond"] = "秒", 
}


function RestorationOption:Init()
	-- 尺寸
	self:SetWidth(480); self:SetHeight(230);
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
	self:CreateFontString("RestorationOptionTitle", "ARTWORK", "GameFontHighlight")
	RestorationOptionTitle:SetPoint("TOPLEFT", 10, -10)
	RestorationOptionTitle:SetTextColor(0, 1, 0)
	RestorationOptionTitle:SetText(self.locStr["RestorationOptions"])

	-- 按钮
	RestorationOption:InitButtons()
	
	-- 治疗设置Title
	self:CreateFontString("RestorationOptionHealsFrameTitle", "ARTWORK", "GameFontHighlight")
	RestorationOptionHealsFrameTitle:SetPoint("TOPLEFT", 15, -40)
	RestorationOptionHealsFrameTitle:SetText(self.locStr["RestorationOption_Heals"])

	-- 效能设置Title
	self:CreateFontString("RestorationOptionEffectTitle", "ARTWORK", "GameFontHighlight")
	RestorationOptionEffectTitle:SetPoint("TOPLEFT", 235, -40)
	RestorationOptionEffectTitle:SetText(self.locStr["RestorationOption_Effect"])

	-- 状态设置Title
	self:CreateFontString("RestorationOptionAurasTitle", "ARTWORK", "GameFontHighlight")
	RestorationOptionAurasTitle:SetPoint("TOPLEFT", 235, -100)
	RestorationOptionAurasTitle:SetText(self.locStr["RestorationOption_Auras"])

	-- 其它设置Title
	self:CreateFontString("RestorationOptionOtherTitle", "ARTWORK", "GameFontHighlight")
	RestorationOptionOtherTitle:SetPoint("TOPLEFT", 355, -40)
	RestorationOptionOtherTitle:SetText(self.locStr["RestorationOption_Other"])

	-- 扫描目标间隔
	self:CreateFontString("RestorationOptionTraversalHealthIntervalTitle", "ARTWORK", "GameFontHighlight")
	RestorationOptionTraversalHealthIntervalTitle:SetPoint("TOPLEFT", 15, -195)
	RestorationOptionTraversalHealthIntervalTitle:SetText(self.locStr["RestorationOption_TraversalHealthInterval"])

	-- 读取选项
	RestorationOption:LoadOptions()

	StaticPopupDialogs["Restoration_OPTION_RESET"] = {
		text = Text_Restoration_Option_Reset_StaticPopup_text, 
		button1 = Text_Restoration_Clear_Cache_StaticPopup_button1, 
		button2 = Text_Restoration_Clear_Cache_StaticPopup_button2, 
		timeout = 0, 
		whileDead = 1, 
		hideOnEscape = 1, 
		multiple = 1, 
	}
	-- 完成
	self.ready = 1
end

function RestorationOption:InitButtons()
	if not RestorationOptionRestorationOptionEffect then
		CreateFrame("Button", "RestorationOptionRestorationOptionEffect", RestorationOption, "UIDropDownMenuTemplate")
	end
	RestorationOptionRestorationOptionEffect:ClearAllPoints()
	RestorationOptionRestorationOptionEffect:SetPoint("TOPLEFT", RestorationOption, "TOPLEFT", 215, -65)
	RestorationOptionRestorationOptionEffectItems = {
		"强力", 
		"正常", 
		"省蓝", 
	}
	local function OnClick(self)
		UIDropDownMenu_SetSelectedID(RestorationOptionRestorationOptionEffect, self:GetID())
		if self:GetID() == 1 then
			RestorationSaves.RestorationOption_Effect = 1
		elseif self:GetID() == 2 then
			RestorationSaves.RestorationOption_Effect = 2
		elseif self:GetID() == 3 then
			RestorationSaves.RestorationOption_Effect = 3
		end
	end
	local function initialize(self, level)
		local info = UIDropDownMenu_CreateInfo()
		for k, v in pairs(RestorationOptionRestorationOptionEffectItems) do
			info = UIDropDownMenu_CreateInfo()
			info.text = v
			info.value = v
			info.func = OnClick
			UIDropDownMenu_AddButton(info, level)
		end
	end
	UIDropDownMenu_Initialize(RestorationOptionRestorationOptionEffect, initialize)
	UIDropDownMenu_SetWidth(RestorationOptionRestorationOptionEffect, 60);
	UIDropDownMenu_SetButtonWidth(RestorationOptionRestorationOptionEffect, 84)
	UIDropDownMenu_JustifyText(RestorationOptionRestorationOptionEffect, "CENTER")
	-- 下拉菜单
	
	self.Buttons = {
		-- 关闭 Butons
		{name="Close", type="Button", inherits="UIPanelCloseButton", 
			point="TOPRIGHT", func = function() RestorationOption:Hide() end, }, 
		{name="Reset", type="Button", inherits="UIPanelButtonTemplate", 
			width=70, height=20, text = self.locStr["RestorationOption_Reset"], 
			point="TOPRIGHT", x=-28, y=-6, func = RestorationOption.Reset}, 
	
		-- 治疗设置 Buttons
		{name="RestorationOption_Heals_HealTank", type="CheckButton", var="RestorationOption_Heals_HealTank", width=25, height=25, 
			point="TOPLEFT", x=10, y=-65}, 
		{name="RestorationOption_Heals_AutoIronbark", type="CheckButton", var="RestorationOption_Heals_AutoIronbark", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_HealTank", rpoint="BOTTOM", }, 
		{name="RestorationOption_Heals_AutoTranquility", type="CheckButton", var="RestorationOption_Heals_AutoTranquility", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_AutoIronbark", rpoint="BOTTOM", }, 
		{name="RestorationOption_Heals_AutoIncarnationTreeofLife", type="CheckButton", var="RestorationOption_Heals_AutoIncarnationTreeofLife", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_AutoTranquility", rpoint="BOTTOM", }, 
		{name="RestorationOption_Heals_AutoCovenant", type="CheckButton", var="RestorationOption_Heals_AutoCovenant", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_AutoIncarnationTreeofLife", rpoint="BOTTOM", }, 
			
		{name="RestorationOption_Heals_DBMWillRejuvenation", type="CheckButton", var="RestorationOption_Heals_DBMWillRejuvenation", width=25, height=25, 
			point="TOPLEFT", x=130, y=-65}, 
		{name="RestorationOption_Heals_DynamicHealOfBoss", type="CheckButton", var="RestorationOption_Heals_DynamicHealOfBoss", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_DBMWillRejuvenation", rpoint="BOTTOM", }, 
		{name="RestorationOption_Heals_AllRejuvenation", type="CheckButton", var="RestorationOption_Heals_AllRejuvenation", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_DynamicHealOfBoss", rpoint="BOTTOM", }, 
		{name="RestorationOption_Heals_AutoEfflorescence", type="CheckButton", var="RestorationOption_Heals_AutoEfflorescence", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_AllRejuvenation", rpoint="BOTTOM", }, 
		{name="RestorationOption_Auras_ClearEnrage", type="CheckButton", var="RestorationOption_Auras_ClearEnrage", width=25, height=25, 
			point="TOP", relative="RestorationOption_Heals_AutoEfflorescence", rpoint="BOTTOM", }, 
			
		-- 状态设置 Buttons
		{name="RestorationOption_Auras_ClearCurse", type="CheckButton", var="RestorationOption_Auras_ClearCurse", width=25, height=25, 
			point="TOPLEFT", x=230, y=-115}, 
		{name="RestorationOption_Auras_ClearMagic", type="CheckButton", var="RestorationOption_Auras_ClearMagic", width=25, height=25, 
			point="TOP", relative="RestorationOption_Auras_ClearCurse", rpoint="BOTTOM", }, 
		{name="RestorationOption_Auras_ClearPoison", type="CheckButton", var="RestorationOption_Auras_ClearPoison", width=25, height=25, 
			point="TOP", relative="RestorationOption_Auras_ClearMagic", rpoint="BOTTOM", }, 
		{name="RestorationOption_Auras_ClearMouseover", type="CheckButton", var="RestorationOption_Auras_ClearMouseover", width=25, height=25, 
			point="TOP", relative="RestorationOption_Auras_ClearPoison", rpoint="BOTTOM", }, 
			
		-- 其它设置 Buttons
		{name="RestorationOption_Other_NoRange", type="CheckButton", var="RestorationOption_Other_NoRange", width=25, height=25, 
			point="TOPLEFT", x=350, y=-65}, 
		{name="RestorationOption_Other_Dead", type="CheckButton", var="RestorationOption_Other_Dead", width=25, height=25, 
			point="TOP", relative="RestorationOption_Other_NoRange", rpoint="BOTTOM", }, 
		{name="RestorationOption_Other_AutoDPS", type="CheckButton", var="RestorationOption_Other_AutoDPS", width=25, height=25, 
			point="TOP", relative="RestorationOption_Other_Dead", rpoint="BOTTOM", }, 
		{name="RestorationOption_Other_ShowCastlInfo", type="CheckButton", var="RestorationOption_Other_ShowCastlInfo", width=25, height=25, 
			point="TOP", relative="RestorationOption_Other_AutoDPS", rpoint="BOTTOM", }, 
		{name="RestorationOption_Other_AutoRebirth", type="CheckButton", var="RestorationOption_Other_AutoRebirth", width=25, height=25, 
			point="TOP", relative="RestorationOption_Other_ShowCastlInfo", rpoint="BOTTOM", }, 
		{name="RestorationOption_Other_ClearRoot", type="CheckButton", var="RestorationOption_Other_ClearRoot", width=25, height=25, 
			point="TOP", relative="RestorationOption_Other_AutoRebirth", rpoint="BOTTOM", }, 
		
		{name="RestorationOption_TraversalHealthIntervalSecond", type="EditBox", width=40, height=20, var="TraversalHealthInterval", 
			point="TOPLEFT", relative="RestorationOption_Heals_AutoEfflorescence", rpoint="BOTTOM", x=-5, y=-27}, 
	}

	local button, text, name, value
	for key, value in ipairs(RestorationOption.Buttons) do
		-- pre settings
		if value.type == "CheckButton" then
			value.inherits = "UICheckButtonTemplate"
		elseif value.type == "EditBox" then
			value.inherits = "InputBoxTemplate"
		end

		-- creations
		button = CreateFrame(value.type, "RestorationOption"..value.name, RestorationOption, value.inherits)

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
				value.relative = "RestorationOption"..value.relative
			end
			button:SetPoint(value.point, value.relative or RestorationOption, value.rpoint or value.point, value.x or 0, value.y or 0)
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
				button:SetScript("OnClick", RestorationOption.OnCheckButtonClicked)
			end
		elseif value.type == "EditBox" then
			button:SetAutoFocus(false)
			if not value.text then button.text:SetText(self.locStr[value.name]) end
			if value.func then
				button:SetScript("OnEnterPressed", value.func)
			else
				button:SetScript("OnEnterPressed", RestorationOption.OnEditBoxEnterPressed)
				button:SetScript("OnTextChanged", RestorationOption.OnEditBoxTextChanged)
			end
			button:SetScript("OnEscapePressed", button.ClearFocus)
		end
	end
end

local value, isChecked

function RestorationOption:Reset()
	StaticPopupDialogs["Restoration_OPTION_RESET"].OnAccept = function()
		RestorationSaves = RestorationOptionSavesFrame:GetDefault()
		RestorationOption:LoadOptions()
	end
	StaticPopup_Show("Restoration_OPTION_RESET")
end

function RestorationOption:OnCheckButtonClicked()
	isChecked = self:GetChecked()
	if isChecked then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
	value = RestorationOption.Buttons[self:GetID()]
	if value.var then
		if isChecked then
			RestorationSaves[value.var] = true
		else
			RestorationSaves[value.var] = false
		end
	end
end

function RestorationOption:OnEditBoxEnterPressed()
	local num = self:GetText()
	if not num then return end
	--num = tonumber(num)
	if not num then return end
	value = RestorationOption.Buttons[self:GetID()]
	RestorationSaves[value.var] = num
	self:ClearFocus()
end

function RestorationOption:OnEditBoxTextChanged()
	local num = self:GetText()
	if not num then return end
	--num = tonumber(num)
	if not num then return end
	value = RestorationOption.Buttons[self:GetID()]
	RestorationSaves[value.var] = num
end

function RestorationOption:LoadOptions()
	local button
	for key, value in ipairs(RestorationOption.Buttons) do
		button = _G["RestorationOption"..value.name]
		if value.type == "CheckButton" then
			if value.var then
				button:SetChecked(RestorationSaves[value.var])
			end
		elseif value.type == "EditBox" then
			if not RestorationSaves[value.var] then
				RestorationSaves.TraversalHealthInterval = ""
			end
			button:SetText(RestorationSaves[value.var])
		end
	end
	UIDropDownMenu_SetSelectedID(RestorationOptionRestorationOptionEffect, RestorationSaves.RestorationOption_Effect)
	RestorationOptionRestorationOptionEffectText:SetText(RestorationOptionRestorationOptionEffectItems[RestorationSaves.RestorationOption_Effect])
end

RestorationOption:RegisterEvent("PLAYER_LOGIN")
RestorationOption:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
RestorationOption:SetScript("OnEvent", function(self, event)
	if not RestorationSaves.RestorationOption_XSVV or RestorationSaves.RestorationOption_XSVV ~= DA_GetAddOnMetadata("WoWAssistantPX", "X-SVV") then --插件更新后自动重置为默认设置
		RestorationSaves = RestorationOptionSavesFrame:GetDefault()
	end
	
	if DA_GetSpecialization() ~= 105 or RestorationNoteShowIng then return end
	
	WoWAssistantNoteDate = WoWAssistantNoteDate or time()
	if time() - WoWAssistantNoteDate > 86400 or time() - WoWAssistantNoteDate == 0 then --每24小时提示一次使用说明
		RestorationNoteShowIng = 1
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
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."切换效能设置: "..GetBindingKey("WoWAssistant_Replace"))
			else
				DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."切换效能设置: 无")
			end
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFF7D0A<魔兽小助手>|r ".."提示: 按键可在按键设置中自行更改")
			RestorationNoteShowIng = nil
		end)
		WoWAssistantNoteDate = time()
	end
end)