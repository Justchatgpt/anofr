--获取免疫控制的目标

local ImmuneControlUnitCache = {
	{["GUID"] = 174567, ["Name"] = "团队副本训练假人",["Instance"] = "炽蓝仙野",}, -- [1]
	{["GUID"] = 174569, ["Name"] = "训练假人",["Instance"] = "炽蓝仙野",}, -- [2]
	{["GUID"] = 164557, ["Name"] = "哈尔吉亚斯的碎片",["Instance"] = "赎罪大厅",}, -- [3]
	{["GUID"] = 167876, ["Name"] = "审判官西加尔",["Instance"] = "赎罪大厅",}, -- [4]
	{["GUID"] = 162047, ["Name"] = "贪食的蛮兵",["Instance"] = "赤红深渊",}, -- [5]
	{["GUID"] = 168318, ["Name"] = "弃誓哥利亚",["Instance"] = "晋升高塔",}, -- [6]
	{["GUID"] = 168844, ["Name"] = "拉科西斯",["Instance"] = "晋升高塔",}, -- [7]
	{["GUID"] = 162040, ["Name"] = "大监督者",["Instance"] = "赤红深渊",}, -- [8]
	{["GUID"] = 171376, ["Name"] = "首席管理者加弗林",["Instance"] = "赤红深渊",}, -- [9]
	{["GUID"] = 162057, ["Name"] = "大厅哨兵",["Instance"] = "赤红深渊",}, -- [10]
	{["GUID"] = 162038, ["Name"] = "皇家舞雾者",["Instance"] = "赤红深渊",}, -- [11]
	{["GUID"] = 165919, ["Name"] = "骷髅劫掠者",["Instance"] = "通灵战潮",}, -- [12]
	{["GUID"] = 172981, ["Name"] = "格里恩缝合憎恶",["Instance"] = "通灵战潮",}, -- [13]
	{["GUID"] = 173044, ["Name"] = "缝合助理",["Instance"] = "通灵战潮",}, -- [14]
	{["GUID"] = 163620, ["Name"] = "烂吐",["Instance"] = "通灵战潮",}, -- [15]
	{["GUID"] = 164578, ["Name"] = "缝肉的造物",["Instance"] = "通灵战潮",}, -- [16]
	{["GUID"] = 164929, ["Name"] = "仙木灵居民",["Instance"] = "塞兹仙林的迷雾",}, -- [17]
	{["GUID"] = 173655, ["Name"] = "纱雾龙母",["Instance"] = "塞兹仙林的迷雾",}, -- [18]
	{["GUID"] = 167998, ["Name"] = "传送门守卫",["Instance"] = "伤逝剧场",}, -- [19]
	{["GUID"] = 165824, ["Name"] = "纳祖达",["Instance"] = "通灵战潮",}, -- [20]
	{["GUID"] = 165197, ["Name"] = "骸骨巨怪",["Instance"] = "通灵战潮",}, -- [21]
	{["GUID"] = 158314, ["Name"] = "游移哀伤",["Instance"] = "噬渊",}, -- [22]
	{["GUID"] = 168934, ["Name"] = "激怒之灵",["Instance"] = "彼界",}, -- [23]
	{["GUID"] = 170572, ["Name"] = "阿塔莱灾厄妖术师",["Instance"] = "彼界",}, -- [24]
	{["GUID"] = 170483, ["Name"] = "阿塔莱死亡行者的灵魂",["Instance"] = "彼界",}, -- [25]
	{["GUID"] = 173729, ["Name"] = "傲慢具象",["Instance"] = "彼界",}, -- [26]
	{["GUID"] = 164558, ["Name"] = "夺灵者哈卡",["Instance"] = "彼界",}, -- [27]
	{["GUID"] = 165905, ["Name"] = "哈卡之子",["Instance"] = "彼界",}, -- [28]
	{["GUID"] = 167963, ["Name"] = "无头的终端机",["Instance"] = "彼界",}, -- [29]
	{["GUID"] = 167964, ["Name"] = "4.RF-4.RF",["Instance"] = "彼界",}, -- [30]
	{["GUID"] = 162133, ["Name"] = "卡尔将军",["Instance"] = "赤红深渊",}, -- [31]
	{["GUID"] = 170850, ["Name"] = "狂怒的血角",["Instance"] = "伤逝剧场",}, -- [32]
	{["GUID"] = 167536, ["Name"] = "嗜血的哈鲁吉亚",["Instance"] = "伤逝剧场",}, -- [33]
	{["GUID"] = 169893, ["Name"] = "卑劣的暗语者",["Instance"] = "伤逝剧场",}, -- [34]
	{["GUID"] = 167731, ["Name"] = "分离助理",["Instance"] = "通灵战潮",}, -- [35]
	{["GUID"] = 163621, ["Name"] = "碎淤",["Instance"] = "通灵战潮",}, -- [36]
	{["GUID"] = 164926, ["Name"] = "德鲁斯特碎枝者",["Instance"] = "塞兹仙林的迷雾",}, -- [37]}
}

function DamagerEngineGetImmuneControlUnit(Unit)
	local UnitImmuneControl = nil
	for k, v in ipairs(ImmuneControlUnitCache) do
		if DA_ObjectId(Unit) == v.GUID then
			if (v.GUID == 103224 or v.GUID == 103217) and not AuraUtil.FindAuraByName('被包裹', Unit, "HELPFUL") then
				--[爆裂幼蝎]、[晶化幼蝎]没有[被包裹]BUFF,可以控制
				return
			end
			UnitImmuneControl = 1
			break
		end
	end
	if WoWAssistant_ImmuneControlUnitCache then
		for k, v in ipairs(WoWAssistant_ImmuneControlUnitCache) do
			if DA_ObjectId(Unit) == v.GUID then
				if (v.GUID == 103224 or v.GUID == 103217) and not AuraUtil.FindAuraByName('被包裹', Unit, "HELPFUL") then
					--[爆裂幼蝎]、[晶化幼蝎]没有[被包裹]BUFF,可以控制
					return
				end
				UnitImmuneControl = 1
				break
			end
		end
	end
	if UnitImmuneControl then
		return true
	else
		return false
	end
end

local FindImmuneControlUnit = CreateFrame("Frame")
FindImmuneControlUnit:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
--通过战斗记录发现新的免疫控制目标并缓存

FindImmuneControlUnit:SetScript("OnEvent", function(self, event, ...)
	if not BalanceCycleStart and not FeralCycleStart and not RestorationCycleStart then return end
	local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = ...
	if event == "COMBAT_LOG_EVENT" or event == "COMBAT_LOG_EVENT_UNFILTERED" then
		a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = CombatLogGetCurrentEventInfo()
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_MISSED" and o == "IMMUNE" then
		if not C_PvP.IsActiveBattlefield() and (l == 339 or l == 102359 or l == 99 or l == 5211) then
			local ImmuneControlUnitCacheTemporary = WoWAssistant_ImmuneControlUnitCache or {}
			local UnitIsInTab = nil
			for k, v in ipairs(ImmuneControlUnitCacheTemporary) do
				if tonumber(h:match("-(%d+)-%x+$"), 10) == v.GUID then
					UnitIsInTab = 1
					break
				end
			end
			if not UnitIsInTab then
				table.insert(ImmuneControlUnitCacheTemporary, {
					Name = i, 
					GUID = tonumber(h:match("-(%d+)-%x+$"), 10), 
					Instance = GetZoneText(), 
				}) --免疫控制目标写入表格
				--print(i.." 免疫控制")
			end
			WoWAssistant_ImmuneControlUnitCache = CloneTable(ImmuneControlUnitCacheTemporary)
		end
	end
end)