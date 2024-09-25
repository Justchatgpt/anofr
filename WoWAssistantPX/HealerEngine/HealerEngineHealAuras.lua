--需要治疗Auras监测(使用愈合、滋养)

local DebuffCache = {
	--{Name = "昏睡", ID = 81075, Type = "Full", Breakout = false, Instance = "ALL"}, --菲拉斯-加德米尔噩梦龙人-测试
	--{Name = "虚空感染", ID = 426308, Type = "Over", Breakout = false, Instance = "矶石宝库"}, --测试
	{Name = "重伤", ID = 240559, Type = "Over", Breakout = false, Instance = "大秘境"}, 
	{Name = "法力尖刺", ID = 235992, Type = "Over", Breakout = false, Instance = "神器挑战"}, 
	{Name = "影舌舔舐", ID = 228253, Type = "Over", Breakout = false, Instance = "勇气试炼"}, 
	{Name = "痛苦撕扯", ID = 196376, Type = "Over", Breakout = false, Instance = "黑心林地"}, 
	{Name = "时间释放", ID = 219965, Type = "Over", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "时间释放", ID = 219966, Type = "Over", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "彗星冲撞", ID = 230345, Type = "Full", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "急速射击", ID = 236596, Type = "Full", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "苦痛之矛", ID = 238442, Type = "Over", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "冷凝之血", ID = 245586, Type = "Over", Breakout = false, Instance = "安托鲁斯，燃烧王座"}, 
	{Name = "锯齿荨麻", ID = 260741, Type = "Over", Breakout = false, Instance = "维克雷斯庄园"}, 
	{Name = "尖刺镣铐", ID = 335306, Type = "Full", Breakout = false, Instance = "赤红深渊"}, 
	{Name = "知识烦扰", ID = 317963, Type = "Full", Breakout = false, Instance = "晋升高塔"}, 
	{Name = "滚雷", ID = 392641, Type = "Full", Breakout = true, Instance = "红玉新生法池"}, 
	{Name = "活动炸弹", ID = 373693, Type = "Full", Breakout = true, Instance = "红玉新生法池"}, 
	{Name = "折磨光束", ID = 431365, Type = "Full", Breakout = false, Instance = "破晨号"}, 
	{Name = "暗影之幕", ID = 426736, Type = "Over", Breakout = false, Instance = "破晨号"}, 
	{Name = "深渊轰击", ID = 451119, Type = "Full", Breakout = false, Instance = "破晨号"}, 
	{Name = "腐化附层", ID = 442285, Type = "Over", Breakout = false, Instance = "千丝之城"}, 
	{Name = "猩红之雨", ID = 443305, Type = "Over", Breakout = false, Instance = "尼鲁巴尔王宫"}, 
	{Name = "摄食黑血", ID = 442437, Type = "Over", Breakout = false, Instance = "尼鲁巴尔王宫"}, 
	{Name = "不稳定的灌能", ID = 443274, Type = "Over", Breakout = false, Instance = "尼鲁巴尔王宫"}, 
}

function HealerEngine_GetHealAuras(unitid)
	if not unitid then return end
	--print(unitid)
	local guid = UnitGUID(unitid)
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	HealerEngineHeals_HealAurasUnitID = nil
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
				
				if spellID1 == 240559 and (count1 < 3 or count1 > 4) then
					--特定法术层数小于3层或大于4层则忽视(3-4层治疗), 比如大秘境词缀[重伤]
					spellID1 = nil
				end
				if spellID1 == DebuffCache[i].ID then
					if (UnitGetIncomingHeals(unitid) < UnitHealthMax("player") * 0.05 or UnitGetIncomingHeals(unitid, "player") >= UnitHealthMax("player") * 0.05) then
						HealerEngine_UnitHasHealAuras = 1
						--HealerEngine不要打断过量治疗
						if DebuffCache[i].Type ~= "Over" then
							HealerEngineHeals_HealAurasNoOver = 1
							--部分DEBUFF不需要过量治疗, 比如萨格拉斯之墓格罗斯的[彗星冲撞]、月之姐妹的[急速射击]
						end
						HealerEngineHeals_HealAurasUnitID = unitid
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
					end
					
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