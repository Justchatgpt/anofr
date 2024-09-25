--增减益监测

local PassNoClearDebuffCache = {
	--驱散后会有不良影响的DEBUFF白名单(可以驱散)
	--[31589] = {Name = "减速", Instance = "测试"},
}
local NoClearDebuffCache = {
	--绝对不要驱散的DEBUFF(用法术名称及Instance匹配)
	--["减速"] = {SpellID = 31589, Instance = "测试"},
}
local NoPriorityClearDebuffCache = {
	--忽视的DEBUFF(用法术ID匹配)
	--[31589] = {Name = "减速", Instance = "测试"},
}
local AffectGropuDebuffCache = {
	--驱散后会影响附近队友的DEBUFF(用法术名称及Instance匹配)
	--["减速"] = {SpellID = 31589, Distance = 10, TimeLeftClear = 3, Instance = "测试"},
	["培植毒药"] = {SpellID = 461487, Distance = 20, TimeLeftClear = 3, Instance = "艾拉-卡拉，回响之城"},
}

local NoClearPVPDebuffCache = {
	--不要驱散的PVP DEBUFF
	["痛苦无常"] = {Type = "", Instance = "术士"},
	["吸血鬼之触"] = {Type = "", Instance = "牧师"},
}
local PVPDebuffCache = {
	--PVP只驱散特定DEBUFF
	["妖术"] = {Type = "", Instance = "萨满"},
	["虚弱诅咒"] = {Type = "", Instance = "术士"},
	["语言诅咒"] = {Type = "", Instance = "术士"},
	["致伤药膏"] = {Type = "", Instance = "潜行者"},
}

function Balance_ScanUnitAuras(unitid)
	if not unitid or RemoveCorruptionCD then return end
	--print(unitid)
	if DA_GetHasActiveAffix('受难') then
		--大秘境[受难]词缀
		local SpecialUnitID = DA_GetHealsSpecialExists('受难之魂')
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
	
	if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not Balance_GetTargetNotVisible(unitid) and DA_GetLineOfSight("player", unitid) and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup()) then
		local index = 1
		while true do
			local PVP_debuffType = nil
			local name, icon, count, debuffType, duration, expirationTime, caster, isStealable, nameplateShowPersonal, spellID = DA_UnitDebuff(unitid, index)
			if not spellID then
				break
			end
			
			if debuffType == "Curse" or debuffType == "Poison" then 
				if MouseoverUnitTime < 0.3 or not BalanceSaves.BalanceOption_Auras_ClearMouseover then
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
							if timeDuration < 2.5 and (DamagerEngine_HealerAssigned and #DamagerEngine_HealerAssigned >= 1) and spellID ~= 319603 then
							--存在其他治疗的情况下，DEBUFF存在2.5秒后才驱散,特殊DEBUFF除外
								return
							elseif timeDuration < 0.2 then
							--DEBUFF存在0.2秒后才驱散
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
						if (spellID == 319603) and (select(3, GetInstanceInfo()) == 23 or select(3, GetInstanceInfo()) == 8) and guid ~= UnitGUID("player") then
							--特定法术在史诗或者大秘境难度下,不在自己身上则忽视, 比如赎罪大厅-艾谢朗的[羁石诅咒]
							debuffType = nil
						end
						if ((spellID == 461487) and (guid ~= UnitGUID("player") or IsPlayerMoving())) then
							--特定法术只驱散自己身上的,如果在移动中则不驱散, 比如艾拉-卡拉，回响之城-收割者吉卡塔尔的[培植毒药]
							debuffType = nil
						end
						if ((spellID == 275836) and count < 3) then
							--特定法术层数小于3层则忽视, 比如围攻伯拉勒斯小怪的[钉刺之毒]
							debuffType = nil
						end
					end
				end
				
				if debuffType == "Curse" then
					if (BalanceSaves.BalanceOption_Auras_ClearCurse or (BalanceSaves.BalanceOption_Auras_ClearMouseover and MouseoverUnitTime >= 0.3)) then
					--自动解诅咒
						if not RemoveCorruptionCD and not IsStealthed() and not Balance_CastSpellIng then
							if GetCVar("autoSelfCast") == '1' and UnitIsUnit('player', unitid) and (UnitCanAttack("player", "target") or UnitIsEnemy("player", "target")) then
							--施法目标是玩家自己且玩家自己的目标是可攻击或敌对目标
								DA_CastSpellByID(Remove_Corruption_SpellID)
							else
							--友方目标
								DA_TargetUnit(unitid)
								if UnitIsUnit('target',unitid) then
									DA_CastSpellByID(Remove_Corruption_SpellID)
								end
							end
							--清除腐蚀
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("清除腐蚀")
						end
					end
				end
				if debuffType == "Poison" then
					if (BalanceSaves.BalanceOption_Auras_ClearPoison or (BalanceSaves.BalanceOption_Auras_ClearMouseover and MouseoverUnitTime >= 0.3)) then
					--自动解毒药
						if not RemoveCorruptionCD and not IsStealthed() and not Balance_CastSpellIng then
							if GetCVar("autoSelfCast") == '1' and UnitIsUnit('player', unitid) and (UnitCanAttack("player", "target") or UnitIsEnemy("player", "target")) then
							--施法目标是玩家自己且玩家自己的目标是可攻击或敌对目标
								DA_CastSpellByID(Remove_Corruption_SpellID)
							else
							--友方目标
								DA_TargetUnit(unitid)
								if UnitIsUnit('target',unitid) then
									DA_CastSpellByID(Remove_Corruption_SpellID)
								end
							end
							--清除腐蚀
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("清除腐蚀")
						end
					end
				end
			end
			
			index = index + 1
		end
	end
end

function Balance_GetGroupWithUnitCount(unitid, distance)
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