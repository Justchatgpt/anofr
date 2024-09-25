--DEBUFF驱散

local PassNoClearDebuffCache = {
	--驱散后会有不良影响的DEBUFF白名单(可以驱散)
	--[31589] = {Name = "减速", Instance = "测试"},
}
local NoClearDebuffCache = {
	--绝对不要驱散的DEBUFF(用法术名称及Instance匹配)
	--["减速"] = {SpellID = 31589, Instance = "测试"},
	--["虚空感染"] = {SpellID = 426308, Instance = "矶石宝库"},--测试
	["消化酸液"] = {SpellID = 435138, Instance = "尼鲁巴尔王宫"},
	["针刺虫群"] = {SpellID = 438708, Instance = "尼鲁巴尔王宫"},
	["晦暗之触"] = {SpellID = 447972, Instance = "尼鲁巴尔王宫"},
	["粘性之网"] = {SpellID = 446349, Instance = "尼鲁巴尔王宫"},
	["粘性之网"] = {SpellID = 446344, Instance = "尼鲁巴尔王宫"},
}
local NoPriorityClearDebuffCache = {
	--忽视的DEBUFF(用法术ID匹配)
	--[31589] = {Name = "减速", Instance = "测试"},
	[425974] = {Name = "震地", Instance = "矶石宝库-小怪"},
	[328664] = {Name = "冰冻", Instance = "通灵战潮-收割者阿玛厄斯"},
	[438200] = {Name = "毒液箭", Instance = "尼鲁巴尔王宫-流丝之庭"},
	[441772] = {Name = "虚空箭", Instance = "尼鲁巴尔王宫-流丝之庭"},
}
local AffectGropuDebuffCache = {
	--驱散后会影响附近队友的DEBUFF(用法术名称及Instance匹配)
	--["减速"] = {SpellID = 31589, Distance = 10, TimeLeftClear = 3, Instance = "测试"},
	--["不稳定的妖术"] = {SpellID = 252781, Distance = 10, TimeLeftClear = nil, Instance = "阿塔达萨"},
	--["寰宇操控"] = {SpellID = 325725, Distance = 15, TimeLeftClear = 3, Instance = "彼界"},
	["冻结之缚"] = {SpellID = 320788, Distance = 17, TimeLeftClear = 4, Instance = "通灵战潮"},
	["疑之影"] = {SpellID = 443437, Distance = 10, TimeLeftClear = 3, Instance = "千丝之城"},
	["疑之影"] = {SpellID = 448561, Distance = 10, TimeLeftClear = 3, Instance = "千丝之城"},
	["培植毒药"] = {SpellID = 461487, Distance = 20, TimeLeftClear = 3, Instance = "艾拉-卡拉，回响之城"},
	["腐败之水"] = {SpellID = 275014, Distance = 3, TimeLeftClear = 1.5, Instance = "围攻伯拉勒斯"},
	["冥河之种"] = {SpellID = 432448, Distance = 4, TimeLeftClear = 2, Instance = "破晨号"},
}

local NoClearPVPDebuffCache = {
	--不要驱散的PVP DEBUFF(用法术名称匹配)
	["痛苦无常"] = {Type = "", Instance = "术士"},
	["吸血鬼之触"] = {Type = "", Instance = "牧师"},
}
local PVPDebuffCache = {
	--PVP只驱散特定DEBUFF(用法术名称匹配)
	["休眠"] = {Type = "Disorients", Instance = "德鲁伊"},
	["缠绕"] = {Type = "ROOT", Instance = "德鲁伊"},
	["群体缠绕"] = {Type = "ROOT", Instance = "德鲁伊"},
	["台风"] = {Type = "ROOT", Instance = "德鲁伊"},
	["精灵虫群"] = {Type = "", Instance = "德鲁伊"},
	["梦游"] = {Type = "Disorients", Instance = "唤魔师"},
	["束缚射击"] = {Type = "", Instance = "猎人"},
	["翼龙钉刺"] = {Type = "", Instance = "猎人"},
	["冰冻陷阱"] = {Type = "", Instance = "猎人"},
	["恐吓野兽"] = {Type = "Disorients", Instance = "猎人"},
	["变形术"] = {Type = "", Instance = "法师"},
	["冰霜新星"] = {Type = "ROOT", Instance = "法师"},
	["冰冻术"] = {Type = "ROOT", Instance = "法师"},
	["龙息术"] = {Type = "", Instance = "法师"},
	["冰霜之环"] = {Type = "", Instance = "法师"},
	["制裁之锤"] = {Type = "", Instance = "圣骑士"},
	["忏悔"] = {Type = "Disorients", Instance = "圣骑士"},
	["盲目之光"] = {Type = "", Instance = "圣骑士"},
	["心灵尖啸"] = {Type = "", Instance = "牧师"},
	["沉默"] = {Type = "", Instance = "牧师"},
	["精神控制"] = {Type = "Disorients", Instance = "牧师"},
	["束缚亡灵"] = {Type = "", Instance = "牧师"},
	["妖术"] = {Type = "", Instance = "萨满"},
	["静电充能"] = {Type = "", Instance = "萨满"},
	["陷地"] = {Type = "ROOT", Instance = "萨满"},
	["恐惧"] = {Type = "Disorients", Instance = "术士"},
	["恐惧嚎叫"] = {Type = "Disorients", Instance = "术士"},
	["诱惑"] = {Type = "Disorients", Instance = "术士"},
	["迷魅"] = {Type = "Disorients", Instance = "术士"},
	["放逐术"] = {Type = "", Instance = "术士"},
	["暗影之怒"] = {Type = "", Instance = "术士"},
	["死亡缠绕"] = {Type = "", Instance = "术士"},
	["虚弱诅咒"] = {Type = "", Instance = "术士"},
	["语言诅咒"] = {Type = "", Instance = "术士"},
	["绞袭"] = {Type = "", Instance = "死亡骑士"},
	["致盲冰雨"] = {Type = "", Instance = "死亡骑士"},
	["锁链符咒"] = {Type = "ROOT", Instance = "恶魔猎手"},
	["悲苦符咒"] = {Type = "", Instance = "恶魔猎手"},
	["沉默符咒"] = {Type = "", Instance = "恶魔猎手"},
	["混乱新星"] = {Type = "", Instance = "恶魔猎手"},
	["致伤药膏"] = {Type = "", Instance = "潜行者"},
}

function Restoration_ClearUnitAuras(unitid)
	if not unitid or Restoration_NatureCureCD then return end
	--print(unitid)
	if DA_GetHasActiveAffix('受难') then
		--大秘境[受难]词缀
		local SpecialUnitID, Cont = DA_GetHealsSpecialExists('受难之魂')
		if SpecialUnitID and UnitName(unitid) ~= '受难之魂' then
			--存在[受难之魂],且该单位不是[受难之魂]
			--print(UnitName(unitid)..' 不是受难之魂,无视')
			return
		end
	end
	local guid = UnitGUID(unitid)
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	local class, classFileName = UnitClass(unitid)
	local MouseoverUnitTime = DA_GetMouseoverUnitTime(unitid)
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

	if UnitCanAssist("player", unitid) and not RestorationUnitHasAuras then
		local index = 1
		while true do
			local PVP_debuffType = nil
			local name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID = DA_UnitDebuff(unitid, index)
			if not spellID then
				break
			end
			if debuffType == "Curse" or debuffType == "Magic" or debuffType == "Poison" then 
				if MouseoverUnitTime < 0.3 or not RestorationSaves.RestorationOption_Auras_ClearMouseover then
				--鼠标在该单位身上停留小于0.3秒,或者没有开启强驱鼠标指向,才进行是否驱散特殊DEBUFF判断
				
					local timeLeft = expirationTime and expirationTime > GetTime() and (expirationTime - GetTime()) or 0
					--DEBUFF剩余时间
					local timeDuration = duration and duration - timeLeft
					--DEBUFF已持续时间
					local description = C_Spell.GetSpellDescription(spellID)
					--DEBUFF文字描述
					
					if C_PvP.IsActiveBattlefield() then
					--战场/竞技场中
						PVP_debuffType = debuffType
						debuffType = nil
						if timeLeft > 0 then
							--如果DEBUFF有剩余时间
							if timeDuration < 1 and (DamagerEngine_HealerAssigned and #DamagerEngine_HealerAssigned >= 2) then
								--存在其他治疗的情况下，DEBUFF存在1秒后才驱散
								return
							elseif timeDuration < 0.15 then
								--DEBUFF存在0.15秒后才驱散
								return
							end
						end

						if NoClearPVPDebuffCache[name] then
							--中了不要驱散的PVP DEBUFF则不驱散该目标
							if Health75 and Health75 <= 0 then
								--除非没有血量低于75%的单位
							else
								return
							end
						end

						if (timeLeft < 1.5 and timeLeft ~= 0) then
							--DEBUFF剩余时间小于1.5秒则忽视, 不包括无限时间的DEBUFF
							debuffType = nil
						end

						if PVPDebuffCache[name] then
							--PVP只驱散PVPDebuffCache中的DEBUFF
							debuffType = PVP_debuffType
							
							if classFileName == "DRUID" and PVPDebuffCache[name].Type == "ROOT" then
								--无视德鲁伊身上的定身减速类DEBUFF
								debuffType = nil
							end
							if (name == '致伤药膏' and count < 3) then
								--特定法术层数小于3层则忽视, 比如潜行者的[致伤药膏]
								debuffType = nil
							end
						end
						
					else
					--非战场/竞技场
						if timeLeft > 0 then
						--如果DEBUFF有剩余时间
							if timeDuration < 1 and (DamagerEngine_HealerAssigned and #DamagerEngine_HealerAssigned >= 2) then
							--存在其他治疗的情况下，DEBUFF存在1秒后才驱散
								return
							elseif timeDuration < 0.5 then
							--DEBUFF存在0.5秒后才驱散
								return
							end
						end
						
						local patterns = {"效果结束", "被驱散", "移除时", "移除后", "被移除"}
						for _, pattern in ipairs(patterns) do
							local startPos = description:find(pattern)
							if startPos then
								local causePos = description:find("造成", startPos)
								if causePos and description:find("伤害", causePos) then
									--DEBUFF驱散后会造成伤害则不驱散该目标,除非该DEBUFF在白名单里
									--print('DEBUFF: '..spellID..' 会造成移除伤害')
									if not PassNoClearDebuffCache[spellID] and not AffectGropuDebuffCache[name] then
										--该DEBUFF不在白名单和驱散后会影响附近队友的DEBUFF名单
										return
									end
								end
							end
						end
						if NoClearDebuffCache[name] and NoClearDebuffCache[name].Instance == PlayerInstance then
						--中了绝对不要驱散的DEBUFF则不驱散该目标
							return
						end
						if NoPriorityClearDebuffCache[spellID] then
						--中了忽视的DEBUFF则忽视该DEBUFF
							debuffType = nil
						end
						if AffectGropuDebuffCache[name] and AffectGropuDebuffCache[name].Instance == PlayerInstance then
							local debuffInfo = AffectGropuDebuffCache[name]
							if ObjectPosition and ObjectPosition("player") then
								--能获取位置,则根据单位附近队友数量判断是否驱散
								if Restoration_GetGroupWithUnitCount(unitid, debuffInfo.Distance) == 0 or (debuffInfo.TimeLeftClear and timeDuration - debuffInfo.TimeLeftClear > 0) then
									--print("可以驱散: "..name)
								else
									debuffType = nil
								end
							elseif debuffInfo.TimeLeftClear and timeDuration - debuffInfo.TimeLeftClear > 0 then
								--不能获取位置,则根据DEBUFF类型和已持续时间判断是否驱散
								--print("可以驱散: "..name)
							else
								debuffType = nil
							end
						end
						
						if (timeLeft < 1.5 and timeLeft ~= 0) then
							--DEBUFF剩余时间小于1.5秒则忽视, 不包括无限时间的DEBUFF
							debuffType = nil
						end
						if ((spellID == 191960 or spellID == 207278 or spellID == 214690 or spellID == 196515 or spellID == 203685 or spellID == 238480) and guid == UnitGUID("player")) then
							--特定法术在自己身上则忽视, 比如噬魂之喉小怪的[带钩长矛]、群星庭院巡逻队长加多的[奥术锁定]、群星庭院邪恶的格伦斯的[残废术]、艾萨拉之眼小怪的[魔法禁锢]、守望者地窟小怪的[石化血肉]、永夜大教堂小怪的[镣铐书籍]
							debuffType = nil
						end
						if ((spellID == 209469 or spellID == 243299) and count < 2 and timeDuration < 10) then
							--特定法术层数小于2层且已持续时间小于10秒则忽视, 比如翡翠梦魇伊格诺斯，腐蚀之心的[腐蚀之触]、萨格拉斯之墓小怪的[痛楚]
							debuffType = nil
						end
						if ((spellID == 211007 or spellID == 204044 or spellID == 272180) and count < 2) then
							--特定法术层数小于2层则忽视, 比如群星庭院夜之子复国者的[漩涡之眼]、翡翠梦魇梦魇之龙的[暗影爆裂]、地渊孢林小怪的[湮灭之球
							debuffType = nil
						end
						if (spellID == 228829 and count > 2 and UnitHealth(unitid) > UnitHealthMax("player") * 0.3) then
							--特定法术层数大于2层且血量高于玩家最大血量的30%则忽视, 比如卡拉赞夜之魇的[炽燃之骨]
							debuffType = nil
						end
						if ((spellID == 200642 or spellID == 193938 or spellID == 210645 or spellID == 203685 or spellID == 269301 or spellID == 322817 or spellID == 372682 or spellID == 275836) and count < 3) then
							--特定法术层数小于3层则忽视, 比如黑心林地恐魂毁灭者的[绝望]、群星庭院酸蚀胆汁的[软泥爆炸]、群星庭院枯法魔的[奥术之灾]、守望者地窟小怪的[石化血肉], 地渊孢林不羁畸变怪的[腐败之血], 晋升高塔疑虑圣杰德沃丝的[疑云密布]], 红玉新生法池的[原始酷寒],围攻伯拉勒斯小怪的[钉刺之毒]
							debuffType = nil
						end
						if ((spellID == 201380 or spellID == 193636 or spellID == 269298) and count < 5) then
							--特定法术层数小于5层则忽视, 紫罗兰监狱颤栗之喉的[冰霜吐息], 艾萨拉之眼盐水小水滴的[水花飞溅], 暴富矿区！！小怪的[寡妇蛛毒素]
							debuffType = nil
						end
						if (spellID == 225909 and count < 10 and (timeDuration < 5 or count < 5)) then
							--特定法术层数小于10层且(已持续时间小于5秒或层数大于5层)则忽视, 比如黑鸦堡垒鸦堡小蜘蛛的[灵魂毒液]
							debuffType = nil
						end
						if (spellID == 257974 and (count < 9 or timeLeft < 4)) then
							--特定法术层数小于9层或剩余时间小于4秒则忽视, 比如安托鲁斯，燃烧王座安托兰统帅议会的[混乱脉冲]
							debuffType = nil
						end
						if ((spellID == 244613) and timeDuration < 3.5) then
							--特定法术已持续时间小于3.5秒则忽视, 比如燃烧王座传送门守护者哈萨贝尔的[永燃烈焰]
							debuffType = nil
						end
						if (spellID == 267037 and UnitHealth(unitid) > UnitHealthMax(unitid) * 0.6) then
							--特定法术玩家血量大于60%则忽视, 比如风暴神殿低语者沃尔兹斯的[力量的低语]
							debuffType = nil
						end
						if (spellID == 258128) and DA_UnitGroupRolesAssigned(unitid) ~= "DAMAGER" then
							--特定法术不在DPS身上则忽视, 比如托尔达戈小怪的[衰弱怒吼]
							debuffType = nil
						end
						if (spellID == 319603) and (select(3, GetInstanceInfo()) == 23 or select(3, GetInstanceInfo()) == 8) and guid ~= UnitGUID("player") then
							--特定法术在史诗或者大秘境难度下,不在自己身上则忽视, 比如赎罪大厅-艾谢朗的[羁石诅咒]
							debuffType = nil
						end
						if spellID == 240443 then
							--大秘境[爆裂]
							if count <= 1 and UnitHealth(unitid) > UnitHealthMax("player") * 0.5 then
								debuffType = nil
							end
							if count <= 2 and UnitHealth(unitid) > UnitHealthMax("player") * 0.6 and Restoration_EnemyCache and #Restoration_EnemyCache > 0 then
								debuffType = nil
							end
							if count <= 3 and UnitHealth(unitid) > UnitHealthMax("player") * 0.7 and Restoration_EnemyCache and #Restoration_EnemyCache > 0 then
								debuffType = nil
							end
							if count <= 4 and UnitHealth(unitid) > UnitHealthMax("player") * 0.8 and Restoration_EnemyCache and #Restoration_EnemyCache > 0 then
								debuffType = nil
							end
							if count <= 5 and UnitHealth(unitid) > UnitHealthMax("player") * 0.9 and Restoration_EnemyCache and #Restoration_EnemyCache > 0 then
								debuffType = nil
							end
						end
						if (spellID == 392641 and UnitHealth(unitid) < UnitHealthMax(unitid) * 0.5) then
							--特定法术玩家血量小于50%则忽视, 比如红玉新生法池雷霆之颅的[滚雷]
							debuffType = nil
						end
						if ((spellID == 461487) and (guid ~= UnitGUID("player") or IsPlayerMoving())) then
							--特定法术只驱散自己身上的,如果在移动中则不驱散, 比如艾拉-卡拉，回响之城-收割者吉卡塔尔的[培植毒药]
							debuffType = nil
						end
					end
				end
				
				if debuffType == "Curse" and IsPlayerSpell(392378) and (RestorationSaves.RestorationOption_Auras_ClearCurse or (RestorationSaves.RestorationOption_Auras_ClearMouseover and MouseoverUnitTime >= 0.3)) and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not Restoration_NatureCureCD then
					DA_TargetUnit(unitid)
					if UnitIsUnit('target', unitid) then
						DA_CastSpellByID(Nature_Cure_SpellID)
					end
					Restoration_RefreshRaidCastlInfo(unitid, Nature_Cure_SpellID)
					RestorationSpellWillBeCast = 1
					RestorationUnitHasAuras = 1
				end
				if debuffType == "Magic" and (RestorationSaves.RestorationOption_Auras_ClearMagic or (RestorationSaves.RestorationOption_Auras_ClearMouseover and MouseoverUnitTime >= 0.3)) and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not Restoration_NatureCureCD then
					DA_TargetUnit(unitid)
					if UnitIsUnit('target', unitid) then
						DA_CastSpellByID(Nature_Cure_SpellID)
					end
					Restoration_RefreshRaidCastlInfo(unitid, Nature_Cure_SpellID)
					RestorationSpellWillBeCast = 1
					RestorationUnitHasAuras = 1
				end
				if debuffType == "Poison" and IsPlayerSpell(392378) and (RestorationSaves.RestorationOption_Auras_ClearPoison or (RestorationSaves.RestorationOption_Auras_ClearMouseover and MouseoverUnitTime >= 0.3)) and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not Restoration_NatureCureCD then
					DA_TargetUnit(unitid)
					if UnitIsUnit('target', unitid) then
						DA_CastSpellByID(Nature_Cure_SpellID)
					end
					Restoration_RefreshRaidCastlInfo(unitid, Nature_Cure_SpellID)
					RestorationSpellWillBeCast = 1
					RestorationUnitHasAuras = 1
				end
			end
			
			index = index + 1
		end
	end
end

function Restoration_GetGroupWithUnitCount(unitid, distance)
	--获取目标附近一定距离内队友数量
	local PartyCount = 0
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			unitid2 = "raid"..i
			if UnitGUID(unitid) ~= UnitGUID(unitid2) and DA_GetNovaDistance(unitid, unitid2) <= distance then
				PartyCount = PartyCount + 1
			end
		end
	elseif IsInGroup() then
		for i=1, GetNumGroupMembers() - 1 do
			unitid2 = "party"..i
			if UnitGUID(unitid) ~= UnitGUID(unitid2) and DA_GetNovaDistance(unitid, unitid2) <= distance then
				PartyCount = PartyCount + 1
			end
		end
		unitid2 = "player"
		if UnitGUID(unitid) ~= UnitGUID(unitid2) and DA_GetNovaDistance(unitid, unitid2) <= distance then
			PartyCount = PartyCount + 1
		end
	end
	return PartyCount
end