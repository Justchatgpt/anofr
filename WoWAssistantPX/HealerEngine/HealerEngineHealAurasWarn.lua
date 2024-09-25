--急需要治疗Auras监测(使用迅捷治愈、愈合)

local DebuffCache = {
	--{Name = "昏睡", ID = 81075, Breakout = false, Instance = "ALL"}, --菲拉斯-加德米尔噩梦龙人-测试
	--{Name = "虚空感染", ID = 426308, Breakout = false, Instance = "矶石宝库"}, --测试
	{Name = "重度醉拳", ID = 124273, Breakout = false, Instance = "武僧"}, 
	{Name = "重伤", ID = 240559, Breakout = false, Instance = "大秘境"}, 
	{Name = "爆裂", ID = 240443, Breakout = false, Instance = "大秘境"}, 
	{Name = "痛苦撕裂", ID = 225484, Breakout = false, Instance = "黑心林地"}, 
	{Name = "粉碎之握", ID = 204611, Breakout = false, Instance = "黑心林地"}, 
	{Name = "弱肉强食", ID = 200238, Breakout = false, Instance = "黑心林地"}, 
	{Name = "吞噬", ID = 199705, Breakout = false, Instance = "奈萨里奥的巢穴"}, 
	{Name = "吸收活力", ID = 228835, Breakout = false, Instance = "卡拉赞"}, 
	{Name = "邪恶清算", ID = 228883, Breakout = false, Instance = "勇气试炼"}, 
	{Name = "吞噬", ID = 255421, Breakout = false, Instance = "阿塔达萨"}, 
	{Name = "衰落意志", ID = 278961, Breakout = false, Instance = "地渊孢林"}, 
	{Name = "割肉", ID = 268214, Breakout = false, Instance = "风暴神殿"}, 
	{Name = "死亡棱镜", ID = 268202, Breakout = false, Instance = "维克雷斯庄园"}, 
	{Name = "魔药炸弹", ID = 328501, Breakout = false, Instance = "凋魂之殇"}, 
	{Name = "严惩", ID = 322554, Breakout = false, Instance = "赤红深渊"}, 
	{Name = "过度生长", ID = 322486, Breakout = false, Instance = "塞兹仙林的迷雾"}, 
	{Name = "旋光链接", ID = 54396, Breakout = false, Instance = "紫罗兰监狱"}, 
	{Name = "虚空转移", ID = 59743, Breakout = false, Instance = "紫罗兰监狱"}, 
	{Name = "炽焰冲刺", ID = 372796, Breakout = false, Instance = "红玉新生法池"}, 
	{Name = "腐蚀", ID = 451395, Breakout = false, Instance = "格瑞姆巴托"}, 
	{Name = "盛宴", ID = 455404, Breakout = false, Instance = "尼鲁巴尔王宫"}, 
}

function HealerEngine_GetHealAurasWarn(unitid)
	if not unitid then return end
	--print(unitid)
	local guid = UnitGUID(unitid)
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	HealerEngineHeals_HealAurasWarnUnitID = nil
	local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1
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
	
	for i = 1, #DebuffCache do
		if (DebuffCache[i].Instance == PlayerInstance) or (IsInGroup() and not IsInRaid() and DebuffCache[i].Instance == "大秘境") or (UnitClass(unitid) == DebuffCache[i].Instance) or (DebuffCache[i].Instance == "ALL") then
			name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DebuffCache[i].Name, unitid, "HARMFUL")
			if spellID1 then
				local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
				--DEBUFF剩余时间
				local timeDuration = duration1 and duration1 - timeLeft
				--DEBUFF已持续时间
				
				if spellID1 == 240559 and count1 < 5 then
					--特定法术层数小于5层则忽视(5层及以上治疗), 比如大秘境词缀[重伤]
					spellID1 = nil
				end
				if spellID1 == 240443 and (((count1 < 5 or UnitHealthScale > 0.9) and guid == UnitGUID("player")) or guid ~= UnitGUID("player")) then
					--特定法术(玩家自己层数小于5层或血量大于90%)或(非玩家自己)则忽视, 比如大秘境词缀[爆裂]
					spellID1 = nil
				end
				if spellID1 == 124273 and ((UnitGetIncomingHeals(unitid) > UnitHealthMax("player") * 0.05 and UnitHealthScale <= 0.4) or UnitHealthScale > 0.4) then
					--特定法术(即将受到的治疗大于玩家血量*0.05且血量小于40%)或(血量大于40%)则忽视, 比如武僧坦克的[重度醉拳]
					spellID1 = nil
				end
				
				if spellID1 == DebuffCache[i].ID then
					HealerEngine_UnitHasHealAurasWarn = 1
					--HealerEngine不要打断过量治疗
					HealerEngineHeals_HealAurasWarnUnitID = unitid
					for k, v in ipairs(HealerEngineHeals_HealAurasUnitCount) do --遍历表格, 看目标是否已存在表格内
						if UnitGUID(unitid) == UnitGUID(v) then --目标存在表格内
							HealerEngineHeals_HealAurasUnitCount_UnitIsInTable = 1
							break
						end
					end
					if not HealerEngineHeals_HealAurasUnitCount_UnitIsInTable then
						table.insert(HealerEngineHeals_HealAurasUnitCount, unitid) --写入表格内
					end
					HealerEngineHeals_HealAurasUnitCount_UnitIsInTable = nil
					
					if DebuffCache[i].Breakout then
						HealerEngineHeals_HealBreakoutSpellUnitID = unitid
						--部分技能结束后会有爆发性伤害
					end
					--print("DebuffCache: ["..DebuffCache[i].Name.."] ID: "..spellID1)
					break
				end
			end
		end
	end
	--DeBuff
end