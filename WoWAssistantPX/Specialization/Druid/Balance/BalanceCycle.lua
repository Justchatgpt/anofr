--平衡德

BalanceCycleFrame = CreateFrame("Frame")
BalanceCycleFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
BalanceCycleFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
BalanceCycleFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
BalanceCycleFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
BalanceCycleFrame:RegisterEvent("UI_ERROR_MESSAGE")
BalanceCycleFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
BalanceCycleFrame:RegisterEvent("CURSOR_CHANGED")
BalanceCycleFrame:RegisterEvent("UNIT_SPELLCAST_START")
BalanceCycleFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
BalanceCycleFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
BalanceCycleFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

local SDPHR = 0.25
--当前版本玩家单体DPS与玩家血量的比值(SingleDPS_PlayerHealthMax_Ratio)
--7.0版本后期:0.35
--8.0版本初期:0.075

function Balance_SetDebugInfo(spell)
	local name, rank, icon = DA_GetSpellInfo(spell)
	--print('使用:'..spell)
	if icon then
		Balance_DeBugSpellIcon.Texture:SetTexture(icon)
	end
end
		
local TargetHealth = 0
local TargetHealthScale = 0
local PlayerHealthScale = 0
local PlayerPowerNow = 0
local PlayerPowerMaximum = 0
local PlayerPowerScale = 0
local PlayerPowerVacancy = 0
local StarfallUnitCount = 2

Balance_FindEnemyCombatLogAttackMeUnitCache = {}

function Balance_UseAttributesEnhancedItem()
	--使用属性增强饰品
	if not BalanceSaves.BalanceOption_Attack_AutoAccessories then return end
	
	for i = 13, 14 do
		local ItemID = _G["AttributesEnhancedItemID"..i]
		local slotID = nil
		if ItemID == 144258 and C_PvP.IsActiveBattlefield() then
			--部分饰品不能在战场中使用,例如[基尔加丹的炽燃决心]
			ItemID = nil
		end
		if ItemID and C_Item.IsUsableItem(ItemID) and GetItemCooldown(ItemID) == 0 and not UnitChannelInfo("player") then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			DA_UseItem(slotID)
			Balance_CastSpellIng = 1
			return true
		end
	end
end

function Balance_UseConcoctionKissOfDeath()
	--[制剂：死亡之吻]
	if C_Item.IsEquippedItem(215174) then
		local SpecialItemSlotID = nil
		for i = 13, 14 do
			local ItemID = _G["SpecialItemID"..i]
			local slotID = nil
			if ItemID and C_Item.IsUsableItem(ItemID) and DA_GetItemCooldown(ItemID) == 0 then
				if i == 13 then
					slotID = 13
				elseif i == 14 then
					slotID = 14
				end
				SpecialItemSlotID = slotID
			end
		end
		
		if SpecialItemSlotID then
			local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(435493), "player", "HELPFUL")
			local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
			--BUFF剩余时间
			if timeLeft < 2 then
				local CastTime = 0
				local _, _, _, startTime, endTime = UnitCastingInfo('player')
				CastTime = endTime and endTime/1000 - GetTime()
				--剩余施法时间
				if name1 and CastTime >= 1 then
					DA_SpellStopCasting()
					--中断施法
				end
				DA_UseItem(SpecialItemSlotID)
				--使用制剂：死亡之吻
			end
		end
	end
end

function Balance_GetDirectSingleDPSItemCD(Unit)
	--判断单体伤害饰品CD
	if not Unit then return end
	DirectSingleDPSItemCD = 1
	for i = 13, 14 do
		local ItemID = _G["DirectSingleDPSItemID"..i]
		local slotID = nil
		if ItemID and C_Item.IsUsableItem(ItemID) and GetItemCooldown(ItemID) == 0 and (C_Item.IsItemInRange(ItemID, Unit) or C_Item.IsItemInRange(ItemID, Unit) == nil) and not UnitChannelInfo("player") and UnitAffectingCombat("player") then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			DirectSingleDPSItemCD = nil
			DirectSingleDPSItemID = slotID
		end
	end
end

function Balance_GetDirectAoeDPSItemCD(Unit)
	--判断AOE伤害饰品CD
	if not Unit then return end
	DirectAoeDPSItemCD = 1
	for i = 13, 14 do
		local ItemID = _G["DirectAoeDPSItemID"..i]
		local slotID = nil
		if ItemID and C_Item.IsUsableItem(ItemID) and GetItemCooldown(ItemID) == 0 and (C_Item.IsItemInRange(ItemID, Unit) or C_Item.IsItemInRange(ItemID, Unit) == nil) and not UnitChannelInfo("player") and UnitAffectingCombat("player") then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			DirectAoeDPSItemCD = nil
			DirectAoeDPSItemID = slotID
			if ItemID == 140800 and DA_GetNovaDistance("player", Unit) < 10 then
				--部分饰品存在距离限制,例如[法拉米尔的禁忌魔典]
				DirectAoeDPSItemCD = 1
			end
			if ItemID == 144259 and C_PvP.IsActiveBattlefield() then
				--部分饰品不能在战场中使用,例如[基尔加丹的炽燃决心]
				DirectAoeDPSItemCD = 1
			end
			if ItemID == 184019 and (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) and AuraUtil.FindAuraByName(DA_GetSpellInfo(345211), "player", "HELPFUL") then
				--首次使用[燃魂者]不会进入CD,会产生[灵魂燃烧]BUFF.当敌对目标总体血量不低时,[灵魂燃烧]BUFF结束后自动AOE
				DirectAoeDPSItemCD = 1
			end
		end
	end
end

function GetBalance_EnemyCacheByHealth(sort)
	--按血量高低获取敌对单位
	local Cache = CloneTable(Balance_EnemyCacheHasThreat) or {}
	if #Cache > 0 then
		if sort == "LOW" then
			table.sort(Cache, function(a, b) return a.UnitHealth < b.UnitHealth end)
			--血量从低到高排序
		elseif sort == "HIGH" then
			table.sort(Cache, function(a, b) return a.UnitHealth > b.UnitHealth end)
			--血量从高到低排序
		elseif sort == "VacancyLOW" then
			table.sort(Cache, function(a, b) return a.UnitHealthVacancy < b.UnitHealthVacancy end)
			--损失的血量从低到高排序
		elseif sort == "VacancyHIGH" then
			table.sort(Cache, function(a, b) return a.UnitHealthVacancy > b.UnitHealthVacancy end)
			--损失的血量从高到低排序
		end
		return Cache[1].Unit
	end
end

function Balance_OnEvent(self, event, ...)
	if not BalanceCycleStart then return end
	local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = ...
	if event == "COMBAT_LOG_EVENT" or event == "COMBAT_LOG_EVENT_UNFILTERED" then
		a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = CombatLogGetCurrentEventInfo()
	end
	
	if event == "PLAYER_TARGET_CHANGED" then
		Just_OneTargetNearest = nil
		if DA_Start_TargetNearest_Unit and UnitGUID("target") == UnitGUID(DA_Start_TargetNearest_Unit) then
			--print("已选中目标: " .. UnitName("target"))
			DA_Start_TargetNearest_Unit = nil
			DA_pixel_target_frame.texture:SetColorTexture(1, 0, 0)
			--如果玩家目标改变则重置选择目标标识,避免因插件和工具不同步导致重复多次选择目标
			DA_traversedGUIDs = {}
		else
			DA_traversedGUIDs = DA_traversedGUIDs or {}
			local TargetGUID = UnitGUID("target")
			if TargetGUID then
				if DA_traversedGUIDs[TargetGUID] then
					--GUID已经存在,已遍历完一个循环
					--print('已经遍历完一个循环')
					
					DA_pixel_target_frame.texture:SetColorTexture(1, 0, 0)
					DA_traversedGUIDs_Last = DA_traversedGUIDs
					--将当前TAB能选择到的目标加入缓存,3秒后清空
					DA_traversedGUIDs = {}
					
					DA_CanNotTargetNearest = DA_CanNotTargetNearest or {}
					if DA_Start_TargetNearest_Unit and not DA_UnitIsInTable(UnitGUID(DA_Start_TargetNearest_Unit), DA_CanNotTargetNearest) then
						--print(UnitName(DA_Start_TargetNearest_Unit)..' 不可选中')
						DA_TargetVisibleTime = GetTime()
						table.insert(DA_CanNotTargetNearest, {
							Unit = DA_Start_TargetNearest_Unit, 
							UnitGUID = UnitGUID(DA_Start_TargetNearest_Unit), 
						})
					end
					
					DA_Start_TargetNearest_Unit = nil
				else
					DA_traversedGUIDs[TargetGUID] = true
					--print("选到新的目标: " .. UnitName("target"))
					--选到新的目标
				end
			else
				DA_Start_TargetNearest_Unit = nil
				--print('清空DA_Start_TargetNearest_Unit')
			end
		end
	end
	
	if event == "ACTIVE_TALENT_GROUP_CHANGED" then
		C_Timer.After(0.5, function()
			if BalanceCycleStart == 1 and DA_GetSpecialization() ~= 102 then
				BalanceSwitchStatusText:SetTextColor(1, 0, 0)
				BalanceSwitchStatusText:Hide()
				BalanceCycleStart = nil
			end
		end)
	end
	if event == "CURSOR_CHANGED" 
	and ((C_Spell.IsCurrentSpell(Rebirth_SpellID) and not BalanceSaves.BalanceOption_Other_AutoRebirth) 
	--[复生]
	or C_Spell.IsCurrentSpell(50769) 
	--[起死回生]
	or C_Spell.IsCurrentSpell(102793) 
	--[乌索尔旋风]
	or IsCurrentItem(219310) 
	--[爆裂圣光碎片]
	or IsCurrentItem(219303) 
	--[高阶代言人的吸积水晶]
	or IsCurrentItem(219294) 
	--[充能雷鸫飞羽]
	or IsCurrentItem(219301) 
	--[超频回旋齿轮发射器]
	) then
		if C_PvP.IsActiveBattlefield() then
			BalanceManualCursorCastingDelayTime = 1
		else
			BalanceManualCursorCastingDelayTime = 3
		end
		Balance_ManualCursorCasting = 1
		Balance_ManualCursorCastingTime = GetTime()
		--手动技能待选择目标指示
	end
	if (event == "UNIT_SPELLCAST_FAILED" or event == "UNIT_SPELLCAST_SENT" or event == "UNIT_SPELLCAST_SUCCEEDED") and a == "player" then
		if event == "UNIT_SPELLCAST_FAILED" then
			eid = c
		end
		if event == "UNIT_SPELLCAST_SENT" then
			eid = d
		end
		if event == "UNIT_SPELLCAST_SUCCEEDED" then
			eid = c
		end
		local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
		if spellID then
			if C_PvP.IsActiveBattlefield() then
				BalanceManualCastingDelayTime = 0.25
			else
				BalanceManualCastingDelayTime = 1
			end
			BalanceCycle = nil
			--print(name)
			--print(DA_SelfCastSpellName)
			if name == DA_SelfCastSpellName then BalanceCycle = 1 end
			-- if spellID == Moonfire_SpellID then BalanceCycle = 1 end --月火术
			-- if spellID == Sunfire_SpellID then BalanceCycle = 1 end --阳炎术
			-- if spellID == Starfire_SpellID then BalanceCycle = 1 end --星火术
			-- if spellID == Wrath_SpellID or spellID == 190984 then BalanceCycle = 1 end --愤怒
			-- if spellID == Starsurge_SpellID then BalanceCycle = 1 end --星涌术
			-- if spellID == Starfall_SpellID then BalanceCycle = 1 end --星辰坠落
			-- if spellID == 194223 then BalanceCycle = 1 end --超凡之盟
			-- if spellID == Elune_Wrath_SpellID then BalanceCycle = 1 end --艾露恩之怒
			-- if spellID == Innervate_SpellID then BalanceCycle = 1 end --激活
			-- if spellID == Convoke_the_Spirits_SpellID and BalanceSaves.BalanceOption_Attack_AutoCovenant then BalanceCycle = 1 end --万灵之召
			-- if spellID == Warrior_of_Elune_SpellID then BalanceCycle = 1 end --艾露恩的战士
			-- if spellID == New_Moon_SpellID then BalanceCycle = 1 end --新月
			-- if spellID == Force_of_Nature_SpellID then BalanceCycle = 1 end --自然之力
			-- if spellID == Wild_Mushroom_SpellID then BalanceCycle = 1 end --野性蘑菇
			-- if spellID == Stellar_Flare_SpellID then BalanceCycle = 1 end --星辰耀斑
			-- if spellID == Renewal_SpellID then BalanceCycle = 1 end --甘霖
			-- --if spellID == Rejuvenation_SpellID and BalanceSaves.BalanceOption_Attack_AutoIronbark then BalanceCycle = 1 end --回春术
			-- if spellID == Regrowth_SpellID and BalanceSaves.BalanceOption_Attack_AutoIronbark then BalanceCycle = 1 end --愈合
			-- if spellID == Barkskin_SpellID then BalanceCycle = 1 end --树皮术
			-- if spellID == Moonkin_Form_SpellID then BalanceCycle = 1 end --枭兽形态
			-- if spellID == Soothe_SpellID and BalanceSaves.BalanceOption_Auras_ClearEnrage then BalanceCycle = 1 end --安抚
			-- if spellID == 102560 then BalanceCycle = 1 end --化身：艾露恩之眷
			-- if spellID == Berserking_SpellID then BalanceCycle = 1 end --狂暴(种族特长)
			-- if spellID == Solar_Beam_SpellID and BalanceSaves.BalanceOption_Auras_AutoInterrupt then BalanceCycle = 1 end --日光术
			-- if spellID == Mighty_Bash_SpellID and BalanceSaves.BalanceOption_Auras_AutoInterrupt then BalanceCycle = 1 end --蛮力猛击
			-- if spellID == Remove_Corruption_SpellID and BalanceSaves.BalanceOption_Auras_ClearCurse and BalanceSaves.BalanceOption_Auras_ClearPoison then BalanceCycle = 1 end --清除腐蚀
			-- if spellID == Rebirth_SpellID and BalanceSaves.BalanceOption_Other_AutoRebirth then BalanceCycle = 1 end --复生
			if not BalanceCycle then
				local start, duration = DA_GetSpellCooldown(113)
				local start2, duration2 = DA_GetSpellCooldown(spellID)
				if (duration2 == duration or duration2 == 0) and Balance_DA_IsUsableSpell(spellID) and (IsPlayerSpell(spellID) or DA_GetSpellInfo(spellID) == "野性冲锋") then
					Balance_ManualCasting = 1
					if DA_IsCastingSpell('星火术') or DA_IsCastingSpell('愤怒') or DA_IsCastingSpell('新月') or DA_IsCastingSpell('半月') or DA_IsCastingSpell('满月') or ((DA_IsCastingSpell('愈合') or DA_IsCastingSpell('野性成长')) and BalanceSaves.BalanceOption_Attack_AutoIronbark) then
						local CastTime = 0
						local _, _, _, startTime, endTime = UnitCastingInfo('player')
						CastTime = endTime and endTime/1000 - GetTime()
						--剩余施法时间
						if CastTime >= 0.5 then
							--DA_SpellStopCasting()
							--中断施法
						end
					end
					--手动技能指示
				end
				Balance_ManualCastingTime = GetTime()
			end
			if event == "UNIT_SPELLCAST_SUCCEEDED" and (IsPlayerSpell(spellID) or DA_GetSpellInfo(spellID) == "野性冲锋") then
				if spellID == 339 or spellID == 2637 or spellID == 209753 then
					--纠缠根须、休眠、旋风,延迟0.1秒取消手动施法指示
					C_Timer.After(0.1, function()
						Balance_ManualCasting = nil
					end)
				else
					Balance_ManualCasting = nil
				end
			end
		end
	end
	if event == "UNIT_SPELLCAST_SENT" and a == "player" then
		if BalanceSaves.BalanceOption_TargetFilter == 2 then
			--手动目标模式
			local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
			if spellID == Convoke_the_Spirits_SpellID then
				--万灵之召保护,防止发包万灵之召技能之后,后续技能中断万灵之召
				Balance_ChannelSpellIng = 1
				C_Timer.After(1, function()
				--发包1秒后保护结束
					Balance_ChannelSpellIng = nil
				end)
			end
			if spellID == Innervate_SpellID then
				--激活
				BalanceTargetNotVisibleUnit = Balance_InnervateSentTarget
				Balance_InnervateSentTarget = nil
			elseif spellID == Solar_Beam_SpellID then
				--日光术
				BalanceTargetNotVisibleUnit = DamagerEngineInterruptSpellTarget
			elseif spellID == Mighty_Bash_SpellID then
				--蛮力猛击
				BalanceTargetNotVisibleUnit = DamagerEngineControlInterruptSpellTarget
			elseif spellID == Moonfire_SpellID and Balance_SpellCastSentMoonfireTargetS then
				--特殊目标月火术
				BalanceTargetNotVisibleUnit = Balance_AutoDPS_MoonfireTargetS
				Balance_SpellCastSentMoonfireTargetS = nil
			else
				--其他法术
				BalanceTargetNotVisibleUnit = "target"
			end
		else
			--其他目标模式
			local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
			if spellID == Innervate_SpellID then
				--激活
				BalanceTargetNotVisibleUnit = Balance_InnervateSentTarget
				Balance_InnervateSentTarget = nil
			elseif spellID == Solar_Beam_SpellID then
				--日光术
				BalanceTargetNotVisibleUnit = DamagerEngineInterruptSpellTarget
			elseif spellID == Mighty_Bash_SpellID then
				--蛮力猛击
				BalanceTargetNotVisibleUnit = DamagerEngineControlInterruptSpellTarget
			elseif spellID == Moonfire_SpellID and Balance_SpellCastSentMoonfireTargetS then
				--特殊目标月火术
				BalanceTargetNotVisibleUnit = Balance_AutoDPS_MoonfireTargetS
				Balance_SpellCastSentMoonfireTargetS = nil
			elseif spellID == Sunfire_SpellID then
				--阳炎术
				BalanceTargetNotVisibleUnit = Balance_AutoDPS_SunfireTarget
			elseif spellID == Moonfire_SpellID then
				--月火术
				BalanceTargetNotVisibleUnit = Balance_AutoDPS_MoonfireTarget
			else
				--其他法术
				BalanceTargetNotVisibleUnit = Balance_AutoDPS_DPSTarget
			end
		end
	end
	if event == "UNIT_SPELLCAST_SUCCEEDED" and a == "player" then
		if not ClearSelfCastSpell_C_TimerIng then
			ClearSelfCastSpell_C_TimerIng = 1
			C_Timer.After(0.3, function()
				DA_SelfCastSpellName = nil
				--网络延迟,施法成功0.3秒后才清空插件使用技能变量
				ClearSelfCastSpell_C_TimerIng = nil
				--print('清空插件使用技能变量')
			end)
		end
		local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
		if spellID == Convoke_the_Spirits_SpellID then
			C_Timer.After(1, function()
			--万灵之召施法成功,1秒后保护结束
				Balance_ChannelSpellIng = nil
			end)
		end
		if spellID == Wild_Mushroom_SpellID then
			Balance_Casted_WildMushroom = 1
			C_Timer.After(2, function()
			--野性蘑菇施法成功,2秒内不再重复施放
				Balance_Casted_WildMushroom = nil
			end)
		end
		if spellID == Stellar_Flare_SpellID then
			Balance_Casted_StellarFlare = 1
			C_Timer.After(1, function()
			--星辰耀斑施法成功,1秒内不再重复施放
				Balance_Casted_StellarFlare = nil
			end)
		end
		if select(2, DA_GetSpellCooldown(113)) * 1000 > 0 then
			BalanceSpellGCD = select(2, DA_GetSpellCooldown(113)) * 1000
			--获取公共CD时间
		end
	end
	if event == "UI_ERROR_MESSAGE" and (b == "目标不在视野中" or b == "你的视线被遮挡了" or b == "无效的目标" or b == "你必须面对目标。") then
		BalanceTargetNotVisibleUnit = 'target' --像素版只能对当前目标使用技能,因此直接给BalanceTargetNotVisibleUnit赋值
		if BalanceTargetNotVisibleUnit then
			Balance_TargetNotVisible = Balance_TargetNotVisible or {}
			for k, v in ipairs(Balance_TargetNotVisible) do --遍历表格, 看目标是否已存在表格内
				if UnitGUID(BalanceTargetNotVisibleUnit) == UnitGUID(v) then --目标存在表格内
					Balance_TargetNotVisible_UnitIsInTable = 1
					break
				end
			end
			if not Balance_TargetNotVisible_UnitIsInTable then
				table.insert(Balance_TargetNotVisible, UnitGUID(BalanceTargetNotVisibleUnit)) --写入表格内
			end
			Balance_TargetNotVisible_UnitIsInTable = nil
			BalanceTargetNotVisibleUnit = nil
			if not ClearTargetNotVisibleTable_C_TimerIng then
				ClearTargetNotVisibleTable_C_TimerIng = 1
				if IsActiveBattlefieldArena() then
					ClearTargetNotVisibleTableAfterTime = 1
				else
					ClearTargetNotVisibleTableAfterTime = 3
				end
				C_Timer.After(ClearTargetNotVisibleTableAfterTime, function()
					--print('清空TargetNotVisibleTable')
					Balance_TargetNotVisible = {}
					ClearTargetNotVisibleTable_C_TimerIng = nil
				end)
			end
		end
	end

	--if event == "COMBAT_LOG_EVENT_UNFILTERED" or not Balance_Time then
	--COMBAT_LOG_EVENT_UNFILTERED及子事件性能不及UNIT_SPELLCAST_系列事件,事件多时偶尔会产生延迟影响代码执行 2024-8-4
	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED" or not Balance_Time then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("player")
		if name and not TQMark then
		--读条技能
			GCDMarkTime = GCDMarkTime or GetTime()
			--开始施法时间
			CastTime = (endTime - startTime)/1000
			--读条技能时长
		elseif not TQMark then
		--瞬发技能
			GCDMarkTime = GCDMarkTime or GetTime()
			--开始施法时间
			CastTime = CastTime or select(2, DA_GetSpellCooldown(113))
			--瞬发技能公共CD
		end
		if GCDMarkTime and CastTime and GetTime() - GCDMarkTime > CastTime - 0.75 then
		--提前0.75秒结束公共CD状态
			--关闭公共CD状态标识
			Balance_InGCD = nil
			TQMark = 1
			--提前量区间标记
		end
		if event == "UNIT_SPELLCAST_START" and a == 'player' then
			DA_pixel_spell_frame.texture:SetColorTexture(0, 0, 1)
			--重置技能指示像素
			
			if c == Entangling_Roots_SpellID then
			--开始施放[纠缠根须]后,2秒内不再施放
				DA_EntanglingRootsCastStart = 1
				--print('2秒内不再施放')
				if not DA_ClearRootsCastStart_C_TimerIng then
					DA_ClearRootsCastStart_C_TimerIng = 1
					C_Timer.After(2.5, function()
					--开始施放2秒后才可以进行下一次施放
						--print('可以进行下一次施放')
						DA_EntanglingRootsCastStart = nil
						DA_ClearRootsCastStart_C_TimerIng = nil
					end)
				end
			end
		end
		if GetTime() - GCDMarkTime < CastTime - 0.5 then
		--获取即将产生的星界能量
			PlayerPowerNow = UnitPower("player", 8)
			if UnitCastingInfo("player") == DA_GetSpellInfo(Wrath_SpellID) then
			--愤怒
				if IsPlayerSpell(114107) and AuraUtil.FindAuraByName('日蚀', "player", "HELPFUL") then
				--丛林之魂天赋-日蚀
					PlayerPowerNow = PlayerPowerNow + (6 * 1.5)
				else
					PlayerPowerNow = PlayerPowerNow + 6
				end
			elseif UnitCastingInfo("player") == DA_GetSpellInfo(Starfire_SpellID) then
			--星火术
				PlayerPowerNow = PlayerPowerNow + 8
			elseif UnitCastingInfo("player") == DA_GetSpellInfo(New_Moon_SpellID) then
			--新月
				PlayerPowerNow = PlayerPowerNow + 10
			elseif UnitCastingInfo("player") == DA_GetSpellInfo(274282) then
			--半月
				PlayerPowerNow = PlayerPowerNow + 20
			elseif UnitCastingInfo("player") == DA_GetSpellInfo(274283) then
			--满月
				PlayerPowerNow = PlayerPowerNow + 40
			end
			PlayerPowerMaximum = UnitPowerMax("player", 8)
			PlayerPowerScale = PlayerPowerNow / PlayerPowerMaximum
			PlayerPowerVacancy = PlayerPowerMaximum - PlayerPowerNow
		end
		if (not TQMark and select(2, DA_GetSpellCooldown(113)) ~= 0) or UnitChannelInfo("player") then
		--非提前结束公共CD状态且公共CD中、引导法术中
			Balance_InGCD = 1
			--启动公共CD状态标识
		end
		if select(2, DA_GetSpellCooldown(113)) == 0 and not name then
		--非公共CD中且不在读条中(中断施法监测)
			CastTime = nil
			--重新读取公共CD
			GCDMarkTime = nil
			--重新读取开始施法时间
			TQMark = nil
			--终止提前结束公共CD状态
			C_Timer.After(0.25, function()
				PlayerPowerNow = UnitPower("player", 8)
				PlayerPowerMaximum = UnitPowerMax("player", 8)
				PlayerPowerScale = PlayerPowerNow / PlayerPowerMaximum
				PlayerPowerVacancy = PlayerPowerMaximum - PlayerPowerNow
			end)
		end
		--if event == "COMBAT_LOG_EVENT_UNFILTERED" and (b == "SPELL_CAST_START" or b == "SPELL_CAST_SUCCESS") and e == UnitName("player") then
		--COMBAT_LOG_EVENT_UNFILTERED及子事件性能不及UNIT_SPELLCAST_系列事件,事件多时偶尔会产生延迟影响代码执行 2024-8-4
		if (event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED") and a == 'player' then
		--施法事件监测
			CastTime = nil
			--重新读取公共CD
			GCDMarkTime = nil
			--重新读取开始施法时间
			TQMark = nil
			--终止提前结束公共CD状态
		end
		--公共CD指示
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and (b == "SPELL_DAMAGE" or b == "SWING_DAMAGE") and string.sub(d, 1, 6) == "Player" then
		if (Balance_FindEnemyCombatLogIntervalTime and GetTime() - Balance_FindEnemyCombatLogIntervalTime > 1) or not Balance_FindEnemyCombatLogIntervalTime then
			Balance_FindEnemyCombatLogIntervalTime = GetTime()
			local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(d)
			if UnitPlayerOrPetInParty(name) and ((DA_GetNovaDistance("player", name) <= 30 and DA_GetLineOfSight("player", name)) or not WoWAssistantUnlocked) then
			--过滤其他无关玩家
				if Balance_EnemyCache and not DA_UnitIsInTable(h, Balance_EnemyCache) and not UnitIsDeadOrGhost("player") then
					Balance_FindEnemyIntervalTime = nil
					--通过战斗记录监测,如果受到队友伤害的目标没在Balance_EnemyCache内,则无视扫描目标间隔,重新扫描所有目标
				end
				if Balance_EnemyCacheHasThreat and not DA_UnitIsInTable(h, Balance_EnemyCacheHasThreat) and not UnitIsDeadOrGhost("player") then
					Balance_FindEnemyCombatLogUnitGUID = h
					--通过战斗记录监测,将受到队友伤害的目标写入Balance_EnemyCacheHasThreat内
				end
			end
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_CAST_SUCCESS" and l == 320823 then
		C_Timer.After(0.1, function()
			Balance_FindEnemyIntervalTime = nil
		end)
		--通过战斗记录监测,如果召唤了实验型松鼠炸弹,则0.1秒后无视扫描目标间隔,重新扫描所有目标
	end
	
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
		--战斗状态改变时重置攻击我的敌对玩家控制目标表格
		Balance_FindEnemyCombatLogAttackMeUnitCache = {}
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and (b == "SPELL_DAMAGE" or b == "SWING_DAMAGE") and h == UnitGUID("player") and (not IsInInstance() or C_PvP.IsActiveBattlefield()) then
		if WoWAssistantUnlocked then
			local GUID = d
			local thisUnit = GetObjectWithGUID(GUID)
			local UnitInCache = nil
			
			Balance_FindEnemyCombatLogAttackMeUnitCache = Balance_FindEnemyCombatLogAttackMeUnitCache or {}
			
			if UnitPlayerControlled(thisUnit) and not DA_UnitIsInTable(GUID, Balance_FindEnemyCombatLogAttackMeUnitCache) and not DamagerEngineGetIgnoreUnit(thisUnit) and not Balance_GetTargetNotVisible(thisUnit) and DA_GetTargetCanAttack(thisUnit, Moonfire_SpellID) then
				local X1,Y1,Z1 = ObjectPosition(thisUnit)
				table.insert(Balance_FindEnemyCombatLogAttackMeUnitCache, {
					Unit = thisUnit, 
					UnitName = UnitName(thisUnit), 
					UnitGUID = UnitGUID(thisUnit), 
					UnitHealth = UnitHealth(thisUnit),
					UnitHealthMax = UnitHealthMax(thisUnit),
					UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
					UnitPositionX = X1,
					UnitPositionY = Y1,
					UnitPositionZ = Z1,
				}) --攻击我的敌对玩家控制目标写入表格
			end
		end
	end
	
	Balance_Time = Balance_Time or GetTime()
	if GetTime() - Balance_Time > 0.05 then
		DA_Clear_Rooted = 1
		DA_Clear_Deceleration = 1
		Balance_Time = nil
		
		Balance_AutoDPS_MoonfireTargetS = nil
		Balance_AutoDPS_SunfireTarget = nil
		Balance_AutoDPS_WildMushroomTarget = nil
		Balance_AutoDPS_StellarFlareTarget = nil
		Balance_AutoDPS_MoonfireTarget = nil
		Balance_AutoDPS_DPSTarget = nil
		Balance_AutoDPS_DPSTarget2 = nil
		Balance_ClearEnrageTarget = nil
		DamagerEngine_AutoDPS_SinglePriorityTatgetExists = nil
		DamagerEngineInterruptSpell = nil
		DamagerEngineInterruptSpellTarget = nil
		DamagerEngineControlInterruptSpell = nil
		DamagerEngineControlInterruptSpellTarget = nil
		DamagerEngine_IsNotInterruptibleSpell = nil
		Balance_CastSpellIng = nil
		Balance_SelfSaveIng = nil
		Balance_EnemyCount = 0
		
		BalanceSpellGCD = BalanceSpellGCD or 1250
		
		if BalanceSaves.BalanceOption_Other_ShowDebug then
			if not BalanceSwitchStatusText:IsShown() and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:Show()
			end
			if Balance_Enemy_SumHealthScale then
				if Balance_Enemy_SumHealthScale >= 0.7 then
					Balance_DeBugEnemyCount:SetTextColor(1, 1 - Balance_Enemy_SumHealthScale, 0)
				else
					Balance_DeBugEnemyCount:SetTextColor(Balance_Enemy_SumHealthScale * 2, 1 - Balance_Enemy_SumHealthScale, 0)
				end
			end
			
			if Balance_DoNotDPS and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:SetTextColor(1, 0, 0)
			elseif (Balance_ManualCasting or Balance_ManualCursorCasting) and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:SetTextColor(0.5, 0, 0.5)
			elseif Balance_InGCD and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:SetTextColor(1, 1, 0)
			elseif BalanceSaves.BalanceOption_TargetFilter == 2 and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
			elseif BalanceSaves.BalanceOption_TargetFilter == 3 and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
			elseif BalanceSaves.BalanceOption_TargetFilter == 1 and not BalanceCycleStartFlash then
				BalanceSwitchStatusText:SetTextColor(1, 0.55, 0.3)
			end
		elseif BalanceSwitchStatusText then
			BalanceSwitchStatusText:Hide()
			Balance_DeBugEnemyCount:Hide()
			Balance_DeBugSpellIcon:Hide()
		end
		
		if Balance_ManualCasting then
			Balance_ManualCastingTime = Balance_ManualCastingTime or GetTime()
			if GetTime() - Balance_ManualCastingTime < BalanceManualCastingDelayTime or UnitCastingInfo("player") then
				DA_pixel_target_frame.texture:SetColorTexture(1, 0, 0)
				--重置目标指示像素
				DA_pixel_spell_frame.texture:SetColorTexture(0, 0, 1)
				--重置技能指示像素
				if IsInRaid() then
					DA_pixel_frame2.texture:SetColorTexture(0.34, 0.91, 0)
				else
					DA_pixel_frame2.texture:SetColorTexture(0.19, 0.43, 0)
				end
				return
			else
				Balance_ManualCasting = nil
				Balance_ManualCastingTime = nil
			end
		end
		if Balance_ManualCursorCasting then
			Balance_ManualCursorCastingTime = Balance_ManualCursorCastingTime or GetTime()
			if GetTime() - Balance_ManualCursorCastingTime < BalanceManualCursorCastingDelayTime and SpellIsTargeting() then
				DA_pixel_target_frame.texture:SetColorTexture(1, 0, 0)
				--重置目标指示像素
				DA_pixel_spell_frame.texture:SetColorTexture(0, 0, 1)
				--重置技能指示像素
				if IsInRaid() then
					DA_pixel_frame2.texture:SetColorTexture(0.34, 0.91, 0)
				else
					DA_pixel_frame2.texture:SetColorTexture(0.19, 0.43, 0)
				end
				return
			else
				Balance_ManualCursorCasting = nil
				Balance_ManualCursorCastingTime = nil
			end
		end
		DA_TargetVisibleTime = DA_TargetVisibleTime or GetTime()
		if GetTime() - DA_TargetVisibleTime > 1.5 then
			DA_TargetVisibleTime = nil
			DA_CanNotTargetNearest = nil
			DA_Start_TargetNearest_Unit = nil
			DA_traversedGUIDs_Last = nil
		end
		
		if DA_Start_TargetNearest_Unit then return end
		DA_pixel_target_frame.texture:SetColorTexture(1, 0, 0)
		--重置目标指示像素
		DA_pixel_spell_frame.texture:SetColorTexture(0, 0, 1)
		--重置技能指示像素
		if IsInRaid() then
			DA_pixel_frame2.texture:SetColorTexture(0.34, 0.91, 0)
		else
			DA_pixel_frame2.texture:SetColorTexture(0.19, 0.43, 0)
		end
		
		DamagerEngine_GetNoCastingAuras()
		--不要读条Auras监测
		if DamagerEngine_NoCastingAuras then
		--防止因为施法队列导致OnEvent中断一次读条后,继续读条
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				DA_SpellStopCasting()
				--读条时遇到不要读条施法则中断施法
			end
		end
		
		if C_Item.IsEquippedItem(215174) and AuraUtil.FindAuraByName(DA_GetSpellInfo(435493), "player", "HELPFUL") then
		--装备了[制剂：死亡之吻],且存在[制剂：死亡之吻]BUFF
			Balance_UseConcoctionKissOfDeath()
			--[制剂：死亡之吻]
		end
		
		if Balance_InGCD then return end
		
		Balance_DoNotDPSAura = nil
		local DoNotDPSAuraCache = {
			--{Name = "熊形态", ID = 5487, Instance = "德鲁伊-测试"}, 
			{Name = "进食饮水", ID = 167152, Instance = "进食"}, 
			{Name = "饮水", ID = 175787, Instance = "进食"}, 
			{Name = "喝水", ID = 192001, Instance = "进食"}, 
			{Name = "食物和饮水", ID = 192002, Instance = "进食"}, 
			{Name = "食物和饮料", ID = 327786, Instance = "进食"}, 
			{Name = "影遁", ID = 58984, Instance = "种族天赋"}, 
			{Name = "鲜血与荣耀", ID = 320102, Instance = "伤逝剧场-无堕者哈夫"}, 
		}
		for i=1, #DoNotDPSAuraCache do
			local name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID = AuraUtil.FindAuraByName(DoNotDPSAuraCache[i].Name, "player", "HELPFUL")
			if name then
				Balance_DoNotDPSAura = 1
				break
			end
		end
		if (GetShapeshiftFormID() and GetShapeshiftFormID() ~= 31 and GetShapeshiftFormID() ~= 5) or IsStealthed() or IsMounted() or UnitIsDeadOrGhost("player") or Balance_DoNotDPSAura or not HasFullControl() or (C_Spell.GetSpellLossOfControlCooldown(Moonfire_SpellID) > 0 and C_Spell.GetSpellLossOfControlCooldown(Regrowth_SpellID) > 0) or GetCurrentKeyBoardFocus() then
			Balance_DoNotDPS = 1
			Balance_DeBugEnemyCount:Hide()
			Balance_DeBugSpellIcon:Hide()
			return
		else
			Balance_DoNotDPS = nil
		end
		--非DPS状态指示
		
		Balance_FindEnemy()
		--遍历附近敌对目标
		
		Balance_FindEnemyInEnemyCache()
		--从Balance_EnemyCache遍历附近可攻击的敌对目标
		
		if WoWAssistantUnlocked then
			if (Balance_ObjectIsInTableTime and GetTime() - Balance_ObjectIsInTableTime > 1) or not Balance_ObjectIsInTableTime then
				if DA_ObjectIsInTable(173729, Balance_EnemyCache) then
				--存在傲慢具象
					Balance_ManifestationOfPrideExists = 1
				else
					Balance_ManifestationOfPrideExists = nil
				end
				Balance_ObjectIsInTableTime = GetTime()
			end
		else
			if DA_ObjectIsInTable(173729, Balance_EnemyCache) then
			--存在傲慢具象
				Balance_ManifestationOfPrideExists = 1
			else
				Balance_ManifestationOfPrideExists = nil
			end
		end
		
		if (Balance_GetNoUsePowerfulSpell and GetTime() - Balance_GetNoUsePowerfulSpell > 0.5) or not Balance_GetNoUsePowerfulSpell then
			if DamagerEngineGetNoUsePowerfulSpell(Balance_EnemyCacheHasThreat) then
			--不用爆发技能
				Balance_NoUsePowerfulSpell = 1
			else
				Balance_NoUsePowerfulSpell = nil
			end
			Balance_GetNoUsePowerfulSpell = GetTime()
		end
	
		local name1, icon1, count1, _, duration1, expires1, caster1, _, _, spellID1 = AuraUtil.FindAuraByName('月火术', "target", "HARMFUL")
		--月火术
		if select(7, AuraUtil.FindAuraByName('月火术', "target", "HARMFUL")) ~= "player" then
			name1, icon1, count1, _, duration1, expires1, caster1, _, _, spellID1 = nil
		end
		
		local name2, icon2, count2, _, duration2, expires2, caster2, _, _, spellID2 = AuraUtil.FindAuraByName('阳炎术', "target", "HARMFUL")
		--阳炎术
		if select(7, AuraUtil.FindAuraByName('阳炎术', "target", "HARMFUL")) ~= "player" then
			name2, icon2, count2, _, duration2, expires2, caster2, _, _, spellID2 = nil
		end
		
		local name3, icon3, count3, _, duration3, expires3, caster3, _, _, spellID3 = AuraUtil.FindAuraByName('枭兽狂怒', "player", "HELPFUL")
		--枭兽狂怒
		
		local name4, icon4, count4, _, duration4, expires4, caster4, _, _, spellID4 = AuraUtil.FindAuraByName('超凡之盟', "player", "HELPFUL")
		--超凡之盟
		
		local name5, icon5, count5, _, duration5, expires5, caster5, _, _, spellID5 = AuraUtil.FindAuraByName('化身：艾露恩之眷', "player", "HELPFUL")
		--化身：艾露恩之眷
		
		local name8, icon8, count8, _, duration8, expires8, caster8, _, _, spellID8 = AuraUtil.FindAuraByName('日蚀', "player", "HELPFUL")
		--日蚀
		local timeLeft8 = expires8 and expires8 > GetTime() and (expires8 - GetTime()) or 0
		--日蚀剩余时间
		
		local name9, icon9, count9, _, duration9, expires9, caster9, _, _, spellID9 = AuraUtil.FindAuraByName('月蚀', "player", "HELPFUL")
		--月蚀
		local timeLeft9 = expires9 and expires9 > GetTime() and (expires9 - GetTime()) or 0
		--月蚀剩余时间
		
		local name10, icon10, count10, _, duration10, expires10, caster10, _, _, spellID10 = AuraUtil.FindAuraByName('星辰坠落', "player", "HELPFUL")
		--星辰坠落
		local timeLeft10 = expires10 and expires10 > GetTime() and (expires10 - GetTime()) or 0
		--星辰坠落剩余时间
		
		local name11, icon11, count11, _, duration11, expires11, caster11, _, _, spellID11 = AuraUtil.FindAuraByName('织星者的纬纱', "player", "HELPFUL")
		--织星者的纬纱(下一个星涌术不消耗星界能量)
		
		local name12, icon12, count12, _, duration12, expires12, caster12, _, _, spellID12 = AuraUtil.FindAuraByName('织星者的经纱', "player", "HELPFUL")
		--织星者的经纱(下一个星辰坠落不消耗星界能量)
		
		local name13, icon13, count13, _, duration13, expires13, caster13, _, _, spellID13 = AuraUtil.FindAuraByName('艾露恩的战士', "player", "HELPFUL")
		--艾露恩的战士
		
		local name14, icon14, count14, _, duration14, expires14, caster14, _, _, spellID14 = AuraUtil.FindAuraByName('万物平衡', "player", "HELPFUL")
		--万物平衡(提升自然法术暴击)
		local timeLeft14 = expires14 and expires14 > GetTime() and (expires14 - GetTime()) or 0
		--万物平衡剩余时间
	
		local name15, icon15, count15, _, duration15, expires15, caster15, _, _, spellID15 = AuraUtil.FindAuraByName('野性蘑菇', "target", "HARMFUL")
		--野性蘑菇
		local timeLeft15 = expires15 and expires15 > GetTime() and (expires15 - GetTime()) or 0
		--野性蘑菇剩余时间
		if select(7, AuraUtil.FindAuraByName('野性蘑菇', "target", "HARMFUL")) ~= "player" then
			name15, icon15, count15, _, duration15, expires15, caster15, _, _, spellID15 = nil
		end
	
		local name16, icon16, count16, _, duration16, expires16, caster16, _, _, spellID16 = AuraUtil.FindAuraByName('星辰耀斑', "target", "HARMFUL")
		--星辰耀斑
		local timeLeft16 = expires16 and expires16 > GetTime() and (expires16 - GetTime()) or 0
		--星辰耀斑剩余时间
		if select(7, AuraUtil.FindAuraByName('星辰耀斑', "target", "HARMFUL")) ~= "player" then
			name16, icon16, count16, _, duration16, expires16, caster16, _, _, spellID16 = nil
		end
		
		name_TouchTheCosmos_Starsurge, icon_TouchTheCosmos_Starsurge, count_TouchTheCosmos_Starsurge, _, duration_TouchTheCosmos_Starsurge, expires_TouchTheCosmos_Starsurge, caster_TouchTheCosmos_Starsurge, _, _, spellID_TouchTheCosmos_Starsurge = AuraUtil.FindAuraByName('浩瀚之触', "player", "HELPFUL")
		--浩瀚之触(下一个星涌术不消耗星界能量)
		if spellID_TouchTheCosmos_Starsurge ~= 450360 then
			name_TouchTheCosmos_Starsurge, icon_TouchTheCosmos_Starsurge, count_TouchTheCosmos_Starsurge, _, duration_TouchTheCosmos_Starsurge, expires_TouchTheCosmos_Starsurge, caster_TouchTheCosmos_Starsurge, _, _, spellID_TouchTheCosmos_Starsurge = nil
		end
		
		name_TouchTheCosmos_Starfall, icon_TouchTheCosmos_Starfall, count_TouchTheCosmos_Starfall, _, duration_TouchTheCosmos_Starfall, expires_TouchTheCosmos_Starfall, caster_TouchTheCosmos_Starfall, _, _, spellID_TouchTheCosmos_Starfall = AuraUtil.FindAuraByName('浩瀚之触', "player", "HELPFUL")
		--浩瀚之触(下一个星辰坠落不消耗星界能量)
		if spellID_TouchTheCosmos_Starfall ~= 450361 then
			name_TouchTheCosmos_Starfall, icon_TouchTheCosmos_Starfall, count_TouchTheCosmos_Starfall, _, duration_TouchTheCosmos_Starfall, expires_TouchTheCosmos_Starfall, caster_TouchTheCosmos_Starfall, _, _, spellID_TouchTheCosmos_Starfall = nil
		end

		SolarEmpowerment = nil
		LunarEmpowerment = nil
		ComeEclipse = nil
		ComeEclipse_EquippedBalanceOfAllThings = nil
		SolarEmpowermentCount = DA_GetSpellCount(Wrath_SpellID) or 0
		--愤怒剩余使用次数
		LunarEmpowermentCount = DA_GetSpellCount(Starfire_SpellID) or 0
		--星火术剩余使用次数
		SolarCastingTime = select(4, DA_GetSpellInfo(Wrath_SpellID)) / 1000
		--愤怒施法时间
		LunarCastingTime = select(4, DA_GetSpellInfo(Starfire_SpellID)) / 1000
		--星火术施法时间
		if SolarEmpowermentCount > 0 or LunarEmpowermentCount > 0 or name8 or name9 then
		
			local Unit = select(2, Balance_GetStarfireUnit(7.5)) or 0
			--获取星火术最多能攻击到的目标数量
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 8.5 * SDPHR) then
				Balance_SumHealthControl = nil
			else
				Balance_SumHealthControl = 1
			end
			
			if IsPlayerSpell(429523) then
			--[皎月呼唤]英雄天赋,不会进入日蚀
				if SolarEmpowermentCount == 1 and DA_IsCastingSpell(Wrath_SpellID) then
				--愤怒剩余使用次数等于1,且正在施放愤怒(即将进入月蚀)
					LunarEmpowerment = 1
					--使用星火术
				elseif SolarEmpowermentCount >= 1 then
				--愤怒剩余使用次数大于1
					SolarEmpowerment = 1
					--使用愤怒进月蚀
				elseif name9 then
				--月蚀状态
					if timeLeft9 >= LunarCastingTime + 0.1 then
						LunarEmpowerment = 1
						--使用星火术
					else
						SolarEmpowerment = 1
						--使用愤怒进月蚀
					end
				end
			else
				if Unit >= 4 and SolarEmpowermentCount == 0 then
				--星火术能攻击到的目标大于等于4,且愤怒剩余使用次数等于0(相当于忽略日月蚀)
					if timeLeft9 >= LunarCastingTime + 0.1 then
						LunarEmpowerment = 1
						--使用星火术
					else
						SolarEmpowerment = 1
						--使用愤怒
					end
				elseif #Balance_EnemyCacheHasThreat > 2 and (name4 or name5) then
				--有仇恨的敌对目标大于2,且在超凡/化身状态(同时有日月蚀)
					LunarEmpowerment = 1
					--使用星火术
				else
					if LunarEmpowermentCount == 1 and DA_IsCastingSpell(Starfire_SpellID) then
					--星火术剩余使用次数等于1,且正在施放星火术(即将进入日蚀)
						SolarEmpowerment = 1
						--使用愤怒
					elseif SolarEmpowermentCount > 1 then
					--愤怒剩余使用次数大于1
						if Unit >= 2 then
						--星火术能攻击到2个及以上目标
							SolarEmpowerment = 1
							--使用愤怒进月蚀
						else
							LunarEmpowerment = 1
							--使用星火术进日蚀
						end
					elseif name8 then
					--日蚀状态
						if timeLeft8 >= SolarCastingTime + 0.1 then
							SolarEmpowerment = 1
							--使用愤怒
						else
							LunarEmpowerment = 1
							--使用星火术
						end
					elseif SolarEmpowermentCount == 1 and not DA_IsCastingSpell(Wrath_SpellID) then
					--愤怒剩余使用次数等于1,且没有施放愤怒
						if Unit >= 2 then
						--星火术能攻击到2个及以上目标
							SolarEmpowerment = 1
							--使用愤怒进月蚀
						else
							LunarEmpowerment = 1
							--使用星火术进日蚀
						end
					elseif SolarEmpowermentCount == 1 and DA_IsCastingSpell(Wrath_SpellID) then
					--愤怒剩余使用次数等于1,且正在施放愤怒(即将进入月蚀)
						LunarEmpowerment = 1
						--使用星火术
					elseif LunarEmpowermentCount > 1 then
					--星火术剩余使用次数大于1
						LunarEmpowerment = 1
						--使用星火术进日蚀
					elseif LunarEmpowermentCount == 1 and not DA_IsCastingSpell(Starfire_SpellID) then
					--星火术剩余使用次数等于1,且没有施放星火术
						LunarEmpowerment = 1
						--使用星火术进日蚀
					elseif name9 then
					--月蚀状态
						if timeLeft9 >= LunarCastingTime + 0.1 then
							LunarEmpowerment = 1
							--使用星火术
						else
							SolarEmpowerment = 1
							--使用愤怒
						end
					end
				end
			end
			if LunarEmpowerment then
				--print('使用星火术')
			elseif SolarEmpowerment then
				--print('使用愤怒')
			else
				--print('都不使用')
			end
			
			if LunarEmpowermentCount == 1 and DA_IsCastingSpell(Starfire_SpellID) then
			--星火术剩余使用次数等于1,且正在施放星火术
				ComeEclipse = 1
				if IsPlayerSpell(394048) then
					ComeEclipse_EquippedBalanceOfAllThings = 1
				end
			end
			if SolarEmpowermentCount == 1 and DA_IsCastingSpell(Wrath_SpellID) then
			--愤怒剩余使用次数等于1,且正在施放愤怒
				ComeEclipse = 1
				if IsPlayerSpell(394048) then
					ComeEclipse_EquippedBalanceOfAllThings = 1
				end
			end
		end
		
		DamagerEngine_PlayerInEnemyCache = nil
		if Balance_FindEnemyCombatLogAttackMeUnitCache and #Balance_FindEnemyCombatLogAttackMeUnitCache > 0 and (not IsInInstance() or C_PvP.IsActiveBattlefield()) then
			--Balance_FindEnemyCombatLogAttackMeUnitCache表中的目标大于0个且(不在副本或在战场)时
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if UnitIsPlayer(v.Unit) then
					DamagerEngine_PlayerInEnemyCache = 1
					break
					--Balance_EnemyCacheHasThreat表中有玩家存在
				end
			end
		end
		
		for i = #Balance_EnemyCacheHasThreat, 1, -1 do
			DamagerEngineRemoveNoAttackAurasUnit(Balance_EnemyCacheHasThreat, Balance_EnemyCacheHasThreat[i].Unit, i)
			--从Balance_EnemyCacheHasThreat表中移除某些的目标
		end
		
		Balance_FindEnemyCacheNoThreat()
		--查找无辜目标

		for k, v in ipairs(Balance_EnemyCacheHasThreat) do
			DamagerEngineGetInterruptSpell(v.Unit)
			--获取常规技能打断
		end
		for k, v in ipairs(Balance_EnemyCacheHasThreatInMelee) do
			DamagerEngineGetControlInterruptSpell(v.Unit)
			--获取控制技能打断
		end
		
		for k, v in ipairs(Balance_EnemyCacheS) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) then
			--获取不攻击BUFF、判断目标是否可以攻击
				local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(v.Unit)
				local timeLeft = endTime and endTime - GetTime() * 1000
				--剩余施法时间(单位:毫秒)
				local castTime = endTime and endTime - startTime
				--施法总时间(单位:毫秒)
				local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('月火术', v.Unit, "HARMFUL")
				--月火术
				if select(7, AuraUtil.FindAuraByName('月火术', v.Unit, "HARMFUL")) ~= "player" then
					name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
				end
				Balance_AutoDPS_ShredTargetS_Switch = 1
				--if v.UnitName == "爆炸物" and timeLeft and timeLeft > BalanceSpellGCD + 1000 and name1 and #Balance_EnemyCacheS < 3 then
					--爆炸剩余施法时间大于公共CD+1秒且已上月火且特殊目标小于3则不攻击
				if v.UnitName == "爆炸物" and timeLeft and timeLeft > 3000 and #Balance_EnemyCacheS < 3 then
					--爆炸剩余施法时间大于3秒且特殊目标小于3则不攻击
					Balance_AutoDPS_ShredTargetS_Switch = nil
				end
				if Balance_AutoDPS_ShredTargetS_Switch then
					Balance_AutoDPS_MoonfireTargetS = v.Unit
					--特殊目标月火术
					break
				end
			end
		end
		
		Balance_EnemyCacheHasThreat_PrioritySingle = CloneTable(Balance_EnemyCacheHasThreat)
		table.sort(Balance_EnemyCacheHasThreat_PrioritySingle, function(a, b) return a.UnitHealth < b.UnitHealth end)
		--血量从低到高排序(优先打血低的)
		for k, v in ipairs(Balance_EnemyCacheHasThreat_PrioritySingle) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) and not Balance_AutoDPS_MoonfireTargetS then
			--获取不攻击BUFF、判断目标是否可以攻击
				if DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked then
					DamagerEngineGetSinglePriorityUnit(v.Unit)
					if DamagerEngine_AutoDPS_SinglePriorityTatgetExists then break end
					--获取优先击杀目标
				end
			end
		end
		
		Balance_EnemyCount = #Balance_EnemyCacheHasThreat
		if DamagerEngine_AutoDPS_SinglePriorityTatgetExists then
		--优先击杀目标
			local Unit = DamagerEngine_AutoDPS_DPSTarget
			
			local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('月火术', Unit, "HARMFUL")
			--月火术
			if select(7, AuraUtil.FindAuraByName('月火术', Unit, "HARMFUL")) ~= "player" then
				name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
			end
			if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and (not name1 or (expires1 and expires1 - GetTime() < 3)) and ((UnitHealthMax(Unit) - UnitHealth(Unit) > UnitHealthMax("player") * 0.01) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth(Unit) > UnitHealthMax("player") * 0.1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
				--print("月火术 - "..v.UnitName)
				Balance_AutoDPS_MoonfireTarget = Unit
				--月火术目标
			end
			
			local name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = AuraUtil.FindAuraByName('阳炎术', Unit, "HARMFUL")
			--阳炎术
			if select(7, AuraUtil.FindAuraByName('阳炎术', Unit, "HARMFUL")) ~= "player" then
				name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = nil
			end
			if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and (not name2 or (expires2 and expires2 - GetTime() < 3)) and ((UnitHealthMax(Unit) - UnitHealth(Unit) > UnitHealthMax("player") * 0.01) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth(Unit) > UnitHealthMax("player") * 0.1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
				--print("阳炎术 - "..v.UnitName)
				Balance_AutoDPS_SunfireTarget = Unit
				--阳炎术目标
			end
			
			Balance_AutoDPS_DPSTarget = Unit
			
			Balance_EnemyCount = 1
			--单体输出,不AOE
		end
		
		if not DamagerEngine_AutoDPS_SinglePriorityTatgetExists then
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not DamagerEngineGetNoAttackAuras(v.Unit) and not Balance_AutoDPS_MoonfireTarget then
				--获取不攻击BUFF、判断目标是否可以攻击
					if string.match(UnitName(v.Unit), "训练假人") then
						v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
						v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						TargetHealthScale = v.UnitHealth / v.UnitHealthMax
					end
					if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
					--[矶石宝库]部分小怪初始血量为80%,70%,60%
						if (IsPlayerSpell(279620) and Balance_EnemyCount <= 4) or Balance_EnemyCount <= 2 then
							local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('月火术', v.Unit, "HARMFUL")
							--月火术
							if select(7, AuraUtil.FindAuraByName('月火术', v.Unit, "HARMFUL")) ~= "player" then
								name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
							end
							
							if (not name1 or (expires1 and expires1 - GetTime() < 3)) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								--print("月火术 - "..v.UnitName)
								Balance_AutoDPS_MoonfireTarget = v.Unit
								--月火术目标
								break
							end
						end
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_UnitWithNoAttackAurasUnitDecide(v.Unit, 8.5) and not DamagerEngineGetNoAttackAuras(v.Unit) and not Balance_AutoDPS_SunfireTarget then
				--获取不攻击BUFF、判断目标是否可以攻击
					if string.match(UnitName(v.Unit), "训练假人") then
						v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
						v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						TargetHealthScale = v.UnitHealth / v.UnitHealthMax
					end
					if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
					--[矶石宝库]部分小怪初始血量为80%,70%,60%
						if (IsPlayerSpell(231050) and Balance_EnemyCount <= 4) or Balance_EnemyCount <= 2 then
							local name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = AuraUtil.FindAuraByName('阳炎术', v.Unit, "HARMFUL")
							--阳炎术
							if select(7, AuraUtil.FindAuraByName('阳炎术', v.Unit, "HARMFUL")) ~= "player" then
								name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = nil
							end
							if Balance_EnemyCount <= 2 then
								SunfireTarget_HealthControl = 0.05
							else
								SunfireTarget_HealthControl = 0.75
							end
							if (not name2 or (expires2 and expires2 - GetTime() < 3)) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * SunfireTarget_HealthControl) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								--print("阳炎术 - "..v.UnitName)
								Balance_AutoDPS_SunfireTarget = v.Unit
								--阳炎术目标
								break
							end
						end
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not DamagerEngineGetNoAttackAuras(v.Unit) and not Balance_AutoDPS_WildMushroomTarget then
				--获取不攻击BUFF、判断目标是否可以攻击
					if string.match(UnitName(v.Unit), "训练假人") then
						v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
						v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						TargetHealthScale = v.UnitHealth / v.UnitHealthMax
					end
					if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
					--[矶石宝库]部分小怪初始血量为80%,70%,60%
						local name15, icon15, count15, dispelType15, duration15, expires15, caster15, isStealable15, nameplateShowPersonal15, spellID15 = AuraUtil.FindAuraByName('野性蘑菇', v.Unit, "HARMFUL")
						--野性蘑菇
						if select(7, AuraUtil.FindAuraByName('野性蘑菇', v.Unit, "HARMFUL")) ~= "player" then
							name15, icon15, count15, dispelType15, duration15, expires15, caster15, isStealable15, nameplateShowPersonal15, spellID15 = nil
						end
						
						if (not name15 or (expires15 and expires15 - GetTime() < 3)) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
							--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
							--print("野性蘑菇 - "..v.UnitName)
							Balance_AutoDPS_WildMushroomTarget = v.Unit
							--野性蘑菇目标
							break
						end
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not DamagerEngineGetNoAttackAuras(v.Unit) and not Balance_AutoDPS_StellarFlareTarget then
				--获取不攻击BUFF、判断目标是否可以攻击
					if string.match(UnitName(v.Unit), "训练假人") then
						v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
						v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						TargetHealthScale = v.UnitHealth / v.UnitHealthMax
					end
					if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
					--[矶石宝库]部分小怪初始血量为80%,70%,60%
						local name16, icon16, count16, dispelType16, duration16, expires16, caster16, isStealable16, nameplateShowPersonal16, spellID16 = AuraUtil.FindAuraByName('星辰耀斑', v.Unit, "HARMFUL")
						--星辰耀斑
						if select(7, AuraUtil.FindAuraByName('星辰耀斑', v.Unit, "HARMFUL")) ~= "player" then
							name16, icon16, count16, dispelType16, duration16, expires16, caster16, isStealable16, nameplateShowPersonal16, spellID16 = nil
						end
						
						if (not name16 or (expires16 and expires16 - GetTime() < 5)) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
							--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
							--print("星辰耀斑 - "..v.UnitName)
							Balance_AutoDPS_StellarFlareTarget = v.Unit
							--星辰耀斑目标
							break
						end
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if not DamagerEngineGetNoAttackAuras(v.Unit) and not Balance_AutoDPS_DPSTarget then
				--获取不攻击BUFF、判断目标是否可以攻击
					if string.match(UnitName(v.Unit), "训练假人") then
						v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
						v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
						TargetHealthScale = v.UnitHealth / v.UnitHealthMax
					end
					if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
					--[矶石宝库]部分小怪初始血量为80%,70%,60%
						if WoWAssistantUnlocked then
							if DA_GetFacing("player", v.Unit) then
								if ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * 0.2 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
									--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
									--print("循环输出目标 - "..v.UnitName)
									Balance_AutoDPS_DPSTarget = v.Unit
									Balance_AutoDPS_DPSTarget2 = v.Unit
									--循环输出目标
									break
								end
							else
								if ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * 0.2 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
									--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
									--print("循环输出目标 - "..v.UnitName)
									Balance_AutoDPS_DPSTarget2 = v.Unit
									--循环输出目标(不需要面对目标)
								end
							end
						else
							if ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * 0.2 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								--print("循环输出目标 - "..v.UnitName)
								Balance_AutoDPS_DPSTarget = v.Unit
								Balance_AutoDPS_DPSTarget2 = v.Unit
								--循环输出目标
								break
							end
						end
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if not DamagerEngineGetNoAttackAuras(v.Unit) then
				--获取不攻击BUFF
					if DA_UnitHasEnrage(v.Unit) and (v.UnitHealth > UnitHealthMax("player") * 1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						--print("驱散激怒效果 - "..v.UnitName)
						Balance_ClearEnrageTarget = v.Unit
						--驱散激怒效果目标
						break
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheS2) do
				if not DamagerEngineGetNoAttackAuras(v.Unit) then
				--获取不攻击BUFF、判断目标是否可以攻击
					if WoWAssistantUnlocked then
						if DA_GetFacing("player", v.Unit) then
							--print("循环输出目标 - "..v.UnitName)
							Balance_AutoDPS_DPSTarget = v.Unit
							Balance_AutoDPS_DPSTarget2 = v.Unit
							--部分特殊目标先打血高的
							break
						else
							--print("循环输出目标 - "..v.UnitName)
							Balance_AutoDPS_DPSTarget2 = v.Unit
							--部分特殊目标先打血高的(不需要面对目标)
						end
					else
						--print("循环输出目标 - "..v.UnitName)
						Balance_AutoDPS_DPSTarget = v.Unit
						Balance_AutoDPS_DPSTarget2 = v.Unit
						--部分特殊目标先打血高的
						break
					end
				end
			end
			
			for k, v in ipairs(Balance_EnemyCacheS3) do
				if not DamagerEngineGetNoAttackAuras(v.Unit) then
				--获取不攻击BUFF、判断目标是否可以攻击
					if WoWAssistantUnlocked then
						if DA_GetFacing("player", v.Unit) then
							--print("循环输出目标 - "..v.UnitName)
							Balance_AutoDPS_DPSTarget = v.Unit
							Balance_AutoDPS_DPSTarget2 = v.Unit
							--部分特殊目标先打血低的
							break
						else
							--print("循环输出目标 - "..v.UnitName)
							Balance_AutoDPS_DPSTarget2 = v.Unit
							--部分特殊目标先打血低的(不需要面对目标)
						end
					else
						--print("循环输出目标 - "..v.UnitName)
						Balance_AutoDPS_DPSTarget = v.Unit
						Balance_AutoDPS_DPSTarget2 = v.Unit
						--部分特殊目标先打血低的
						break
					end
				end
			end
			
		end
			
		local Balance_StarfireUnit, Balance_StarfireUnitCount = Balance_GetStarfireUnit(7.5)
		--7.5码溅射AOE目标
		if DamagerEngine_AutoDPS_SinglePriorityTatgetExists or #Balance_EnemyCacheS2 > 0 or #Balance_EnemyCacheS3 > 0 then
			Balance_StarfireUnit = Balance_AutoDPS_DPSTarget
		end
		
		TargetHealth, TargetHealthScale = nil
		if Balance_AutoDPS_DPSTarget then
			TargetHealth = UnitHealth(Balance_AutoDPS_DPSTarget)
			TargetHealthScale = UnitHealth(Balance_AutoDPS_DPSTarget) / UnitHealthMax(Balance_AutoDPS_DPSTarget)
		end
		PlayerHealthScale = UnitHealth("player") / UnitHealthMax("player")
		--print(PlayerPowerNow)
		
		if Balance_AutoDPS_DPSTarget and string.match(UnitName(Balance_AutoDPS_DPSTarget), "训练假人") then
			TargetHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
			TargetHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
			Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
			TargetHealthScale = TargetHealth / TargetHealthMax
		end
		
		local start, duration = DA_GetSpellCooldown(113)
		local start2, duration2 = DA_GetSpellCooldown(Barkskin_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Barkskin_SpellID)) > 3 or not IsPlayerSpell(Barkskin_SpellID) then
			BarkskinCD = 1
		elseif duration2 == 0 then
			BarkskinCD = nil
		end
		--树皮术CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Berserking_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Berserking_SpellID)) > 3 or not IsPlayerSpell(Berserking_SpellID) then
			BerserkingCD = 1
		elseif duration2 == 0 then
			BerserkingCD = nil
		end
		--狂暴(种族特长)CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Rebirth_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Soothe_SpellID)) > 3 or not IsPlayerSpell(Rebirth_SpellID) then
			RebirthCD = 1
		elseif duration2 == duration then
			RebirthCD = nil
		end
		--复生CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Solar_Beam_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Solar_Beam_SpellID)) > 3 or not IsPlayerSpell(Solar_Beam_SpellID) then
			SolarBeamCD = 1
		elseif duration2 == 0 then
			SolarBeamCD = nil
		end
		--日光术CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Mighty_Bash_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Mighty_Bash_SpellID) or not IsPlayerSpell(Mighty_Bash_SpellID) then
			MightyBashCD = 1
		elseif duration2 == duration then
			MightyBashCD = nil
		end
		--蛮力猛击CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Remove_Corruption_SpellID)
		if duration2 ~= duration or not Balance_DA_IsUsableSpell(Remove_Corruption_SpellID) or not IsPlayerSpell(Remove_Corruption_SpellID) then
			RemoveCorruptionCD = 1
		elseif duration2 == duration then
			RemoveCorruptionCD = nil
		end
		--清除腐蚀CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Renewal_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Renewal_SpellID)) > 3 or not IsPlayerSpell(Renewal_SpellID) then
			RenewalCD = 1
		elseif duration2 == 0 then
			RenewalCD = nil
		end
		--甘霖CD判断
		
		start2, duration2 = DA_GetSpellCooldown(22842)
		if duration2 ~= duration or not DA_IsUsableSpell(22842) or not IsPlayerSpell(22842) then
			FrenziedRegenerationCD = 1
		elseif duration2 == duration then
			FrenziedRegenerationCD = nil
		end
		--狂暴回复CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Innervate_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Innervate_SpellID)) > 3 or AuraUtil.FindAuraByName(DA_GetSpellInfo(340880), "player", "HARMFUL") or not IsPlayerSpell(Innervate_SpellID) then
			InnervateCD = 1
		elseif duration2 == duration then
			InnervateCD = nil
		end
		--激活CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Warrior_of_Elune_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Warrior_of_Elune_SpellID)) > 3 or not IsPlayerSpell(Warrior_of_Elune_SpellID) or name13 then
			WarriorOfEluneCD = 1
		elseif duration2 == 0 then
			WarriorOfEluneCD = nil
		end
		--艾露恩的战士CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Elune_Wrath_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Elune_Wrath_SpellID)) > 3 or not IsPlayerSpell(Elune_Wrath_SpellID) then
			FuryOfEluneCD = 1
		elseif duration2 == duration then
			FuryOfEluneCD = nil
		end
		--艾露恩之怒CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Soothe_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Soothe_SpellID)) > 3 or not IsPlayerSpell(Soothe_SpellID) then
			SootheCD = 1
		elseif duration2 == duration then
			SootheCD = nil
		end
		--安抚CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Force_of_Nature_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Force_of_Nature_SpellID) or not IsPlayerSpell(Force_of_Nature_SpellID) then
			ForceOfNatureCD = 1
		elseif duration2 == duration then
			ForceOfNatureCD = nil
		end
		--自然之力CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Convoke_the_Spirits_SpellID)
		if (duration2 ~= duration and GetTime() - start2 > 0.5) or not DA_IsUsableSpell(DA_GetSpellInfo(Convoke_the_Spirits_SpellID)) or not BalanceSaves.BalanceOption_Attack_AutoCovenant or DamagerEngine_NoCastingAuras or DamagerEngine_NoChannelAuras then
			--延迟0.5秒进CD
			ConvokeTheSpiritsCD = 1
		elseif duration2 == duration then
			ConvokeTheSpiritsCD = nil
		end
		--万灵之召CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Wild_Mushroom_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Wild_Mushroom_SpellID) or not IsPlayerSpell(Wild_Mushroom_SpellID) then
			WildMushroomCD = 1
		elseif duration2 == duration then
			WildMushroomCD = nil
		end
		--野性蘑菇CD指示
		
		start2, duration2 = DA_GetSpellCooldown(5176)
		if duration2 ~= duration or not DA_IsUsableSpell(5176) or not IsPlayerSpell(5176) then
			WrathCD = 1
		elseif duration2 == duration then
			WrathCD = nil
		end
		--愤怒CD指示(自然系法术被打断)
		
		start2, duration2 = DA_GetSpellCooldown(102359)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(102359)) > 3 or not DA_IsUsableSpell('群体缠绕') or not IsPlayerSpell(102359) then
			Mass_EntanglementCD = 1
		elseif duration2 == duration then
			Mass_EntanglementCD = nil
		end
		--群体缠绕CD判断
		
		if DA_GetSpellCharges("满月") then
			Spell_NewMoon = "FullMoon"
		elseif DA_GetSpellCharges("半月") then
			Spell_NewMoon = "HalfMoon"
		else
			Spell_NewMoon = "NewMoon"
		end
		
		Balance_StarsurgePower = C_Spell.GetSpellPowerCost(Starsurge_SpellID)[1].cost
		--星涌术能耗判断
		
		if BalanceSaves.BalanceOption_Attack_AutoIronbark and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
		--自动保命
			if C_PvP.IsActiveBattlefield() then
			--PVP
				if PlayerHealthScale <= 0.3 and UnitAffectingCombat("player") and IsPlayerSpell(Renewal_SpellID) and not RenewalCD and not IsStealthed() then
					DA_CastSpellByName('熊形态甘霖治疗石宏')
					--熊形态甘霖治疗石宏
					Balance_SetDebugInfo("甘霖")
					Balance_CastSpellIng = 1
					Balance_SelfSaveIng = 1
				elseif PlayerHealthScale <= 0.5 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not FrenziedRegenerationCD then
					DA_CastSpellByName('熊形态狂暴回复宏')
					--熊形态狂暴回复宏
					Balance_SetDebugInfo("狂暴回复")
					Balance_CastSpellIng = 1
					Balance_SelfSaveIng = 1
				elseif PlayerHealthScale <= 0.7 and UnitAffectingCombat("player") and IsPlayerSpell(Barkskin_SpellID) and not BarkskinCD and not IsStealthed() then
					DA_CastSpellByID(Barkskin_SpellID, "player")
					--树皮术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("树皮术")
				elseif PlayerHealthScale <= 0.3 and UnitAffectingCombat("player") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Balance_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愈合")
				elseif PlayerHealthScale <= 0.7 and not UnitAffectingCombat("player") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Balance_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愈合")
				end
			else
				if PlayerHealthScale <= 0.4 and UnitAffectingCombat("player") and C_Item.IsUsableItem(5512) and GetItemCooldown(5512) == 0 and not IsStealthed() then
					DA_UseItem(5512)
					--治疗石
					Balance_CastSpellIng = 1
				end
				if PlayerHealthScale <= 0.5 and UnitAffectingCombat("player") and IsPlayerSpell(Renewal_SpellID) and not RenewalCD and not IsStealthed() then
					DA_CastSpellByID(Renewal_SpellID, "player")
					--甘霖
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("甘霖")
				elseif PlayerHealthScale <= 0.7 and UnitAffectingCombat("player") and IsPlayerSpell(Barkskin_SpellID) and not BarkskinCD and not IsStealthed() then
					DA_CastSpellByID(Barkskin_SpellID, "player")
					--树皮术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("树皮术")
				elseif PlayerHealthScale <= 0.3 and UnitAffectingCombat("player") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Balance_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愈合")
				elseif PlayerHealthScale <= 0.7 and not UnitAffectingCombat("player") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Balance_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愈合")
				end
			end
		end
		
		if IsActiveBattlefieldArena() then
			if #Balance_EnemyCacheHasThreat >= 0 and (#Balance_EnemyCacheHasThreatIn5 <= 0 or DA_UnitIsArenaChosen('player') <= 0) and PlayerHealthScale >= 0.4 then
			--竞技场中有敌对目标,且(5码内没有敌方或者玩家没有被敌方选中),且玩家血量大于40%则不解定身
				DA_Clear_Rooted = nil
			end
			if #Balance_EnemyCacheHasThreat >= 0 and (#Balance_EnemyCacheHasThreatIn5 <= 0 or DA_UnitIsArenaChosen('player') <= 0) and PlayerHealthScale >= 0.4 then
			--竞技场中有敌对目标,且(5码内没有敌方或者玩家没有被敌方选中),且玩家血量大于40%则不解定身
				DA_Clear_Deceleration = nil
			end
		end
		--if UnitExists("boss1") and IsInRaid() then
		--团队中BOSS战不解减速(很多减速DEBUFF无法解除)
		if DA_UnitHasDecelerationAndDamageDeBuff('player') then
		--减速同时附带伤害的DEBUFF不解减速
			DA_Clear_Deceleration = nil
		end
		if select(10, AuraUtil.FindAuraByName('眩晕', 'player', "HARMFUL")) == 1604 then
		--被怪背后攻击造成的[眩晕]不解减速
			DA_Clear_Deceleration = nil
		end
		if AuraUtil.FindAuraByName('冻结之缚', "player", "HARMFUL") then
		--中了通灵战潮-缚霜者纳尔佐的[冻结之缚],则不解定身减速
			DA_Clear_Rooted = nil
			DA_Clear_Deceleration = nil
		end
		if AuraUtil.FindAuraByName('抓握之血', "player", "HARMFUL") and UnitCastingInfo("boss1") == '宇宙奇点' then
		--中了艾拉-卡拉，回响之城-收割者吉卡塔尔的[抓握之血],且BOSS正在读条[宇宙奇点],则不解定身减速
			DA_Clear_Rooted = nil
			DA_Clear_Deceleration = nil
		end
		if BalanceSaves.BalanceOption_Other_ClearRoot and UnitAffectingCombat("player") and C_Spell.GetSpellLossOfControlCooldown(Regrowth_SpellID) == 0 then
			local speed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
			local Rooted, timeRemaining, spellID = DA_CheckPlayerRooted()
			if ((Rooted and timeRemaining and timeRemaining >= 0.35 and DA_Clear_Rooted) or (not IsSwimming() and speed ~= 0 and speed ~= 2.5 and speed ~= 4.5 and DA_GetUnitSpeed('player') <= 70 and DA_Clear_Deceleration)) then
			--被定身减速
				--print('被定身减速')
				if not UnitChannelInfo("player") and not IsFalling() and not IsFlying() and not UnitOnTaxi("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not Balance_CastSpellIng and not Balance_ChannelSpellIng and not Balance_SelfSaveIng then
					if (GetShapeshiftFormID() == 31 or AuraUtil.FindAuraByName('枭兽形态', "player", "HELPFUL")) and not IsStealthed() then
					--枭兽形态下直接通过取消变形解除定身
						--print('取消变形解除定身')
						DA_Cancelform()
						--print('取消变形3')
					elseif not IsStealthed() then
					--非枭兽形态下直接通过枭兽形态解除定身
						--print('枭兽形态解除定身')
						DA_CastSpellByID(Moonkin_Form_SpellID)
						--枭兽形态
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("枭兽形态")
					end
				end
			end
		end
		
		if not Balance_CastSpellIng and not Balance_ChannelSpellIng and not Balance_SelfSaveIng and GetShapeshiftFormID() ~= 31 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") then
			DA_CastSpellByID(Moonkin_Form_SpellID)
			--枭兽形态
			Balance_CastSpellIng = 1
			Balance_SetDebugInfo("枭兽形态")
		end

		if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 8.5 * SDPHR) then
			Balance_SumHealthControl = nil
		else
			Balance_SumHealthControl = 1
		end
		if Balance_Heals_SumHealthScaleDamager <= 0.75 and DamagerEngine_HealerAssigned and #DamagerEngine_HealerAssigned > 0 and not InnervateCD and IsPlayerSpell(Innervate_SpellID) and not Balance_SumHealthControl and not Balance_ChannelSpellIng then
			if UnitGUID(DamagerEngine_HealerAssigned[1].Unit) ~= UnitGUID("player") and not AuraUtil.FindAuraByName(DA_GetSpellInfo(Innervate_SpellID), DamagerEngine_HealerAssigned[1].Unit, "HELPFUL") and (not Balance_ManifestationOfPrideExists or UnitPower(DamagerEngine_HealerAssigned[1].Unit, 0) / UnitPowerMax(DamagerEngine_HealerAssigned[1].Unit, 0) <= 0.15) and not AuraUtil.FindAuraByName(DA_GetSpellInfo(64901), DamagerEngine_HealerAssigned[1].Unit, "HELPFUL") and (DA_GetLineOfSight("player", DamagerEngine_HealerAssigned[1].Unit) or not WoWAssistantUnlocked) then
				DA_TargetUnit(DamagerEngine_HealerAssigned[1].Unit)
				if UnitIsUnit('target', DamagerEngine_HealerAssigned[1].Unit) then
					DA_CastSpellByID(Innervate_SpellID)
				end
				--激活
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("激活")
				Balance_InnervateSentTarget = DamagerEngine_HealerAssigned[1].Unit
			end
		end
		
		if BalanceSaves.BalanceOption_Auras_ClearCurse or BalanceSaves.BalanceOption_Auras_ClearPoison or BalanceSaves.BalanceOption_Auras_ClearMouseover then
			if IsInRaid() then
				--团队
				Balance_ScanUnitAuras_Time = Balance_ScanUnitAuras_Time or GetTime()
				if GetTime() - Balance_ScanUnitAuras_Time > 2 then
					--团队中2秒才检测一次,降低CPU占用
					Balance_ScanUnitAuras_Time = nil
					for i=1, GetNumGroupMembers() do
						unitid = "raid"..i
						Balance_ScanUnitAuras(unitid)
						--增减益监测
					end
				end
			elseif IsInGroup() then
				--小队
				for i=1, GetNumGroupMembers() - 1 do
					unitid = "party"..i
					Balance_ScanUnitAuras(unitid)
					--增减益监测
				end
				unitid = "player"
				Balance_ScanUnitAuras(unitid)
				unitid = "focus"
				if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
					Balance_ScanUnitAuras(unitid)
				end
				--增减益监测
			else
				unitid = "player"
				Balance_ScanUnitAuras(unitid)
				unitid = "focus"
				if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
					Balance_ScanUnitAuras(unitid)
				end
				--增减益监测
			end
		end
		
		if BalanceSaves.BalanceOption_Auras_AutoInterrupt then
		--自动打断
			if DamagerEngineInterruptSpell and not SolarBeamCD and IsPlayerSpell(Solar_Beam_SpellID) and ((not UnitCastingInfo("player") and not UnitChannelInfo("player")) or #DamagerEngine_GroupMember <= 1) and not Balance_ChannelSpellIng then
				DA_TargetUnit(DamagerEngineInterruptSpellTarget)
				if UnitIsUnit('target', DamagerEngineInterruptSpellTarget) then
					DA_CastSpellByID(Solar_Beam_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("日光术")
				--日光术
			end
			if DamagerEngineControlInterruptSpell and (DA_GetFacing("player", DamagerEngineControlInterruptSpellTarget) or not WoWAssistantUnlocked) and (SolarBeamCD or DamagerEngine_IsNotInterruptibleSpell) and not MightyBashCD and IsPlayerSpell(Mighty_Bash_SpellID) and not IsStealthed() and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(DamagerEngineControlInterruptSpellTarget)
				if UnitIsUnit('target', DamagerEngineControlInterruptSpellTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Mighty_Bash_SpellID))
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("蛮力猛击")
				--蛮力猛击
			end
		end
		
		if BalanceSaves.BalanceOption_Other_AutoRebirth then
			Balance_DeadTankUnitid = Balance_GetTankAssignedDead()
			Balance_DeadHealerUnitid = Balance_GetHealerAssignedDead()
			Balance_DeadDamagerUnitid = Balance_GetDamagerAssignedDead()
			if Balance_DeadTankUnitid and not RebirthCD and IsPlayerSpell(Rebirth_SpellID) and UnitAffectingCombat("player") and Balance_IsCanMovingCast(Rebirth_SpellID) and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_DeadTankUnitid)
				if UnitIsUnit('target', Balance_DeadTankUnitid) then
					DA_CastSpellByID(Rebirth_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("复生")
			end
			--复生坦克
			if Balance_DeadHealerUnitid and #DamagerEngine_GroupMember <= 7 and #DamagerEngine_TankAssigned >= 1 and not RebirthCD and IsPlayerSpell(Rebirth_SpellID) and UnitAffectingCombat("player") and Balance_IsCanMovingCast(Rebirth_SpellID) and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_DeadHealerUnitid)
				if UnitIsUnit('target', Balance_DeadHealerUnitid) then
					DA_CastSpellByID(Rebirth_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("复生")
			end
			--复生治疗(附近队友不大于7人)
			if Balance_DeadDamagerUnitid and UnitExists("boss1") and #DamagerEngine_GroupMember <= 7 and #DamagerEngine_TankAssigned >= 1 and not RebirthCD and IsPlayerSpell(Rebirth_SpellID) and UnitAffectingCombat("player") and Balance_IsCanMovingCast(Rebirth_SpellID) and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_DeadDamagerUnitid)
				if UnitIsUnit('target', Balance_DeadDamagerUnitid) then
					DA_CastSpellByID(Rebirth_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("复生")
			end
			--复生伤害输出(BOSS战,且附近队友不大于7人)
		end
		
		if not Balance_CastSpellIng and not Balance_ChannelSpellIng and not IsStealthed() then
		--特定目标控制
			for k, v in ipairs(Balance_ControlEnemyCache) do
				if DA_ObjectId(v.Unit) == 111111 then
				--多恩诺加尔-顺劈训练假人(测试)控制逻辑:
				
					--print("控制目标 - "..UnitName(v.Unit))
					if not AuraUtil.FindAuraByName('纠缠根须', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('群体缠绕', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('变形术', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('恐惧', v.Unit, "HARMFUL") then
					--没有纠缠根须等控制效果
						if IsPlayerSpell(102359) and DA_IsUsableSpell(102359) and not Mass_EntanglementCD and DA_IsSpellInRange(102359, v.Unit) then
							DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
							--选择特定控制目标宏
							if UnitIsUnit('target', v.Unit) then
								DA_CastSpellByID(102359)
								BalanceSpellWillBeCast = 1
								--使用[群体缠绕]控制
							end
						elseif IsPlayerSpell(Entangling_Roots_SpellID) and DA_IsUsableSpell(Entangling_Roots_SpellID) and not WrathCD and DA_IsSpellInRange(Entangling_Roots_SpellID, v.Unit) and not DA_EntanglingRootsCastStart and ((Balance_IsCanMovingCast(Entangling_Roots_SpellID) and not DamagerEngine_NoCastingAuras) or select(4, DA_GetSpellInfo('纠缠根须')) == 0) then
							DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
							--选择特定控制目标宏
							if UnitIsUnit('target', v.Unit) then
								DA_CastSpellByID(Entangling_Roots_SpellID)
								BalanceSpellWillBeCast = 1
								--使用[纠缠根须]控制
							end
						end
					end
				end
				
				if DA_ObjectId(v.Unit) == 165251 then
				--塞兹仙林的迷雾-幻影仙狐控制逻辑:
				
					--print("控制目标 - "..UnitName(v.Unit))
					if GetUnitSpeed(v.Unit) ~= 0 and not AuraUtil.FindAuraByName('纠缠根须', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('群体缠绕', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('变形术', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('恐惧', v.Unit, "HARMFUL") then
					--幻影仙狐在移动,且没有纠缠根须等控制效果
						if IsPlayerSpell(102359) and DA_IsUsableSpell(102359) and not Mass_EntanglementCD and DA_IsSpellInRange(102359, v.Unit) then
							DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
							--选择特定控制目标宏
							if UnitIsUnit('target', v.Unit) then
								DA_CastSpellByID(102359)
								BalanceSpellWillBeCast = 1
								--使用[群体缠绕]控制
							end
						elseif IsPlayerSpell(Entangling_Roots_SpellID) and DA_IsUsableSpell(Entangling_Roots_SpellID) and not WrathCD and DA_IsSpellInRange(Entangling_Roots_SpellID, v.Unit) and not DA_EntanglingRootsCastStart and ((Balance_IsCanMovingCast(Entangling_Roots_SpellID) and not DamagerEngine_NoCastingAuras) or select(4, DA_GetSpellInfo('纠缠根须')) == 0) then
							DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
							--选择特定控制目标宏
							if UnitIsUnit('target', v.Unit) then
								DA_CastSpellByID(Entangling_Roots_SpellID)
								BalanceSpellWillBeCast = 1
								--使用[纠缠根须]控制
							end
						end
					end
					
					break
				end
			end
		end
		
		if Balance_AutoDPS_MoonfireTargetS and not Balance_CastSpellIng and not Balance_ChannelSpellIng and IsPlayerSpell(Moonfire_SpellID) then
			DA_TargetUnit(Balance_AutoDPS_MoonfireTargetS)
			if UnitIsUnit('target', Balance_AutoDPS_MoonfireTargetS) then
				DA_CastSpellByID(Moonfire_SpellID)
			end
			Balance_SpellCastSentMoonfireTargetS = 1
			Balance_CastSpellIng = 1
			Balance_SetDebugInfo("月火术")
		end
		--特殊目标月火术
		
		if C_PvP.IsActiveBattlefield() then
			StarfallUnitCount = 3
		else
			StarfallUnitCount = 2
		end
		
		if Balance_EnemyCount >= StarfallUnitCount and not Balance_AutoDPS_MoonfireTargetS and not DamagerEngine_AutoDPS_SinglePriorityTatgetExists and BalanceSaves.BalanceOption_TargetFilter ~= 2 then
		--AOE模式
			Balance_GetDirectSingleDPSItemCD(Balance_AutoDPS_DPSTarget)
			--判断单体伤害饰品CD
			Balance_GetDirectAoeDPSItemCD(Balance_AutoDPS_DPSTarget)
			--判断AOE伤害饰品CD
			
			if Balance_ClearEnrageTarget and not SootheCD and IsPlayerSpell(Soothe_SpellID) and UnitAffectingCombat("player") and BalanceSaves.BalanceOption_Auras_ClearEnrage and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_ClearEnrageTarget)
				if UnitIsUnit('target', Balance_ClearEnrageTarget) then
					DA_CastSpellByID(Soothe_SpellID)
				end
				--安抚
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("安抚")
			end
			
			if not WarriorOfEluneCD and IsPlayerSpell(Warrior_of_Elune_SpellID) and UnitAffectingCombat("player") and (not Balance_IsCanMovingCast(Starfire_SpellID) or PlayerPowerNow < 50) and not name3 and not name8 and LunarEmpowerment then
				DA_CastSpellByID(Warrior_of_Elune_SpellID, "player")
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("艾露恩的战士")
				--艾露恩的战士
			end
			
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 8.5 * SDPHR) then
				Balance_SumHealthControl = nil
			else
				Balance_SumHealthControl = 1
			end
			if not Balance_SumHealthControl and not DirectSingleDPSItemCD and BalanceSaves.BalanceOption_Attack_AutoAccessories and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_UseItem(DirectSingleDPSItemID)
				end
				--使用单体伤害饰品
				Balance_CastSpellIng = 1
			end
			
			if not Balance_SumHealthControl and not DirectAoeDPSItemCD and BalanceSaves.BalanceOption_Attack_AutoAccessories and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_UseItem(DirectAoeDPSItemID)
				end
				--使用AOE伤害饰品
				Balance_CastSpellIng = 1
			end
		
			local start1, duration1 = DA_GetSpellCooldown(113)
			local start2, duration2 = DA_GetSpellCooldown(194223)
			if IsPlayerSpell(390378) then
			--学习了[轨道打击]天赋
				start2, duration2 = DA_GetSpellCooldown(383410)
			end
			if IsPlayerSpell(102560) then
			--学习了[化身：艾露恩之眷]天赋
				start2, duration2 = DA_GetSpellCooldown(102560)
			end
			if (UnitExists("boss1") and select(2, IsInInstance()) == "raid") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 27.5 * SDPHR) then
				Balance_SumHealthControl = nil
			else
				Balance_SumHealthControl = 1
			end
			if duration2 == 0 and UnitAffectingCombat("player") and (IsPlayerSpell(194223) or IsPlayerSpell(102560)) and not name8 and not name9 and not ComeEclipse and ((not Balance_AutoDPS_SunfireTarget and (Balance_EnemyCount >= 2 or not C_PvP.IsActiveBattlefield())) or (Balance_EnemyCount >= 5 and C_PvP.IsActiveBattlefield())) and not Balance_SumHealthControl and Balance_IsCanMovingCast(194223) and BalanceSaves.BalanceOption_Attack_AutoCelestialAlignment and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				DA_CastSpellByName('超凡之盟')
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("超凡之盟")
			end
			--超凡之盟、化身：艾露恩之眷
			
			if not Balance_SumHealthControl and UnitAffectingCombat("player") and IsPlayerSpell(Berserking_SpellID) and not IsStealthed() and PlayerPowerNow >= 40 and not BerserkingCD and Balance_AutoDPS_DPSTarget and BalanceSaves.BalanceOption_Attack_AutoAccessories and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and not Balance_ChannelSpellIng then
				DA_CastSpellByID(Berserking_SpellID)
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("狂暴(种族特长)")
			end
			--狂暴(种族特长)
			
			if not Balance_SumHealthControl and PlayerPowerNow >= 40 and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				Balance_UseAttributesEnhancedItem()
				--使用属性增强饰品
				Balance_UseConcoctionKissOfDeath()
				--[制剂：死亡之吻]
			end
			
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 7 * SDPHR) then
				Balance_SumHealthControl = nil
			else
				Balance_SumHealthControl = 1
			end
			if IsPlayerSpell(428731) then
				if not Balance_SumHealthControl and not ForceOfNatureCD and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and IsPlayerSpell(Force_of_Nature_SpellID) and not Balance_NoUsePowerfulSpell and not IsStealthed() and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_CastSpellByID(Force_of_Nature_SpellID, "player")
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("自然之力")
				end
			end
			--自然之力
			
			if not Balance_SumHealthControl and BalanceSaves.BalanceOption_Attack_AutoCovenant and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and not ConvokeTheSpiritsCD and not Balance_AutoDPS_SunfireTarget and not IsStealthed() and ((expires8 and expires8 - GetTime() > 5) or (expires9 and expires9 - GetTime() > 5)) and not DamagerEngine_NoCastingAuras and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng then
				Balance_UseAttributesEnhancedItem()
				--使用属性增强饰品
				Balance_UseConcoctionKissOfDeath()
				--[制剂：死亡之吻]
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Convoke_the_Spirits_SpellID))
				end
				Balance_CastSpellIng = 1
				Balance_ChannelSpellIng = 1
				C_Timer.After(0.75, function()
					Balance_ChannelSpellIng = nil
				end)
				Balance_SetDebugInfo("万灵之召")
			end
			--万灵之召
			
			if IsPlayerSpell(Starfall_SpellID) and UnitAffectingCombat("player") and Balance_DA_IsUsableSpell(Starfall_SpellID) and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_CastSpellByID(Starfall_SpellID)
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星辰坠落")
			end
			--星辰坠落
			
			if UnitName('target') ~= '拉夏南' and not FuryOfEluneCD and IsPlayerSpell(Elune_Wrath_SpellID) and not Balance_SumHealthControl and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and Balance_AutoDPS_DPSTarget and Balance_UnitWithAttackUnitDecide(Balance_AutoDPS_DPSTarget, 8.5) >= 2 and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and PlayerPowerVacancy > 20 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Elune_Wrath_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("艾露恩之怒")
			end
			--艾露恩之怒(AOE)
			
			if IsPlayerSpell(New_Moon_SpellID) then
				if Spell_NewMoon == "FullMoon" then
					--满月时
					if Balance_IsCanMovingCast("新月") and DA_GetSpellCharges(New_Moon_SpellID) > 0 and PlayerPowerVacancy >= 40 and ((timeLeft8 and timeLeft8 >= select(4, DA_GetSpellInfo("满月")) / 1000 + 0.1) or (timeLeft9 and timeLeft9 >= select(4, DA_GetSpellInfo("满月")) / 1000 + 0.1)) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 1.425 * SDPHR and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then	
						DA_TargetUnit(Balance_StarfireUnit)
						if UnitIsUnit('target', Balance_StarfireUnit) then
							DA_CastSpellByName("新月")
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("新月")
					end
				else
					--非满月时
					if Balance_IsCanMovingCast("新月") and DA_GetSpellCharges(New_Moon_SpellID) > 0 and PlayerPowerVacancy >= 20 and not name14 and not DA_IsCastingSpell(274282) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByName("新月")
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("新月")
					end
				end
			end
			--新月
			
			if IsPlayerSpell(202430) then
				StarsurgeHealthControl = 2.85 * SDPHR
			else
				StarsurgeHealthControl = 4.25 * SDPHR
			end
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * StarsurgeHealthControl) then
				Balance_SumHealthControl = nil
			else
				Balance_SumHealthControl = 1
			end
			if (name11 or name_TouchTheCosmos_Starsurge) and (ComeEclipse or name8 or name9) 
			--星涌术不消耗星界能量且即将进入日月蚀,或日蚀状态,或月蚀状态
			and (Balance_EnemyCount <= 4 or not name9) and Balance_DA_IsUsableSpell(Starsurge_SpellID) and UnitAffectingCombat("player") and IsPlayerSpell(Starsurge_SpellID) and not Balance_SumHealthControl and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Starsurge_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星涌术")
			end
			--星涌术
			
			if not Balance_SumHealthControl and not WildMushroomCD and IsPlayerSpell(Wild_Mushroom_SpellID) and not Balance_Casted_WildMushroom and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_WildMushroomTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_WildMushroomTarget)
				if UnitIsUnit('target', Balance_AutoDPS_WildMushroomTarget) then
					DA_CastSpellByID(Wild_Mushroom_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("野性蘑菇")
			end
			--野性蘑菇
			
			if not IsPlayerSpell(428731) then
				if not Balance_SumHealthControl and not ForceOfNatureCD and IsPlayerSpell(Force_of_Nature_SpellID) and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_CastSpellByID(Force_of_Nature_SpellID, "player")
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("自然之力")
				end
			end
			--自然之力
			
			if Balance_EnemyCount <= 2 and not Balance_SumHealthControl and Balance_IsCanMovingCast(Stellar_Flare_SpellID) and IsPlayerSpell(Stellar_Flare_SpellID) and not Balance_Casted_StellarFlare and not DA_IsCastingSpell(Stellar_Flare_SpellID) and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_StellarFlareTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_StellarFlareTarget)
				if UnitIsUnit('target', Balance_AutoDPS_StellarFlareTarget) then
					DA_CastSpellByID(Stellar_Flare_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星辰耀斑")
			end
			--星辰耀斑

			if IsPlayerSpell(Moonfire_SpellID) and not name14 and Balance_AutoDPS_MoonfireTarget and not Balance_AutoDPS_MoonfireTargetS and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_MoonfireTarget)
				if UnitIsUnit('target', Balance_AutoDPS_MoonfireTarget) then
					DA_CastSpellByID(Moonfire_SpellID)
				end
				--月火术
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("月火术")
			end
			
			if IsPlayerSpell(Sunfire_SpellID) and not name14 and Balance_AutoDPS_SunfireTarget and not Balance_AutoDPS_MoonfireTargetS and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_SunfireTarget)
				if UnitIsUnit('target', Balance_AutoDPS_SunfireTarget) then
					DA_CastSpellByID(Sunfire_SpellID)
				end
				--阳炎术
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("阳炎术")
			end
					
			if IsPlayerSpell(279620) then
			--[双月]天赋
				if ((Balance_UnitWithAttackUnitDecide(Balance_AutoDPS_DPSTarget, 8.5) >= 2 or name3 or name9 or name13) or (timeLeft10 < 4.5 and PlayerPowerNow < 15) or (timeLeft10 < 2.5 and PlayerPowerNow < 30)) then
					if Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and not LunarEmpowerment and (SolarEmpowerment or (expires8 and expires8 - GetTime() > 1.5)) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
						end
						--愤怒
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("愤怒")
					elseif (Balance_IsCanMovingCast(Starfire_SpellID) or name3 or name13) and not SolarEmpowerment and IsPlayerSpell(Starfire_SpellID) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_StarfireUnit)
						if UnitIsUnit('target', Balance_StarfireUnit) then
							DA_CastSpellByID(Starfire_SpellID)
						end
						--星火术
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星火术")
					elseif Balance_IsCanMovingCast(Wrath_SpellID) and name8 and IsPlayerSpell(Wrath_SpellID) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByID(Wrath_SpellID)
						end
						--愤怒
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("愤怒")
					end
				elseif Balance_AutoDPS_DPSTarget2 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					if IsPlayerSpell(Sunfire_SpellID) then 
						DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
							DA_CastSpellByID(Sunfire_SpellID)
						end
						--阳炎术
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("阳炎术")
					elseif IsPlayerSpell(Moonfire_SpellID) then 
						DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
							DA_CastSpellByID(Moonfire_SpellID)
						end
						--月火术
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("月火术")
					end
				end
			else
				if Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and not LunarEmpowerment and (SolarEmpowerment or (expires8 and expires8 - GetTime() > 1.5)) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_AutoDPS_DPSTarget)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
						DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
					end
					--愤怒
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愤怒")
				elseif (Balance_IsCanMovingCast(Starfire_SpellID) or name3 or name13) and not SolarEmpowerment and IsPlayerSpell(Starfire_SpellID) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_StarfireUnit)
					if UnitIsUnit('target', Balance_StarfireUnit) then
						DA_CastSpellByID(Starfire_SpellID)
					end
					--星火术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("星火术")
				elseif Balance_IsCanMovingCast(Wrath_SpellID) and name8 and IsPlayerSpell(Wrath_SpellID) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_AutoDPS_DPSTarget)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
						DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
					end
					--愤怒
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愤怒")
				end
			end
			
			if IsPlayerSpell(Moonfire_SpellID) and Balance_AutoDPS_DPSTarget2 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
			--所有施法判断不通过时
				if IsPlayerSpell(Sunfire_SpellID) then 
					DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
						DA_CastSpellByID(Sunfire_SpellID)
					end
					--阳炎术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("阳炎术")
				elseif IsPlayerSpell(Moonfire_SpellID) then 
					DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
						DA_CastSpellByID(Moonfire_SpellID)
					end
					--月火术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("月火术")
				end
			end
			--月火术
			
		elseif not Balance_AutoDPS_MoonfireTargetS and BalanceSaves.BalanceOption_TargetFilter ~= 2 then
		--非AOE模式
		
			Balance_GetDirectSingleDPSItemCD(Balance_AutoDPS_DPSTarget)
			--判断单体伤害饰品CD
			Balance_GetDirectAoeDPSItemCD(Balance_AutoDPS_DPSTarget)
			--判断AOE伤害饰品CD
			
			if Balance_ClearEnrageTarget and not SootheCD and IsPlayerSpell(Soothe_SpellID) and UnitAffectingCombat("player") and BalanceSaves.BalanceOption_Auras_ClearEnrage and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_ClearEnrageTarget)
				if UnitIsUnit('target', Balance_ClearEnrageTarget) then
					DA_CastSpellByID(Soothe_SpellID)
				end
				--安抚
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("安抚")
			end
			
			if not WarriorOfEluneCD and UnitAffectingCombat("player") and IsPlayerSpell(Warrior_of_Elune_SpellID) and (not Balance_IsCanMovingCast(Starfire_SpellID) or PlayerPowerNow < 50) and not name3 and not name8 and LunarEmpowerment then
				DA_CastSpellByID(Warrior_of_Elune_SpellID, "player")
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("艾露恩的战士")
				--艾露恩的战士
			end
			
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 8.5 * SDPHR) then
				Balance_SumHealthControl = nil
			else
				Balance_SumHealthControl = 1
			end
			if not Balance_SumHealthControl and not DirectSingleDPSItemCD and BalanceSaves.BalanceOption_Attack_AutoAccessories and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_UseItem(DirectSingleDPSItemID)
				end
				--使用单体伤害饰品
				Balance_CastSpellIng = 1
			end
		
			local start1, duration1 = DA_GetSpellCooldown(113)
			local start2, duration2 = DA_GetSpellCooldown(194223)
			if IsPlayerSpell(390378) then
			--学习了[轨道打击]天赋
				start2, duration2 = DA_GetSpellCooldown(383410)
			end
			if IsPlayerSpell(102560) then
			--学习了[化身：艾露恩之眷]天赋
				start2, duration2 = DA_GetSpellCooldown(102560)
			end
			if (UnitExists("boss1") and select(2, IsInInstance()) == "raid") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (TargetHealth and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 20 * SDPHR) then
				Balance_TargetHealthControl = nil
			else
				Balance_TargetHealthControl = 1
			end
			if duration2 == 0 and UnitAffectingCombat("player") and (IsPlayerSpell(194223) or IsPlayerSpell(102560)) and not name8 and not name9 and not ComeEclipse and ((not Balance_AutoDPS_SunfireTarget and (Balance_EnemyCount >= 2 or not C_PvP.IsActiveBattlefield())) or (Balance_EnemyCount >= 5 and C_PvP.IsActiveBattlefield())) and not Balance_TargetHealthControl and Balance_IsCanMovingCast(194223) and BalanceSaves.BalanceOption_Attack_AutoCelestialAlignment and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				DA_CastSpellByName('超凡之盟')
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("超凡之盟")
			end
			--超凡之盟、化身：艾露恩之眷
			
			if not Balance_TargetHealthControl and UnitAffectingCombat("player") and IsPlayerSpell(Berserking_SpellID) and not IsStealthed() and PlayerPowerNow >= 40 and not BerserkingCD and Balance_AutoDPS_DPSTarget and BalanceSaves.BalanceOption_Attack_AutoAccessories and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and not Balance_ChannelSpellIng then
				DA_CastSpellByID(Berserking_SpellID)
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("狂暴(种族特长)")
			end
			--狂暴(种族特长)
			
			if not Balance_TargetHealthControl and PlayerPowerNow >= 40 and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
				Balance_UseAttributesEnhancedItem()
				--使用属性增强饰品
				Balance_UseConcoctionKissOfDeath()
				--[制剂：死亡之吻]
			end
			
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 7 * SDPHR) then
				Balance_TargetHealthControl = nil
			else
				Balance_TargetHealthControl = 1
			end
			if IsPlayerSpell(428731) then
				if not Balance_TargetHealthControl and not ForceOfNatureCD and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and IsPlayerSpell(Force_of_Nature_SpellID) and not Balance_NoUsePowerfulSpell and not IsStealthed() and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_CastSpellByID(Force_of_Nature_SpellID, "player")
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("自然之力")
				end
			end
			--自然之力
			
			if not Balance_TargetHealthControl and BalanceSaves.BalanceOption_Attack_AutoCovenant and (timeLeft14 >= 2 or ComeEclipse_EquippedBalanceOfAllThings or not IsPlayerSpell(394048)) and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and not ConvokeTheSpiritsCD and IsPlayerSpell(Convoke_the_Spirits_SpellID) and not Balance_AutoDPS_SunfireTarget and not IsStealthed() and ((expires8 and expires8 - GetTime() > 5) or (expires9 and expires9 - GetTime() > 5)) and not DamagerEngine_NoCastingAuras and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng then
				Balance_UseAttributesEnhancedItem()
				--使用属性增强饰品
				Balance_UseConcoctionKissOfDeath()
				--[制剂：死亡之吻]
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Convoke_the_Spirits_SpellID))
				end
				Balance_CastSpellIng = 1
				Balance_ChannelSpellIng = 1
				C_Timer.After(0.75, function()
					Balance_ChannelSpellIng = nil
				end)
				Balance_SetDebugInfo("万灵之召")
			end
			--万灵之召
			
			if IsPlayerSpell(New_Moon_SpellID) then
				if Spell_NewMoon == "FullMoon" then
					--满月时
					if Balance_IsCanMovingCast("新月") and DA_GetSpellCharges(New_Moon_SpellID) > 0 and PlayerPowerVacancy >= 40 and ((timeLeft8 and timeLeft8 >= select(4, DA_GetSpellInfo("满月")) / 1000 + 0.1) or (timeLeft9 and timeLeft9 >= select(4, DA_GetSpellInfo("满月")) / 1000 + 0.1)) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 1.425 * SDPHR and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then	
						DA_TargetUnit(Balance_StarfireUnit)
						if UnitIsUnit('target', Balance_StarfireUnit) then
							DA_CastSpellByName("新月")
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("新月")
					end
				else
					--非满月时
					if Balance_IsCanMovingCast("新月") and DA_GetSpellCharges(New_Moon_SpellID) > 0 and PlayerPowerVacancy >= 20 and not name14 and not DA_IsCastingSpell(274282) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByName("新月")
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("新月")
					end
				end
			end
			--新月
			
			if IsPlayerSpell(202430) then
				StarsurgeHealthControl = 2.85 * SDPHR
			else
				StarsurgeHealthControl = 4.25 * SDPHR
			end
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (TargetHealth and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * StarsurgeHealthControl) or #DamagerEngine_DamagerAssigned <= 3 then
				Balance_TargetHealthControl = nil
			else
				Balance_TargetHealthControl = 1
			end
			if (PlayerPowerNow > 80 or timeLeft14 > 1 or name11 or name_TouchTheCosmos_Starsurge or (ComeEclipse and PlayerPowerNow > 80) or ComeEclipse_EquippedBalanceOfAllThings or not Balance_IsCanMovingCast(Starfire_SpellID) or DamagerEngine_NoCastingAuras) 
			--能量大于80,或万物平衡BUFF时间大于1秒,或者星涌术不消耗能量,或即将进入日月蚀且能量大于80,或即将获得万物平衡BUFF,或者在移动中,或者存在不读条的状态
			and ((ComeEclipse or name8 or name9) or not Balance_IsCanMovingCast(Starfire_SpellID) or DamagerEngine_NoCastingAuras) 
			--即将进入日月蚀,或日蚀状态,或月蚀状态,或者在移动中,或者存在不读条的状态
			and ((not Balance_NeedMovingCast() and not NeedMovingCastWill) or PlayerPowerNow > 80) 
			and Balance_DA_IsUsableSpell(Starsurge_SpellID) and UnitAffectingCombat("player") and IsPlayerSpell(Starsurge_SpellID) and not Balance_TargetHealthControl and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Starsurge_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星涌术")
			end
			--星涌术
			
			if UnitName('target') ~= '拉夏南' and not FuryOfEluneCD and IsPlayerSpell(Elune_Wrath_SpellID) and not Balance_TargetHealthControl and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and Balance_AutoDPS_DPSTarget and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and PlayerPowerVacancy > 20 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Elune_Wrath_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("艾露恩之怒")
			end
			--艾露恩之怒(单体)
			
			if IsPlayerSpell(Starfall_SpellID) and UnitAffectingCombat("player") and Balance_DA_IsUsableSpell(Starfall_SpellID) and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_CastSpellByID(Starfall_SpellID)
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星辰坠落")
			end
			--星辰坠落
			
			if not IsPlayerSpell(428731) then
				if not Balance_TargetHealthControl and not ForceOfNatureCD and IsPlayerSpell(Force_of_Nature_SpellID) and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_CastSpellByID(Force_of_Nature_SpellID, "player")
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("自然之力")
				end
			end
			--自然之力
			
			if not Balance_TargetHealthControl and Balance_IsCanMovingCast(Stellar_Flare_SpellID) and IsPlayerSpell(Stellar_Flare_SpellID) and not Balance_Casted_StellarFlare and not DA_IsCastingSpell(Stellar_Flare_SpellID) and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_StellarFlareTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_StellarFlareTarget)
				if UnitIsUnit('target', Balance_AutoDPS_StellarFlareTarget) then
					DA_CastSpellByID(Stellar_Flare_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星辰耀斑")
			end
			--星辰耀斑
			
			if IsPlayerSpell(Sunfire_SpellID) and Balance_AutoDPS_SunfireTarget and not Balance_AutoDPS_MoonfireTargetS and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_SunfireTarget)
				if UnitIsUnit('target', Balance_AutoDPS_SunfireTarget) then
					DA_CastSpellByID(Sunfire_SpellID)
				end
				--阳炎术
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("阳炎术")
			end
			if IsPlayerSpell(Moonfire_SpellID) and Balance_AutoDPS_MoonfireTarget and not Balance_AutoDPS_MoonfireTargetS and not Balance_AutoDPS_SunfireTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_MoonfireTarget)
				if UnitIsUnit('target', Balance_AutoDPS_MoonfireTarget) then
					DA_CastSpellByID(Moonfire_SpellID)
				end
				--月火术
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("月火术")
			end
			
			if not Balance_TargetHealthControl and not WildMushroomCD and IsPlayerSpell(Wild_Mushroom_SpellID) and not Balance_Casted_WildMushroom and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_WildMushroomTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_WildMushroomTarget)
				if UnitIsUnit('target', Balance_AutoDPS_WildMushroomTarget) then
					DA_CastSpellByID(Wild_Mushroom_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("野性蘑菇")
			end
			--野性蘑菇
			
			if IsPlayerSpell(Starfire_SpellID) and (Balance_IsCanMovingCast(Starfire_SpellID) or name3 or name13) and not SolarEmpowerment and (LunarEmpowerment or (expires9 and expires9 - GetTime() > 2 and not name8) or name3 or (name13 and not Balance_IsCanMovingCast(Wrath_SpellID))) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_AutoDPS_DPSTarget, 8.5) and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Starfire_SpellID)
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("星火术")
			end
			--星火术
			
			if IsPlayerSpell(Wrath_SpellID) and Balance_IsCanMovingCast(Wrath_SpellID) and (((SolarEmpowerment or (expires8 and expires8 - GetTime() > 1.5)) or (PlayerPowerNow < Balance_StarsurgePower and not name9)) or Balance_TargetHealthControl) and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("愤怒")
			end
			--愤怒
			
			if Balance_AutoDPS_DPSTarget2 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				if Balance_EnemyCount >= 2 and IsPlayerSpell(Sunfire_SpellID) then
					DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
						DA_CastSpellByID(Sunfire_SpellID)
					end
					--阳炎术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("阳炎术")
				elseif IsPlayerSpell(Moonfire_SpellID) then
					DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
						DA_CastSpellByID(Moonfire_SpellID)
					end
					--月火术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("月火术")
				end
			end
			--移动状态DOT
			
			if Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng and Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and not DamagerEngine_NoCastingAuras then
			--所有施法判断不通过时
				DA_TargetUnit(Balance_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
				end
				Balance_CastSpellIng = 1
				Balance_SetDebugInfo("愤怒")
			end
			--愤怒
			
		elseif BalanceSaves.BalanceOption_TargetFilter == 2 then
		--手动目标模式
			Balance_AutoDPS_StellarFlareTarget = nil
			Balance_AutoDPS_WildMushroomTarget = nil
			Balance_AutoDPS_SunfireTarget = nil
			Balance_AutoDPS_MoonfireTarget = nil
			Balance_AutoDPS_DPSTarget = nil
			Balance_AutoDPS_DPSTarget2 = nil
			Balance_ClearEnrageTarget = nil
			Balance_StarfireUnit = nil
			
			if UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") ~= 0.8 and UnitHealth("target") / UnitHealthMax("target") ~= 0.7 and UnitHealth("target") / UnitHealthMax("target") ~= 0.6 then --[矶石宝库]部分小怪初始血量为80%,70%,60%
				local status = UnitThreatSituation("player", "target")
				
				if ((status and UnitAffectingCombat("target")) 
				--单位有仇恨且在战斗中
				or DamagerEngineGetNoThreatUnit("target") 
				--单位是无仇恨类特殊目标
				or (UnitIsPlayer('targettarget') and IsInInstance())
				--单位的目标是玩家且在副本中 
				or (UnitIsPlayer("target") and C_PvP.IsActiveBattlefield())
				--单位是玩家且在战场/竞技场中
				or (UnitPlayerControlled("target") and UnitAffectingCombat("player")))
				--单位是玩家控制的单位且自己在战斗中
				and DA_IsSpellInRange(Moonfire_SpellID, "target") == 1 and (DA_GetLineOfSight("player", "target") or not WoWAssistantUnlocked) and UnitExists("target") and not UnitIsDeadOrGhost("target") and (not UnitIsFriend("target", "player") or UnitIsEnemy("target", "player")) and UnitPhaseReason("target")~=0 and UnitPhaseReason("target")~=1 and UnitCanAttack("player","target") then
					if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and (not name1 or (expires1 and expires1 - GetTime() < 3)) and ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.075) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
						Balance_AutoDPS_MoonfireTarget = "target"
						--月火术目标
					end
					
					if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_UnitWithNoAttackAurasUnitDecide("target", 8.5) and (not name2 or (expires2 and expires2 - GetTime() < 3)) and ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.075) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
						Balance_AutoDPS_SunfireTarget = "target"
						--阳炎术目标
					end
					
					if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_UnitWithNoAttackAurasUnitDecide("target", 8.5) and (not name15 or (expires15 and expires15 - GetTime() < 3)) and ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.075) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
						Balance_AutoDPS_WildMushroomTarget = "target"
						--野性蘑菇目标
					end
					
					if timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_UnitWithNoAttackAurasUnitDecide("target", 8.5) and (not name16 or (expires16 and expires16 - GetTime() < 5)) and ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.075) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
						Balance_AutoDPS_StellarFlareTarget = "target"
						--星辰耀斑目标
					end
					if WoWAssistantUnlocked then
						if DA_GetFacing("player", "target") then
							if ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * 0.2 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not DamagerEngineGetNoAttackAuras("target") then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								Balance_AutoDPS_DPSTarget = "target"
								Balance_AutoDPS_DPSTarget2 = "target"
								--循环输出目标
							end
						else
							if ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * 0.2 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not DamagerEngineGetNoAttackAuras("target") then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								Balance_AutoDPS_DPSTarget2 = "target"
								--循环输出目标
							end
						end
					else
						if ((UnitHealthMax("target") - UnitHealth("target") > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (UnitHealth("target") > UnitHealthMax("player") * 0.2 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not DamagerEngineGetNoAttackAuras("target") then
							--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
							Balance_AutoDPS_DPSTarget = "target"
							Balance_AutoDPS_DPSTarget2 = "target"
							--循环输出目标
						end
					end
					if DA_UnitHasEnrage("target") and (UnitHealth("target") > UnitHealthMax("player") * 1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						Balance_ClearEnrageTarget = "target"
						--驱散激怒效果目标
					end
					Balance_StarfireUnit = "target"
				end
				
				if not Balance_AutoDPS_DPSTarget then
					Balance_DeBugEnemyCount:Hide()
					Balance_DeBugSpellIcon:Hide()
					return
				end
				
				Balance_GetDirectSingleDPSItemCD(Balance_AutoDPS_DPSTarget)
				--判断单体伤害饰品CD
				Balance_GetDirectAoeDPSItemCD(Balance_AutoDPS_DPSTarget)
				--判断AOE伤害饰品CD
			
				if Balance_ClearEnrageTarget and not SootheCD and IsPlayerSpell(Soothe_SpellID) and UnitAffectingCombat("player") and BalanceSaves.BalanceOption_Auras_ClearEnrage and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_ClearEnrageTarget)
					if UnitIsUnit('target', Balance_ClearEnrageTarget) then
						DA_CastSpellByID(Soothe_SpellID)
					end
					--安抚
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("安抚")
				end
				
				TargetHealth = UnitHealth("target")
				TargetHealthScale = UnitHealth("target") / UnitHealthMax("target")
		
				if string.match(UnitName(Balance_AutoDPS_DPSTarget), "训练假人") then
					TargetHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
					TargetHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
					Balance_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
					TargetHealthScale = TargetHealth / TargetHealthMax
				end
			
				if not WarriorOfEluneCD and IsPlayerSpell(Warrior_of_Elune_SpellID) and UnitAffectingCombat("player") and (not Balance_IsCanMovingCast(Starfire_SpellID) or PlayerPowerNow < 50) and not name3 and not name8 and LunarEmpowerment then
					DA_CastSpellByID(Warrior_of_Elune_SpellID, "player")
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("艾露恩的战士")
					--艾露恩的战士
				end

				if (UnitExists("boss1") and select(2, IsInInstance()) == "raid") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (TargetHealth and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 8.5 * SDPHR) then
					Balance_TargetHealthControl = nil
				else
					Balance_TargetHealthControl = 1
				end
				if not Balance_TargetHealthControl and not DirectSingleDPSItemCD and BalanceSaves.BalanceOption_Attack_AutoAccessories and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_AutoDPS_DPSTarget)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
						DA_UseItem(DirectSingleDPSItemID)
					end
					--使用单体伤害饰品
					Balance_CastSpellIng = 1
				end
		
				local start1, duration1 = DA_GetSpellCooldown(113)
				local start2, duration2 = DA_GetSpellCooldown(194223)
				if IsPlayerSpell(390378) then
				--学习了[轨道打击]天赋
					start2, duration2 = DA_GetSpellCooldown(383410)
				end
				if IsPlayerSpell(102560) then
				--学习了[化身：艾露恩之眷]天赋
					start2, duration2 = DA_GetSpellCooldown(102560)
				end
				if (UnitExists("boss1") and select(2, IsInInstance()) == "raid") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (TargetHealth and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 20 * SDPHR) then
					Balance_TargetHealthControl = nil
				else
					Balance_TargetHealthControl = 1
				end
				if duration2 == 0 and UnitAffectingCombat("player") and (IsPlayerSpell(194223) or IsPlayerSpell(102560)) and not name8 and not name9 and not ComeEclipse and ((not Balance_AutoDPS_SunfireTarget and (Balance_EnemyCount >= 2 or not C_PvP.IsActiveBattlefield())) or (Balance_EnemyCount >= 5 and C_PvP.IsActiveBattlefield())) and not Balance_TargetHealthControl and Balance_IsCanMovingCast(194223) and BalanceSaves.BalanceOption_Attack_AutoCelestialAlignment and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
					DA_CastSpellByName('超凡之盟')
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("超凡之盟")
				end
				--超凡之盟、化身：艾露恩之眷
			
				if not Balance_TargetHealthControl and UnitAffectingCombat("player") and IsPlayerSpell(Berserking_SpellID) and not IsStealthed() and PlayerPowerNow >= 40 and not BerserkingCD and Balance_AutoDPS_DPSTarget and BalanceSaves.BalanceOption_Attack_AutoAccessories and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and not Balance_ChannelSpellIng then
					DA_CastSpellByID(Berserking_SpellID)
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("狂暴(种族特长)")
				end
				--狂暴(种族特长)
				
				if not Balance_TargetHealthControl and PlayerPowerNow >= 40 and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
					Balance_UseAttributesEnhancedItem()
					--使用属性增强饰品
					Balance_UseConcoctionKissOfDeath()
					--[制剂：死亡之吻]
				end
			
				if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 7 * SDPHR) then
					Balance_TargetHealthControl = nil
				else
					Balance_TargetHealthControl = 1
				end
				if IsPlayerSpell(428731) then
					if not Balance_TargetHealthControl and not ForceOfNatureCD and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and IsPlayerSpell(Force_of_Nature_SpellID) and not Balance_NoUsePowerfulSpell and not IsStealthed() and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_CastSpellByID(Force_of_Nature_SpellID, "player")
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("自然之力")
					end
				end
				--自然之力
				
				if not Balance_TargetHealthControl and BalanceSaves.BalanceOption_Attack_AutoCovenant and (timeLeft14 >= 2 or ComeEclipse_EquippedBalanceOfAllThings or not IsPlayerSpell(394048)) and (not Balance_ManifestationOfPrideExists or Balance_EnemyCount >= 6) and not Balance_NoUsePowerfulSpell and not ConvokeTheSpiritsCD and IsPlayerSpell(Convoke_the_Spirits_SpellID) and not Balance_AutoDPS_SunfireTarget and not IsStealthed() and ((expires8 and expires8 - GetTime() > 5) or (expires9 and expires9 - GetTime() > 5)) and not DamagerEngine_NoCastingAuras and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng then
					Balance_UseAttributesEnhancedItem()
					--使用属性增强饰品
					Balance_UseConcoctionKissOfDeath()
					--[制剂：死亡之吻]
					DA_TargetUnit(Balance_AutoDPS_DPSTarget)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
						DA_CastSpellByName(DA_GetSpellInfo(Convoke_the_Spirits_SpellID))
					end
					Balance_CastSpellIng = 1
					Balance_ChannelSpellIng = 1
					C_Timer.After(0.75, function()
						Balance_ChannelSpellIng = nil
					end)
					Balance_SetDebugInfo("万灵之召")
				end
				--万灵之召
			
				if IsPlayerSpell(New_Moon_SpellID) then
					if Spell_NewMoon == "FullMoon" then
						--满月时
						if Balance_IsCanMovingCast("新月") and DA_GetSpellCharges(New_Moon_SpellID) > 0 and PlayerPowerVacancy >= 40 and ((timeLeft8 and timeLeft8 >= select(4, DA_GetSpellInfo("满月")) / 1000 + 0.1) or (timeLeft9 and timeLeft9 >= select(4, DA_GetSpellInfo("满月")) / 1000 + 0.1)) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 1.425 * SDPHR and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then	
							DA_TargetUnit(Balance_StarfireUnit)
							if UnitIsUnit('target', Balance_StarfireUnit) then
								DA_CastSpellByName("新月")
							end
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("新月")
						end
					else
						--非满月时
						if Balance_IsCanMovingCast("新月") and DA_GetSpellCharges(New_Moon_SpellID) > 0 and PlayerPowerVacancy >= 20 and not name14 and not DA_IsCastingSpell(274282) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
							DA_TargetUnit(Balance_AutoDPS_DPSTarget)
							if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
								DA_CastSpellByName("新月")
							end
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("新月")
						end
					end
				end
				--新月
			
				if UnitName('target') ~= '拉夏南' and not FuryOfEluneCD and IsPlayerSpell(Elune_Wrath_SpellID) and not Balance_TargetHealthControl and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and Balance_AutoDPS_DPSTarget and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and PlayerPowerVacancy > 20 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_AutoDPS_DPSTarget)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
						DA_CastSpellByID(Elune_Wrath_SpellID)
					end
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("艾露恩之怒")
				end
				--艾露恩之怒(单体)
				
				if Balance_AutoDPS_SunfireTarget and not Balance_AutoDPS_MoonfireTargetS and not Balance_CastSpellIng and not Balance_ChannelSpellIng and IsPlayerSpell(Sunfire_SpellID) then
					DA_TargetUnit(Balance_AutoDPS_SunfireTarget)
					if UnitIsUnit('target', Balance_AutoDPS_SunfireTarget) then
						DA_CastSpellByID(Sunfire_SpellID)
					end
					--阳炎术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("阳炎术")
				end
				if Balance_AutoDPS_MoonfireTarget and not Balance_AutoDPS_MoonfireTargetS and not Balance_AutoDPS_SunfireTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng and IsPlayerSpell(Moonfire_SpellID) then
					DA_TargetUnit(Balance_AutoDPS_MoonfireTarget)
					if UnitIsUnit('target', Balance_AutoDPS_MoonfireTarget) then
						DA_CastSpellByID(Moonfire_SpellID)
					end
					--月火术
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("月火术")
				end
			
				if not IsPlayerSpell(428731) then
					if not Balance_TargetHealthControl and not ForceOfNatureCD and IsPlayerSpell(Force_of_Nature_SpellID) and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_CastSpellByID(Force_of_Nature_SpellID, "player")
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("自然之力")
					end
				end
				--自然之力
			
				if not Balance_TargetHealthControl and not WildMushroomCD and IsPlayerSpell(Wild_Mushroom_SpellID) and not Balance_Casted_WildMushroom and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_WildMushroomTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					DA_TargetUnit(Balance_AutoDPS_WildMushroomTarget)
					if UnitIsUnit('target', Balance_AutoDPS_WildMushroomTarget) then
						DA_CastSpellByID(Wild_Mushroom_SpellID)
					end
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("野性蘑菇")
				end
				--野性蘑菇
				
				if Balance_EnemyCount < 2 then
					--非AOE模式
					if (name12 or name_TouchTheCosmos_Starfall) and IsPlayerSpell(Starfall_SpellID) and UnitAffectingCombat("player") and Balance_DA_IsUsableSpell(Starfall_SpellID) and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_CastSpellByID(Starfall_SpellID)
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星辰坠落")
					end
					--星辰坠落
					
					if IsPlayerSpell(202430) then
						StarsurgeHealthControl = 2.85 * SDPHR
					else
						StarsurgeHealthControl = 4.25 * SDPHR
					end
					if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (TargetHealth and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * StarsurgeHealthControl) or #DamagerEngine_DamagerAssigned <= 3 then
						Balance_TargetHealthControl = nil
					else
						Balance_TargetHealthControl = 1
					end
					if (PlayerPowerNow > 80 or timeLeft14 > 1 or name11 or name_TouchTheCosmos_Starsurge or (ComeEclipse and PlayerPowerNow > 80) or ComeEclipse_EquippedBalanceOfAllThings or not Balance_IsCanMovingCast(Starfire_SpellID) or DamagerEngine_NoCastingAuras) 
					--能量大于80,或万物平衡BUFF时间大于1秒,或者星涌术不消耗能量,或即将进入日月蚀且能量大于80,或即将获得万物平衡BUFF,或者在移动中,或者存在不读条的状态
					and ((ComeEclipse or name8 or name9) or not Balance_IsCanMovingCast(Starfire_SpellID) or DamagerEngine_NoCastingAuras) 
					--即将进入日月蚀,或日蚀状态,或月蚀状态,或者在移动中,或者存在不读条的状态
					and ((not Balance_NeedMovingCast() and not NeedMovingCastWill) or PlayerPowerNow > 80) 
					and Balance_DA_IsUsableSpell(Starsurge_SpellID) and UnitAffectingCombat("player") and IsPlayerSpell(Starsurge_SpellID) and not Balance_TargetHealthControl and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByID(Starsurge_SpellID)
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星涌术")
					end
					--星涌术
			
					if not Balance_TargetHealthControl and Balance_IsCanMovingCast(Stellar_Flare_SpellID) and IsPlayerSpell(Stellar_Flare_SpellID) and not Balance_Casted_StellarFlare and not DA_IsCastingSpell(Stellar_Flare_SpellID) and timeLeft14 <= 1 and not ComeEclipse_EquippedBalanceOfAllThings and not IsStealthed() and Balance_AutoDPS_StellarFlareTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_StellarFlareTarget)
						if UnitIsUnit('target', Balance_AutoDPS_StellarFlareTarget) then
							DA_CastSpellByID(Stellar_Flare_SpellID)
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星辰耀斑")
					end
					--星辰耀斑
					
					if (Balance_IsCanMovingCast(Starfire_SpellID) or name3 or name13) and not SolarEmpowerment and IsPlayerSpell(Starfire_SpellID) and (LunarEmpowerment or (expires9 and expires9 - GetTime() > 2 and not name8) or name3 or (name13 and not Balance_IsCanMovingCast(Wrath_SpellID))) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_AutoDPS_DPSTarget, 8.5) and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByID(Starfire_SpellID)
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星火术")
					end
					--星火术
				
					if Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and (((SolarEmpowerment or (expires8 and expires8 - GetTime() > 1.5)) or (PlayerPowerNow < Balance_StarsurgePower and not name9)) or Balance_TargetHealthControl) and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("愤怒")
					end
					--愤怒
				else
					--AOE模式
					if IsPlayerSpell(202430) then
						StarsurgeHealthControl = 2.85 * SDPHR
					else
						StarsurgeHealthControl = 4.25 * SDPHR
					end
					if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (TargetHealth and TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * StarsurgeHealthControl) or #DamagerEngine_DamagerAssigned <= 3 then
						Balance_TargetHealthControl = nil
					else
						Balance_TargetHealthControl = 1
					end
					
					if IsPlayerSpell(Starfall_SpellID) and UnitAffectingCombat("player") and Balance_DA_IsUsableSpell(Starfall_SpellID) and not Balance_TargetHealthControl and (name8 or name9 or ComeEclipse_EquippedBalanceOfAllThings) and ((Balance_Enemy_SumHealth and Balance_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_CastSpellByID(Starfall_SpellID)
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星辰坠落")
					end
					--星辰坠落
					
					if (name11 or name_TouchTheCosmos_Starsurge) and (ComeEclipse or name8 or name9) 
					--星涌术不消耗星界能量且即将进入日月蚀,或日蚀状态,或月蚀状态
					and Balance_DA_IsUsableSpell(Starsurge_SpellID) and UnitAffectingCombat("player") and IsPlayerSpell(Starsurge_SpellID) and not Balance_TargetHealthControl and Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_CastSpellByID(Starsurge_SpellID)
						end
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("星涌术")
					end
					--星涌术
				
					if not Balance_TargetHealthControl and not DirectAoeDPSItemCD and BalanceSaves.BalanceOption_Attack_AutoAccessories and Balance_AutoDPS_DPSTarget and not Balance_ChannelSpellIng then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
							DA_UseItem(DirectAoeDPSItemID)
						end
						--使用AOE伤害饰品
						Balance_CastSpellIng = 1
					end
					
					if IsPlayerSpell(279620) then
					--[双月]天赋
						if ((Balance_UnitWithAttackUnitDecide(Balance_AutoDPS_DPSTarget, 8.5) >= 2 or name3 or name9 or name13) or (timeLeft10 < 4.5 and PlayerPowerNow < 15) or (timeLeft10 < 2.5 and PlayerPowerNow < 30)) then
							if Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and not LunarEmpowerment and (SolarEmpowerment or (expires8 and expires8 - GetTime() > 1.5)) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
								DA_TargetUnit(Balance_AutoDPS_DPSTarget)
								if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
									DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
								end
								--愤怒
								Balance_CastSpellIng = 1
								Balance_SetDebugInfo("愤怒")
							elseif (Balance_IsCanMovingCast(Starfire_SpellID) or name3 or name13) and not SolarEmpowerment and IsPlayerSpell(Starfire_SpellID) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
								DA_TargetUnit(Balance_StarfireUnit)
								if UnitIsUnit('target', Balance_StarfireUnit) then
									DA_CastSpellByID(Starfire_SpellID)
								end
								--星火术
								Balance_CastSpellIng = 1
								Balance_SetDebugInfo("星火术")
							elseif Balance_IsCanMovingCast(Wrath_SpellID) and name8 and IsPlayerSpell(Wrath_SpellID) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
								DA_TargetUnit(Balance_AutoDPS_DPSTarget)
								if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
									DA_CastSpellByID(Wrath_SpellID)
								end
								--愤怒
								Balance_CastSpellIng = 1
								Balance_SetDebugInfo("愤怒")
							end
						elseif IsPlayerSpell(Moonfire_SpellID) and Balance_AutoDPS_DPSTarget2 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
							DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
							if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
								DA_CastSpellByID(Moonfire_SpellID)
							end
							--月火术
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("月火术")
						end
					else
						if Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and not LunarEmpowerment and (SolarEmpowerment or (expires8 and expires8 - GetTime() > 1.5)) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
							DA_TargetUnit(Balance_AutoDPS_DPSTarget)
							if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
								DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
							end
							--愤怒
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("愤怒")
						elseif (Balance_IsCanMovingCast(Starfire_SpellID) or name3 or name13) and not SolarEmpowerment and IsPlayerSpell(Starfire_SpellID) and not Balance_UnitWithNoAttackAurasUnitDecide(Balance_StarfireUnit, 8.5) and not Balance_AutoDPS_SunfireTarget and Balance_StarfireUnit and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
							DA_TargetUnit(Balance_StarfireUnit)
							if UnitIsUnit('target', Balance_StarfireUnit) then
								DA_CastSpellByID(Starfire_SpellID)
							end
							--星火术
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("星火术")
						elseif Balance_IsCanMovingCast(Wrath_SpellID) and name8 and IsPlayerSpell(Wrath_SpellID) and not Balance_AutoDPS_SunfireTarget and Balance_AutoDPS_DPSTarget and not DamagerEngine_NoCastingAuras and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
							DA_TargetUnit(Balance_AutoDPS_DPSTarget)
							if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
								DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
							end
							--愤怒
							Balance_CastSpellIng = 1
							Balance_SetDebugInfo("愤怒")
						end
					end
				end
				
				if Balance_AutoDPS_DPSTarget2 and not Balance_CastSpellIng and not Balance_ChannelSpellIng then
					if Balance_EnemyCount >= 2 and IsPlayerSpell(Sunfire_SpellID) then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
							DA_CastSpellByID(Sunfire_SpellID)
						end
						--阳炎术
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("阳炎术")
					elseif IsPlayerSpell(Moonfire_SpellID) then
						DA_TargetUnit(Balance_AutoDPS_DPSTarget2)
						if UnitIsUnit('target', Balance_AutoDPS_DPSTarget2) then
							DA_CastSpellByID(Moonfire_SpellID)
						end
						--月火术
						Balance_CastSpellIng = 1
						Balance_SetDebugInfo("月火术")
					end
				end
				--移动状态DOT
				
				if Balance_AutoDPS_DPSTarget and not Balance_CastSpellIng and not Balance_ChannelSpellIng and Balance_IsCanMovingCast(Wrath_SpellID) and IsPlayerSpell(Wrath_SpellID) and not DamagerEngine_NoCastingAuras then
				--所有施法判断不通过时
					DA_TargetUnit(Balance_AutoDPS_DPSTarget)
					if UnitIsUnit('target', Balance_AutoDPS_DPSTarget) then
						DA_CastSpellByName(DA_GetSpellInfo(Wrath_SpellID))
					end
					Balance_CastSpellIng = 1
					Balance_SetDebugInfo("愤怒")
				end
				--愤怒
				
			end
		end
		
		if BalanceSaves.BalanceOption_Other_ShowDebug then
			Balance_DeBugEnemyCount:SetText(Balance_EnemyCount)
			if Balance_EnemyCount == 0 then
				Balance_DeBugEnemyCount:Hide()
			else
				Balance_DeBugEnemyCount:Show()
			end
			if not Balance_CastSpellIng and not Balance_ChannelSpellIng then
				Balance_DeBugSpellIcon:Hide()
			else
				Balance_DeBugSpellIcon:Show()
			end
		else
			Balance_DeBugEnemyCount:Hide()
			Balance_DeBugSpellIcon:Hide()
		end
	end
	
end

function Balance_GetTankAssignedDead()
	--获取阵亡的坦克
	local UnitID = nil
	if DamagerEngine_TankAssignedDead and #DamagerEngine_TankAssignedDead > 0 then
		for k, v in ipairs(DamagerEngine_TankAssignedDead) do
			UnitID = v.Unit
			break
		end
	end
	return UnitID
end

function Balance_GetHealerAssignedDead()
	--获取阵亡的治疗
	local UnitID = nil
	if DamagerEngine_HealerAssignedDead and #DamagerEngine_HealerAssignedDead > 0 then
		for k, v in ipairs(DamagerEngine_HealerAssignedDead) do
			UnitID = v.Unit
			break
		end
	end
	return UnitID
end

function Balance_GetDamagerAssignedDead()
	--获取阵亡的伤害输出
	local UnitID = nil
	if DamagerEngine_DamagerAssignedDead and #DamagerEngine_DamagerAssignedDead > 0 then
		for k, v in ipairs(DamagerEngine_DamagerAssignedDead) do
			UnitID = v.Unit
			break
		end
	end
	return UnitID
end

function Balance_IsCanMovingCast(spellID)
	--获取是否可以成功移动读条
	--if (not EWT and HackEnabled("MovingCast")) or (EWT and IsHackEnabled("MovingCast")) then return true end
	local name, rank, icon, castingTime = DA_GetSpellInfo(spellID)
	--获取技能施法时间
	castingTime = castingTime and castingTime / 1000 or 2
	local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('星辰坠落', "player", "HELPFUL")
	--星辰坠落
	if (not IsPlayerMoving() and not IsFalling()) or (IsPlayerSpell(197073) and name1 and expires1 and expires1 - GetTime() > castingTime + 0.2) or (spellID == Starfire_SpellID and AuraUtil.FindAuraByName('月蚀', "player", "HELPFUL") and (AuraUtil.FindAuraByName('艾露恩的战士', "player", "HELPFUL") or AuraUtil.FindAuraByName('枭兽狂怒', "player", "HELPFUL"))) then	
		--print(name.." "..castingTime.." true")
		return true
	else
		--print(name.." "..castingTime.." false")
		return false
	end
end

function Balance_NeedMovingCast()
	--获取是否需要移动施法(星辰漂流天赋)
	--if (not EWT and HackEnabled("MovingCast")) or (EWT and IsHackEnabled("MovingCast")) then return false end
	if NeedMovingCastWill and PlayerPowerScale >= 0.9 then
	--为避免DBM提示了技能,但实际没有施放技能,导致NeedMovingCastWill不归零,因此设置能量大于90%时,取消即将施放移动施法技能状态
		C_Timer.After(5, function()
			NeedMovingCastWill = nil
		end)
	end
	if IsPlayerSpell(197073) then
	
		local NeedMovingCast = nil
		
		local BuffCache = {
			--{Name = "愈合", ID = Regrowth_SpellID, Instance = "愈合-测试"}, 
		}
		
		local DebuffCache = {
			--{Name = "昏睡", ID = 81075, Instance = "菲拉斯-加德米尔噩梦龙人-测试"}, 
			{Name = "下冲气流", ID = 220855, Instance = "黑心林地-德萨隆"}, 
			{Name = "无尽寒冬", ID = 227806, Instance = "卡拉赞-麦迪文之影"}, 
			{Name = "灵魂回响", ID = 194966, Instance = "黑鸦堡垒-融合之魂"}, 
			{Name = "眼棱", ID = 197687, Instance = "黑鸦堡垒-伊莉萨娜·拉文凯斯"}, 
			{Name = "攫取裂隙", ID = 323825, Instance = "伤逝剧场-无尽女皇莫德蕾莎"}, 
			{Name = "病态凝视", ID = 338606, Instance = "通灵战潮-小怪"}, 
			{Name = "病态凝视", ID = 343556, Instance = "通灵战潮-外科医生缝肉"}, 
		}
		
		local CastSpell = {
			{Name = "下冲气流", ID = 199345, Instance = "黑心林地-德萨隆"}, 
			{Name = "折射罪光", ID = 322711, Instance = "赎罪大厅-哈尔吉亚斯"}, 
			{Name = "唤石", ID = 319733, Instance = "赎罪大厅-艾谢朗"}, 
			{Name = "彗星风暴", ID = 320772, Instance = "通灵战潮-缚霜者纳尔佐"}, 
			{Name = "软肉碎击", ID = 318406, Instance = "伤逝剧场-斩血"}, 
			{Name = "攫取裂隙", ID = 323685, Instance = "伤逝剧场-无尽女皇莫德蕾莎"}, 
			{Name = "加速孵化", ID = 322550, Instance = "塞兹仙林的迷雾-特雷德奥瓦"}, 
			{Name = "无尽的折磨", ID = 326039, Instance = "赤红深渊-大学监贝律莉娅"}, 
		}
		
		local ChannelSpell = {
			{Name = "毁灭", ID = 207631, Instance = "暗夜要塞-崔利艾克斯"}, 
			{Name = "折射罪光", ID = 322711, Instance = "赎罪大厅-哈尔吉亚斯"}, 
			{Name = "彗星风暴", ID = 320772, Instance = "通灵战潮-缚霜者纳尔佐"}, 
			{Name = "凝结", ID = 334970, Instance = "彼界-穆厄扎拉"}, 
			{Name = "无尽的折磨", ID = 326039, Instance = "赤红深渊-大学监贝律莉娅"}, 
		}
		
	
		BalanceCycleFrame.DBM = BalanceCycleFrame.DBM or {}

		function BalanceCycleFrame.DBM:getBars()
			if DBM then
				if not BalanceCycleFrame.DBM.Timer then
					BalanceCycleFrame.DBM.Timer = {}
				else
					wipe(BalanceCycleFrame.DBM.Timer)
				end

				for bar in pairs(DBT.bars) do
					--"DBM-StatusBarTimers\DBT.lua"   function DBT:CreateBar(timer, id, icon, huge, small, color, isDummy, colorType, inlineIcon, keep, fade, countdown, countdownMax)
					--colorType:(1-小怪入场, 2-AOE, 3-点名技能, 4-打断, 5-剧情, 6-阶段转换, 7-自定义)
					local number = tonumber(string.match(bar.id ,"%d+"))
					local timer = tonumber(string.format("%.1f", bar.timer))
					if (number and number > 100) or not number then
						if not number then number = '无' end
						--print('DBM:'..bar.id..' '..DA_GetSpellLink(number).." 技能ID:"..number.." 剩余时间:"..timer.."秒 类型:"..bar.colorType)
						table.insert(BalanceCycleFrame.DBM.Timer, {id = bar.id, timer = timer, spellid = number, Type = bar.colorType})
					end
				end
			end
		end

		function BalanceCycleFrame.DBM:getAoe()
			if DBM then
				BalanceCycleFrame.DBM:getBars()
				for i = 1, #BalanceCycleFrame.DBM.Timer do
					if BalanceCycleFrame.DBM.Timer[i].spellid then
						local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(BalanceCycleFrame.DBM.Timer[i].spellid)
						if not castingTime then
							castingTime = 0
						else
							castingTime = castingTime / 1000
						end
						Balance_DBMControlTime = 7.5 - castingTime
						if BalanceCycleFrame.DBM.Timer[i].timer and BalanceCycleFrame.DBM.Timer[i].timer < Balance_DBMControlTime then
							for ii = 1, #BuffCache do
								if spellID == BuffCache[ii].ID then
									--print(DA_GetSpellInfo(spellID).." ID:"..spellID.." 剩余时间:"..BalanceCycleFrame.DBM.Timer[i].timer)
									NeedMovingCast = 1
									NeedMovingCastWill = 1
									break
								end
							end
							for ii = 1, #DebuffCache do
								if spellID == DebuffCache[ii].ID then
									--print(DA_GetSpellInfo(spellID).." ID:"..spellID.." 剩余时间:"..BalanceCycleFrame.DBM.Timer[i].timer)
									NeedMovingCast = 1
									NeedMovingCastWill = 1
									break
								end
							end
							for ii = 1, #CastSpell do
								if spellID == CastSpell[ii].ID then
									--print(DA_GetSpellInfo(spellID).." ID:"..spellID.." 剩余时间:"..BalanceCycleFrame.DBM.Timer[i].timer)
									NeedMovingCast = 1
									NeedMovingCastWill = 1
									break
								end
							end
							for ii = 1, #ChannelSpell do
								if spellID == ChannelSpell[ii].ID then
									--print(DA_GetSpellInfo(spellID).." ID:"..spellID.." 剩余时间:"..BalanceCycleFrame.DBM.Timer[i].timer)
									NeedMovingCast = 1
									NeedMovingCastWill = 1
									break
								end
							end
						end
					end
				end
			end
		end
		BalanceCycleFrame.DBM:getAoe()
		
		local index1 = 1
		while true do
			local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = DA_UnitBuff("player", index1)
			if not spellID1 then
				break
			end
			for i=1, #BuffCache do
				if spellID1 == BuffCache[i].ID then
					NeedMovingCast = 1
					NeedMovingCastWill = nil
					break
				end
			end
			index1 = index1 + 1
		end
		--Buff
		
		local index2 = 1
		while true do
			local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = DA_UnitDebuff("player", index2)
			if not spellID1 then
				break
			end
			for i=1, #DebuffCache do
				if spellID1 == DebuffCache[i].ID then
					NeedMovingCast = 1
					NeedMovingCastWill = nil
					break
				end
			end
			index2 = index2 + 1
		end
		--DeBuff
		
		for k, v in ipairs(CastSpell) do
			bossspellname1 = UnitCastingInfo("boss1")
			bossspellname2 = UnitCastingInfo("boss2")
			bossspellname3 = UnitCastingInfo("boss3")
			bossspellname4 = UnitCastingInfo("boss4")
			bossspellname5 = UnitCastingInfo("boss5")
			bossspellname6 = UnitCastingInfo("boss6")
			bossspellname7 = UnitCastingInfo("boss7")
			if bossspellname1 == v.Name or bossspellname2 == v.Name or bossspellname3 == v.Name or bossspellname4 == v.Name or bossspellname5 == v.Name or bossspellname6 == v.Name or bossspellname7 == v.Name then
				NeedMovingCast = 1
				NeedMovingCastWill = nil
				break
			end
		end
		--BOSS读条技能
		
		for k, v in ipairs(ChannelSpell) do
			bossspellname1 = UnitChannelInfo("boss1")
			bossspellname2 = UnitChannelInfo("boss2")
			bossspellname3 = UnitChannelInfo("boss3")
			bossspellname4 = UnitChannelInfo("boss4")
			bossspellname5 = UnitChannelInfo("boss5")
			bossspellname6 = UnitChannelInfo("boss6")
			bossspellname7 = UnitChannelInfo("boss7")
			if bossspellname1 == v.Name or bossspellname2 == v.Name or bossspellname3 == v.Name or bossspellname4 == v.Name or bossspellname5 == v.Name or bossspellname6 == v.Name or bossspellname7 == v.Name then
				NeedMovingCast = 1
				NeedMovingCastWill = nil
				break
			end
		end
		--BOSS引导技能
		
		if NeedMovingCast == 1 then
			return true
		else
			return false
		end
	end
end

function Balance_DA_IsUsableSpell(spellID)
	--是否可以施放法术(增加星界能量预判)
	if spellID == Starfall_SpellID then
	--星辰坠落
		if (PlayerPowerNow and PlayerPowerNow >= C_Spell.GetSpellPowerCost(Starfall_SpellID)[1].cost) or AuraUtil.FindAuraByName('织星者的经纱', "player", "HELPFUL") or select(10, AuraUtil.FindAuraByName('浩瀚之触', "player", "HELPFUL")) == 450361 then
			return true
		else
			return false
		end
	elseif spellID == Starsurge_SpellID then
	--星涌术
		if (PlayerPowerNow and PlayerPowerNow >= Balance_StarsurgePower) or AuraUtil.FindAuraByName('织星者的纬纱', "player", "HELPFUL") or select(10, AuraUtil.FindAuraByName('浩瀚之触', "player", "HELPFUL")) == 450360 then
			return true
		else
			return false
		end
	else
		if DA_IsUsableSpell(spellID) then
			return true
		else
			return false
		end
	end
end

function Balance_GetTargetNotVisible(Unit)
	--判断目标是否在视野中
	if Balance_TargetNotVisible then
		for k, v in ipairs(Balance_TargetNotVisible) do
			if v == UnitGUID(Unit) then
				--print(UnitName(Unit).." :不在视野中")
				return true
			end
		end
	end
end

function Balance_FindEnemy()
	--遍历附近敌对目标
	if WoWAssistantUnlocked then
		if UnitAffectingCombat("player") or (Balance_EnemyCacheHasThreat and #Balance_EnemyCacheHasThreat > 0) then
			--战斗中
			Balance_FindEnemyControlTime = tonumber(BalanceSaves.TraversalObjectInterval)
		else
			--非战斗
			if BalanceSaves.BalanceOption_TargetFilter == 3 then
				Balance_FindEnemyControlTime = tonumber(BalanceSaves.TraversalObjectInterval)
			else
				Balance_FindEnemyControlTime = tonumber(BalanceSaves.TraversalObjectInterval) * 4
			end
		end
		if Balance_FindEnemyControlTime < 0.1 then
			Balance_FindEnemyControlTime = 0.1
		end
		if (Balance_FindEnemyIntervalTime and GetTime() - Balance_FindEnemyIntervalTime > Balance_FindEnemyControlTime) or not Balance_FindEnemyIntervalTime then
			Balance_FindEnemyIntervalTime = GetTime()
			
			Balance_EnemyCache = {}
			
			if GetObjectCount() > 0 then
				local MX,MY,MZ = ObjectPosition("player")
				for i = 1, GetObjectCount() do
					local thisUnit = GetObjectWithIndex(i)
					if UnitExists(thisUnit) and UnitCreatureType(thisUnit) ~= "小动物" and UnitCreatureType(thisUnit) ~= "野生宠物" and UnitIsVisible(thisUnit) then
						local X1,Y1,Z1 = ObjectPosition(thisUnit)
						if DA_GetNovaDistance("player", thisUnit) < 75 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then			
							if math.abs(MZ - Z1) < 10 or DA_GetLineOfSight("player", thisUnit) then
								--排除与玩家高度坐标相差10以上且不在视野中的单位
								table.insert(Balance_EnemyCache, {
									Unit = thisUnit, 
									UnitName = UnitName(thisUnit), 
									UnitGUID = UnitGUID(thisUnit), 
									UnitHealth = UnitHealth(thisUnit),
									UnitHealthMax = UnitHealthMax(thisUnit),
									UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									UnitPositionX = X1,
									UnitPositionY = Y1,
									UnitPositionZ = Z1,
								}) --75码内所有敌对目标写入表格
							end
						end
					end
				end
			end
		end
	end
end

function Balance_FindEnemyInEnemyCache()
	--从Balance_EnemyCache遍历附近可攻击的敌对目标
	
	Balance_Enemy_SumHealth = 0
	Balance_Enemy_SumHealthMax = 0
	Balance_Enemy_SumHealthScale = 0
	
	Balance_Heals_SumHealthTank = 0
	Balance_Heals_SumHealthMaxTank = 0
	Balance_Heals_SumHealthScaleTank = 1
	Balance_Heals_SumHealthHealer = 0
	Balance_Heals_SumHealthMaxHealer = 0
	Balance_Heals_SumHealthScaleHealer = 1
	Balance_Heals_SumHealthDamager = 0
	Balance_Heals_SumHealthMaxDamager = 0
	Balance_Heals_SumHealthScaleDamager = 1
	
	Balance_EnemyCacheS = {}
	Balance_EnemyCacheS2 = {}
	Balance_EnemyCacheS3 = {}
	Balance_EnemyCacheHasThreat = {}
	Balance_EnemyCacheHasThreatIn5 = {}
	Balance_EnemyCacheHasThreatIn7 = {}
	Balance_EnemyCacheHasThreatInMelee = {}
	
	DamagerEngine_GroupMember = {}
	DamagerEngine_TankAssigned = {}
	DamagerEngine_HealerAssigned = {}
	DamagerEngine_DamagerAssigned = {}
	DamagerEngine_TankAssignedDead = {}
	DamagerEngine_HealerAssignedDead = {}
	DamagerEngine_DamagerAssignedDead = {}
	
	if IsInRaid() then
		--团队
		for i=1, GetNumGroupMembers() do
			unitid = "raid"..i
			DamagerEngine_GetPosition(unitid)
			--职责监测
		end
	elseif IsInGroup() then
		--小队
		for i=1, GetNumGroupMembers() - 1 do
			unitid = "party"..i
			DamagerEngine_GetPosition(unitid)
			--职责监测
		end
		unitid = "player"
		DamagerEngine_GetPosition(unitid)
		--职责监测
	else
		unitid = "player"
		DamagerEngine_GetPosition(unitid)
		--职责监测
	end
	
	if #DamagerEngine_GroupMember > 0 then
		table.sort(DamagerEngine_GroupMember, function(a, b) return a.UnitHealthScale < b.UnitHealthScale end)
		--队友血量按比例从低到高排序
	end
	if #DamagerEngine_HealerAssigned > 0 then
		table.sort(DamagerEngine_HealerAssigned, function(a, b) return a.UnitPower < b.UnitPower end)
		--治疗按蓝量从低到高排序
	end
	
	if #DamagerEngine_TankAssigned > 0 then
		--坦克血量信息
		for k, v in ipairs(DamagerEngine_TankAssigned) do
			Balance_Heals_SumHealthTank = Balance_Heals_SumHealthTank + v.UnitHealth
			Balance_Heals_SumHealthMaxTank = Balance_Heals_SumHealthMaxTank + v.UnitHealthMax
		end
		Balance_Heals_SumHealthScaleTank = Balance_Heals_SumHealthTank / Balance_Heals_SumHealthMaxTank
		--print("坦克总剩余血量: "..Balance_Heals_SumHealthTank)
		--print("坦克总血量: "..Balance_Heals_SumHealthMaxTank)
		--print("坦克总血量比例: "..Balance_Heals_SumHealthScaleTank)
	end
	if #DamagerEngine_HealerAssigned > 0 then
		--治疗血量信息
		for k, v in ipairs(DamagerEngine_HealerAssigned) do
			Balance_Heals_SumHealthHealer = Balance_Heals_SumHealthHealer + v.UnitHealth
			Balance_Heals_SumHealthMaxHealer = Balance_Heals_SumHealthMaxHealer + v.UnitHealthMax
		end
		Balance_Heals_SumHealthScaleHealer = Balance_Heals_SumHealthHealer / Balance_Heals_SumHealthMaxHealer
		--print("治疗总剩余血量: "..Balance_Heals_SumHealthHealer)
		--print("治疗总血量: "..Balance_Heals_SumHealthMaxHealer)
		--print("治疗总血量比例: "..Balance_Heals_SumHealthScaleHealer)
	end
	if #DamagerEngine_DamagerAssigned > 0 then
		--伤害输出血量信息
		for k, v in ipairs(DamagerEngine_DamagerAssigned) do
			Balance_Heals_SumHealthDamager = Balance_Heals_SumHealthDamager + v.UnitHealth
			Balance_Heals_SumHealthMaxDamager = Balance_Heals_SumHealthMaxDamager + v.UnitHealthMax
		end
		Balance_Heals_SumHealthScaleDamager = Balance_Heals_SumHealthDamager / Balance_Heals_SumHealthMaxDamager
		--print("伤害输出总剩余血量: "..Balance_Heals_SumHealthDamager)
		--print("伤害输出总血量: "..Balance_Heals_SumHealthMaxDamager)
		--print("伤害输出总血量比例: "..Balance_Heals_SumHealthScaleDamager)
	end
	--获取治疗目标总体血量信息
	
	if not WoWAssistantUnlocked then
		Balance_EnemyCache = {}
		Balance_ControlEnemyCache = {}
		if IsActiveBattlefieldArena() then
		--竞技场中
			for ism = 1, 5 do
				local thisUnit = "arena"..ism
				if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) then
					if UnitExists(thisUnit) and UnitCreatureType(thisUnit) ~= "小动物" and UnitCreatureType(thisUnit) ~= "野生宠物" and UnitIsVisible(thisUnit) then
						if DA_IsSpellInRange(Moonfire_SpellID, thisUnit) == 1 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then
							if not DA_UnitIsInTable(UnitGUID(thisUnit), Balance_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
								--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
								table.insert(Balance_ControlEnemyCache, {
									Unit = thisUnit, 
									UnitName = UnitName(thisUnit), 
									UnitGUID = UnitGUID(thisUnit), 
									UnitHealth = UnitHealth(thisUnit),
									UnitHealthMax = UnitHealthMax(thisUnit),
									UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
								}) --需要控制的特定目标写入表格
							end
							if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
							--战场中只将玩家目标列入表格
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Balance_EnemyCache) then
									table.insert(Balance_EnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									}) --所有敌对的目标写入表格
								end
							end
						end
					end
				end
			end
		else
		--非竞技场中
			for k, v in ipairs(DamagerEngine_GroupMember) do
				local thisUnit = v.Unit.."target"
				if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) then
					if UnitExists(thisUnit) and UnitCreatureType(thisUnit) ~= "小动物" and UnitCreatureType(thisUnit) ~= "野生宠物" and UnitIsVisible(thisUnit) then
						if DA_IsSpellInRange(Moonfire_SpellID, thisUnit) == 1 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then
							if not DA_UnitIsInTable(UnitGUID(thisUnit), Balance_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
								--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
								table.insert(Balance_ControlEnemyCache, {
									Unit = thisUnit, 
									UnitName = UnitName(thisUnit), 
									UnitGUID = UnitGUID(thisUnit), 
									UnitHealth = UnitHealth(thisUnit),
									UnitHealthMax = UnitHealthMax(thisUnit),
									UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
								}) --需要控制的特定目标写入表格
							end
							if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
							--战场中只将玩家目标列入表格
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Balance_EnemyCache) then
									table.insert(Balance_EnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									}) --所有敌对的目标写入表格
								end
							end
						end
					end
				end
			end
			for ism = 1, 10 do
				if _G["NamePlate"..ism] and _G["NamePlate"..ism].UnitFrame and _G["NamePlate"..ism].UnitFrame.unit then
					local thisUnit = _G["NamePlate"..ism].UnitFrame.unit
					if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) then
						if UnitExists(thisUnit) and UnitCreatureType(thisUnit) ~= "小动物" and UnitCreatureType(thisUnit) ~= "野生宠物" and UnitIsVisible(thisUnit) then
							if DA_IsSpellInRange(Moonfire_SpellID, thisUnit) == 1 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Balance_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
									--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
									table.insert(Balance_ControlEnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
										UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
									}) --需要控制的特定目标写入表格
								end
								if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
								--战场中只将玩家目标列入表格
									if not DA_UnitIsInTable(UnitGUID(thisUnit), Balance_EnemyCache) then
										table.insert(Balance_EnemyCache, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
										}) --所有敌对的目标写入表格
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	for k, v in ipairs(Balance_EnemyCache) do
		if UnitExists(v.Unit) and UnitIsVisible(v.Unit) then
			local X1,Y1,Z1 = 0, 0, 0
			if WoWAssistantUnlocked then
				X1,Y1,Z1 = ObjectPosition(v.Unit)
			end
			local status = UnitThreatSituation("player", v.Unit)
			local red, green, blue, alpha = UnitSelectionColor(v.Unit)
			v.Unit = v.Unit
			v.UnitName = UnitName(v.Unit)
			v.UnitGUID = UnitGUID(v.Unit)
			v.UnitHealth = UnitHealth(v.Unit)
			v.UnitHealthMax = UnitHealthMax(v.Unit)
			v.UnitHealthScale = UnitHealth(v.Unit)/UnitHealthMax(v.Unit)
			v.UnitPositionX = X1
			v.UnitPositionY = Y1
			v.UnitPositionZ = Z1
			--重新获取Balance_EnemyCache表中单位状态
			if not DamagerEngineGetIgnoreUnit(v.Unit) and not Balance_GetTargetNotVisible(v.Unit) and DA_GetTargetCanAttack(v.Unit, 5221) then
				--排除忽略的目标、不在视野中的目标外的可攻击目标
				
				if (((status and UnitAffectingCombat(v.Unit)) 
				--单位有仇恨且在战斗中
				or DamagerEngineGetNoThreatUnit(v.Unit) 
				--单位是无仇恨类特殊目标
				or (UnitIsPlayer(v.Unit..'target') and IsInInstance()) 
				--单位的目标是玩家且在副本中
				or (v.UnitGUID == Balance_FindEnemyCombatLogUnitGUID and not DamagerEngineGetIgnoreUnit(v.Unit) and not Balance_GetTargetNotVisible(v.Unit)) 
				--单位是队友攻击的目标
				or (BalanceSaves.BalanceOption_TargetFilter == 3 and not UnitIsTapDenied(v.Unit) and green == 0)) 
				--所有目标模式且单位不是灰名且单位是红名
				and ((not UnitIsPlayer(v.Unit) and not UnitPlayerControlled(v.Unit)) or (IsInInstance() and not C_PvP.IsActiveBattlefield())))
				--以上所有判断都要符合:单位不是玩家和玩家控制的单位，副本中除外(避免不攻击被心灵控制的目标)
				or (UnitIsPlayer(v.Unit) and C_PvP.IsActiveBattlefield())
				--单位是玩家且在战场/竞技场中
				or DA_UnitIsInTable(v.UnitGUID, Balance_FindEnemyCombatLogAttackMeUnitCache) then
				--单位是攻击我的目标
					table.insert(Balance_EnemyCacheHasThreatInMelee, {
						Unit = v.Unit,
						UnitName = v.UnitName,
						UnitGUID = v.UnitGUID,
						UnitHealth = v.UnitHealth,
						UnitHealthMax = v.UnitHealthMax,
						UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
						UnitPositionX = v.UnitPositionX,
						UnitPositionY = v.UnitPositionY,
						UnitPositionZ = v.UnitPositionZ,
					}) --近战范围内可攻击目标写入表格
				end
			end
			if not DamagerEngineGetIgnoreUnit(v.Unit) and not Balance_GetTargetNotVisible(v.Unit) and DA_GetTargetCanAttack(v.Unit, Moonfire_SpellID) then
				--排除忽略的目标、不在视野中的目标外的可攻击目标
				if DA_IsSpecialEnemy(v.Unit) then
					--特殊敌对目标,不计入AOE目标数量
					table.insert(Balance_EnemyCacheS, {
						Unit = v.Unit,
						UnitName = v.UnitName,
						UnitGUID = v.UnitGUID,
						UnitHealth = v.UnitHealth,
						UnitHealthMax = v.UnitHealthMax,
						UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
						UnitPositionX = v.UnitPositionX,
						UnitPositionY = v.UnitPositionY,
						UnitPositionZ = v.UnitPositionZ,
					}) --特殊敌对目标写入表格
				else
					if (((status and UnitAffectingCombat(v.Unit)) 
					--单位有仇恨且在战斗中
					or DamagerEngineGetNoThreatUnit(v.Unit) 
					--单位是无仇恨类特殊目标
					or (UnitIsPlayer(v.Unit..'target') and IsInInstance()) 
					--单位的目标是玩家且在副本中
					or (v.UnitGUID == Balance_FindEnemyCombatLogUnitGUID and not DamagerEngineGetIgnoreUnit(v.Unit) and not Balance_GetTargetNotVisible(v.Unit)) 
					--单位是队友攻击的目标
					or (BalanceSaves.BalanceOption_TargetFilter == 3 and not UnitIsTapDenied(v.Unit) and green == 0)) 
					--所有目标模式且单位不是灰名且单位是红名
					and ((not UnitIsPlayer(v.Unit) and not UnitPlayerControlled(v.Unit)) or (IsInInstance() and not C_PvP.IsActiveBattlefield())))
					--以上所有判断都要符合:单位不是玩家和玩家控制的单位，副本中除外(避免不攻击被心灵控制的目标)
					or (UnitIsPlayer(v.Unit) and C_PvP.IsActiveBattlefield())
					--单位是玩家且在战场/竞技场中
					or DA_UnitIsInTable(v.UnitGUID, Balance_FindEnemyCombatLogAttackMeUnitCache) then
					--单位是攻击我的目标
						table.insert(Balance_EnemyCacheHasThreat, {
							Unit = v.Unit,
							UnitName = v.UnitName,
							UnitGUID = v.UnitGUID,
							UnitHealth = v.UnitHealth,
							UnitHealthMax = v.UnitHealthMax,
							UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
							UnitHealthVacancy = v.UnitHealthMax - v.UnitHealth,
							UnitPositionX = v.UnitPositionX,
							UnitPositionY = v.UnitPositionY,
							UnitPositionZ = v.UnitPositionZ,
						}) --有仇恨敌对目标写入表格
						if DA_GetUnitDistance(v.Unit) <= 5 then
							table.insert(Balance_EnemyCacheHasThreatIn5, {
								Unit = v.Unit,
								UnitName = v.UnitName,
								UnitGUID = v.UnitGUID,
								UnitHealth = v.UnitHealth,
								UnitHealthMax = v.UnitHealthMax,
								UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
								UnitPositionX = v.UnitPositionX,
								UnitPositionY = v.UnitPositionY,
								UnitPositionZ = v.UnitPositionZ,
							})--5码内敌对目标写入表格
						end
						if DA_GetUnitDistance(v.Unit) <= 7 then
							table.insert(Balance_EnemyCacheHasThreatIn7, {
								Unit = v.Unit,
								UnitName = v.UnitName,
								UnitGUID = v.UnitGUID,
								UnitHealth = v.UnitHealth,
								UnitHealthMax = v.UnitHealthMax,
								UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
								UnitPositionX = v.UnitPositionX,
								UnitPositionY = v.UnitPositionY,
								UnitPositionZ = v.UnitPositionZ,
							})--7码内敌对目标写入表格
						end
					end
				end
			end
			if v.UnitGUID == Balance_FindEnemyCombatLogUnitGUID then
				--print(v.UnitName)
				Balance_FindEnemyCombatLogUnitGUID = nil
			end
		end
	end
	
	for k, v in ipairs(Balance_EnemyCacheHasThreat) do
		--从有仇恨敌对目标表格中判断优先击杀目标
		if DamagerEngineGetPriorityUnit(v.Unit) then
			--先打血高的特殊目标(非单体输出,可AOE)
			table.insert(Balance_EnemyCacheS2, {
				Unit = v.Unit,
				UnitName = v.UnitName,
				UnitGUID = v.UnitGUID,
				UnitHealth = v.UnitHealth,
				UnitHealthMax = v.UnitHealthMax,
				UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
				UnitPositionX = v.UnitPositionX,
				UnitPositionY = v.UnitPositionY,
				UnitPositionZ = v.UnitPositionZ,
			}) --目标写入表格
		end
		if DamagerEngineGetPriorityUnitReverseHealth(v.Unit) or DamagerEngineGetPriorityAttackAuras(v.Unit) then
			--先打血低的特殊目标(非单体输出,可AOE)
			table.insert(Balance_EnemyCacheS3, {
				Unit = v.Unit,
				UnitName = v.UnitName,
				UnitGUID = v.UnitGUID,
				UnitHealth = v.UnitHealth,
				UnitHealthMax = v.UnitHealthMax,
				UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
				UnitPositionX = v.UnitPositionX,
				UnitPositionY = v.UnitPositionY,
				UnitPositionZ = v.UnitPositionZ,
			}) --目标写入表格
		end
	end
	
	if #Balance_EnemyCacheS > 0 then
		table.sort(Balance_EnemyCacheS, function(a, b) return a.UnitHealth > b.UnitHealth end)
		--血量从高到低排序(优先打血高的)
	end
	if #Balance_EnemyCacheS2 > 0 then
		table.sort(Balance_EnemyCacheS2, function(a, b) return a.UnitHealth > b.UnitHealth end)
		--血量从高到低排序(优先打血高的)
	end
	if #Balance_EnemyCacheS3 > 0 then
		table.sort(Balance_EnemyCacheS3, function(a, b) return a.UnitHealth < b.UnitHealth end)
		--血量从低到高排序(优先打血低的)
	end
	if #Balance_EnemyCacheHasThreat > 0 then
		if DA_GetHasActiveAffix('崩裂') or UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or select(3, GetInstanceInfo()) == 167 or select(3, GetInstanceInfo()) == 208 then
			--大秘境词缀存在[崩裂]或BOSS战斗或不在副本或在战场/竞技场或伤害输出职责不超过2人或在托加斯特，罪魂之塔时,血量从低到高排序(优先打血低的)
			table.sort(Balance_EnemyCacheHasThreat, function(a, b) return a.UnitHealth < b.UnitHealth end)
		else
			table.sort(Balance_EnemyCacheHasThreat, function(a, b) return a.UnitHealth > b.UnitHealth end)
			--血量从高到低排序(优先打血高的)
		end
		for k, v in ipairs(Balance_EnemyCacheHasThreat) do
			Balance_Enemy_SumHealth = Balance_Enemy_SumHealth + v.UnitHealth
			Balance_Enemy_SumHealthMax = Balance_Enemy_SumHealthMax + v.UnitHealthMax
		end
		Balance_Enemy_SumHealthScale = Balance_Enemy_SumHealth / Balance_Enemy_SumHealthMax
		--获取附近敌对目标的总剩余血量
		--print(Balance_Enemy_SumHealth)
		--print(Balance_Enemy_SumHealthMax)
		--print(Balance_Enemy_SumHealthScale)
	end
end

function Balance_UnitWithNoAttackAurasUnitDecide(Unit, Distance)
	--获取是否有无辜目标与Unit距离小于Distance
	if WoWAssistantUnlocked then
		local UnitTooNear = nil
		if not Unit then return end
		if UnitExists(Unit) and UnitIsVisible(Unit) then
			local X, Y, Z = ObjectPosition(Unit)
			for k, v in ipairs(Balance_EnemyCacheNoThreat) do
				--无辜目标
				if DA_GetNovaDistance(Unit, v.Unit) < Distance and math.abs(Z - v.UnitPositionZ) <= 10 then
					--print("["..UnitName(Unit).."] 离无辜目标过近")
					UnitTooNear = 1
					break
				end
			end
		end
		if UnitTooNear then
			return true
		else
			--没有不攻击目标过近
			return false
		end
	else
		return false
	end
end

function Balance_UnitWithAttackUnitDecide(Unit, Distance)
	--获取Unit旁距离小于Distance的可攻击目标个数
	if WoWAssistantUnlocked then
		local AttackUnitCount = 0
		if not Unit then return end
		if UnitExists(Unit) and UnitIsVisible(Unit) then
			local X, Y, Z = ObjectPosition(Unit)
			for k, v in ipairs(Balance_EnemyCacheHasThreat) do
				if DA_GetNovaDistance(Unit, v.Unit) < Distance and math.abs(Z - v.UnitPositionZ) <= 10 then
					AttackUnitCount = AttackUnitCount + 1
				end
			end
		end
		return AttackUnitCount
	else
		return #Balance_EnemyCacheHasThreat
	end
end

function Balance_GetStarfireUnit(Distance)
	--获取一定距离内附近怪物最多的单位
	if WoWAssistantUnlocked then
		local UnitCount = 0
		Balance_EnemyCacheGetStarfireUnitTemp = {}
		Balance_EnemyCacheGetStarfireUnit = {}
		for k, v in ipairs(Balance_EnemyCacheHasThreat) do
			if DA_GetFacing("player", v.Unit) then
				UnitCount = Balance_UnitWithAttackUnitDecide(v.Unit, Distance)
				table.insert(Balance_EnemyCacheGetStarfireUnitTemp, {
					Unit = v.Unit, 
					UnitName = v.UnitName, 
					UnitGUID = v.UnitGUID, 
					UnitHealth = v.UnitHealth,
					UnitHealthMax = v.UnitHealthMax,
					UnitHealthScale = v.UnitHealth/v.UnitHealthMax,
					UnitPositionX = v.UnitPositionX,
					UnitPositionY = v.UnitPositionY,
					UnitPositionZ = v.UnitPositionZ,
					StarfireUnitCount = UnitCount
				})
			end
		end
		if #Balance_EnemyCacheGetStarfireUnitTemp > 0 then
			table.sort(Balance_EnemyCacheGetStarfireUnitTemp, function(a, b) return a.StarfireUnitCount > b.StarfireUnitCount end)
			--单位距离内附近怪物数量从高到低排序
			--print(Balance_EnemyCacheGetStarfireUnitTemp[1].UnitName)
			--print(Balance_EnemyCacheGetStarfireUnitTemp[1].StarfireUnitCount)
		end
		for k, v in ipairs(Balance_EnemyCacheGetStarfireUnitTemp) do
			if Balance_EnemyCacheGetStarfireUnitTemp[k].StarfireUnitCount == Balance_EnemyCacheGetStarfireUnitTemp[1].StarfireUnitCount then
				table.insert(Balance_EnemyCacheGetStarfireUnit, {
					Unit = v.Unit, 
					UnitName = v.UnitName, 
					UnitGUID = v.UnitGUID, 
					UnitHealth = v.UnitHealth,
					UnitHealthMax = v.UnitHealthMax,
					UnitHealthScale = v.UnitHealth/v.UnitHealthMax,
					UnitPositionX = v.UnitPositionX,
					UnitPositionY = v.UnitPositionY,
					UnitPositionZ = v.UnitPositionZ,
					StarfireUnitCount = UnitCount
				})
			end
		end
		if #Balance_EnemyCacheGetStarfireUnit > 0 then
			if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 then
				--BOSS战斗或不在副本或在战场/竞技场或伤害输出职责不超过2人时,血量从低到高排序(优先打血低的)
				table.sort(Balance_EnemyCacheGetStarfireUnit, function(a, b) return a.UnitHealth < b.UnitHealth end)
			else
				table.sort(Balance_EnemyCacheGetStarfireUnit, function(a, b) return a.UnitHealth > b.UnitHealth end)
				--血量从高到低排序(优先打血高的)
			end
			return Balance_EnemyCacheGetStarfireUnit[1].Unit, Balance_EnemyCacheGetStarfireUnit[1].StarfireUnitCount
		end
	else
		return Balance_AutoDPS_DPSTarget, #Balance_EnemyCacheHasThreat
	end
end

function Balance_GetStarfallPosition()
	--获取星辰坠落位置
	if WoWAssistantUnlocked then
		local X, Y, Z = ObjectPosition("player")
		--if not Balance_StarfallPositionWithNoThreatUnitDecide(X, Y, Z) and (Balance_GetUnitInStarfallPosition(X, Y, Z) >= StarfallUnitCount or AuraUtil.FindAuraByName('织星者的经纱', "player", "HELPFUL") or Balance_NeedMovingCast()) then
		if Balance_GetUnitInStarfallPosition(X, Y, Z) >= StarfallUnitCount or AuraUtil.FindAuraByName('织星者的经纱', "player", "HELPFUL") or select(10, AuraUtil.FindAuraByName('浩瀚之触', "player", "HELPFUL")) == 450361 or Balance_NeedMovingCast() then
			return true
		else
			return false
		end
	else
		if #Balance_EnemyCacheHasThreat >= StarfallUnitCount or AuraUtil.FindAuraByName('织星者的经纱', "player", "HELPFUL") or select(10, AuraUtil.FindAuraByName('浩瀚之触', "player", "HELPFUL")) == 450361 or Balance_NeedMovingCast() then
			return true
		else
			return false
		end
	end
end

function Balance_GetUnitInStarfallPosition(X, Y, Z)
	--判断星辰坠落范围内怪物数量
	local UnitInStarfallPositionCount = 0
	StarfallDistance = 45
	for k, v in ipairs(Balance_EnemyCache) do
		if DA_GetPositionDistance(X, Y, Z, v.UnitPositionX, v.UnitPositionY, v.UnitPositionZ) < StarfallDistance then
			UnitInStarfallPositionCount = UnitInStarfallPositionCount + 1
		end
	end
	return UnitInStarfallPositionCount
end

function Balance_FindEnemyCacheNoThreat()
	--查找无辜目标
	Balance_EnemyCacheNoThreat = {}
	for k, v in ipairs(Balance_EnemyCache) do
		--从附近所有敌对目标中查找无辜目标
		if UnitExists(v.Unit) and UnitIsVisible(v.Unit) then
		
			Balance_UnitHasThreat = nil
			for k2, v2 in ipairs(Balance_EnemyCacheHasThreat) do
				if v.UnitGUID == v2.UnitGUID then
					--仇恨表中的目标不算无辜目标
					Balance_UnitHasThreat = 1
					break
				end
			end
			if DamagerEngineGetIgnoreUnit(v.Unit) 
			--忽略的目标,不算无辜目标
			or DamagerEngineGetNoThreatUnit(v.Unit) 
			--无仇恨类目标,不算无辜目标
			or select(2, DamagerEngineGetNoAttackAuras(v.Unit)) == "Immune" 
			--因Auras免疫伤害的目标,不算无辜目标
			or (UnitIsPlayer(v.Unit..'target') and IsInInstance()) 
			--目标是玩家的目标(副本内),不算无辜目标
			or (UnitPlayerControlled(v.Unit) and (C_PvP.IsActiveBattlefield() or (Balance_FindEnemyCombatLogAttackMeUnitCache and #Balance_FindEnemyCombatLogAttackMeUnitCache > 0))) then
			--玩家控制的目标(战场内或攻击我的玩家控制目标大于0),不算无辜目标
				Balance_UnitHasThreat = 1
			end
			
			if not Balance_UnitHasThreat or select(2, DamagerEngineGetNoAttackAuras(v.Unit)) == "NoAttack" then
				--判断不算无辜目标的单位、因Auras不要攻击的单位写入表格
				table.insert(Balance_EnemyCacheNoThreat, {
					Unit = v.Unit, 
					UnitName = v.UnitName, 
					UnitGUID = v.UnitGUID, 
					UnitHealth = v.UnitHealth,
					UnitHealthMax = v.UnitHealthMax,
					UnitHealthScale = v.UnitHealth/v.UnitHealthMax,
					UnitPositionX = v.UnitPositionX,
					UnitPositionY = v.UnitPositionY,
					UnitPositionZ = v.UnitPositionZ,
				}) --无辜目标写入表格
				--print(v.UnitName)
			end
		end
	end
end

function Balance_StarfallPositionWithNoThreatUnitDecide(X, Y, Z)
	--获取是否有无辜目标离星辰坠落过近
	local StarfallUnitTooNear = nil
	for k, v in ipairs(Balance_EnemyCacheNoThreat) do
		--无辜目标
		if GetUnitSpeed(v.Unit) == 0 then
			SafeStarfallDistance = 47.5
		else
			SafeStarfallDistance = 57.5
		end
		if DA_GetPositionDistance(X, Y, Z, v.UnitPositionX, v.UnitPositionY, v.UnitPositionZ) < SafeStarfallDistance and math.abs(Z - v.UnitPositionZ) <= 10 then
			--获取是否有无辜目标离星辰坠落过近
			--print("["..v.UnitName.."] 离 "..X..", "..Y..", "..Z.." 过近")
			StarfallUnitTooNear = 1
			break
		end
	end
	if StarfallUnitTooNear then
		return true
		--有无辜目标离星辰坠落过近，不施放星辰坠落
	else
		--没有无辜目标离星辰坠落过近，施放星辰坠落
		return false
	end
end

BalanceCycleFrame:SetScript("OnEvent", Balance_OnEvent)
BalanceCycleFrame:SetScript("OnUpdate", Balance_OnEvent)