--不要读条Auras监测
local RestorationStatusNoCastingAuras = CreateFrame("Frame")

RestorationStatusNoCastingAuras:RegisterEvent("UNIT_SPELLCAST_START")

function Restoration_GetNoCastingAuras()
	if not RestorationHeals_InterruptCastIng then
		RestorationHeals_NoCastingAuras = nil
		RestorationHeals_NoChannelAuras = nil
	end
	local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1
	local timeLeft
	
	for i = 1, #HealerEngineNoCastingDebuffCache do
		name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(HealerEngineNoCastingDebuffCache[i].Name, "player", "HARMFUL")
		if spellID1 then
			timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
			--DEBUFF剩余时间
			if name1 == HealerEngineNoCastingDebuffCache[i].Name then
				--print(name1.." ID: "..spellID1)
			end
			if spellID1 == HealerEngineNoCastingDebuffCache[i].ID then
				local _, _, icon2, castingTime2 = DA_GetSpellInfo(Regrowth_SpellID) --愈合
				if castingTime2/1000 + 0.25 > timeLeft then
					RestorationHeals_NoCastingAuras = 1
				end
				RestorationHeals_NoChannelAuras = 1
				--引导技能提前保护
				if (UnitCastingInfo("player") or UnitChannelInfo("player")) and timeLeft < 0.25 then
					DA_SpellStopCasting()
					--读条时遇到不要读条Auras则中断施法
				end
				break
			end
		end
	end
	--DeBuff
end

RestorationStatusNoCastingAuras:SetScript("OnEvent", function(self, event, ...)
	if not RestorationCycleStart then return end
	local unitid, _, spellID = ...
	if not unitid then return end
	local spell = DA_GetSpellInfo(spellID)
	if UnitIsFriend(unitid, "player") then return end
	for i = 1, #HealerEngineNoCastingSpellCache do
		if spell == HealerEngineNoCastingSpellCache[i].Name then
			--print(spell.." InterruptCastID: "..spellID)
		end
		if spellID == HealerEngineNoCastingSpellCache[i].ID then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
			local _, _, icon2, castingTime2 = DA_GetSpellInfo(Regrowth_SpellID) --愈合
			local interruptcastingTime = (endTime - startTime)/1000
			local t2 = interruptcastingTime - castingTime2/1000 - 0.25
			local t3 = interruptcastingTime - 0.25
			local t4 = interruptcastingTime + 0.1
			if t2 < 0 then t2 = 0 end
			if t3 < 0 then t3 = 0 end
			if t4 < 0 then t4 = 0 end
			
			C_Timer.After(t2, function()
				RestorationHeals_NoCastingAuras = 1
				RestorationHeals_InterruptCastIng = 1
			end)
			C_Timer.After(t3, function()
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					RestorationHeals_NoCastingAuras = 1
					RestorationHeals_InterruptCastIng = 1
					DA_SpellStopCasting()
					--读条时遇到不要读条施法则中断施法
				end
			end)
			RestorationHeals_NoChannelAuras = 1
			--引导技能提前保护
			C_Timer.After(t4, function()
				RestorationHeals_NoCastingAuras = nil
				RestorationHeals_NoChannelAuras = nil
				RestorationHeals_InterruptCastIng = nil
			end)
		end
	end
end)