--获取忽略的目标

local IgnoreTatgetCache = {
	--{Name = "训练假人", GUID = 92164, Type = "", Instance = "梦境林地-测试"}, 
	{Name = "狂怒面具", GUID = 169912, Type = "", Instance = "彼界-小怪"},
	{Name = "阿塔莱死亡行者的灵魂", GUID = 170483, Type = "", Instance = "彼界-小怪"},
	{Name = "实验性淤泥", GUID = 167966, Type = "", Instance = "彼界-小怪"},
	{Name = "不稳定的罐子", GUID = 169159, Type = "", Instance = "凋魂之殇"},
	{Name = "粘稠的大杂烩", GUID = 171887, Type = "", Instance = "凋魂之殇-酤团"},
	{Name = "幻影克隆体", GUID = 165108, Type = "", Instance = "塞兹仙林的迷雾-唤雾者"},
	{Name = "幻影仙狐", GUID = 165251, Type = "", Instance = "塞兹仙林的迷雾-唤雾者"},
	{Name = "血工", GUID = 215826, Type = "", Instance = "艾拉-卡拉，回响之城"},
	{Name = "黑血", GUID = 215968, Type = "", Instance = "艾拉-卡拉，回响之城"},
}

function DamagerEngineGetIgnoreUnit(Unit)
	local DamagerEngine_IsIgnoreTatgetUnit = nil
	if UnitExists(Unit) and UnitIsVisible(Unit) then
		for k, v in ipairs(IgnoreTatgetCache) do
			if DA_ObjectId(Unit) == v.GUID then
				local name1, text1, texture1, startTime1, endTime1, isTradeSkill1, castID1, notInterruptible1, spellid1 = UnitCastingInfo(Unit)
				local name2, text2, texture2, startTime2, endTime2, isTradeSkill2, notInterruptible2 = UnitChannelInfo(Unit)
				if v.GUID == 92387 and UnitHealth(Unit) / UnitHealthMax(Unit) < 1 then
					--[战争之鼓]血量不满,不忽略
					return
				end
				if v.GUID == 100818 and UnitHealth(Unit) / UnitHealthMax(Unit) < 0.9 then
					--[嚎叫雕像]血量低于90%,不忽略
					return
				end
				if v.GUID == 101476 and UnitHealth(Unit) * 1.75 < UnitHealth("boss1") then
					--[熔火焦皮]血量*1.75小于BOSS血量,不忽略
					return
				end
				if v.GUID == 114260 and UnitExists("boss1") and DA_ObjectId("boss1") == v.GUID then
					--[玛吉亚]是BOSS,不忽略
					return
				end
				if v.GUID == 114261 and ((UnitExists("boss1") and DA_ObjectId("boss1") == v.GUID) or (UnitExists("boss2") and DA_ObjectId("boss2") == v.GUID)) then
					--[托尼]是BOSS,不忽略
					return
				end
				if v.GUID == 114265 and UnitHealth(Unit) > 1 then
					--[黑帮恶棍]血量大于1,不忽略
					return
				end
				if v.GUID == 114266 and UnitHealth(Unit) > 1 then
					--[海岸潮语者]血量大于1,不忽略
					return
				end
				if v.GUID == 104880 and UnitHealth(Unit) * 1.75 < UnitHealth("boss1") and not AuraUtil.FindAuraByName('虚空转移', Unit, "HELPFUL") then
					--[不应存在之物]血量*1.75小于BOSS血量且[不应存在之物]没有减伤BUFF,不忽略
					return
				end
				if v.GUID == 109804 and UnitHealth(Unit) * 1.75 < UnitHealth("boss1") and not AuraUtil.FindAuraByName('离子爆炸', "player", "HELPFUL") then
					--[离子球]血量*1.75小于BOSS血量且玩家身上有没有[离子爆炸]DEBUFF,不忽略
					return
				end
				if v.GUID == 117264 and name1 == "净化协议" then
					--[勇气侍女]读条[净化协议],不忽略
					return
				end
				if v.GUID == 114251 and name1 ~= "魔法威仪" then
					--[嘉琳黛尔]没读条[魔法威仪],不忽略
					return
				end
				if v.GUID == 100991 and AuraUtil.FindAuraByName('纠缠之根', Unit, "HELPFUL") then
					--[纠缠之根]有[纠缠之根]BUFF(可以攻击),不忽略
					return
				end
				if v.GUID == 125977 and UnitHealth(Unit) > 1 then
					--[复生图腾]血量大于1,不忽略
					return
				end
				if v.GUID == 132051 and UnitHealth("boss1") / UnitHealthMax("boss1") > 0.25 then
					--BOSS血量大于25%,不忽略[血虱]
					return
				end
				if v.GUID == 165108 and UnitHealthMax(Unit) - UnitHealth(Unit) >= UnitHealthMax("player") * 0.3 then
					--[幻影克隆体]损失血量大于等于玩家血量的30%,不忽略
					return
				end
				if v.GUID == 215826 and DA_GetUnitDistance(Unit) <= 15 then
					--[血工]距离玩家小于15码,不忽略
					return
				end
				if v.GUID == 215968 and UnitCastingInfo("boss1") ~= '宇宙奇点' then
					--BOSS不在读条宇宙奇点,不忽略[黑血]
					return
				end
				
				DamagerEngine_IsIgnoreTatgetUnit = 1
				break
			end
		end
	end
	if DamagerEngine_IsIgnoreTatgetUnit then
		return true
	else
		return false
	end
end