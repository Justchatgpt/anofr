--API's

function DA_IsAddOnLoaded(name)
    -- 获取指定插件是否加载
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        local loaded, finished = C_AddOns.IsAddOnLoaded(name)
        if loaded ~= nil then
            return loaded, finished
        end
    else
        return IsAddOnLoaded(name)
    end
end

function DA_GetAddOnMetadata(name, variable)
    -- 获取指定插件指定配置值的版本号
    if C_AddOns and C_AddOns.GetAddOnMetadata then
        local value = C_AddOns.GetAddOnMetadata(name, variable)
        if value ~= nil then
            return value
        end
    else
        return GetAddOnMetadata(name, variable)
    end
end


SetCVar("Contrast", 50)
--设置对比度
SetCVar("Brightness", 50)
--设置亮度
SetCVar("Gamma", 1)
--设置伽马值

DA_pixel_frame = CreateFrame("Frame", "DA_pixel_frame", UIParent)
DA_pixel_frame:SetFrameStrata("TOOLTIP")
DA_pixel_frame:SetFrameLevel(65535)
DA_pixel_frame:SetSize(1, 1)
if DA_IsAddOnLoaded('WeakAuras') then
	DA_pixel_frame:SetPoint("TOPLEFT", 0, -3)  -- 将DA_pixel_frame放置在游戏窗口的左上角
else
	DA_pixel_frame:SetPoint("TOPLEFT", 0, 0)  -- 将DA_pixel_frame放置在游戏窗口的左上角
end
DA_pixel_frame.texture = DA_pixel_frame:CreateTexture()
DA_pixel_frame.texture:SetAllPoints(DA_pixel_frame)
DA_pixel_frame.texture:SetColorTexture(0.3, 0.4, 0.9)
DA_pixel_frame:Show()
--WoWAssistantPx开关指示起始像素

DA_pixel_target_frame = CreateFrame("Frame", "DA_pixel_target_frame", UIParent)
DA_pixel_target_frame:SetFrameStrata("TOOLTIP")
DA_pixel_target_frame:SetFrameLevel(65535)
DA_pixel_target_frame:SetSize(1, 1)
DA_pixel_target_frame:SetPoint("LEFT", DA_pixel_frame, "RIGHT", 0, 0)
DA_pixel_target_frame.texture = DA_pixel_target_frame:CreateTexture()
DA_pixel_target_frame.texture:SetAllPoints(DA_pixel_target_frame)
DA_pixel_target_frame.texture:SetColorTexture(1, 0, 0)
DA_pixel_target_frame:Show()
--目标指示像素

DA_pixel_event_frame = CreateFrame("Frame", "DA_pixel_event_frame", UIParent)
DA_pixel_event_frame:SetFrameStrata("TOOLTIP")
DA_pixel_event_frame:SetFrameLevel(65535)
DA_pixel_event_frame:SetSize(1, 1)
DA_pixel_event_frame:SetPoint("LEFT", DA_pixel_target_frame, "RIGHT", 0, 0)
DA_pixel_event_frame.texture = DA_pixel_event_frame:CreateTexture()
DA_pixel_event_frame.texture:SetAllPoints(DA_pixel_event_frame)
DA_pixel_event_frame.texture:SetColorTexture(0, 1, 0)
DA_pixel_event_frame:Show()
--事件指示像素

DA_pixel_spell_frame = CreateFrame("Frame", "DA_pixel_Spell_frame", UIParent)
DA_pixel_spell_frame:SetFrameStrata("TOOLTIP")
DA_pixel_spell_frame:SetFrameLevel(65535)
DA_pixel_spell_frame:SetSize(1, 1)
DA_pixel_spell_frame:SetPoint("LEFT", DA_pixel_event_frame, "RIGHT", 0, 0)
DA_pixel_spell_frame.texture = DA_pixel_spell_frame:CreateTexture()
DA_pixel_spell_frame.texture:SetAllPoints(DA_pixel_spell_frame)
DA_pixel_spell_frame.texture:SetColorTexture(0, 0, 1)
DA_pixel_spell_frame:Show()
--技能指示像素

DA_pixel_frame2 = CreateFrame("Frame", "DA_pixel_frame2", UIParent)
DA_pixel_frame2:SetFrameStrata("TOOLTIP")
DA_pixel_frame2:SetFrameLevel(65535)
DA_pixel_frame2:SetSize(1, 1)
DA_pixel_frame2:SetPoint("LEFT", DA_pixel_spell_frame, "RIGHT", 0, 0)
DA_pixel_frame2.texture = DA_pixel_frame2:CreateTexture()
DA_pixel_frame2.texture:SetAllPoints(DA_pixel_frame2)
if IsInRaid() then
	DA_pixel_frame2.texture:SetColorTexture(0.34, 0.91, 0)
else
	DA_pixel_frame2.texture:SetColorTexture(0.19, 0.43, 0)
end
DA_pixel_frame2:Show()
--WoWAssistantPx开关指示结束像素

WoWAssistantAPI = CreateFrame("Frame")
WoWAssistantAPI:RegisterEvent("INSPECT_READY")
WoWAssistantAPI:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
WoWAssistantAPI:RegisterEvent("PLAYER_ROLES_ASSIGNED")
--WoWAssistantAPI:RegisterEvent("PLAYER_STARTED_MOVING")
--WoWAssistantAPI:RegisterEvent("PLAYER_STOPPED_MOVING")
WoWAssistantAPI:RegisterEvent("PLAYER_ENTERING_WORLD")
WoWAssistantAPI:RegisterUnitEvent("PLAYER_EQUIPMENT_CHANGED")


--恢复专精技能-等级-颜色对应表
DA_CastLevelColorCache_Restoration = {
	{NameCN = "生命绽放", NameEN = "Lifebloom", ID = 188550, Level = 0, color = 0.01}, 
	{NameCN = "生命绽放", NameEN = "Lifebloom", ID = 33763, Level = 1, color = 0.01}, 
	{NameCN = "生命绽放", NameEN = "Lifebloom", ID = 48450, Level = 2, color = 0.01}, 
	{NameCN = "生命绽放", NameEN = "Lifebloom", ID = 48451, Level = 3, color = 0.01}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 774, Level = 1, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 1058, Level = 2, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 1430, Level = 3, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 2090, Level = 4, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 2091, Level = 5, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 3627, Level = 6, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 8910, Level = 7, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 9839, Level = 8, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 9840, Level = 9, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 9841, Level = 10, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 25299, Level = 11, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 26981, Level = 12, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 26982, Level = 13, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 48440, Level = 14, color = 0.02}, 
	{NameCN = "回春术", NameEN = "Rejuvenation", ID = 48441, Level = 15, color = 0.02}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 8936, Level = 1, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 8938, Level = 2, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 8939, Level = 3, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 8940, Level = 4, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 8941, Level = 5, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 9750, Level = 6, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 9856, Level = 7, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 9857, Level = 8, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 9858, Level = 9, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 26980, Level = 10, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 48442, Level = 11, color = 0.03}, 
	{NameCN = "愈合", NameEN = "Regrowth", ID = 48443, Level = 12, color = 0.03}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 5185, Level = 1, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 5186, Level = 2, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 5187, Level = 3, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 5188, Level = 4, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 5189, Level = 5, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 6778, Level = 6, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 8903, Level = 7, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 9758, Level = 8, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 9888, Level = 9, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 9889, Level = 10, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 25297, Level = 11, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 26978, Level = 12, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 26979, Level = 13, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 48377, Level = 14, color = 0.04}, 
	{NameCN = "治疗之触", NameEN = "Healing_Touch", ID = 48378, Level = 15, color = 0.04}, 
	{NameCN = "塞纳里奥结界", NameEN = "Cenarion_Ward", ID = 102351, Level = 0, color = 0.04}, 
	{NameCN = "自然迅捷", NameEN = "Nature_Swiftness", ID = 17116, Level = 0, color = 0.05}, 
	{NameCN = "自然迅捷", NameEN = "Nature_Swiftness", ID = 132158, Level = 0, color = 0.05}, 
	{NameCN = "野性成长", NameEN = "Wild_Growth", ID = 48438, Level = 1, color = 0.06}, 
	{NameCN = "野性成长", NameEN = "Wild_Growth", ID = 53248, Level = 2, color = 0.06}, 
	{NameCN = "野性成长", NameEN = "Wild_Growth", ID = 53249, Level = 3, color = 0.06}, 
	{NameCN = "野性成长", NameEN = "Wild_Growth", ID = 53251, Level = 4, color = 0.06}, 
	{NameCN = "树皮术", NameEN = "Barkskin", ID = 22812, Level = 0, color = 0.07}, 
	{NameCN = "滋养", NameEN = "Nourish", ID = 50464, Level = 1, color = 0.08}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 740, Level = 1, color = 0.09}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 8918, Level = 2, color = 0.09}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 9862, Level = 3, color = 0.09}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 9863, Level = 4, color = 0.09}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 26983, Level = 5, color = 0.09}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 48446, Level = 6, color = 0.09}, 
	{NameCN = "宁静", NameEN = "Tranquility", ID = 48447, Level = 7, color = 0.09}, 
	{NameCN = "激活", NameEN = "Innervate", ID = 29166, Level = 0, color = 0.10}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 20484, Level = 1, color = 0.11}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 20739, Level = 2, color = 0.11}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 20742, Level = 3, color = 0.11}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 20747, Level = 4, color = 0.11}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 20748, Level = 5, color = 0.11}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 26994, Level = 6, color = 0.11}, 
	{NameCN = "复生", NameEN = "Rebirth", ID = 48477, Level = 7, color = 0.11}, 
	{NameCN = "迅捷治愈", NameEN = "Swiftmend", ID = 18562, Level = 0, color = 0.12}, 
	{NameCN = "自然之愈", NameEN = "Nature_Cure", ID = 88423, Level = 0, color = 0.13}, 
	{NameCN = "消毒术", NameEN = "Cure_Poison", ID = 8946, Level = 0, color = 0.13}, 
	{NameCN = "解除诅咒", NameEN = "Remove_Curse", ID = 2782, Level = 0, color = 0.14}, 
	{NameCN = "安抚", NameEN = "Soothe", ID = 2908, Level = 0, color = 0.14}, 
	{NameCN = "化身：生命之树", NameEN = "Incarnation_Tree_of_Life", ID = 33891, Level = 0, color = 0.15}, 
	{NameCN = "万灵之召", NameEN = "Convoke_the_Spirits", ID = 391528, Level = 0, color = 0.16}, 
	{NameCN = "百花齐放", NameEN = "Efflorescence", ID = 145205, Level = 0, color = 0.17}, 
	{NameCN = "过度生长", NameEN = "Overgrowth", ID = 203651, Level = 0, color = 0.18}, 
	{NameCN = "铁木树皮", NameEN = "Ironbark", ID = 102342, Level = 0, color = 0.19}, 
	{NameCN = "繁盛", NameEN = "Flourish", ID = 197721, Level = 0, color = 0.20}, 
	{NameCN = "鼓舞", NameEN = "Invigorate", ID = 392160, Level = 0, color = 0.21}, 
	{NameCN = "甘霖", NameEN = "Renewal", ID = 108238, Level = 0, color = 0.22}, 
	{NameCN = "狂暴(种族特长)", NameEN = "Berserking", ID = 26297, Level = 0, color = 0.23}, 
    {NameCN = "野性之心", NameEN = "Heart_Of_The_Wild", ID = 319454, Level = 0, color = 0.24},
    {NameCN = "自然的守护", NameEN = "Nature_Vigil", ID = 124974, Level = 0, color = 0.25},
    {NameCN = "斜掠", NameEN = "Rake", ID = 1822, Level = 0, color = 0.26},
    {NameCN = "撕碎", NameEN = "Shred", ID = 5221, Level = 0, color = 0.27},
    {NameCN = "熊形态", NameEN = "Bear_Form", ID = 5487, Level = 0, color = 0.28},
    {NameCN = "猎豹形态", NameEN = "Cat_Form", ID = 768, Level = 0, color = 0.29},
    {NameCN = "林莽卫士", NameEN = "Grove_Guardians", ID = 102693, Level = 0, color = 0.30},
    {NameCN = "割裂", NameEN = "Rip", ID = 1079, Level = 0, color = 0.31},
    {NameCN = "凶猛撕咬", NameEN = "Ferocious_Bite", ID = 22568, Level = 0, color = 0.32},
    {NameCN = "割碎", NameEN = "Maim", ID = 22570, Level = 0, color = 0.33},
    {NameCN = "痛击", NameEN = "Thrash", ID = 106830, Level = 0, color = 0.34},
    {NameCN = "横扫", NameEN = "Swipe", ID = 106785, Level = 0, color = 0.35},
    {NameCN = "迎头痛击", NameEN = "Skull_Bash", ID = 106839, Level = 0, color = 0.36},
    {NameCN = "夺魂咆哮", NameEN = "Incapacitating_Roar", ID = 99, Level = 0, color = 0.37},
    {NameCN = "蛮力猛击", NameEN = "Bash", ID = 5211, Level = 0, color = 0.38},
    {NameCN = "月火术", NameEN = "Moonfire", ID = 8921, Level = 0, color = 0.39},
    {NameCN = "阳炎术", NameEN = "Sunfire", ID = 93402, Level = 0, color = 0.40},
    {NameCN = "愤怒", NameEN = "Wrath", ID = 5176, Level = 0, color = 0.41},
    {NameCN = "星火术", NameEN = "Starfire", ID = 197628, Level = 0, color = 0.42},
    {NameCN = "星涌术", NameEN = "Starsurge", ID = 197626, Level = 0, color = 0.43},
    {NameCN = "熊形态甘霖治疗石宏", NameEN = "Bear_Form_Renewal_Healthstone", ID = 0, Level = 0, color = 0.44},
    {NameCN = "熊形态狂暴回复宏", NameEN = "Bear_Form_Frenzied_Regeneration", ID = 0, Level = 0, color = 0.45},
    {NameCN = "荆棘术", NameEN = "Thorns", ID = 305497, Level = 0, color = 0.46},
	
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 339, Level = 1, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 1062, Level = 2, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 5195, Level = 3, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 5196, Level = 4, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 9852, Level = 5, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 9853, Level = 6, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 26989, Level = 7, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 53308, Level = 8, color = 0.49},  
	{NameCN = "群体缠绕", NameEN = "Mass_Entanglement", ID = 102359, Level = 0, color = 0.50}, 
	
	{NameCN = "起死回生", NameEN = "Revive", ID = 50769, Level = 1, color = 0.00}, 
	{NameCN = "起死回生", NameEN = "Revive", ID = 50768, Level = 2, color = 0.00}, 
	{NameCN = "起死回生", NameEN = "Revive", ID = 50767, Level = 3, color = 0.00}, 
	{NameCN = "起死回生", NameEN = "Revive", ID = 50766, Level = 4, color = 0.00}, 
	{NameCN = "起死回生", NameEN = "Revive", ID = 50765, Level = 5, color = 0.00}, 
	{NameCN = "起死回生", NameEN = "Revive", ID = 50764, Level = 6, color = 0.00}, 
	{NameCN = "起死回生", NameEN = "Revive", ID = 50763, Level = 7, color = 0.00}, 
	{NameCN = "休眠", NameEN = "Hibernate", ID = 2637, Level = 1, color = 0.00}, 
	{NameCN = "休眠", NameEN = "Hibernate", ID = 18657, Level = 2, color = 0.00}, 
	{NameCN = "休眠", NameEN = "Hibernate", ID = 18658, Level = 3, color = 0.00}, 
	{NameCN = "旋风", NameEN = "Cyclone", ID = 33786, Level = 0, color = 0.00}, 
}

--野性专精技能-等级-颜色对应表
DA_CastLevelColorCache_Feral = {
    {NameCN = "斜掠", NameEN = "Rake", ID = 1822, Level = 0, color = 0.01},
    {NameCN = "回春术", NameEN = "Rejuvenation", ID = 774, Level = 0, color = 0.02},
    {NameCN = "痛击", NameEN = "Thrash", ID = 106830, Level = 0, color = 0.03},
    {NameCN = "痛击", NameEN = "Thrash", ID = 106832, Level = 0, color = 0.03},
    {NameCN = "清除腐蚀", NameEN = "Remove_Corruption", ID = 2782, Level = 0, color = 0.04},
    {NameCN = "割裂", NameEN = "Rip", ID = 1079, Level = 0, color = 0.05},
    {NameCN = "野性成长", NameEN = "Wild_Growth", ID = 48438, Level = 0, color = 0.06},
    {NameCN = "割碎", NameEN = "Maim", ID = 22570, Level = 0, color = 0.07},
    {NameCN = "迎头痛击", NameEN = "Skull_Bash", ID = 106839, Level = 0, color = 0.08},
    {NameCN = "安抚", NameEN = "Soothe", ID = 2908, Level = 0, color = 0.09},
    {NameCN = "甘霖", NameEN = "Renewal", ID = 108238, Level = 0, color = 0.10},
    {NameCN = "夺魂咆哮", NameEN = "Incapacitating_Roar", ID = 99, Level = 0, color = 0.11},
    {NameCN = "蛮力猛击", NameEN = "Mighty_Bash", ID = 5211, Level = 0, color = 0.12},
    {NameCN = "复生", NameEN = "Rebirth", ID = 20484, Level = 0, color = 0.13},
    {NameCN = "野性之心", NameEN = "Heart_of_the_Wild", ID = 319454, Level = 0, color = 0.14},
    {NameCN = "撕碎", NameEN = "Shred", ID = 5221, Level = 0, color = 0.15},
    {NameCN = "猛虎之怒", NameEN = "Tiger_Fury", ID = 5217, Level = 0, color = 0.16},
    {NameCN = "原始之怒", NameEN = "Primal_Wrath", ID = 285381, Level = 0, color = 0.17},
    {NameCN = "生存本能", NameEN = "Survival_Instincts", ID = 61336, Level = 0, color = 0.18},
    {NameCN = "狂暴", NameEN = "Berserk", ID = 106951, Level = 0, color = 0.19},
    {NameCN = "化身：阿莎曼之灵", NameEN = "Incarnation_Avatar_of_Ashamane", ID = 102543, Level = 0, color = 0.19},
    {NameCN = "横扫", NameEN = "Swipe", ID = 106785, Level = 0, color = 0.20},
    {NameCN = "野蛮挥砍", NameEN = "Brutal_Slash", ID = 202028, Level = 0, color = 0.20},
    {NameCN = "激变蜂群", NameEN = "Adaptive_Swarm", ID = 325727, Level = 0, color = 0.21},
    {NameCN = "万灵之召", NameEN = "Convoke_the_Spirits", ID = 323764, Level = 0, color = 0.22},
    {NameCN = "狂暴(种族特长)", NameEN = "Berserking", ID = 26297, Level = 0, color = 0.23},
    {NameCN = "野性狂乱", NameEN = "Feral_Frenzy", ID = 274837, Level = 0, color = 0.24},
    {NameCN = "凶猛撕咬", NameEN = "Ferocious_Bite", ID = 22568, Level = 0, color = 0.25},
    {NameCN = "树皮术", NameEN = "Barkskin", ID = 22812, Level = 0, color = 0.26},
    {NameCN = "狂暴回复", NameEN = "Frenzied_Regeneration", ID = 22842, Level = 0, color = 0.27},
    {NameCN = "熊形态", NameEN = "Bear_Form", ID = 5487, Level = 0, color = 0.28},
    {NameCN = "愈合", NameEN = "Regrowth", ID = 8936, Level = 0, color = 0.29},
    {NameCN = "猎豹形态", NameEN = "Cat_Form", ID = 768, Level = 0, color = 0.30},
    {NameCN = "自然的守护", NameEN = "Nature_Vigil", ID = 124974, Level = 0, color = 0.31},
    {NameCN = "激活", NameEN = "Innervate", ID = 29166, Level = 0, color = 0.32},
    {NameCN = "月火术", NameEN = "Moonfire", ID = 8921, Level = 0, color = 0.33},
    {NameCN = "月火术", NameEN = "Moonfire", ID = 155626, Level = 0, color = 0.33},
    {NameCN = "割碎", NameEN = "Maim", ID = 22570, Level = 0, color = 0.34},
    {NameCN = "队友1愈合宏", NameEN = "Regrowth_P1", ID = 0, Level = 0, color = 0.35},
    {NameCN = "队友2愈合宏", NameEN = "Regrowth_P2", ID = 0, Level = 0, color = 0.36},
    {NameCN = "队友3愈合宏", NameEN = "Regrowth_P3", ID = 0, Level = 0, color = 0.37},
    {NameCN = "队友4愈合宏", NameEN = "Regrowth_P4", ID = 0, Level = 0, color = 0.38},
	
    {NameCN = "熊形态甘霖治疗石宏", NameEN = "Bear_Form_Renewal_Healthstone", ID = 0, Level = 0, color = 0.44},
    {NameCN = "熊形态狂暴回复宏", NameEN = "Bear_Form_Frenzied_Regeneration", ID = 0, Level = 0, color = 0.45},
	
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 339, Level = 1, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 1062, Level = 2, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 5195, Level = 3, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 5196, Level = 4, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 9852, Level = 5, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 9853, Level = 6, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 26989, Level = 7, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 53308, Level = 8, color = 0.49},  
	{NameCN = "群体缠绕", NameEN = "Mass_Entanglement", ID = 102359, Level = 0, color = 0.50}, 
}

--平衡专精技能-等级-颜色对应表
DA_CastLevelColorCache_Balance = {
    {NameCN = "月火术", NameEN = "Moonfire", ID = 8921, Level = 0, color = 0.01},
    {NameCN = "回春术", NameEN = "Rejuvenation", ID = 774, Level = 0, color = 0.02},
    {NameCN = "阳炎术", NameEN = "Sunfire", ID = 93402, Level = 0, color = 0.03},
    {NameCN = "清除腐蚀", NameEN = "Remove_Corruption", ID = 2782, Level = 0, color = 0.04},
    {NameCN = "愤怒", NameEN = "Wrath", ID = 190984, Level = 0, color = 0.05},
    {NameCN = "野性成长", NameEN = "Wild_Growth", ID = 48438, Level = 0, color = 0.06},
    {NameCN = "星火术", NameEN = "Starfire", ID = 194153, Level = 0, color = 0.07},
    {NameCN = "日光术", NameEN = "Solar_Beam", ID = 78675, Level = 0, color = 0.08},
    {NameCN = "安抚", NameEN = "Soothe", ID = 2908, Level = 0, color = 0.09},
    {NameCN = "甘霖", NameEN = "Renewal", ID = 108238, Level = 0, color = 0.10},
    {NameCN = "夺魂咆哮", NameEN = "Incapacitating_Roar", ID = 99, Level = 0, color = 0.11},
    {NameCN = "蛮力猛击", NameEN = "Mighty_Bash", ID = 5211, Level = 0, color = 0.12},
    {NameCN = "复生", NameEN = "Rebirth", ID = 20484, Level = 0, color = 0.13},
    {NameCN = "野性之心", NameEN = "Heart_of_the_Wild", ID = 319454, Level = 0, color = 0.14},
    {NameCN = "星涌术", NameEN = "Starsurge", ID = 78674, Level = 0, color = 0.15},
    {NameCN = "新月", NameEN = "New_Moon", ID = 274281, Level = 0, color = 0.16},
    {NameCN = "野性蘑菇", NameEN = "Wild_Mushroom", ID = 88747, Level = 0, color = 0.17},
    {NameCN = "艾露恩之怒", NameEN = "Elune_Wrath", ID = 202770, Level = 0, color = 0.18},
    {NameCN = "超凡之盟", NameEN = "Celestial_Alignment", ID = 194223, Level = 0, color = 0.19},
    {NameCN = "超凡之盟", NameEN = "Celestial_Alignment", ID = 383410, Level = 0, color = 0.19},
    {NameCN = "化身：艾露恩之眷", NameEN = "Incarnation_Chosen_of_Elune", ID = 102560, Level = 0, color = 0.19},
    {NameCN = "化身：艾露恩之眷", NameEN = "Incarnation_Chosen_of_Elune", ID = 390414, Level = 0, color = 0.19},
    {NameCN = "星辰坠落", NameEN = "Starfall", ID = 191034, Level = 0, color = 0.20},
    {NameCN = "星辰耀斑", NameEN = "Stellar_Flare", ID = 202347, Level = 0, color = 0.21},
    {NameCN = "万灵之召", NameEN = "Convoke_the_Spirits", ID = 323764, Level = 0, color = 0.22},
    {NameCN = "狂暴(种族特长)", NameEN = "Berserking", ID = 26297, Level = 0, color = 0.23},
    {NameCN = "自然之力", NameEN = "Force_of_Nature", ID = 205636, Level = 0, color = 0.24},
    {NameCN = "艾露恩的战士", NameEN = "Warrior_of_Elune", ID = 202425, Level = 0, color = 0.25},
    {NameCN = "树皮术", NameEN = "Barkskin", ID = 22812, Level = 0, color = 0.26},
	
    {NameCN = "熊形态", NameEN = "Bear_Form", ID = 5487, Level = 0, color = 0.28},
    {NameCN = "愈合", NameEN = "Regrowth", ID = 8936, Level = 0, color = 0.29},
    {NameCN = "枭兽形态", NameEN = "Moonkin_Form", ID = 24858, Level = 0, color = 0.30},
    {NameCN = "自然的守护", NameEN = "Nature_Vigil", ID = 124974, Level = 0, color = 0.31},
    {NameCN = "激活", NameEN = "Innervate", ID = 29166, Level = 0, color = 0.32},
	
    {NameCN = "熊形态甘霖治疗石宏", NameEN = "Bear_Form_Renewal_Healthstone", ID = 0, Level = 0, color = 0.44},
    {NameCN = "熊形态狂暴回复宏", NameEN = "Bear_Form_Frenzied_Regeneration", ID = 0, Level = 0, color = 0.45},
	
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 339, Level = 1, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 1062, Level = 2, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 5195, Level = 3, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 5196, Level = 4, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 9852, Level = 5, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 9853, Level = 6, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 26989, Level = 7, color = 0.49}, 
	{NameCN = "纠缠根须", NameEN = "Entangling_Roots", ID = 53308, Level = 8, color = 0.49},  
	{NameCN = "群体缠绕", NameEN = "Mass_Entanglement", ID = 102359, Level = 0, color = 0.50}, 
}

function DA_GetAssignSpellIDs(spellTable)
    for k, v in ipairs(spellTable) do
        local spellNameEN = v.NameEN
        local name = v.NameCN
        local _, _, _, _, _, _, spellID = DA_GetSpellInfo(name)
        if spellID then
            _G[spellNameEN .. "_SpellID"] = spellID
            --print("当前["..name.."]法术ID: "..spellID)
        else
            for _, spell in ipairs(spellTable) do
                if spell.NameEN == spellNameEN and (spell.Level == 0 or spell.Level == 1) then
                    _G[spellNameEN .. "_SpellID"] = spell.ID
                    --print("当前["..name.."]法术ID: "..spell.ID.." (默认等级)")
                    break
                end
            end
        end
    end
end

local TargetColorCache = {
	{target = "raid1", color = 0.01}, 
	{target = "raid2", color = 0.02}, 
	{target = "raid3", color = 0.03}, 
	{target = "raid4", color = 0.04}, 
	{target = "raid5", color = 0.05}, 
	{target = "raid6", color = 0.06}, 
	{target = "raid7", color = 0.07}, 
	{target = "raid8", color = 0.08}, 
	{target = "raid9", color = 0.09}, 
	{target = "raid10", color = 0.10}, 
	{target = "raid11", color = 0.11}, 
	{target = "raid12", color = 0.12}, 
	{target = "raid13", color = 0.13}, 
	{target = "raid14", color = 0.14}, 
	{target = "raid15", color = 0.15}, 
	{target = "raid16", color = 0.16}, 
	{target = "raid17", color = 0.17}, 
	{target = "raid18", color = 0.18}, 
	{target = "raid19", color = 0.19}, 
	{target = "raid20", color = 0.20}, 
	{target = "raid21", color = 0.21}, 
	{target = "raid22", color = 0.22}, 
	{target = "raid23", color = 0.23}, 
	{target = "raid24", color = 0.24}, 
	{target = "raid25", color = 0.25}, 
	{target = "raid26", color = 0.26}, 
	{target = "raid27", color = 0.27}, 
	{target = "raid28", color = 0.28}, 
	{target = "raid29", color = 0.29}, 
	{target = "raid30", color = 0.30}, 
	{target = "raid31", color = 0.31}, 
	{target = "raid32", color = 0.32}, 
	{target = "raid33", color = 0.33}, 
	{target = "raid34", color = 0.34}, 
	{target = "raid35", color = 0.35}, 
	{target = "raid36", color = 0.36}, 
	{target = "raid37", color = 0.37}, 
	{target = "raid38", color = 0.38}, 
	{target = "raid39", color = 0.39}, 
	{target = "raid40", color = 0.40},
	
	{target = "party1", color = 0.015},
	{target = "party2", color = 0.025},
	{target = "party3", color = 0.035},
	{target = "party4", color = 0.045},
	{target = "player", color = 0.055},
	
	{target = "targettarget_harm", color = 0.41},
	{target = "targettarget_help", color = 0.42},
	{target = "focus", color = 0.43},
	
	{target = "boss1", color = 0.48},
	{target = "boss2", color = 0.49},
	{target = "boss3", color = 0.50},
	{target = "boss4", color = 0.51},
	{target = "boss5", color = 0.52},
	
	{target = "arena1", color = 0.54},
	{target = "arena2", color = 0.55},
	{target = "arena3", color = 0.56},
	{target = "arena4", color = 0.57},
	{target = "arena5", color = 0.58},
}
--目标-颜色对应表

local ItemColorCache = {
	{Name = "饰品13", ID = 13, color = 0.02}, 
	{Name = "饰品14", ID = 14, color = 0.03}, 
	{Name = "邪能治疗石", ID = 36892, color = 0.04}, 
	{Name = "邪能治疗石", ID = 36894, color = 0.04}, 
	{Name = "治疗石", ID = 5512, color = 0.04}, 
	{Name = "纯净的斯坦索姆圣水", ID = 202195, color = 0.05}, 
}
--物品-颜色对应表

local AttributesEnhancedItemCache = {
	{Name = "战争囚徒印记", ItemID = 37873}, 
	{Name = "展翼护符", ItemID = 37844}, 
	{Name = "灵魂世界之镜", ItemID = 39388}, 
	{Name = "能量弯管", ItemID = 45292}, 
	{Name = "永冻冰晶", ItemID = 50259}, 
	{Name = "消融之雪", ItemID = 50260}, 
	{Name = "诺甘农的印记", ItemID = 40531}, 
	{Name = "活焰", ItemID = 45148}, 
	{Name = "天谴之石", ItemID = 45263}, 
	{Name = "命运之鳞", ItemID = 45466}, 
	{Name = "禁锢之光", ItemID = 47728}, 
	{Name = "禁锢之光", ItemID = 47947}, 
	{Name = "动荡能量饰物", ItemID = 47726}, 
	{Name = "动荡能量饰物", ItemID = 47946}, 
	{Name = "胜者的召唤", ItemID = 47725}, 
	{Name = "胜者的召唤", ItemID = 47948}, 
	{Name = "明亮暮光龙鳞", ItemID = 54573}, 
	{Name = "明亮暮光龙鳞", ItemID = 54589}, 
	{Name = "纯冰薄片", ItemID = 50339}, 
	{Name = "纯冰薄片", ItemID = 50346}, 
	--WLK
	{Name = "炉铸候选者的凶猛徽章", ItemID = 218421}, 
	{Name = "隐修院印章", ItemID = 219308}, 
	{Name = "瓶装绽翼兽毒素", ItemID = 178742}, 
	{Name = "灰鳞的优雅", ItemID = 133282}, 
	{Name = "迅芯烛台", ItemID = 225649}, 
	--11.0
}
--属性增强饰品

local DirectSingleHealItemCache = {
	{Name = "流冰之晶", ItemID = 40532}, 
	{Name = "纯血珠饰", ItemID = 50354}, 
	{Name = "纯血珠饰", ItemID = 50726}, 
	--WLK
	{Name = "粘稠聚合物", ItemID = 219320}, 
	{Name = "蜡烛之王的雕刀", ItemID = 219306}, 
	{Name = "金辉香炉", ItemID = 225656}, 
	{Name = "被腐蚀的蛋壳", ItemID = 133305}, 
	--11.0
}
--单体治疗饰品

local DirectAoeHealItemCache = {
	{Name = "圣灵微粒", ItemID = 133646, Target = "player"}, 
	--7.0
	{Name = "虹吸护命匣碎片", ItemID = 178783, Target = Restoration_DirectAoeHealItemTarget}, 
	--9.0
	--11.0
}
--群体治疗饰品

local DirectSingleDPSItemCache = {
	{Name = "蠕行凝块", ItemID = 219917}, 
	{Name = "米雷达尔洪钟", ItemID = 219313}, 
	--11.0
}
--单体伤害饰品

local DirectAoeDPSItemCache = {
	{Name = "爆裂圣光碎片", ItemID = 219310}, 
	{Name = "充能雷鸫飞羽", ItemID = 219294}, 
	{Name = "贪食蜂鸣器", ItemID = 219298}, 
	--11.0
}
--群体伤害饰品

local SpecialItemCache = {
	{Name = "唤雾者的陶笛", ItemID = 178715}, 
	{Name = "制剂：死亡之吻", ItemID = 215174}, 
}
--其他特殊饰品

WoWAssistantAPI:SetScript("OnEvent", function(self, event, ...)
	local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = ...
	if event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_EQUIPMENT_CHANGED" then

		local count = 0
		for i = 150, 1, -1 do
			local name = GetMacroInfo(i)
			if name and string.sub(name, 1, 3) == "DA_" then
				DeleteMacro(i)
				--print('删除宏:'..name)
				count = count + 1
			end
		end
		if count > 0 then
			--print('总计删除:'..count..'个宏')
		end
		--清空所有'DA_'开头的宏
	
		WoWAssistant_Trinket13 = GetInventoryItemID("player", 13)
		WoWAssistant_Trinket14 = GetInventoryItemID("player", 14)
		
		for i = 1, #AttributesEnhancedItemCache do
			local ItemID = AttributesEnhancedItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket13 then
				AttributesEnhancedItemID13 = ItemID
				break
			else
				AttributesEnhancedItemID13 = nil
			end
		end
		for i = 1, #AttributesEnhancedItemCache do
			local ItemID = AttributesEnhancedItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket14 then
				AttributesEnhancedItemID14 = ItemID
				break
			else
				AttributesEnhancedItemID14 = nil
			end
		end
		--属性增强饰品
		
		for i = 1, #DirectSingleHealItemCache do
			local ItemID = DirectSingleHealItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket13 then
				DirectSingleHealItemID13 = ItemID
				break
			else
				DirectSingleHealItemID13 = nil
			end
		end
		for i = 1, #DirectSingleHealItemCache do
			local ItemID = DirectSingleHealItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket14 then
				DirectSingleHealItemID14 = ItemID
				break
			else
				DirectSingleHealItemID14 = nil
			end
		end
		--单体治疗饰品
		
		for i = 1, #DirectAoeHealItemCache do
			local ItemID = DirectAoeHealItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket13 then
				DirectAoeHealItemID13 = ItemID
				break
			else
				DirectAoeHealItemID13 = nil
			end
		end
		for i = 1, #DirectAoeHealItemCache do
			local ItemID = DirectAoeHealItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket14 then
				DirectAoeHealItemID14 = ItemID
				break
			else
				DirectAoeHealItemID14 = nil
			end
		end
		--群体治疗饰品
		
		for i = 1, #DirectSingleDPSItemCache do
			local ItemID = DirectSingleDPSItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket13 then
				DirectSingleDPSItemID13 = ItemID
				break
			else
				DirectSingleDPSItemID13 = nil
			end
		end
		for i = 1, #DirectSingleDPSItemCache do
			local ItemID = DirectSingleDPSItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket14 then
				DirectSingleDPSItemID14 = ItemID
				break
			else
				DirectSingleDPSItemID14 = nil
			end
		end
		--单体伤害饰品
		
		for i = 1, #DirectAoeDPSItemCache do
			local ItemID = DirectAoeDPSItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket13 then
				DirectAoeDPSItemID13 = ItemID
				break
			else
				DirectAoeDPSItemID13 = nil
			end
		end
		for i = 1, #DirectAoeDPSItemCache do
			local ItemID = DirectAoeDPSItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket14 then
				DirectAoeDPSItemID14 = ItemID
				break
			else
				DirectAoeDPSItemID14 = nil
			end
		end
		--群体伤害饰品
		
		for i = 1, #SpecialItemCache do
			local ItemID = SpecialItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket13 then
				SpecialItemID13 = ItemID
				break
			else
				SpecialItemID13 = nil
			end
		end
		for i = 1, #SpecialItemCache do
			local ItemID = SpecialItemCache[i].ItemID
			if ItemID == WoWAssistant_Trinket14 then
				SpecialItemID14 = ItemID
				break
			else
				SpecialItemID14 = nil
			end
		end
		--其他特殊饰品
		
	end
end)

function CloneTable(org)
    local function copy(org, res)
        for k,v in pairs(org) do
            if type(v) ~= "table" then
                res[k] = v;
            else
                res[k] = {};
                copy(v, res[k])
            end
        end
    end
 
    local res = {}
    copy(org, res)
    return res
end

function DA_ObjectId(Unit)
	--local GUID = UnitGUID(Unit)
    --local ts = string.reverse(GUID)
    --local param1, param2 = string.find(ts, "-")
    --local m = string.len(GUID) - param2 + 1
    --local result = string.sub(GUID, 1, m-1)
    --local ts = string.reverse(result)
    --local param1, param2 = string.find(ts, "-")
    --local m = string.len(result) - param2 + 1
    --local result2 = string.sub(result, m+1, string.len(result)) 
    --return result2
	if UnitExists(Unit) then
		return tonumber(UnitGUID(Unit):match("-(%d+)-%x+$"), 10)
	end
end

function DA_Sound_Disable()
	--静音
	DA_Sound_Var = GetCVar("Sound_EnableSFX")
	DA_Sound_BeforeVar = DA_Sound_Var
	if DA_Sound_Var == "1" then
		SetCVar("Sound_EnableSFX", 0)
	end
end

function DA_Sound_Enable()
	--恢复声音
	if DA_Sound_BeforeVar == "1" then
		SetCVar("Sound_EnableSFX", 1)
	end
end
		
function DA_GetUnitNameCount(Name)
	--从Cache表中获取名字为Name的单位数量
	local Count = 0
	local Cache = nil
	if Balance_EnemyCacheHasThreat and #Balance_EnemyCacheHasThreat > 0 then
		Cache = Balance_EnemyCacheHasThreat
	end
	if Feral_EnemyCacheHasThreat and #Feral_EnemyCacheHasThreat > 0 then
		Cache = Feral_EnemyCacheHasThreat
	end
	if Restoration_EnemyCache and #Restoration_EnemyCache > 0 then
		Cache = Restoration_EnemyCache
	end
	if Cache then
		for k, v in ipairs(Cache) do
			if UnitExists(v.Unit) and UnitName(v.Unit) == Name then
				Count = Count + 1
			end
		end
	end
	return Count
end

function DA_TargetUnit(Unit)
	--选择目标
	if not Unit then return end
	if UnitIsUnit('target', Unit) then return end
	if (UnitCanAttack("player", Unit) or UnitIsEnemy("player", Unit)) and Unit ~= 'targettarget_harm' then
	--可攻击或敌对目标
		if IsActiveBattlefieldArena() then
		--竞技场中
			--print('目标是竞技场单位')
			local found = false
			local color = nil
			for k, v in ipairs(TargetColorCache) do
				if v.target == Unit then
					found = true
					color = v.color
					break
				end
			end
			if found then
				--print('选择目标 ['..Unit..'] 颜色[ '..color..']')
				DA_pixel_target_frame.texture:SetColorTexture(color, 0, 0)
			else
				print('DA_TargetUnit未找到竞技场单位: '..Unit)
			end
		elseif string.lower(string.sub(Unit, 1, 9)) ~= "nameplate" then
		--目标不是姓名版目标nameplate1之类
			--print('目标不是姓名版目标')
			local WhichPartyTarget = string.sub(Unit, 1, -7)
			if not UnitIsUnit('player', WhichPartyTarget) then
			--如果该队友不是玩家自己
				if UnitIsUnit('target', WhichPartyTarget) then
				--如果选中了该队友
					DA_TargetUnit('targettarget_harm')
					--选择队友的敌对目标
					--print('选择队友的敌对目标')
				else
				--如果没有选中该队友
					DA_TargetUnit(WhichPartyTarget)
					--选择该队友指示
					--print('选择队友')
				end
			else
				--print('该队友是玩家自己')
			end
		else
		--目标是姓名板目标
			--print('目标是姓名板目标')
			if not UnitIsUnit('target', Unit) and not DA_Start_TargetNearest_Unit then
			--如果当前目标不是姓名板目标
				if UnitExists('target') then
					DA_traversedGUIDs = DA_traversedGUIDs or {}
					DA_traversedGUIDs[UnitGUID('target')] = true
				end
				if DA_traversedGUIDs_Last and not DA_traversedGUIDs_Last[UnitGUID(Unit)] then
					DA_CanNotTargetNearest = DA_CanNotTargetNearest or {}
					if not DA_UnitIsInTable(UnitGUID(Unit), DA_CanNotTargetNearest) then
						DA_TargetVisibleTime = GetTime()
						--print(UnitName(Unit)..' 不在TAB能选到的范围内')
						table.insert(DA_CanNotTargetNearest, {
							Unit = Unit, 
							UnitGUID = UnitGUID(Unit), 
						})
					end
				else
					if C_PvP.IsActiveBattlefield() then
						DA_pixel_target_frame.texture:SetColorTexture(0.45, 0, 0)
						--选中最近的敌人(玩家)
					else
						DA_pixel_target_frame.texture:SetColorTexture(0.46, 0, 0)
						--选中最近的敌人
					end
					--print('选中最近的敌人')
					--print(UnitName(Unit)..'  '..UnitGUID(Unit))
					DA_Start_TargetNearest_Unit = Unit
					Just_OneTargetNearest = 1
					--默认只能选中一个单位,如果0.1秒后没触发"PLAYER_TARGET_CHANGED"事件,则认为需要选择的目标不可选中
					if not Just_OneTargetNearest_C_TimerIng then
						Just_OneTargetNearest_C_TimerIng = 1
						C_Timer.After(0.1, function()
							Just_OneTargetNearest_C_TimerIng = nil
							if Just_OneTargetNearest then
								DA_CanNotTargetNearest = DA_CanNotTargetNearest or {}
								if DA_Start_TargetNearest_Unit and not DA_UnitIsInTable(UnitGUID(DA_Start_TargetNearest_Unit), DA_CanNotTargetNearest) then
									--print(UnitName(DA_Start_TargetNearest_Unit)..' 不可选中')
									DA_TargetVisibleTime = GetTime()
									table.insert(DA_CanNotTargetNearest, {
										Unit = DA_Start_TargetNearest_Unit, 
										UnitGUID = UnitGUID(DA_Start_TargetNearest_Unit), 
									})
								end
								DA_Start_TargetNearest_Unit = nil
							end
						end)
					end
				end
			end
		end
	else
		--友方目标
		if string.lower(string.sub(Unit, 1, 9)) ~= "nameplate" and string.lower(string.sub(Unit, 1, 18)) ~= 'ForbiddenNamePlate' then
		--目标不是姓名版目标nameplate1,ForbiddenNamePlate1之类
			if string.match(Unit, "target") == "target" and Unit ~= 'targettarget_help' and Unit ~= 'targettarget_harm' then
			--目标是队友的目标
				local WhichPartyTarget = string.sub(Unit, 1, -7)
				if not UnitIsUnit('player', WhichPartyTarget) then
				--如果该队友不是玩家自己
					if UnitIsUnit('target', WhichPartyTarget) then
					--如果选中了该队友
						DA_TargetUnit('targettarget_help')
						--选择队友的友方目标
						--print('选择队友的友方目标')
					else
					--如果没有选中该队友
						DA_TargetUnit(WhichPartyTarget)
						--选择该队友指示
						--print('选择队友')
					end
				else
					--print('该队友是玩家自己')
				end
			else
			--目标是队友
				--print('目标是队友')
				local found = false
				local color = nil
				for k, v in ipairs(TargetColorCache) do
					if v.target == Unit then
						found = true
						color = v.color
						break
					end
				end
				if found then
					--print('选择目标 ['..Unit..'] 颜色[ '..color..']')
					DA_pixel_target_frame.texture:SetColorTexture(color, 0, 0)
				else
					print('DA_TargetUnit未找到友方目标: '..Unit)
				end
			end
		else
		--目标是姓名板目标
			--print('目标是姓名板目标')
			if not UnitIsUnit('target', Unit) and not DA_Start_TargetNearest_Unit then
			--如果当前目标不是姓名板目标
				if UnitExists('target') then
					DA_traversedGUIDs = DA_traversedGUIDs or {}
					DA_traversedGUIDs[UnitGUID('target')] = true
				end
				DA_pixel_target_frame.texture:SetColorTexture(0.44, 0, 0)
				--选择最近的盟友
				--print('选择最近的盟友')
				--print(UnitName(Unit)..'  '..UnitGUID(Unit))
				DA_Start_TargetNearest_Unit = Unit
				Just_OneTargetNearest = 1
				if not Just_OneTargetNearest_C_TimerIng then
					Just_OneTargetNearest_C_TimerIng = 1
					C_Timer.After(0.05, function()
						Just_OneTargetNearest_C_TimerIng = nil
						if Just_OneTargetNearest then
							DA_CanNotTargetNearest = DA_CanNotTargetNearest or {}
							if DA_Start_TargetNearest_Unit and not DA_UnitIsInTable(UnitGUID(DA_Start_TargetNearest_Unit), DA_CanNotTargetNearest) then
								--print(UnitName(DA_Start_TargetNearest_Unit)..' 不可选中')
								DA_TargetVisibleTime = GetTime()
								table.insert(DA_CanNotTargetNearest, {
									Unit = DA_Start_TargetNearest_Unit, 
									UnitGUID = UnitGUID(DA_Start_TargetNearest_Unit), 
								})
							end
							DA_Start_TargetNearest_Unit = nil
						end
					end)
				end
			end
		end
	end
end

function DA_CastSpellByName(spellName)
	--施放技能
	if not spellName then return end
	local CastCache = nil
    local found = false
    local color = nil
    local name = nil
	if DA_GetSpecialization() == 105 then
		CastCache = DA_CastLevelColorCache_Restoration
	elseif DA_GetSpecialization() == 103 then
		CastCache = DA_CastLevelColorCache_Feral
	elseif DA_GetSpecialization() == 102 then
		CastCache = DA_CastLevelColorCache_Balance
	end
    for k, v in ipairs(CastCache) do
        if v.NameCN == spellName then
            found = true
            color = v.color
            name = v.NameCN
            break
        end
    end
    if found then
		DA_SelfCastSpellName = name
		--标记插件将要使用的技能
        --print('对 ['..UnitName('target')..'] 施放 ['..name..'] 颜色 ['..color..']')
		DA_pixel_spell_frame.texture:SetColorTexture(0, 0, color)
    else
        print('DA_CastSpellByName未找到: '..spellName)
    end
end

function DA_CastSpellByID(spellID)
	--施放技能
	if not spellID then return end
	local CastCache = nil
    local found = false
    local color = nil
    local name = nil
	if DA_GetSpecialization() == 105 then
		CastCache = DA_CastLevelColorCache_Restoration
	elseif DA_GetSpecialization() == 103 then
		CastCache = DA_CastLevelColorCache_Feral
	elseif DA_GetSpecialization() == 102 then
		CastCache = DA_CastLevelColorCache_Balance
	end
	if CastCache then
		for k, v in ipairs(CastCache) do
			if v.ID == spellID then
				found = true
				color = v.color
				name = v.NameCN
				break
			end
		end
		if found then
			DA_SelfCastSpellName = name
			--标记插件将要使用的技能
			--print('对 ['..UnitName('target')..'] 施放 ['..name..'] 颜色 ['..color..']')
			DA_pixel_spell_frame.texture:SetColorTexture(0, 0, color)
		else
			print('DA_CastSpellByID未找到: '..spellID)
		end
    end
end

function DA_UseItem(ItemID)
	--使用物品
	if not ItemID then return end
    local found = false
    local color = nil
    local name = nil
    for k, v in ipairs(ItemColorCache) do
        if v.ID == ItemID then
            found = true
            color = v.color
            name = v.Name
            break
        end
    end
    if found then
        --print('使用 ['..name..'] 颜色 ['..color..']')
		DA_pixel_spell_frame.texture:SetColorTexture(0, color, 0)
    else
        print('DA_UseItem未找到: '..ItemID)
    end
end

function DA_SpellStopCasting()
	--中断施法
	DA_pixel_event_frame.texture:SetColorTexture(0, 0.01, 0)
	if not ClearSpellStopCastingColor_C_TimerIng then
		ClearSpellStopCastingColor_C_TimerIng = 1
		C_Timer.After(0.1, function()
			DA_pixel_event_frame.texture:SetColorTexture(0, 1, 0)
			ClearSpellStopCastingColor_C_TimerIng = nil
		end)
	end
end

function DA_Cancelform()
	--取消变形
	DA_pixel_event_frame.texture:SetColorTexture(0, 0.12, 0)
	if not ClearSpellCancelformColor_C_TimerIng then
		ClearSpellCancelformColor_C_TimerIng = 1
		C_Timer.After(0.1, function()
			DA_pixel_event_frame.texture:SetColorTexture(0, 1, 0)
			ClearSpellCancelformColor_C_TimerIng = nil
		end)
	end
end

function DA_GetSpellInRange(spellID, Unit)
	--获取单位是否在法术射程内
	if not WoWAssistantUnlocked then return true end
	local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(spellID)
	local X1, Y1, Z1 = ObjectPosition("player")
	local X2, Y2, Z2 = ObjectPosition(Unit)
	local PlayerReach = UnitCombatReach("player")
	local UnitReach = UnitCombatReach(Unit)
	if DA_GetPositionDistance(X1, Y1, Z1, X2, Y2, Z2) - PlayerReach - UnitReach < maxRange then
		return true
	else
		return false
	end
end

function DA_GetAOESpellInRange(AoespellID, X, Y, Z)
	--获取坐标点是否在范围法术射程内
	if not WoWAssistantUnlocked then return true end
	local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(AoespellID)
	local X2, Y2, Z2 = ObjectPosition("player")
	if DA_GetPositionDistance(X, Y, Z, X2, Y2, Z2) < maxRange - 2.5 then
		return true
	else
		return false
	end
end

function DA_GetLineOfSightPosition(X, Y, Z)
	--获取坐标点是否在视野内
	if not WoWAssistantUnlocked then return true end
	local X2, Y2, Z2 = ObjectPosition("player")
	if TraceLine(X,Y,Z + 2,X2,Y2,Z2 + 2, 0x10) == nil then
		return true
	else
		return false
	end
end

function DA_GetFacingOfPosition(Unit, Degrees, X, Y, Z)
	--获取Unit是否朝向坐标点
	if not WoWAssistantUnlocked then return true end
	if UnitExists(Unit) and UnitIsVisible(Unit) then
		local Angle1,Angle2,Angle3
		local Angle1 = ObjectFacing(Unit)
		local Y1,X1,Z1 = ObjectPosition(Unit)
		local Y2,X2,Z2 = X, Y, Z
		if Y1 and X1 and Z1 and Y2 and X2 and Z2 and Angle1 then
			local deltaY = Y2 - Y1
			local deltaX = X2 - X1
			Angle1 = math.deg(math.abs(Angle1-math.pi*2))
			if deltaX > 0 then
				Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2)+math.pi)
			elseif deltaX <0 then
				Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2))
			end
			if Angle2-Angle1 > 180 then
				Angle3 = math.abs(Angle2-Angle1-360)
			elseif Angle1-Angle2 > 180 then
				Angle3 = math.abs(Angle1-Angle2-360)
			else
				Angle3 = math.abs(Angle2-Angle1)
			end
			--print(Angle3)
			if (Angle3 < Degrees) or (math.abs(X2 - X1) <= 1 and math.abs(Y2 - Y1) <= 1 and math.abs(Z2 - Z1) <= 1) then
				return true
			else
				return false
			end
		end
	end
end

function DA_IsCastingSpell(spellID)
	--获取玩家是否在读条该技能
	if UnitCastingInfo("player") and UnitCastingInfo("player") == DA_GetSpellInfo(spellID) then
		return true
	else
		return false
	end
end

function DA_GetNovaDistance(Unit1,Unit2)
	--获取两个单位的间距
	if not WoWAssistantUnlocked then return 1 end
	if  UnitExists(Unit1) and UnitIsVisible(Unit1) and UnitExists(Unit2) and UnitIsVisible(Unit2) then
		local Distance = GetDistanceBetweenObjects(Unit1, Unit2) - UnitCombatReach(Unit1) - UnitCombatReach(Unit2)
		if Distance < 0 then Distance = 0 end
		return Distance
	else
		return 1000
	end
end

function DA_GetFacing(Unit1, Unit2, Degrees)
	--获取Unit1是否朝向Unit2
	if not WoWAssistantUnlocked then return true end
	if Unit2 == nil then
		Unit2 = "player"
	end
	if UnitExists(Unit1) and UnitIsVisible(Unit1) and UnitExists(Unit2) and UnitIsVisible(Unit2) then
		if Degrees then
			local Angle1,Angle2,Angle3
			local Angle1 = ObjectFacing(Unit1)
			local Angle2 = ObjectFacing(Unit2)
			local Y1,X1,Z1 = ObjectPosition(Unit1)
			local Y2,X2,Z2 = ObjectPosition(Unit2)
			if Y1 and X1 and Z1 and Angle1 and Y2 and X2 and Z2 and Angle2 then
				local deltaY = Y2 - Y1
				local deltaX = X2 - X1
				Angle1 = math.deg(math.abs(Angle1-math.pi*2))
				if deltaX > 0 then
					Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2)+math.pi)
				elseif deltaX <0 then
					Angle2 = math.deg(math.atan(deltaY/deltaX)+(math.pi/2))
				end
				if Angle2-Angle1 > 180 then
					Angle3 = math.abs(Angle2-Angle1-360)
				elseif Angle1-Angle2 > 180 then
					Angle3 = math.abs(Angle1-Angle2-360)
				else
					Angle3 = math.abs(Angle2-Angle1)
				end
				--print(Angle3)
				if (Angle3 < Degrees) or (math.abs(X2 - X1) <= 1 and math.abs(Y2 - Y1) <= 1 and math.abs(Z2 - Z1) <= 1) then
					return true
				else
					return false
				end
			end
		else
			return ObjectIsFacing(Unit1, Unit2)
		end
	end
end

function DA_FaceToUnit(Unit)
	--朝向单位
	if not WoWAssistantUnlocked then return end
	if UnitExists(Unit) and UnitIsVisible(Unit) and not IsPlayerMoving() and UnitGUID(Unit) ~= UnitGUID("player") then
		local PlayerRadians = ObjectFacing("player")
		local PlayerAngle = ObjectFacing("player") * 180 / math.pi
		local Y1,X1,Z1 = ObjectPosition("player")
		local Y2,X2,Z2 = ObjectPosition(Unit)
		if Y1 and X1 and Z1 and Y2 and X2 and Z2 and PlayerRadians <= 2 * math.pi then
			local deltaY = Y2 - Y1
			local deltaX = X2 - X1
			local Radians = math.atan2(deltaX, deltaY)
			local Angle = math.atan2(deltaX, deltaY) * 180 / math.pi
			if Radians < 0 then
				Radians = Radians + (2 * math.pi)
			end
			if Angle < 0 then
				Angle = Angle + 360
			end
			--print("玩家弧度: "..PlayerRadians)
			--print("玩家角度: "..PlayerAngle)
			--print("弧度: "..Radians)
			--print("角度: "..Angle)
			FaceDirection(Radians, false)
		end
	end
end

function DA_FaceToPosition(X, Y, Z)
	--朝向坐标
	if not WoWAssistantUnlocked then return end
	local PlayerRadians = ObjectFacing("player")
	local PlayerAngle = ObjectFacing("player") * 180 / math.pi
	local X1,Y1,Z1 = ObjectPosition("player")
	if X1 and Y1 and Z1 and X and Y and Z and X ~= X1 and Y ~= Y1 and Z ~= Z1 and PlayerRadians <= 2 * math.pi then
		local deltaX = X - X1
		local deltaY = Y - Y1
		local Radians = math.atan2(deltaY, deltaX)
		local Angle = math.atan2(deltaY, deltaX) * 180 / math.pi
		if Radians < 0 then
			Radians = Radians + (2 * math.pi)
		end
		if Angle < 0 then
			Angle = Angle + 360
		end
		--print("玩家弧度: "..PlayerRadians)
		--print("玩家角度: "..PlayerAngle)
		--print("弧度: "..Radians)
		--print("角度: "..Angle)
		FaceDirection(Radians, true)
	end
end

function DA_GetPositionDistance(X1, Y1, Z1, X2, Y2, Z2)
	--获取两个点的距离
	if not WoWAssistantUnlocked then return 1000 end
	if X1 and Y1 and Z1 and X2 and Y2 and Z2 then
		return math.sqrt(((X2-X1)^2)+((Y2-Y1)^2)+((Z2-Z1)^2))
	else
		return 1000
	end
end

function DA_GetLineOfSight(Unit1,Unit2)
	--获取Unit1是在Unit2视野内
	if not WoWAssistantUnlocked then return true end
	if Unit2 == nil then
		if Unit1 == "player" then
			Unit2 = "target"
		else
			Unit2 = "player"
		end
	end
	if UnitExists(Unit1) and UnitIsVisible(Unit1) and UnitExists(Unit2) and UnitIsVisible(Unit2) then
		local X1,Y1,Z1 = ObjectPosition(Unit1)
		local X2,Y2,Z2 = ObjectPosition(Unit2)
		if TraceLine(X1,Y1,Z1 + 2,X2,Y2,Z2 + 2, 0x10) == nil then
			return true
		else
			--特殊目标判断
			local CanTraceLine = nil
			if Unit1 == "player" then
				Unit2 = Unit2
				Unit1 = "player"
			elseif Unit2 == "player" then
				Unit2 = Unit1
				Unit1 = "player"
			end
			if DA_GetNovaDistance("player", Unit2) < 45 then
				--只判断45码内的特殊目标
				if UnitName("boss1") == "塞塔里斯的化身" then
					--塞塔里斯神庙-塞塔里斯的化身,所有人都在视野中
					CanTraceLine = 1
				end
				if UnitCanAttack("player", Unit2) then
					--敌对目标
					local skipLoSTableHarm = {
						[56754] = "", -- Azure Serpent (Shado'pan Monestary)
						[56895] = "", -- Weak Spot - Raigon (Gate of the Setting Sun)
						[76585] = "", 	-- Ragewing
						[77692] = "", 	-- Kromog
						[77182] = "", 	-- Oregorger
						[96759] = "", 	-- Helya
						[100360] = "",	-- Grasping Tentacle (Helya fight)
						[100354] = "",	-- Grasping Tentacle (Helya fight)
						[100362] = "",	-- Grasping Tentacle (Helya fight)
						[98363] = "",	-- Grasping Tentacle (Helya fight)
						[99803] = "", -- Destructor Tentacle (Helya fight)
						[99801] = "", -- Destructor Tentacle (Helya fight)
						[98696] = "", 	-- Illysanna Ravencrest (Black Rook Hold)
						[114900] = "", -- Grasping Tentacle (Trials of Valor)
						[114901] = "", -- Gripping Tentacle (Trials of Valor)
						[116195] = "", -- Bilewater Slime (Trials of Valor)
						[120436] = "", -- Fallen Avatar (Tomb of Sargeras)
						[116939] = "", -- Fallen Avatar (Tomb of Sargeras)
						[118462] = "", -- Soul Queen Dejahna
						[119072] = "", -- Desolate Host
						[118460] = "", -- Engine of Souls
						--[86644] = "", -- Ore Crate from Oregorger boss
						[122450] = "", -- 安托鲁斯，燃烧王座-加洛西灭世者
						[122773] = "", -- 安托鲁斯，燃烧王座-加洛西灭世者-屠戮者
						[122778] = "", -- 安托鲁斯，燃烧王座-加洛西灭世者-歼灭者
						[122578] = "", -- 安托鲁斯，燃烧王座-金加洛斯
						[131863] = "", -- 维克雷斯庄园-贪食的拉尔
						[134691] = "", -- Static-charged Dervish (Temple of Sethraliss)
						[137405] = "", -- Gripping Terror (Siege of Boralus)
						[140447] = "", -- Demolishing Terror (Siege of Boralus)
						[137119] = "", -- Taloc (Uldir1)
						[137578] = "", -- Blood shtorm (Uldir - Taloc's fight)
						[138959] = "", -- Coalesced Blood (Uldir - Taloc's fight)
						[138017] = "", -- Cudgel of Gore (Uldir - Taloc's fight)
						[130217] = "", -- Nazmani Weevil (Uldir - Taloc's fight)
						[140286] = "", -- Uldir Defensive Beam *Uldir)
						[138530] = "", -- Volatile Droplet (Uldir - Taloc's fight)
						[133392] = "", -- Sethraliss
						[146256] = "", -- Laminaria
						[150773] = "", -- Blackwater Behemoth Mob
						[152364] = "", -- Radiance of Azshara
						[152671] = "", -- Wekemara
						[157602] = "", -- Drest'agath - Ny'alotha
						[158343] = "", -- Organ of Corruption - Ny'alotha
						[166608] = "", -- Mueh'zala - De Other Side
						[166618] = "", -- Other Side Adds
						[169769] = "", -- Other Side Adds
						[171665] = "", -- Other Side Adds
						[168326] = "", -- Other Side Adds
						[164407] = "", -- Sludgefist - Castle Nathria
					}
					if (skipLoSTableHarm[tonumber(string.match(UnitGUID(Unit1),"-(%d+)-%x+$"))] or skipLoSTableHarm[tonumber(string.match(UnitGUID(Unit2),"-(%d+)-%x+$"))]) and UnitAffectingCombat(Unit2) then
						CanTraceLine = 1
					end
				else
					--友善目标
					local skipLoSTableHelp = {
						[165759] = "", -- 凯尔萨斯·逐日者
					}
					if skipLoSTableHelp[tonumber(string.match(UnitGUID(Unit1),"-(%d+)-%x+$"))] or skipLoSTableHelp[tonumber(string.match(UnitGUID(Unit2),"-(%d+)-%x+$"))] then
						CanTraceLine = 1
					end
					if AuraUtil.FindAuraByName('灵能突袭', Unit2, "HARMFUL") then
						--安托鲁斯，燃烧王座[灵能突袭]
						CanTraceLine = 1
					end
				end
			end
			if CanTraceLine then
				return true
			else
				return false
			end
		end
	else
		return true
	end
end

function DA_GetTargetCanAttack(Unit, SpellID)
	--判断目标是否可以被SpellID攻击
	if WoWAssistantUnlocked then
		if DA_IsSpellInRange(SpellID, Unit) == 1 and DA_GetLineOfSight("player", Unit) and not UnitIsDeadOrGhost(Unit) and (not UnitIsFriend(Unit, "player") or UnitIsEnemy(Unit, "player")) and UnitCanAttack("player",Unit) then
			--print(UnitName(Unit).." :可以攻击")
			return true
		else
			return false
		end
	else
		if DA_IsSpellInRange(SpellID, Unit) == 1 and not UnitIsDeadOrGhost(Unit) and (not UnitIsFriend(Unit, "player") or UnitIsEnemy(Unit, "player")) and UnitCanAttack("player",Unit) then
			--print(UnitName(Unit).." :可以攻击")
			return true
		else
			return false
		end
	end
end

function DA_GetTargetCanAttackRange(Unit, Distance)
	--判断距离Distance内的目标是否可以攻击
	if not WoWAssistantUnlocked then return true end
	if DA_GetNovaDistance("player", Unit) <= Distance and DA_GetLineOfSight("player", Unit) and not UnitIsDeadOrGhost(Unit) and (not UnitIsFriend(Unit, "player") or UnitIsEnemy(Unit, "player")) and UnitCanAttack("player",Unit) then
		--print(UnitName(Unit).." :可以攻击")
		return true
	else
		return false
	end
end

function DA_UnitHasEnrage(unitid)
	--获取单位是否存在激怒BUFF
	local UnitHasEnrage = nil
	local index = 1
	while true do
		local name, icon, count, dispelType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID = DA_UnitBuff(unitid, index)
		if not spellID then
			break
		end
		local timeLeft = expirationTime and expirationTime > GetTime() and (expirationTime - GetTime()) or 0
		--激怒剩余时间
		local timeDuration = duration and duration - timeLeft
		--激怒已持续时间
		
		if timeLeft > 0 then
		--如果激怒有剩余时间
			if timeDuration < 0.2 then
			--激怒存在0.2秒后才驱散
				return
			end
		end
		
		if dispelType == "" then
			UnitHasEnrage = 1
		end
		if ((spellID == 320703) and count < 5) then
			--特定法术层数小于5层则忽视, 比如通灵战潮小怪的[沸腾怒气]
			UnitHasEnrage = nil
		end
		index = index + 1
	end
	if UnitHasEnrage then
		return true
	else
		return false
	end
end

function DA_IsSpecialEnemy(unitid)
	--获取单位是否为特殊攻击目标
	local SpecialEnemyCache = {
		--{Name = "团队副本训练假人", GUID = 113964, Type = "", Instance = "梦境林地-测试"},
		{Name = "爆炸物", GUID = 120651, Type = "", Instance = "大秘境-词缀"},
		{Name = "联盟军旗", GUID = 14465, Type = "", Instance = "战场"},
		{Name = "部落军旗", GUID = 14466, Type = "", Instance = "战场"},
		{Name = "地缚图腾", GUID = 2630, Type = "", Instance = "萨满祭司"},
		{Name = "战栗图腾", GUID = 5913, Type = "", Instance = "萨满祭司"},
		{Name = "灵魂链接图腾", GUID = 53006, Type = "", Instance = "萨满祭司"},
		{Name = "电能图腾", GUID = 61245, Type = "", Instance = "萨满祭司"},
		{Name = "天怒图腾", GUID = 105427, Type = "", Instance = "萨满祭司"},
		{Name = "反击图腾", GUID = 105451, Type = "", Instance = "萨满祭司"},
		{Name = "战旗", GUID = 119052, Type = "", Instance = "战士"},
	}
	local UnitIsSpecialEnemy = nil
	for k, v in ipairs(SpecialEnemyCache) do
		if DA_ObjectId(unitid) == v.GUID then
			UnitIsSpecialEnemy = 1
			break
		end
	end
	if UnitIsSpecialEnemy then
		return true
	else
		return false
	end
end

function DA_UnitIsInTable(GUID, Table)
	--获取目标是否在Table内(完整GUID),仅适用于结构中有{.Unit}类型且{.Unit}数据为标准UnitID类型的表格
	if not Table then return end
	local UnitIsInTable = nil
	for k, v in ipairs(Table) do
		if GUID == UnitGUID(v.Unit) then
			UnitIsInTable = 1
			break
		end
	end
	if UnitIsInTable then
		return true
	else
		return false
	end
end

function DA_ObjectIsInTable(ObjectId, Table)
	--获取对象是否在Table内(短GUID)
	local UnitIsInTable = nil
	for k, v in ipairs(Table) do
		if ObjectId == DA_ObjectId(v.Unit) then
			UnitIsInTable = 1
			break
		end
	end
	if UnitIsInTable then
		return true
	else
		return false
	end
end

function DA_GetPvpTalent(PVPTalent)
	--获取是否选择了指定PVP天赋
	local IsLearnPvpTalent = nil
	for k, v in ipairs(C_SpecializationInfo.GetAllSelectedPvpTalentIDs()) do
		local _, name = GetPvpTalentInfoByID(v)
		if v == PVPTalent or name == PVPTalent then
			IsLearnPvpTalent = 1
			break
		end
	end
	if IsLearnPvpTalent then
		return true
	else
		return false
	end
end

function DA_GetPvpTalentActivation()
	--获取PVP天赋是否激活
	local isInstance, instanceType = IsInInstance()
	if instanceType == "party" or instanceType == "raid"  then
		return false
	elseif not C_PvP.IsWarModeDesired() and not isInstance then
		return false
	else
		return true
	end
end

function DA_CancelShapeshiftForm()
	--取消变形(应对MiniBot变形BUG)
	DA_CancelShapeshiftFormFrame = DA_CancelShapeshiftFormFrame or CreateFrame("frame")
	DA_CancelShapeshiftFormFrame:SetScript("OnUpdate", function()
		local shiftFormID = GetShapeshiftFormID()
		if not shiftFormID then
			DA_CancelShapeshiftFormFrame:SetScript("OnUpdate", nil)
		end
		if shiftFormID == 5 then
			--熊形态
			CastSpellByID(5487)
		elseif shiftFormID == 1 then
			--猎豹形态
			CastSpellByID(768)
		elseif shiftFormID == 3 and not AuraUtil.FindAuraByName('旅行形态', "player", "HELPFUL") then
			--坐骑形态
			DA_CancelShapeshiftFormFrame:SetScript("OnUpdate", nil)
		elseif shiftFormID == 3 then
			--旅行形态
			CastSpellByID(783)
		elseif shiftFormID == 31 then
			--枭兽形态
			CastSpellByID(24858)
		elseif shiftFormID == 35 then
			--枭兽形态
			CastSpellByID(197625)
		end
	end)
end

function DA_GetBagHaveItem(SlotItemID)
	--判断背包里是否有指定物品
	local ID = nil
	local Count = 0
	for Container = 0, NUM_BAG_SLOTS + 1 do
		for Slot = 1, GetContainerNumSlots(Container) do
			local icon, itemCount, locked, quality, readable, lootable, itemLink, isFiltered, noValue, itemID = GetContainerItemInfo(Container, Slot)
			if SlotItemID == itemID then
				ID = itemID
				Count = Count + itemCount
			end
		end
	end
	return ID, Count
end

function DA_GetUnitIsBoss(unitid)
	--判断单位是否是Boss
	local IsBoss = nil
	for i = 1, 10 do
		if UnitExists("boss"..i) and not UnitIsDeadOrGhost("boss"..i) then
			if UnitGUID(unitid) == UnitGUID("boss"..i) then
				IsBoss = 1
				break
			end
		end
	end
	if IsBoss then
		return true
	else
		return false
	end
end
		
function DA_GetUnitInDistanceGUID(Distance, UnitGUID, Cache)
	--从Cache表中通过GUID获取玩家附近视野中Distance距离内是否存在指定单位
	for k, v in ipairs(Cache) do
		if DA_ObjectId(v.Unit) == UnitGUID and DA_GetLineOfSight(v.Unit, "player") and DA_GetNovaDistance(v.Unit, "player") <= Distance then
			return v.Unit
		end
	end
end

function DA_InteractUnitSituation(Cache)
	--从Cache表查找需要互动的单位进行互动
	if not WoWAssistantUnlocked or not Cache then return end
	if not IsStealthed() and not UnitIsGhost("player") and HasFullControl() then
		local InteractUnitID = nil
		DA_InteractUnitCache = {
			--{Name = "拉夫温", GUID = 158554, Type = "", Instance = "森林之心-测试"},
			--{Name = "飞翼勇士", GUID = 165605, Type = "", Instance = "通灵战潮"},
			--{Name = "肉钩", GUID = 170584, Type = "", Instance = "通灵战潮"},
			--{Name = "传送门", GUID = 162105, Type = "", Instance = "通灵战潮"},
			--{Name = "传送器", GUID = 169908, Type = "", Instance = "通灵战潮"},
			--{Name = "佐尔拉姆斯传送门", GUID = 165709, Type = "", Instance = "通灵战潮"},
			--{Name = "飞翼勇士", GUID = 168185, Type = "", Instance = "晋升堡垒"},
			--{Name = "飞翼勇士", GUID = 168275, Type = "", Instance = "晋升堡垒"},
			--{Name = "飞翼勇士", GUID = 168279, Type = "", Instance = "晋升堡垒"},
			--{Name = "飞翼勇士", GUID = 168283, Type = "", Instance = "晋升堡垒"},
			--{Name = "飞翼勇士", GUID = 164806, Type = "", Instance = "晋升堡垒"},
			--{Name = "飞翼勇士", GUID = 168249, Type = "", Instance = "晋升堡垒"},
			--{Name = "通灵扭曲", GUID = 171180, Type = "", Instance = "彼界"},
			{Name = "实验型松鼠炸弹", GUID = 164561, Type = "", Instance = "彼界"},
		}
		for k, v in ipairs(DA_InteractUnitCache) do
			local UnitID = DA_GetUnitInDistanceGUID(2.5, v.GUID, Cache)
			if UnitID then
				InteractUnitID = UnitID
				break
			end
		end
		if InteractUnitID then
			if DA_ObjectId(InteractUnitID) == 164561 and not DA_IsCastingSpell(320140) then
			--与部分单位互动时需要读条,因此先中断非该读条技能
				DA_SpellStopCasting()
			end
			ObjectInteract(InteractUnitID)
		end
	end
end

function DA_UnitGroupRolesAssigned(unitid)
	--获取单位职责
	local Assigned = UnitGroupRolesAssigned(unitid)
	return Assigned
end

function DA_GetSpecialization()
	--获取玩家天赋专精
	local Specialization = nil
	if GetSpecializationInfo and GetSpecialization then
		--正式服
		local Spec = GetSpecialization()
		if Spec then
			Specialization = GetSpecializationInfo(Spec)
		end
		return Specialization
	else
		--怀旧服
		local specIndex = 0
		local max = 0
		for tabIndex = 1, GetNumTalentTabs() do
			local spent = select(3, GetTalentTabInfo(tabIndex))
			if spent > max then
				specIndex = tabIndex
				max = spent
			end
		end
		if specIndex == 0 then
			return nil
		else
			name, texture, pointsSpent, fileName = GetTalentTabInfo(specIndex)
			if name == '平衡' then
				Specialization = 102
			elseif name == '野性战斗' then
				Specialization = 103
			elseif name == '恢复' then
				Specialization = 105
			else
				Specialization = nil
			end
		end
		return Specialization
	end
end

function DA_IsGlyphEquipped(glyphID)
	--通过雕文的法术ID检测玩家是否装备该雕文 for WLK
	--54825为[治疗之触雕文]
    for i = 1, 6 do
        local enabled, glyphType, glyphSpell, icon = GetGlyphSocketInfo(i)
        if glyphSpell == glyphID then
            return true
        end
    end
    return false
end

function DA_GetItemCooldown(itemID)
	--获取物品冷却时间
    local start, duration, enable = C_Container.GetItemCooldown(itemID)
    local start2, duration2, enable2 = DA_GetSpellCooldown(113)
    if enable == 1 then
        local cooldown = duration - (GetTime() - start)
        if cooldown > 0 and duration2 ~= duration then
            return cooldown
        else
            return 0
        end
    else
		return 0
    end
end

function DA_IsSpellInRange(spellid, unitid)
	--获取技能是否在施法距离内
	if spellid and unitid then
		if C_Spell.IsSpellInRange then
			if C_Spell.IsSpellInRange(spellid, unitid) then
				return 1
			else
				return nil
			end
		else
			if IsSpellInRange(spellid, unitid) and IsSpellInRange(spellid, unitid) ~= 0 then
				return 1
			elseif IsSpellInRange(spellid, unitid) == 0 then
				return 0
			else
				return nil
			end
		end
	else
		return nil
	end
end

function DA_GetSpellInfo(spellIdentifier)
    -- 获取技能信息
	if not spellIdentifier then return nil end
    if C_Spell.GetSpellInfo then
        local spellInfo = C_Spell.GetSpellInfo(spellIdentifier)
        if spellInfo then
            return spellInfo.name, nil, spellInfo.iconID, spellInfo.castTime, spellInfo.minRange, spellInfo.maxRange, spellInfo.spellID
        end
    else
        return GetSpellInfo(spellIdentifier)
    end
end

function DA_GetSpellCharges(spellIdentifier)
    -- 获取技能充能信息
    if C_Spell.GetSpellCharges then
        local chargesInfo = C_Spell.GetSpellCharges(spellIdentifier)
        if chargesInfo then
            return chargesInfo.currentCharges, chargesInfo.maxCharges, chargesInfo.cooldownStartTime, chargesInfo.cooldownDuration
        end
    else
        return GetSpellCharges(spellIdentifier)
    end
end

function DA_GetSpellCooldown(spellIdentifier)
    -- 获取技能冷却信息
    if C_Spell.GetSpellCooldown then
        local cooldownInfo = C_Spell.GetSpellCooldown(spellIdentifier)
        if cooldownInfo then
            return cooldownInfo.startTime, cooldownInfo.duration, cooldownInfo.isEnabled
        end
    else
        return GetSpellCooldown(spellIdentifier)
    end
end

function DA_GetSpellCount(spellIdentifier)
    -- 获取技能可使用次数
    if C_Spell.GetSpellCastCount then
		return C_Spell.GetSpellCastCount(spellIdentifier)
    else
        return GetSpellCount(spellIdentifier)
    end
end

function DA_GetSpellLink(spellIdentifier)
    -- 获取技能链接
    if C_Spell.GetSpellLink then
        local link, spellID = C_Spell.GetSpellLink(spellIdentifier)
        if link then
            return link, spellID
        end
    else
        return GetSpellLink(spellIdentifier)
    end
end

function DA_UnitDebuff(unit, index)
    -- 获取单位指定索引的DEBUFF信息
    if C_UnitAuras and C_UnitAuras.GetDebuffDataByIndex then
        local debuffInfo = C_UnitAuras.GetDebuffDataByIndex(unit, index)
        if debuffInfo then
            return debuffInfo.name, debuffInfo.icon, debuffInfo.applications, debuffInfo.dispelName, debuffInfo.duration, debuffInfo.expirationTime, debuffInfo.sourceUnit, debuffInfo.isStealable, debuffInfo.nameplateShowPersonal, debuffInfo.spellId
        end
    else
        return UnitDebuff(unit, index)
    end
end

function DA_UnitBuff(unit, index)
    -- 获取单位指定索引的BUFF信息
    if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
        local buffInfo = C_UnitAuras.GetBuffDataByIndex(unit, index)
        if buffInfo then
            return buffInfo.name, buffInfo.icon, buffInfo.applications, buffInfo.dispelName, buffInfo.duration, buffInfo.expirationTime, buffInfo.sourceUnit, buffInfo.isStealable, buffInfo.nameplateShowPersonal, buffInfo.spellId
        end
    else
        return UnitBuff(unit, index)
    end
end

function DA_IsUsableSpell(spellIdentifier)
    -- 获取法术是否可用
    if C_Spell.IsSpellUsable then
        local isUsable, noMana = C_Spell.IsSpellUsable(spellIdentifier)
        if isUsable ~= nil then
            return isUsable, noMana
        end
    else
        return IsUsableSpell(spellIdentifier)
    end
end

function DA_GetCurrentWeekAffixes()
    -- 获取本周大秘境副词缀
    local affixes = C_MythicPlus.GetCurrentAffixes()
    local affixInfoList = {}
    if affixes then
        for _, affix in ipairs(affixes) do
            local name, description, filedataid = C_ChallengeMode.GetAffixInfo(affix.id)
            table.insert(affixInfoList, {id = affix.id, name = name, description = description})
			--print("词缀ID: "..affix.id..", 词缀名: "..name..", 效果: "..description)
        end
    else
        --print("没有找到大秘境词缀")
    end
    return affixInfoList
end
-- 调用函数并打印结果
--for k, v in ipairs(DA_GetCurrentWeekAffixes()) do
    --print("词缀ID: "..v.id..", 词缀名: "..v.name..", 效果: "..v.description)
--end

function DA_GetHasActiveAffix(activeAffix)
	-- 获取当前的大秘境副本是否存在指定词缀
	if IsInInstance() then
		local level, affixes, wasEnergized = C_ChallengeMode.GetActiveKeystoneInfo()
		for k, v in ipairs(affixes) do
			local name, description, filedataid = C_ChallengeMode.GetAffixInfo(v)
			if activeAffix == v or activeAffix == name then
				return true
			end
		end
	end
	return false
end

function DA_GetHealsSpecialExists(unitname)
	-- 从姓名版获取是否存在特定特殊治疗单位
    local count = 0
    local unitid = nil
	for i = 1, 20 do
		if _G["ForbiddenNamePlate"..i] and _G["ForbiddenNamePlate"..i].UnitFrame and _G["ForbiddenNamePlate"..i].UnitFrame.unit then
			local thisUnit = _G["ForbiddenNamePlate"..i].UnitFrame.unit
			if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) and not UnitIsDeadOrGhost(thisUnit) then
				if UnitName(thisUnit) == unitname and UnitCastingInfo(thisUnit) then
					--正在读条的[受难之魂]才算
					count = count + 1
					unitid = thisUnit
				end
			end
		end
	end
	for i = 1, 20 do
		if _G["NamePlate"..i] and _G["NamePlate"..i].UnitFrame and _G["NamePlate"..i].UnitFrame.unit then
			local thisUnit = _G["NamePlate"..i].UnitFrame.unit
			if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) and not UnitIsDeadOrGhost(thisUnit) then
				if UnitName(thisUnit) == unitname and UnitCastingInfo(thisUnit) then
					--正在读条的[受难之魂]才算
					count = count + 1
					unitid = thisUnit
				end
			end
		end
	end
	return unitid, count
end

function DA_GetUnitDistance(unitid)
	--获取敌对单位距离(友方目标大秘境中会受到保护,无法获取正确距离)
	local Range = select(2, LibStub("LibRangeCheck-3.0"):GetRange(unitid))
	if Range then
		return Range
	else
		return 9999
	end
end
local frameCounter = 0
function DA_CreateMacroButton(framename, button, macrotext)
    frameCounter = frameCounter + 1
    local uniqueFrameName = framename.."_"..frameCounter
    local frame = CreateFrame("Button", uniqueFrameName, UIParent, "SecureActionButtonTemplate")
    frame:RegisterForClicks("AnyDown", "AnyUp")
    frame:SetAttribute("type", "macro")
    frame:SetAttribute("macrotext", macrotext)
    SetBinding(button, nil)
    SetBinding(button, "CLICK "..uniqueFrameName..":LeftButton")
    --print('创建框架: '..uniqueFrameName..', '..button..', '..macrotext)
end

function DA_CheckPlayerRooted()
	--获取玩家是否被定身
    local numLossOfControl = C_LossOfControl.GetActiveLossOfControlDataCount()
    for i = 1, numLossOfControl do
        local locData = C_LossOfControl.GetActiveLossOfControlData(i)
		local timeRemaining = 999
        if locData and locData.locType == "ROOT" then
			--print(locData.timeRemaining)
			if locData.timeRemaining then
				timeRemaining = locData.timeRemaining
			end
			return true, timeRemaining, locData.spellID
        end
    end
    return false, 0, nil
end

function DA_GetUnitSpeed(unitid)
	--获取单位移动速度
	local speed, groundSpeed = GetUnitSpeed(unitid)
	if speed == 0 then 
		return tonumber(string.format("%.0f", groundSpeed/BASE_MOVEMENT_SPEED*100))
	else
		return tonumber(string.format("%.0f", speed/BASE_MOVEMENT_SPEED*100))
	end
end

function DA_UnitHasInfiniteBuff(unitid)
	--获取单位是否存在无限长时间的BUFF
    if C_UnitAuras and C_UnitAuras.GetBuffDataByIndex then
		for i = 1, 50 do
			local buff = C_UnitAuras.GetBuffDataByIndex(unitid, i)
			if not buff then break end
			if buff.duration == 0 then
				return true, buff.spellId
			end
		end
		return false
    else
		for i = 1, 50 do
			local name, _, _, _, _, duration _, _, _, spellId = UnitBuff(unitid, i)
			if not name then break end
			if duration == 0 then
				return true, spellId
			end
		end
		return false
	end
end

function DA_UnitHasInfiniteDeBuff(unitid)
	--获取单位是否存在无限长时间的DEBUFF
	--if C_PvP.IsActiveBattlefield() then return false end
	--战场/竞技场中直接返回假
	--if select(10, AuraUtil.FindAuraByName('眩晕', unitid, "HARMFUL")) == 1604 then return true end
	--部分DEBUFF直接返回真
	--if AuraUtil.FindAuraByName('抓握之血', unitid, "HARMFUL") then return false end
	--部分DEBUFF直接返回假
	--if AuraUtil.FindAuraByName('扭曲思绪', unitid, "HARMFUL") then return false end
	--部分DEBUFF直接返回假
	--if AuraUtil.FindAuraByName('流丝之墓', unitid, "HARMFUL") then return false end
	--部分DEBUFF直接返回假
    if C_UnitAuras and C_UnitAuras.GetDebuffDataByIndex then
		for i = 1, 50 do
			local debuff = C_UnitAuras.GetDebuffDataByIndex(unitid, i)
			if not debuff then break end
			if debuff.duration == 0 then
				return true, debuff.spellId
			end
		end
		return false
    else
		for i = 1, 50 do
			local name, _, _, _, _, duration _, _, _, spellId = UnitDeBuff(unitid, i)
			if not name then break end
			if duration == 0 then
				return true, spellId
			end
		end
		return false
    end
end

function DA_UnitHasDecelerationAndDamageDeBuff(unitid)
	--获取单位是否存在减速同时附带伤害的DEBUFF
    if C_UnitAuras and C_UnitAuras.GetDebuffDataByIndex then
		for i = 1, 50 do
			local debuff = C_UnitAuras.GetDebuffDataByIndex(unitid, i)
			if not debuff then break end
			local description = C_Spell.GetSpellDescription(debuff.spellId)
			--DEBUFF文字描述
            if description and (description:match("速度降") or description:match("减速") or description:match("降低")) and description:match("伤害") then
				return true, debuff.spellId
			end
		end
		return false
    else
		for i = 1, 50 do
			local name, _, _, _, _, duration _, _, _, spellId = UnitDeBuff(unitid, i)
			if not name then break end
			local description = C_Spell.GetSpellDescription(debuff.spellId)
			--DEBUFF文字描述
            if description and (description:match("速度降") or description:match("减速") or description:match("降低")) and description:match("伤害") then
				return true, spellId
			end
		end
		return false
    end
end

function DA_UnitIsArenaChosen(unitid)
	--竞技场中获取单位被几名敌方(非治疗职责)选中
	local IsArenaChosen = 0
	local status = DA_UnitGroupRolesAssigned(unitid)
	for ism = 1, 5 do
		local thisUnit = _G["arena"..ism]
		if UnitExists(thisUnit) and UnitIsUnit(thisUnit..'target', unitid) and status and status ~= "HEALER" then
			IsArenaChosen = IsArenaChosen + 1
		end
	end
	return IsArenaChosen
end

local mouseoverTime = 0
local mouseoverUnit = nil
local timerRunning = false
local function CheckMouseoverUnit(unitid, elapsed)
    local mouseoverGUID = UnitGUID("mouseover")
    if UnitExists("mouseover") and mouseoverGUID == UnitGUID(unitid) then
        if mouseoverUnit ~= mouseoverGUID then
            mouseoverUnit = mouseoverGUID
            mouseoverTime = 0
        else
            mouseoverTime = mouseoverTime + elapsed
            --print(UnitName(unitid)..' '..mouseoverTime)
        end
    else
        mouseoverUnit = nil
        mouseoverTime = 0
    end
    return mouseoverTime
end
local function StartTimer()
    if not timerRunning then
        timerRunning = true
        C_Timer.After(0.05, function()
            CheckMouseoverUnit("mouseover", 0.05)
            timerRunning = false
            StartTimer()
        end)
    end
end
StartTimer()
function DA_GetMouseoverUnitTime(unitid)
    -- 获取鼠标在unitid上的停留时间
    if UnitGUID("mouseover") == UnitGUID(unitid) then
        return mouseoverTime
    else
        return 0
    end
end

function DA_UnitIsVulnerable(unitid)
	--获取队友是否为近战伤害输出单位(容易受伤)
	local assigned = DA_UnitGroupRolesAssigned(unitid)
	local class = select(2, UnitClass(unitid))
	if assigned and assigned ~= 'TANK' and assigned ~= 'HEALER' then
		if class == 'ROGUE' or class == 'DEMONHUNTER' or class == 'MONK' or class == 'WARRIOR' or class == 'DEATHKNIGHT' or class == 'PALADIN' then
			return true
		else
			return false
		end
	else
		return false
	end
end