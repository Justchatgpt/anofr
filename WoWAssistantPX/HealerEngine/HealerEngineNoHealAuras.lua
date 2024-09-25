--不治疗Auras监测

local BuffCache = {
	--{Name = "熊形态", ID = 5487, Instance = "德鲁伊"}, --测试
	{Name = "救赎之魂", ID = 27827, Instance = "牧师"}, 
	{Name = "精神控制", ID = 605, Instance = "ALL"}, 
	{Name = "炉脉幻想", ID = 327140, Instance = "牧师"}, --灵魂羁绊
}
local DebuffCache = {
	--{Name = "昏睡", ID = 81075, Instance = "ALL"}, --菲拉斯-加德米尔噩梦龙人-测试
	{Name = "死疽溃烂", ID = 209858, Instance = "大秘境"}, 
	{Name = "炉脉幻想", ID = 327140, Instance = "牧师"},  --灵魂羁绊
	{Name = "枯萎凋零", ID = 341949, Instance = "伤逝剧场"}, 
	{Name = "卡拉梅恩的诅咒", ID = 343320, Instance = "纳斯利亚堡"}, 
	{Name = "暴食瘴气", ID = 329298, Instance = "纳斯利亚堡"}, 
	{Name = "荒芜", ID = 327992, Instance = "纳斯利亚堡"}, 
}

function HealerEngine_GetNoHealAuras(unitid)
	--print(unitid)
	local guid = UnitGUID(unitid)
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	local UnitHasNoHealAuras = nil
	local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1
	local name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2
	local PlayerInstance
	
	if C_PvP.IsActiveBattlefield() then
	--战场中
		PlayerInstance = 'PVP'
	elseif IsInInstance() then
	--副本中
		PlayerInstance = GetInstanceInfo()
	else
	--野外
		PlayerInstance = 'WORLD'
	end
	
	for i=1, #BuffCache do
		if (BuffCache[i].Instance == PlayerInstance) or (IsInGroup() and not IsInRaid() and BuffCache[i].Instance == "大秘境") or (UnitClass(unitid) == BuffCache[i].Instance) or (BuffCache[i].Instance == "ALL") then
			name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(BuffCache[i].Name, unitid, "HELPFUL")
			if spellID1 then
				if spellID1 == BuffCache[i].ID then
					UnitHasNoHealAuras = 1
					--print("BuffCache: ["..BuffCache[i].Name.."] ID: "..spellID1)
					break
				end
			end
		end
	end
	--Buff
	
	for i = 1, #DebuffCache do
		if (DebuffCache[i].Instance == PlayerInstance) or (IsInGroup() and not IsInRaid() and DebuffCache[i].Instance == "大秘境") or (UnitClass(unitid) == DebuffCache[i].Instance) or (DebuffCache[i].Instance == "ALL") then
			name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = AuraUtil.FindAuraByName(DebuffCache[i].Name, unitid, "HARMFUL")
			if spellID2 then
				if ((spellID2 ~= 209858) and spellID2 == DebuffCache[i].ID) 
				or (spellID2 == 209858 and count2 >= 35 and UnitHealthScale >= 0.15) 
				or (spellID2 == 209858 and count2 >= 40) then
					UnitHasNoHealAuras = 1
					--print("DebuffCache: ["..DebuffCache[i].Name.."] ID: "..spellID2)
					break
				end
			end
		end
	end
	
	--DeBuff
	if UnitHasNoHealAuras then
		return true
	else
		return false
	end
end