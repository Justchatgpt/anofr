--技能预警
local RestorationStatusAlertSpell = CreateFrame("Frame")

RestorationStatusAlertSpell:RegisterEvent("UNIT_SPELLCAST_START")
RestorationStatusAlertSpell:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
RestorationStatusAlertSpell:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
RestorationStatusAlertSpell:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")


RestorationStatusAlertSpell:SetScript("OnEvent", function(self, event, ...)
	if not RestorationCycleStart then return end
	local AlertSpellUnitID, _, spellID = ...
	if not AlertSpellUnitID then return end
	local spell = DA_GetSpellInfo(spellID)
	if event == "UNIT_SPELLCAST_START" and spellID == Regrowth_SpellID and AlertSpellUnitID == "player" and not RestorationHeals_AlertSpellChannel then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(AlertSpellUnitID)
		local _, _, icon, castingTime = DA_GetSpellInfo(Regrowth_SpellID) --愈合
		C_Timer.After(castingTime/1000 - 0.1 , function()
			RestorationHeals_AlertSpellGUID = nil
		end)
		--已预读治疗之触
	end
	
	if UnitIsFriend(AlertSpellUnitID, "player") then return end
	
	if UnitGUID(AlertSpellUnitID.."target") then
		for i = 1, #HealerEngineAlertSpellSingleCache do
			if HealerEngine_GetNoHealAuras(AlertSpellUnitID.."target") then break end
			if spell == HealerEngineAlertSpellSingleCache[i].Name then
				local unitid = AlertSpellUnitID.."target"
				if event == "UNIT_SPELLCAST_START" then
					--print(spell.." CastID: "..spellID)
				end
				if event == "UNIT_SPELLCAST_CHANNEL_START" then
					--print(spell.." ChannelID: "..spellID)
				end
			end
			if spellID == HealerEngineAlertSpellSingleCache[i].ID then
				local unitid = AlertSpellUnitID.."target"
				if event == "UNIT_SPELLCAST_START" then
					local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(AlertSpellUnitID)
					local _, _, icon, castingTime = DA_GetSpellInfo(Regrowth_SpellID) --愈合
					AlertSpellduration1 = (endTime - startTime)/1000 - castingTime/1000 - 2
					if AlertSpellduration1 < 0 then AlertSpellduration1 = 0.1 end
					--提前回春延迟时间
					AlertSpellduration2 = (endTime - startTime)/1000 - castingTime/1000 + 1
					--此处+1秒考虑到法术飞行时间
					if AlertSpellduration2 < 0 then AlertSpellduration2 = 0.1 end
					--预读治疗提前时间
					AlertSpellduration3 = (endTime - startTime)/1000 + 1
					--施法完成后1秒
					if AlertSpellduration3 < 0 then AlertSpellduration3 = 0.1 end
					--清除提前回春赋值时间
					
					C_Timer.After(AlertSpellduration1, function()
						if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsDeadOrGhost(unitid) and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup() or HealerEngine_GetSpecialHealsUnit(unitid)) then
							RestorationHeals_AlertSpellRejuvenationGUID = UnitGUID(unitid)
							--提前回春术目标GUID
						end
					end)
					
					if HealerEngineAlertSpellSingleCache[i].Breakout then
						--部分技能结束后会有爆发性伤害
						C_Timer.After(AlertSpellduration1, function()
							if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsDeadOrGhost(unitid) and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup() or HealerEngine_GetSpecialHealsUnit(unitid)) then
								RestorationHeals_AlertSpellBreakoutGUID = UnitGUID(unitid)
								--提前爆发性伤害技能回春术目标GUID
							end
						end)
					end
					
					C_Timer.After(AlertSpellduration2, function()
						if unitid and UnitGetIncomingHeals(unitid) and UnitHealthMax(unitid) and UnitGetIncomingHeals(unitid) > UnitHealthMax(unitid) * 0.2 then return end
						--排除已受到一定治疗量的目标
						if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsDeadOrGhost(unitid) and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup() or HealerEngine_GetSpecialHealsUnit(unitid)) then
							RestorationHeals_AlertSpellGUID = UnitGUID(unitid)
							--预读治疗目标GUID
						end
					end)
					
					C_Timer.After(AlertSpellduration3, function()
						RestorationHeals_AlertSpellRejuvenationGUID = nil
						RestorationHeals_AlertSpellBreakoutGUID = nil
					end)
				end
				if event == "UNIT_SPELLCAST_SUCCEEDED" and spellID ~= 204611 and spellID ~= 227628 and spellID ~= 322554 then
					--排除引导法术
					C_Timer.After(1.5, function()
					--此处1.5秒考虑到法术飞行时间与读条延迟
						RestorationHeals_AlertSpellGUID = nil
					end)
				end
				
				if event == "UNIT_SPELLCAST_CHANNEL_START" then
					local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(AlertSpellUnitID)
					AlertSpellduration1 = 0.1
					if (endTime - startTime)/1000 < 45 then
						AlertSpellduration2 = (endTime - startTime)/1000 + 1
					else
						AlertSpellduration2 = 45
					end
					AlertSpellduration3 = (endTime - startTime)/1000 - 0.5
					if AlertSpellduration3 < 0 then AlertSpellduration3 = 0 end
				
					C_Timer.After(AlertSpellduration1, function()
						if unitid and UnitGetIncomingHeals(unitid) and UnitHealthMax(unitid) and UnitGetIncomingHeals(unitid) > UnitHealthMax(unitid) * 0.2 then return end
						--排除已受到一定治疗量的目标
						if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsDeadOrGhost(unitid) and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup() or HealerEngine_GetSpecialHealsUnit(unitid)) then
							RestorationHeals_AlertSpellRejuvenationGUID = UnitGUID(unitid)
							--提前回春术目标GUID
							RestorationHeals_AlertSpellGUID = UnitGUID(unitid)
							--预读治疗目标GUID
							RestorationHeals_AlertSpellChannel = 1
						end
					end)
					C_Timer.After(AlertSpellduration2, function()
						RestorationHeals_AlertSpellGUID = nil
						RestorationHeals_AlertSpellChannel = nil
						RestorationHeals_AlertSpellRejuvenationGUID = nil
					end)
					C_Timer.After(AlertSpellduration3, function()
						if UnitCastingInfo("player") ~= '愈合' then
							RestorationHeals_AlertSpellGUID = nil
							RestorationHeals_AlertSpellChannel = nil
							RestorationHeals_AlertSpellRejuvenationGUID = nil
						end
					end)
				end
				if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
					RestorationHeals_AlertSpellGUID = nil
					RestorationHeals_AlertSpellChannel = nil
					RestorationHeals_AlertSpellRejuvenationGUID = nil
				end
				
				break
			end
		end
	end
	
	for i = 1, #HealerEngineAlertSpellAOECache do
		if spell == HealerEngineAlertSpellAOECache[i].Name then
			if event == "UNIT_SPELLCAST_START" then
				--print(spell.." CastAOEID: "..spellID)
			end
			if event == "UNIT_SPELLCAST_CHANNEL_START" then
				--print(spell.." ChannelAOEID: "..spellID)
			end
		end
		if spellID == HealerEngineAlertSpellAOECache[i].ID then
			if event == "UNIT_SPELLCAST_START" then
				local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(AlertSpellUnitID)
				local _, _, icon, castingTime = DA_GetSpellInfo(Wild_Growth_SpellID) --野性成长
				AlertSpellduration4 = (endTime - startTime)/1000 - 0.5
				if AlertSpellduration4 < 0 then AlertSpellduration4 = 0 end
				RestorationHeals_SpellGCD = RestorationHeals_SpellGCD or 1250
				AlertSpellduration5 = (endTime - startTime)/1000 - castingTime/1000 - RestorationHeals_SpellGCD/1000
				if AlertSpellduration5 < 0 then AlertSpellduration5 = 0 end
				AlertSpellduration6 = (endTime - startTime)/1000 - castingTime/1000 + 0.1
				if AlertSpellduration6 < 0 then AlertSpellduration6 = 0 end
				AlertSpellduration7 = (endTime - startTime)/1000 + 0.25
				if AlertSpellduration7 < 0 then AlertSpellduration7 = 0 end
				RestorationHeals_AlertSpellAOE = 1
				C_Timer.After(AlertSpellduration4, function()
					RestorationHeals_AlertSpellAOE = nil
					RestorationHeals_HealBreakoutSpellAOE = nil
				end)
				if HealerEngineAlertSpellAOECache[i].Type ~= "Repel" then
				--如果非击退技能,则预读野性成长
					C_Timer.After(AlertSpellduration5, function()
						if not WildGrowthCD then
							--print("停止施法留出GCD")
							RestorationHeals_AlertSpellAOEWillWildGrowth = 1
							RestorationHeals_AlertSpellAOE = nil
							RestorationHeals_HealBreakoutSpellAOE = nil
						end
					end)
					C_Timer.After(AlertSpellduration6, function()
						if not WildGrowthCD and UnitCastingInfo(AlertSpellUnitID) then
							--print("野性成长")
							--if UnitCastingInfo("player") == '愈合' or UnitCastingInfo("player") == '愤怒' then
							if UnitCastingInfo("player") == '愤怒' then
								DA_SpellStopCasting()
							end
							RestorationHeals_AlertSpellAOEWildGrowth = 1
						end
					end)
					C_Timer.After(AlertSpellduration7, function()
						--print("野性成长结束")
						RestorationHeals_AlertSpellAOEWillWildGrowth = nil
						RestorationHeals_AlertSpellAOEWildGrowth = nil
					end)
				end
				if HealerEngineAlertSpellAOECache[i].Breakout then
					RestorationHeals_HealBreakoutSpellAOE = 1
					--部分技能结束后会有爆发性伤害
				end
			end
			
			if event == "UNIT_SPELLCAST_CHANNEL_START" then
				local name, text, texture, startTime, endTime, isTradeSkill, notInterruptible = UnitChannelInfo(AlertSpellUnitID)
				if (endTime - startTime)/1000 < 45 then
					AlertSpellduration4 = (endTime - startTime)/1000
				else
					AlertSpellduration4 = 45
				end
				
				RestorationHeals_AlertSpellAOE = 1
				C_Timer.After(AlertSpellduration4, function()
					RestorationHeals_AlertSpellAOE = nil
				end) 
			end
			if event == "UNIT_SPELLCAST_CHANNEL_STOP" then
				RestorationHeals_AlertSpellAOE = nil
			end
		
			break
		end
	end
end)