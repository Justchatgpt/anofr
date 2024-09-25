--获取不攻击Auras

local BuffCache = {
	--{Name = "超强打击", ID = 167385, Type = "NoAttack", Valid = "All", Instance = "团队副本训练假人-测试"}, 
	{Name = "圣盾术", ID = 642, Type = "Immune", Valid = "All", Instance = "圣骑士"}, 
	{Name = "圣盾术", ID = 228050, Type = "Immune", Valid = "All", Instance = "圣骑士"}, 
	{Name = "保护祝福", ID = 1022, Type = "Immune", Valid = "Melee", Instance = "圣骑士"}, 
	{Name = "闪避", ID = 5277, Type = "Immune", Valid = "Melee", Instance = "潜行者"}, 
	{Name = "灵体形态", ID = 210918, Type = "Immune", Valid = "Melee", Instance = "萨满祭司"}, 
	{Name = "寒冰屏障", ID = 45438, Type = "Immune", Valid = "All", Instance = "法师"}, 
	{Name = "棱彩屏障", ID = 198064, Type = "Immune", Valid = "Magic", Instance = "法师"}, 
	{Name = "法术反射", ID = 23920, Type = "Immune", Valid = "Magic", Instance = "战士"}, 
	{Name = "法术反射", ID = 216890, Type = "Immune", Valid = "Magic", Instance = "战士"}, 
	{Name = "剑在人在", ID = 118038, Type = "Immune", Valid = "Melee", Instance = "战士"}, 
	{Name = "反魔法护罩", ID = 48707, Type = "Immune", Valid = "Magic", Instance = "死亡骑士"}, 
	{Name = "反魔法护罩", ID = 171465, Type = "Immune", Valid = "Magic", Instance = "死亡骑士"}, 
	{Name = "反魔法护罩", ID = 181425, Type = "Immune", Valid = "Magic", Instance = "死亡骑士"}, 
	{Name = "虚空行走", ID = 196555, Type = "Immune", Valid = "All", Instance = "恶魔猎手"}, 
	{Name = "灵龟守护", ID = 186265, Type = "Immune", Valid = "All", Instance = "猎人"}, 
	{Name = "强化渐隐术", ID = 213602, Type = "Immune", Valid = "All", Instance = "牧师"}, 
	{Name = "业报之触", ID = 125174, Type = "Immune", Valid = "All", Instance = "武僧"}, 
	{Name = "暗影斗篷", ID = 31224, Type = "Immune", Valid = "Magic", Instance = "潜行者"}, 
	{Name = "虚空守卫", ID = 212295, Type = "Immune", Valid = "Magic", Instance = "术士"}, 
	{Name = "坚岩形态", ID = 329636, Type = "Immune", Valid = "All", Instance = "纳斯利亚堡-顽石军团干将"}, 
	{Name = "瞬息面容", ID = 323741, Type = "Immune", Valid = "All", Instance = "赎罪大厅"}, 
	{Name = "毒雾", ID = 326629, Type = "Immune", Valid = "All", Instance = "通灵战潮-外科医生缝肉"}, 
	{Name = "黑暗之拥", ID = 323149, Type = "Immune", Valid = "All", Instance = "塞兹仙林的迷雾-英格拉·马洛克"}, 
	{Name = "猜谜游戏", ID = 336499, Type = "Immune", Valid = "All", Instance = "塞兹仙林的迷雾-唤雾者"}, 
	{Name = "不屑一顾", ID = 442611, Type = "Immune", Valid = "All", Instance = "燧酿酒庄-酿造大师阿德里尔"}, 
	{Name = "黑暗降临", ID = 453859, Type = "Immune", Valid = "All", Instance = "破晨号-代言人夏多克朗"}, 
}--"NoAttack"Buff放在"Immune"Buff前


local DebuffCache = {
	{Name = "诱惑", ID = 6358, Type = "NoAttack", Valid = "All", Instance = "术士"}, 
	{Name = "迷魅", ID = 115268, Type = "NoAttack", Valid = "All", Instance = "术士"}, 
	{Name = "盲目之光", ID = 105421, Type = "NoAttack", Valid = "All", Instance = "圣骑士"}, 
	{Name = "盲目之光", ID = 115750, Type = "NoAttack", Valid = "All", Instance = "圣骑士"}, 
	{Name = "忏悔", ID = 20066, Type = "NoAttack", Valid = "All", Instance = "圣骑士"}, 
	{Name = "致盲", ID = 2094, Type = "NoAttack", Valid = "All", Instance = "潜行者"}, 
	{Name = "凿击", ID = 1776, Type = "NoAttack", Valid = "All", Instance = "潜行者"}, 
	{Name = "闷棍", ID = 6770, Type = "NoAttack", Valid = "All", Instance = "潜行者"}, 
	{Name = "分筋错骨", ID = 115078, Type = "NoAttack", Valid = "All", Instance = "武僧"}, 
	{Name = "震山掌", ID = 107079, Type = "NoAttack", Valid = "All", Instance = "武僧"}, 
	{Name = "变形术", ID = 118, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 28271, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 28272, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 61305, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 61721, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 61780, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 126819, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 161353, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 161354, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 161355, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 161372, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 277787, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 277792, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "变形术", ID = 321395, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "冰霜之环", ID = 82691, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "冰霜之环", ID = 113724, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "龙息术", ID = 31661, Type = "NoAttack", Valid = "All", Instance = "法师"}, 
	{Name = "禁锢", ID = 217832, Type = "NoAttack", Valid = "All", Instance = "恶魔猎手"}, 
	{Name = "冰冻陷阱", ID = 187650, Type = "NoAttack", Valid = "All", Instance = "猎人"}, 
	{Name = "冰冻陷阱", ID = 3355, Type = "NoAttack", Valid = "All", Instance = "猎人"}, 
	{Name = "翼龙钉刺", ID = 19386, Type = "NoAttack", Valid = "All", Instance = "猎人"}, 
	{Name = "束缚亡灵", ID = 9484, Type = "NoAttack", Valid = "All", Instance = "牧师"}, 
	{Name = "夺魂咆哮", ID = 99, Type = "NoAttack", Valid = "All", Instance = "德鲁伊"}, 
	{Name = "纠缠根须", ID = 339, Type = "NoAttack", Valid = "All", Instance = "德鲁伊"}, 
	{Name = "群体缠绕", ID = 102359, Type = "NoAttack", Valid = "All", Instance = "德鲁伊"}, 
	{Name = "休眠", ID = 2637, Type = "NoAttack", Valid = "All", Instance = "德鲁伊"}, 
	--{Name = "月火术", ID = 155625, Type = "Immune", Valid = "All", Instance = "德鲁伊-测试"}, 
	{Name = "心灵尖啸", ID = 8122, Type = "Immune", Valid = "All", Instance = "牧师"}, 
	{Name = "超度邪恶", ID = 10326, Type = "Immune", Valid = "All", Instance = "圣骑士"}, 
	{Name = "恐吓野兽", ID = 1513, Type = "Immune", Valid = "All", Instance = "猎人"}, 
	{Name = "破胆怒吼", ID = 5246, Type = "Immune", Valid = "All", Instance = "术士"}, 
	{Name = "恐惧嚎叫", ID = 5484, Type = "Immune", Valid = "All", Instance = "术士"}, 
	{Name = "恐惧", ID = 5782, Type = "Immune", Valid = "All", Instance = "术士"}, 
	{Name = "放逐术", ID = 710, Type = "Immune", Valid = "All", Instance = "术士"}, 
	{Name = "旋风", ID = 33786, Type = "Immune", Valid = "All", Instance = "德鲁伊"}, 
	{Name = "旋风", ID = 209753, Type = "Immune", Valid = "All", Instance = "德鲁伊"}, 
	{Name = "玛卓克萨斯之壁", ID = 336449, Type = "Immune", Valid = "All", Instance = "凋魂之殇"}, 
}--"NoAttack"Debuff放在"Immune"Debuff前


function DamagerEngineGetNoAttackAuras(Unit)
	--获取不攻击BUFF
	
	local PlayerAttackType = "Melee"
	--默认,物理攻击类
	if DA_GetSpecialization() == 102 then
		--平衡德鲁伊,物理攻击类
		PlayerAttackType = "Magic"
	end
	if DA_GetSpecialization() == 103 then
		--野性德鲁伊,物理攻击类
		PlayerAttackType = "Melee"
	end
	if DA_GetSpecialization() == 105 then
		--恢复德鲁伊,法术攻击类
		PlayerAttackType = "Magic"
	end
	
	DamagerEngine_UnitHasNoAttackAuras = nil
	DamagerEngine_UnitHasImmuneAttackAuras = nil
	
	local index1 = 1
	while true do
		local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = DA_UnitBuff(Unit, index1)
		if not spellID1 then
			break
		end
		for i=1, #BuffCache do
			if spellID1 == BuffCache[i].ID and (PlayerAttackType == BuffCache[i].Valid or BuffCache[i].Valid == "All") then
				--如果玩家攻击类型与Buff影响的类型不符,则无视该Buff
				DamagerEngine_UnitHasNoAttackAuras = 1
				if BuffCache[i].Type == "Immune" then
					DamagerEngine_UnitHasImmuneAttackAuras = 1
				end
				if (spellID1 == 5277 or spellID1 == 118038) and not DA_GetFacing(Unit, "player") then
					--特定法术如果该目标没有面对玩家则忽视, 比如潜行者的[闪避]、战士的[剑在人在]
					DamagerEngine_UnitHasNoAttackAuras = nil
					DamagerEngine_UnitHasImmuneAttackAuras = nil
				end
				if DamagerEngine_UnitHasNoAttackAuras then
					break
				end
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
			if spellID1 == DebuffCache[i].ID and (PlayerAttackType == DebuffCache[i].Valid or DebuffCache[i].Valid == "All") then
				--如果玩家攻击类型与DeBuff影响的类型不符,则无视该DeBuff
				--print(UnitName(Unit).." 受到控制")
				DamagerEngine_UnitHasNoAttackAuras = 1
				if DebuffCache[i].Type == "Immune" then
					DamagerEngine_UnitHasImmuneAttackAuras = 1
				end
				if (spellID1 == 339 or spellID1 == 102359) and ((C_Item.IsEquippedItem(132452) and UnitLevel("player") <= 115) or C_PvP.IsActiveBattlefield()) then
					--身穿[塞弗斯的秘密]或在战场/竞技场中时,无视[纠缠根须]、[群体缠绕]DEBUFF
					DamagerEngine_UnitHasNoAttackAuras = nil
					DamagerEngine_UnitHasImmuneAttackAuras = nil
				end
				if DamagerEngine_UnitHasNoAttackAuras then
					break
				end
			end
		end
		index1 = index1 + 1
	end
	--DeBuff
	
	if DamagerEngine_UnitHasImmuneAttackAuras then
		return true, "Immune"
	elseif DamagerEngine_UnitHasNoAttackAuras then
		return true, "NoAttack"
	else
		return false
	end
end

function DamagerEngineRemoveNoAttackAurasUnit(Table, Unit, index)
--从单位表中移除某些目标
	if DamagerEngineGetNoAttackAuras(Unit) then
	--移除有不攻击Auras的目标
		table.remove(Table, index)
	end
	if DA_GetHasActiveAffix('崩裂') and AuraUtil.FindAuraByName('爆裂', "player", "HARMFUL") and select(3, AuraUtil.FindAuraByName('爆裂', "player", "HARMFUL")) >= 3 and UnitHealth(Unit) <= UnitHealthMax("player") * 3 then
		--大秘境[崩裂]词缀时,3层[爆裂]则移除血量过低的目标
		--print("崩裂: ["..UnitName(Unit).."] 血量过低")
		table.remove(Table, index)
	end
	if DamagerEngine_PlayerInEnemyCache then
		if not UnitIsPlayer(Unit) then
			--当DamagerEngine_EnemyCacheHasThreat表中有玩家时,则移除非玩家目标,以优先攻击玩家
			table.remove(Table, index)
		end
	end
end