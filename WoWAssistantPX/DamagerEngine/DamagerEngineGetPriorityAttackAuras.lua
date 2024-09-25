--获取优先攻击Auras

local BuffCache = {
	--{Name = "超强打击", ID = 167385, Instance = "团队副本训练假人-测试"}, 
	{Name = "聚焦之虹", ID = 260805, Instance = "维克雷斯庄园"}, 
	{Name = "鼓舞光环", ID = 343502, Instance = "大秘境"}, 
}

local DebuffCache = {
	--{Name = "月火术", ID = 155625, Instance = "德鲁伊-测试"}, 
	{Name = "上古催心者", ID = 269131, Instance = "风暴神殿"}, 
	{Name = "灵魂操控", ID = 260900, Instance = "维克雷斯庄园"}, 
	{Name = "归还的宝珠", ID = 265755, Instance = "塞塔里斯神庙"}, 
}

function DamagerEngineGetPriorityAttackAuras(Unit)
	--先打血低的特殊Auras目标(非单体输出,可AOE)
	local UnitHasPriorityAttackAuras = nil
	
	local index1 = 1
	while true do
		local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = DA_UnitBuff(Unit, index1)
		if not spellID1 then
			break
		end
		for i=1, #BuffCache do
			if spellID1 == BuffCache[i].ID then
				UnitHasPriorityAttackAuras = 1
				break
			end
		end
		index1 = index1 + 1
	end
	--Buff
	
	local index1 = 1
	while true do
		local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = DA_UnitDebuff(Unit, index1)
		if not spellID1 then
			break
		end
		for i=1, #DebuffCache do
			if spellID1 == DebuffCache[i].ID then
				UnitHasPriorityAttackAuras = 1
				break
			end
		end
		index1 = index1 + 1
	end
	--DeBuff
	
	if UnitHasPriorityAttackAuras then
		return true
	else
		return false
	end
end