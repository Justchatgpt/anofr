--需要轻度治疗Auras监测(使用回春术(Normal)、萌芽(High))

local DebuffCache = {
	--{Name = "昏睡", ID = 81075, Type = "High", Breakout = false, Instance = "ALL"}, --菲拉斯-加德米尔噩梦龙人-测试
	--{Name = "虚空感染", ID = 426308, Type = "High", Breakout = true, Instance = "矶石宝库"}, --测试
	{Name = "重伤", ID = 240559, Type = "High", Breakout = false, Instance = "大秘境"}, 
	{Name = "践踏", ID = 240447, Type = "Normal", Breakout = false, Instance = "大秘境"}, 
	{Name = "爆裂", ID = 240443, Type = "High", Breakout = false, Instance = "大秘境"}, 
	{Name = "吸血", ID = 202231, Type = "Normal", Breakout = false, Instance = "奈萨里奥的巢穴"}, 
	{Name = "剑刃奔涌", ID = 209667, Type = "High", Breakout = false, Instance = "群星庭院"}, 
	{Name = "投掷长矛", ID = 192131, Type = "High", Breakout = false, Instance = "艾萨拉之眼"}, 
	{Name = "剧毒创伤", ID = 191855, Type = "Normal", Breakout = false, Instance = "艾萨拉之眼"}, 
	{Name = "雷霆打击", ID = 198599, Type = "Normal", Breakout = false, Instance = "英灵殿"}, 
	{Name = "驱逐之光", ID = 192048, Type = "Normal", Breakout = false, Instance = "英灵殿"}, 
	{Name = "风暴之眼", ID = 200901, Type = "High", Breakout = false, Instance = "英灵殿"}, 
	{Name = "风暴之眼", ID = 203963, Type = "High", Breakout = false, Instance = "英灵殿"}, 
	{Name = "掠食飞扑", ID = 197556, Type = "High", Breakout = false, Instance = "英灵殿"}, 
	{Name = "掠食飞扑", ID = 196497, Type = "High", Breakout = false, Instance = "英灵殿"}, 
	{Name = "平行空间", ID = 211125, Type = "High", Breakout = false, Instance = "魔法回廊"}, 
	{Name = "灼热伤口", ID = 211756, Type = "Normal", Breakout = false, Instance = "魔法回廊"}, 
	{Name = "动荡魔法", ID = 196562, Type = "Normal", Breakout = false, Instance = "魔法回廊"}, 
	{Name = "缠绕之网", ID = 200284, Type = "Normal", Breakout = false, Instance = "魔法回廊"}, 
	{Name = "时间放逐", ID = 203914, Type = "High", Breakout = false, Instance = "魔法回廊"}, 
	{Name = "不稳定的魔法", ID = 220871, Type = "Normal", Breakout = false, Instance = "魔法回廊"}, 
	{Name = "折磨之眼", ID = 204243, Type = "High", Breakout = false, Instance = "黑心林地"}, 
	{Name = "纠缠之根", ID = 199063, Type = "Normal", Breakout = false, Instance = "黑心林地"}, 
	{Name = "梦魇之息", ID = 204667, Type = "Normal", Breakout = false, Instance = "黑心林地"}, 
	{Name = "腐化之息", ID = 191326, Type = "Normal", Breakout = false, Instance = "黑心林地"}, 
	{Name = "落石", ID = 199460, Type = "Normal", Breakout = false, Instance = "黑心林地"}, 
	{Name = "怨恨凝视", ID = 198079, Type = "Normal", Breakout = false, Instance = "黑鸦堡垒"}, 
	{Name = "野蛮强击", ID = 198245, Type = "Normal", Breakout = false, Instance = "黑鸦堡垒"}, 
	{Name = "针刺虫群", ID = 201733, Type = "Normal", Breakout = false, Instance = "黑鸦堡垒"}, 
	{Name = "神圣之地", ID = 227848, Type = "High", Breakout = false, Instance = "卡拉赞"}, 
	{Name = "锁喉", ID = 227742, Type = "Low", Breakout = false, Instance = "卡拉赞"}, 
	{Name = "炼狱箭", ID = 228249, Type = "Normal", Breakout = false, Instance = "卡拉赞"}, 
	{Name = "溃烂", ID = 203096, Type = "Low", Breakout = false, Instance = "翡翠梦魇"}, 
	{Name = "腐蚀爆发", ID = 203646, Type = "Normal", Breakout = false, Instance = "翡翠梦魇"}, 
	{Name = "腐化吐息", ID = 208929, Type = "Normal", Breakout = false, Instance = "翡翠梦魇"}, 
	{Name = "死灵毒液", ID = 215460, Type = "Normal", Breakout = false, Instance = "翡翠梦魇"}, 
	{Name = "撕裂肉体", ID = 204859, Type = "Normal", Breakout = false, Instance = "翡翠梦魇"}, 
	{Name = "快速传染", ID = 203787, Type = "Normal", Breakout = false, Instance = "翡翠梦魇"}, 
	{Name = "驱逐之光", ID = 228029, Type = "Normal", Breakout = false, Instance = "勇气试炼"}, 
	{Name = "毒性薄片", ID = 206798, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "冰霜印记", ID = 212587, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "寒冰喷射", ID = 206936, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "邪能喷射", ID = 205649, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "邪能烈焰", ID = 206398, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "腐肉瘟疫", ID = 206480, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "剧毒孢子", ID = 219235, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "透心折磨", ID = 211261, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "邪能束缚", ID = 209011, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "强化邪能束缚", ID = 206366, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "强化邪能束缚", ID = 206384, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "古尔丹之眼", ID = 209454, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "强化古尔丹之眼", ID = 221728, Type = "Normal", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "灵魂虹吸", ID = 221891, Type = "Low", Breakout = false, Instance = "暗夜要塞"}, 
	{Name = "意志剪切", ID = 243289, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "吞噬之饥", ID = 230920, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "污染墨汁", ID = 232913, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "浸透", ID = 231770, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "切割旋风", ID = 232732, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "月灼", ID = 236519, Type = "Low", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "月蚀之拥", ID = 233263, Type = "High", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "苦痛之矛", ID = 235924, Type = "High", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "枯萎", ID = 236138, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "动荡的灵魂", ID = 240209, Type = "Normal", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "末日之雨", ID = 234310, Type = "Low", Breakout = false, Instance = "萨格拉斯之墓"}, 
	{Name = "闷烧", ID = 251445, Type = "Normal", Breakout = false, Instance = "安托鲁斯，燃烧王座"}, 
	{Name = "冥魂之拥", ID = 244094, Type = "Normal", Breakout = false, Instance = "安托鲁斯，燃烧王座"}, 
	{Name = "灵能突袭", ID = 244172, Type = "High", Breakout = false, Instance = "安托鲁斯，燃烧王座"}, 
	{Name = "爆裂脉冲", ID = 253520, Type = "High", Breakout = false, Instance = "安托鲁斯，燃烧王座"}, 
	{Name = "艾泽里特觅心者", ID = 262515, Type = "Normal", Breakout = false, Instance = "暴富矿区！！"}, 
	{Name = "自控导弹", ID = 260829, Type = "Normal", Breakout = false, Instance = "暴富矿区！！"}, 
	{Name = "戈霍恩之蚀", ID = 260685, Type = "Normal", Breakout = false, Instance = "地渊孢林"}, 
	{Name = "恐惧印记", ID = 265880, Type = "Normal", Breakout = false, Instance = "维克雷斯庄园"}, 
	{Name = "萦绕恐惧", ID = 265882, Type = "Normal", Breakout = false, Instance = "维克雷斯庄园"}, 
	{Name = "暗影伏击", ID = 331818, Type = "High", Breakout = true, Instance = "凋魂之殇"}, 
	{Name = "暗影伏击", ID = 333353, Type = "High", Breakout = true, Instance = "凋魂之殇"}, 
	{Name = "不稳定的酸液", ID = 325418, Type = "High", Breakout = false, Instance = "塞兹仙林的迷雾"}, 
	{Name = "心灵连接", ID = 322648, Type = "High", Breakout = false, Instance = "塞兹仙林的迷雾"}, 
	{Name = "通灵箭", ID = 320462, Type = "Normal", Breakout = false, Instance = "通灵战潮"}, 
	{Name = "通灵箭", ID = 330784, Type = "Normal", Breakout = false, Instance = "通灵战潮"}, 
	{Name = "胁迫", ID = 328434, Type = "High", Breakout = false, Instance = "晋升高塔"}, 
	{Name = "净化冲击波", ID = 323195, Type = "High", Breakout = false, Instance = "晋升高塔"}, 
	{Name = "无法控制的能量", ID = 59281, Type = "High", Breakout = false, Instance = "紫罗兰监狱"}, 
	{Name = "定时炸弹", ID = 59686, Type = "High", Breakout = false, Instance = "乌特加德城堡"}, 
	{Name = "霜风", ID = 385518, Type = "High", Breakout = false, Instance = "红玉新生法池"}, 
	{Name = "诱引烛焰", ID = 423693, Type = "High", Breakout = false, Instance = "暗焰裂口"}, 
	{Name = "折光射线", ID = 424795, Type = "Normal", Breakout = true, Instance = "矶石宝库"}, 
	{Name = "抓握之血", ID = 432031, Type = "Normal", Breakout = false, Instance = "艾拉-卡拉，回响之城"}, 
	{Name = "突岩尖刺", ID = 448870, Type = "High", Breakout = true, Instance = "格瑞姆巴托"}, 
	{Name = "黑暗喷发", ID = 456712, Type = "High", Breakout = true, Instance = "格瑞姆巴托"},
	{Name = "暗影烈焰笼罩", ID = 451224, Type = "High", Breakout = false, Instance = "格瑞姆巴托"}, 
	{Name = "深渊腐蚀", ID = 448057, Type = "High", Breakout = false, Instance = "格瑞姆巴托"}, 
	{Name = "深渊腐蚀", ID = 448057, Type = "High", Breakout = false, Instance = "格瑞姆巴托"}, 
	{Name = "迸发虫茧", ID = 451107, Type = "High", Breakout = true, Instance = "破晨号"}, 
	{Name = "折磨喷发", ID = 431350, Type = "High", Breakout = false, Instance = "破晨号"}, 
	{Name = "艾泽里特炸药", ID = 454437, Type = "High", Breakout = true, Instance = "围攻伯拉勒斯"}, 
	{Name = "艾泽里特炸药", ID = 454439, Type = "High", Breakout = false, Instance = "围攻伯拉勒斯"}, 
	{Name = "猩红之雨", ID = 443305, Type = "High", Breakout = false, Instance = "尼鲁巴尔王宫"}, 
	{Name = "摄食黑血", ID = 442437, Type = "High", Breakout = false, Instance = "尼鲁巴尔王宫"}, 
	{Name = "不稳定的灌能", ID = 443274, Type = "High", Breakout = false, Instance = "尼鲁巴尔王宫"}, 
}

function HealerEngine_GetHealAurasLow(unitid)
	if not unitid then return end
	--print(unitid)
	local guid = UnitGUID(unitid)
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	local PlayerPowerScale = UnitPower("player", 0) / UnitPowerMax("player", 0)
	HealerEngineHeals_HealAurasLowHigh = nil
	HealerEngineHeals_HealAurasLowUnitID = nil
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
				
				if name1 == DebuffCache[i].Name then
					--print(name1.." ID: "..spellID1)
				end
				if spellID1 == 240559 and count1 > 2 then
					--特定法术层数大于2层则忽视(1-2层治疗), 比如大秘境词缀[重伤]
					spellID1 = nil
				end
				if spellID1 == DebuffCache[i].ID then
					HealerEngine_UnitHasHealAurasLow = 1
					
					if DebuffCache[i].Type == "High" then
						HealerEngineHeals_HealAurasLowUnitID = unitid
						HealerEngineHeals_HealAurasLowHigh = 1
						--部分DEBUFF威胁较高
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
					
					if (DebuffCache[i].Type ~= "Low" or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Effect ~= 3 then
						HealerEngineHeals_HealAurasLowUnitID = unitid
						--部分DEBUFF一直持续, 导致耗蓝太多, 强力模式才治疗
					end
					
					if DebuffCache[i].Breakout then
						HealerEngineHeals_HealBreakoutSpellUnitID = unitid
						--部分技能结束后会有爆发性伤害
					end
					break
				end
			end
		end
	end
	--DeBuff
end