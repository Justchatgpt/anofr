--昏迷及递减监测

local DamagerEngineGetDiminishingStuns = CreateFrame("Frame")
DamagerEngineGetDiminishingStuns:RegisterEvent("PLAYER_ENTERING_WORLD")
DamagerEngineGetDiminishingStuns:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
DamagerEngineGetDiminishingStuns:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")

DamagerEngineGetDiminishingStunsCache = {}

DamagerEngineGetDiminishingStunsSpells = {
	{SpellName = "僵尸爆炸", SpellID = 210141, Class = "DEATHKNIGHT"},
	{SpellName = "绝对零度（辛达苟萨之息）", SpellID = 334693, Class = "DEATHKNIGHT"},
	{SpellName = "窒息（邪恶）", SpellID = 108194, Class = "DEATHKNIGHT"},
	{SpellName = "窒息（鲜血）", SpellID = 221562, Class = "DEATHKNIGHT"},
	{SpellName = "撕咬（食尸鬼）", SpellID = 91800, Class = "DEATHKNIGHT"},
	{SpellName = "巨兽打击（变异食尸鬼）", SpellID = 91797, Class = "DEATHKNIGHT"},
	{SpellName = "冬之死", SpellID = 287254, Class = "DEATHKNIGHT"},
	{SpellName = "混乱新星", SpellID = 179057, Class = "DEMONHUNTER"},
	{SpellName = "伊利丹之握（主要效果）", SpellID = 205630, Class = "DEMONHUNTER"},
	{SpellName = "伊利丹之握（次要效果）", SpellID = 208618, Class = "DEMONHUNTER"},
	{SpellName = "邪能爆发", SpellID = 211881, Class = "DEMONHUNTER"},
	{SpellName = "恶魔变形（PvE眩晕效果）", SpellID = 200166, Class = "DEMONHUNTER"},
	{SpellName = "割裂", SpellID = 203123, Class = "DRUID"},
	{SpellName = "扑击（潜行）", SpellID = 163505, Class = "DRUID"},
	{SpellName = "强力一击", SpellID = 5211, Class = "DRUID"},
	{SpellName = "碾压", SpellID = 202244, Class = "DRUID"},
	{SpellName = "野性冲锋", SpellID = 325321, Class = "DRUID"},
	{SpellName = "天空恐惧", SpellID = 372245, Class = "DRUID"},
	{SpellName = "地震猛击", SpellID = 408544, Class = "DRUID"},
	{SpellName = "束缚射击", SpellID = 117526, Class = "HUNTER"},
	{SpellName = "连续震荡", SpellID = 357021, Class = "HUNTER"},
	{SpellName = "胁迫", SpellID = 24394, Class = "HUNTER"},
	{SpellName = "雪崩", SpellID = 389831, Class = "MONK"},
	{SpellName = "扫堂腿", SpellID = 119381, Class = "MONK"},
	{SpellName = "扫堂腿2", SpellID = 458605, Class = "MONK"},
	{SpellName = "双管齐下", SpellID = 202346, Class = "MONK"},
	{SpellName = "驱邪术", SpellID = 385149, Class = "PALADIN"},
	{SpellName = "制裁之锤", SpellID = 853, Class = "PALADIN"},
	{SpellName = "灰烬觉醒", SpellID = 255941, Class = "PALADIN"},
	{SpellName = "心灵恐惧", SpellID = 64044, Class = "PRIEST"},
	{SpellName = "圣言术：罚", SpellID = 200200, Class = "PRIEST"},
	{SpellName = "偷袭", SpellID = 1833, Class = "ROGUE"},
	{SpellName = "肾击", SpellID = 408, Class = "ROGUE"},
	{SpellName = "静电充能（电容图腾）", SpellID = 118905, Class = "SHAMAN"},
	{SpellName = "粉碎（原始土元素）", SpellID = 118345, Class = "SHAMAN"},
	{SpellName = "闪电套索", SpellID = 305485, Class = "SHAMAN"},
	{SpellName = "斧击", SpellID = 89766, Class = "WARLOCK"},
	{SpellName = "流星打击（地狱火）", SpellID = 171017, Class = "WARLOCK"},
	{SpellName = "流星打击（深渊领主）", SpellID = 171018, Class = "WARLOCK"},
	{SpellName = "暗影之怒", SpellID = 30283, Class = "WARLOCK"},
	{SpellName = "盾牌冲锋", SpellID = 385954, Class = "WARRIOR"},
	{SpellName = "震荡波", SpellID = 46968, Class = "WARRIOR"},
	{SpellName = "震荡波（防护）", SpellID = 132168, Class = "WARRIOR"},
	{SpellName = "震荡波（试炼场PvE）", SpellID = 145047, Class = "WARRIOR"},
	{SpellName = "风暴之锤", SpellID = 132169, Class = "WARRIOR"},
	{SpellName = "战路", SpellID = 199085, Class = "WARRIOR"},
	{SpellName = "战争践踏（种族技能，牛头人）", SpellID = 20549, Class = "WARRIOR"},
	{SpellName = "蛮牛冲撞（种族技能，高山牛头人）", SpellID = 255723, Class = "WARRIOR"},
	{SpellName = "重拳出击（种族技能，库尔提拉斯人）", SpellID = 287712, Class = "WARRIOR"},
	{SpellName = "闪耀漂流球核心（格里恩盟约）", SpellID = 332423, Class = "WARRIOR"},
}

DamagerEngineImmunityStunsSpells = {
	{SpellName = "冰封之韧", SpellID = 48792, Class = "DEATHKNIGHT"},
	{SpellName = "寒冰形态", SpellID = 198144, Class = "MAGE"},
	{SpellName = "剑刃风暴", SpellID = 227847, Class = "WARRIOR"},
}

function DamagerEngineGetDiminishingStunsOnEvent(self, event, ...)
	if event == "ARENA_PREP_OPPONENT_SPECIALIZATIONS" then
		DamagerEngineGetDiminishingStunsCache = {}
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = ...
		if event == "COMBAT_LOG_EVENT" or event == "COMBAT_LOG_EVENT_UNFILTERED" then
			a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = CombatLogGetCurrentEventInfo()
		end
		if b == "SPELL_AURA_APPLIED" or b == "SPELL_AURA_REFRESH" then 
			
			for k, v in ipairs(DamagerEngineGetDiminishingStunsSpells) do --从技能表中遍历递减技能
				if l == v.SpellID then
					for k, v in ipairs(DamagerEngineGetDiminishingStunsCache) do --遍历表格, 看目标是否已存在表格内
						if h == v.destGUID then --目标存在表格内
							if v.Dp < 3 then --递减层数小于3
								v.Dp = v.Dp + 1 or 0 --递减层数+1
								v.SpellStart = 1
							end
							InTB = 1
							break
						end
					end
					if not InTB then
						table.insert(DamagerEngineGetDiminishingStunsCache, { destGUID=h, Dp=1 , Time=0 , SpellStart=1}) --写入表格内
					end
				end 
			end
			InTB = nil
		end
		if b == "SPELL_AURA_REMOVED" then 
			for k, v in ipairs(DamagerEngineGetDiminishingStunsSpells) do --从技能表中遍历递减技能
				if l == v.SpellID then
					for k, v in ipairs(DamagerEngineGetDiminishingStunsCache) do --遍历表格, 看目标是否已存在表格内
						if h == v.destGUID then --目标存在表格内
							v.Time = 20 --递减重置时间
							v.SpellStart = nil
							InTB = 1
							break
						end
					end
					if not InTB then
						table.insert(DamagerEngineGetDiminishingStunsCache, { destGUID=h, Dp=1 , Time=0 , SpellStart=nil}) --写入表格内
					end
				end 
			end
			InTB = nil
		end
	end
	
	DamagerEngineGetDiminishingStunsInterval_Time = DamagerEngineGetDiminishingStunsInterval_Time or GetTime()
	if GetTime() - DamagerEngineGetDiminishingStunsInterval_Time >= 0.1 then
		for k, v in ipairs(DamagerEngineGetDiminishingStunsCache) do --遍历表格
			if not v.SpellStart then
				if v.Time >= 0 then --递减中
					v.Time = v.Time - (GetTime() - DamagerEngineGetDiminishingStunsInterval_Time) --递减时间-0.1
				else --递减结束
					v.Dp = 0 --递减层数归零
				end
			end
		end
		DamagerEngineGetDiminishingStunsInterval_Time = GetTime()
	end
end

DamagerEngineGetDiminishingStuns:SetScript("OnEvent", DamagerEngineGetDiminishingStunsOnEvent)
DamagerEngineGetDiminishingStuns:SetScript("OnUpdate", DamagerEngineGetDiminishingStunsOnEvent)

function DA_GetStunned(unitid)
--获取单位是否被昏迷
	local Stunned = false
	local guid = UnitGUID(unitid)
	if not guid then return end
	local index = 1
	while true do
		local name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID = DA_UnitDebuff(unitid, index)
		if not spellID then
			break
		end
		for k, v in ipairs(DamagerEngineGetDiminishingStunsSpells) do --从技能表中遍历
			if spellID == v.SpellID then
				Stunned = true
				break
			end 
		end
        if Stunned then
            break
        end
		index = index + 1
	end
	return Stunned
end

function DA_GetDiminishingStuns(unitid)
--获取单位昏迷递减层数
	local diminishing = 0
	local guid = UnitGUID(unitid)
	if not guid then return end
	for k, v in ipairs(DamagerEngineGetDiminishingStunsCache) do --遍历表格
		if guid == v.destGUID then --目标存在表格内
			if v.Dp >= 1 then
				diminishing = v.Dp
				break
			end
		end
	end
	return diminishing
end

function DA_GetImmunityStuns(unitid)
--获取单位是否存在免疫昏迷BUFF
	local immunity = false
	local guid = UnitGUID(unitid)
	if not guid then return end
	local index = 1
	while true do
		local name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID = DA_UnitBuff(unitid, index)
		if not spellID then
			break
		end
		for k, v in ipairs(DamagerEngineImmunityStunsSpells) do --从技能表中遍历
			if spellID == v.SpellID then
				immunity = true
				break
			end 
		end
        if immunity then
            break
        end
		index = index + 1
	end
	return immunity
end