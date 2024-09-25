--野德

FeralCycleFrame = CreateFrame("Frame")
FeralCycleFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
FeralCycleFrame:RegisterEvent("UNIT_SPELLCAST_FAILED")
FeralCycleFrame:RegisterEvent("UNIT_SPELLCAST_SENT")
FeralCycleFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
FeralCycleFrame:RegisterEvent("UI_ERROR_MESSAGE")
FeralCycleFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
FeralCycleFrame:RegisterEvent("CURSOR_CHANGED")
FeralCycleFrame:RegisterEvent("UNIT_SPELLCAST_START")
FeralCycleFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
FeralCycleFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
FeralCycleFrame:RegisterEvent("PLAYER_TARGET_CHANGED")

local SDPHR = 0.25
--当前版本玩家单体DPS与玩家血量的比值(SingleDPS_PlayerHealthMax_Ratio)
--7.0版本后期:0.35
--8.0版本初期:0.075

function Feral_SetDebugInfo(spell)
	local name, rank, icon = DA_GetSpellInfo(spell)
	--print('使用:'..spell)
	if icon then
		Feral_DeBugSpellIcon.Texture:SetTexture(icon)
	end
end

local TargetHealth = 0
local TargetHealthScale = 0
local PlayerPowerNow = 0
local PlayerPowerMaximum = 0
local PlayerPowerScale = 0
local PlayerPowerVacancy = 0
local ComboPoints = 0
local PlayerHealthScale = 0

local TalentCheck = nil
local PowerCheck = nil
local ComboPointsCheck = nil
local BuffCheck = nil
local DeBuffCheck = nil

Feral_FindEnemyCombatLogAttackMeUnitCache = {}

function Feral_UseAttributesEnhancedItem()
	--使用属性增强饰品
	if not FeralSaves.FeralOption_Attack_AutoAccessories then return end
	
	for i = 13, 14 do
		local ItemID = _G["AttributesEnhancedItemID"..i]
		local slotID = nil
		if ItemID == 144258 and C_PvP.IsActiveBattlefield() then
			--部分饰品不能在战场中使用,例如[基尔加丹的炽燃决心]
			ItemID = nil
		end
		if ItemID == 178742 and AuraUtil.FindAuraByName(DA_GetSpellInfo(345545), "player", "HELPFUL") then
			--用过[瓶装绽翼兽毒素]存在[绽翼兽之毒]BUFF则不再使用
			ItemID = nil
		end
		if ItemID and C_Item.IsUsableItem(ItemID) and GetItemCooldown(ItemID) == 0 and not UnitChannelInfo("player") then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			DA_UseItem(slotID)
			Feral_CastSpellIng = 1
			return true
		end
	end
end

function Feral_UseConcoctionKissOfDeath()
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

function Feral_UseMistcallerOcarina()
	--[唤雾者的陶笛]
	if C_Item.IsEquippedItem(178715) then
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
			local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(330067), "player", "HELPFUL")
			local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
			--BUFF剩余时间
			if not UnitAffectingCombat("player") and timeLeft < 300 and not IsPlayerMoving() and not IsFalling() then
				if not UnitCastingInfo("player") and not UnitChannelInfo("player") and not IsStealthed() and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
					DA_UseItem(SpecialItemSlotID)
					--使用唤雾者的陶笛
				end
			end
		end
	end
end

function Feral_GetDirectSingleDPSItemCD(Unit)
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

function Feral_GetDirectAoeDPSItemCD(Unit)
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
			if ItemID == 144259 and C_PvP.IsActiveBattlefield() then
				--部分饰品不能在战场中使用,例如[基尔加丹的炽燃决心]
				DirectAoeDPSItemCD = 1
			end
		end
	end
end

function Feral_OnEvent(self, event, ...)
	if not FeralCycleStart then return end
	local a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = ...
	if event == "COMBAT_LOG_EVENT" or event == "COMBAT_LOG_EVENT_UNFILTERED" then
		a, b, c, d, e, f, g, h, i, j, k, l, m, n, o, p = CombatLogGetCurrentEventInfo()
	end
	
	if event == "PLAYER_TARGET_CHANGED" then
		Just_OneTargetNearest = nil
		if DA_Start_TargetNearest_Unit and UnitGUID("target") == UnitGUID(DA_Start_TargetNearest_Unit) then
			--print("已选中目标: " .. UnitGUID("target"))
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
			if FeralCycleStart == 1 and DA_GetSpecialization() ~= 103 then
				FeralSwitchStatusText:SetTextColor(1, 0, 0)
				FeralSwitchStatusText:Hide()
				FeralCycleStart = nil
			end
		end)
	end
	if event == "CURSOR_CHANGED" 
	and ((C_Spell.IsCurrentSpell(Rebirth_SpellID) and not FeralSaves.FeralOption_Other_AutoRebirth) 
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
			FeralManualCursorCastingDelayTime = 1
		else
			FeralManualCursorCastingDelayTime = 3
		end
		Feral_ManualCursorCasting = 1
		Feral_ManualCursorCastingTime = GetTime()
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
				FeralManualCastingDelayTime = 0.25
			else
				FeralManualCastingDelayTime = 1
			end
			FeralCycle = nil
			--print(name)
			--print(DA_SelfCastSpellName)
			if name == DA_SelfCastSpellName then FeralCycle = 1 end
			-- if spellID == Rake_SpellID then FeralCycle = 1 end --斜掠
			-- if spellID == Shred_SpellID then FeralCycle = 1 end --撕碎
			-- if spellID == Thrash_SpellID then FeralCycle = 1 end --痛击
			-- if spellID == Swipe_SpellID then FeralCycle = 1 end --横扫
			-- if spellID == Rip_SpellID then FeralCycle = 1 end --割裂
			-- if spellID == Ferocious_Bite_SpellID then FeralCycle = 1 end --凶猛撕咬
			-- if spellID == Tiger_Fury_SpellID then FeralCycle = 1 end --猛虎之怒
			-- if spellID == Convoke_the_Spirits_SpellID and FeralSaves.FeralOption_Attack_AutoCovenant then FeralCycle = 1 end --万灵之召
			-- if spellID == Adaptive_Swarm_SpellID and FeralSaves.FeralOption_Attack_AutoCovenant then FeralCycle = 1 end --激变蜂群
			-- if (spellID == Moonfire_SpellID or spellID == 155625) and IsPlayerSpell(155580) then FeralCycle = 1 end --月火术
			-- if spellID == Brutal_Slash_SpellID and IsPlayerSpell(Brutal_Slash_SpellID) then FeralCycle = 1 end --野蛮挥砍
			-- if spellID == Feral_Frenzy_SpellID and IsPlayerSpell(274837) then FeralCycle = 1 end --野性狂乱
			-- if spellID == Primal_Wrath_SpellID and IsPlayerSpell(285381) then FeralCycle = 1 end --原始之怒
			-- if spellID == Berserk_SpellID then FeralCycle = 1 end --狂暴
			-- if spellID == Incarnation_Avatar_of_Ashamane_SpellID then FeralCycle = 1 end --化身：丛林之王
			-- if spellID == Berserking_SpellID then FeralCycle = 1 end --狂暴(种族特长)
			-- if spellID == Skull_Bash_SpellID then FeralCycle = 1 end --迎头痛击
			-- --if spellID == Incapacitating_Roar_SpellID and FeralSaves.FeralOption_Auras_AutoInterrupt then FeralCycle = 1 end --夺魂咆哮
			-- if spellID == Mighty_Bash_SpellID and FeralSaves.FeralOption_Auras_AutoInterrupt then FeralCycle = 1 end --蛮力猛击
			-- if spellID == Survival_Instincts_SpellID and FeralSaves.FeralOption_Attack_AutoIronbark then FeralCycle = 1 end --生存本能
			-- if spellID == Renewal_SpellID then FeralCycle = 1 end --甘霖
			-- if spellID == Frenzied_Regeneration_SpellID then FeralCycle = 1 end --狂暴回复
			-- if spellID == Rejuvenation_SpellID and IsPlayerSpell(774) and FeralSaves.FeralOption_Attack_AutoIronbark then FeralCycle = 1 end --回春术
			-- if spellID == Regrowth_SpellID and FeralSaves.FeralOption_Attack_AutoIronbark then FeralCycle = 1 end --愈合
			-- if spellID == Bear_Form_SpellID then FeralCycle = 1 end --熊形态
			-- if spellID == Barkskin_SpellID then FeralCycle = 1 end --树皮术
			-- if spellID == 768 then FeralCycle = 1 end --猎豹形态
			-- if spellID == 22570 then FeralCycle = 1 end --割碎
			-- if spellID == Soothe_SpellID and FeralSaves.FeralOption_Auras_ClearEnrage then FeralCycle = 1 end --安抚
			-- if spellID == Remove_Corruption_SpellID and FeralSaves.FeralOption_Auras_ClearCurse and FeralSaves.FeralOption_Auras_ClearPoison then FeralCycle = 1 end --清除腐蚀
			if spellID == Rebirth_SpellID and FeralSaves.FeralOption_Other_AutoRebirth then FeralCycle = 1 end --复生
			if not FeralCycle then
				local start, duration = DA_GetSpellCooldown(113)
				local start2, duration2 = DA_GetSpellCooldown(spellID)
				if (duration2 == duration or duration2 == 0) and DA_IsUsableSpell(spellID) and (IsPlayerSpell(spellID) or DA_GetSpellInfo(spellID) == "野性冲锋") then
					Feral_ManualCasting = 1
					--手动技能指示
				end
				Feral_ManualCastingTime = GetTime()
			end
			if event == "UNIT_SPELLCAST_SUCCEEDED" and (IsPlayerSpell(spellID) or DA_GetSpellInfo(spellID) == "野性冲锋" or name == "月火术") then
				if spellID == 339 or spellID == 2637 or spellID == 209753 then
					--纠缠根须、休眠、旋风,延迟0.1秒取消手动施法指示
					C_Timer.After(0.1, function()
						Feral_ManualCasting = nil
					end)
				else
					Feral_ManualCasting = nil
				end
			end
		end
	end
	if event == "UNIT_SPELLCAST_SENT" and a == "player" then
		if FeralSaves.FeralOption_TargetFilter == 2 then
			--手动目标模式
			local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
			if spellID == Convoke_the_Spirits_SpellID then
				--万灵之召保护,防止发包万灵之召技能之后,后续技能中断万灵之召
				Feral_ChannelSpellIng = 1
				C_Timer.After(1, function()
				--发包1秒后保护结束
					Feral_ChannelSpellIng = nil
				end)
			end
			if spellID == Skull_Bash_SpellID then
				--迎头痛击
				FeralTargetNotVisibleUnit = DamagerEngineInterruptSpellTarget
			elseif spellID == Mighty_Bash_SpellID then
				--蛮力猛击
				FeralTargetNotVisibleUnit = DamagerEngineControlInterruptSpellTarget
			elseif spellID == Shred_SpellID and Feral_SpellCastSentShredTargetS then
				--特殊目标撕碎
				FeralTargetNotVisibleUnit = Feral_AutoDPS_ShredTargetS
				Feral_SpellCastSentShredTargetS = nil
			else
				--其他法术
				FeralTargetNotVisibleUnit = "target"
			end
		else
			--其他目标模式
			local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
			if spellID == Skull_Bash_SpellID then
				--迎头痛击
				FeralTargetNotVisibleUnit = DamagerEngineInterruptSpellTarget
			elseif spellID == Mighty_Bash_SpellID then
				--蛮力猛击
				FeralTargetNotVisibleUnit = DamagerEngineControlInterruptSpellTarget
			elseif spellID == Shred_SpellID and Feral_SpellCastSentShredTargetS then
				--特殊目标撕碎
				FeralTargetNotVisibleUnit = Feral_AutoDPS_ShredTargetS
				Feral_SpellCastSentShredTargetS = nil
			elseif spellID == Rake_SpellID then
				--斜掠
				FeralTargetNotVisibleUnit = Feral_AutoDPS_RakeTarget
			elseif spellID == Rip_SpellID then
				--割裂
				FeralTargetNotVisibleUnit = Feral_AutoDPS_RipTarget
			else
				--其他法术
				FeralTargetNotVisibleUnit = Feral_AutoDPS_DPSTarget
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
				Feral_ChannelSpellIng = nil
			end)
		end
		if select(2, DA_GetSpellCooldown(113)) * 1000 > 0 then
			FeralSpellGCD = select(2, DA_GetSpellCooldown(113)) * 1000
			--获取公共CD时间
		end
	end
	if event == "UI_ERROR_MESSAGE" and (b == "目标不在视野中" or b == "你的视线被遮挡了" or b == "无效的目标" or b == "你必须面对目标。") then
		FeralTargetNotVisibleUnit = 'target' --像素版只能对当前目标使用技能,因此直接给FeralTargetNotVisibleUnit赋值
		if FeralTargetNotVisibleUnit then
			Feral_TargetNotVisible = Feral_TargetNotVisible or {}
			for k, v in ipairs(Feral_TargetNotVisible) do --遍历表格, 看目标是否已存在表格内
				if UnitGUID(FeralTargetNotVisibleUnit) == UnitGUID(v) then --目标存在表格内
					Feral_TargetNotVisible_UnitIsInTable = 1
					break
				end
			end
			if not Feral_TargetNotVisible_UnitIsInTable then
				table.insert(Feral_TargetNotVisible, UnitGUID(FeralTargetNotVisibleUnit)) --写入表格内
			end
			Feral_TargetNotVisible_UnitIsInTable = nil
			FeralTargetNotVisibleUnit = nil
			if not ClearTargetNotVisibleTable_C_TimerIng then
				ClearTargetNotVisibleTable_C_TimerIng = 1
				if IsActiveBattlefieldArena() then
					ClearTargetNotVisibleTableAfterTime = 1
				else
					ClearTargetNotVisibleTableAfterTime = 3
				end
				C_Timer.After(ClearTargetNotVisibleTableAfterTime, function()
					--print('清空TargetNotVisibleTable')
					Feral_TargetNotVisible = {}
					ClearTargetNotVisibleTable_C_TimerIng = nil
				end)
			end
		end
	end
	if event == "UI_ERROR_MESSAGE" and (b == "你面朝错误的方向！") then
		Feral_TargetNotVisible = Feral_TargetNotVisible or {}
		for k, v in ipairs(Feral_TargetNotVisible) do --遍历表格, 看目标是否已存在表格内
			if UnitGUID("target") == UnitGUID(v) then --目标存在表格内
				Feral_TargetNotVisible_UnitIsInTable = 1
				break
			end
		end
		if not Feral_TargetNotVisible_UnitIsInTable then
			table.insert(Feral_TargetNotVisible, UnitGUID("target")) --写入表格内
		end
		Feral_TargetNotVisible_UnitIsInTable = nil
		if not ClearTargetNotVisibleTable_C_TimerIng2 then
			ClearTargetNotVisibleTable_C_TimerIng2 = 1
			if IsActiveBattlefieldArena() then
				ClearTargetNotVisibleTableAfterTime = 0.35
			else
				ClearTargetNotVisibleTableAfterTime = 1
			end
			C_Timer.After(ClearTargetNotVisibleTableAfterTime, function()
				--print('清空TargetNotVisibleTable')
				Feral_TargetNotVisible = {}
				ClearTargetNotVisibleTable_C_TimerIng2 = nil
			end)
		end
	end

	--if event == "COMBAT_LOG_EVENT_UNFILTERED" or not Feral_Time then
	--COMBAT_LOG_EVENT_UNFILTERED及子事件性能不及UNIT_SPELLCAST_系列事件,事件多时偶尔会产生延迟影响代码执行 2024-8-4
	if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED" or not Feral_Time then
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
			Feral_InGCD = nil
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
		if (not TQMark and select(2, DA_GetSpellCooldown(113)) ~= 0) or UnitChannelInfo("player") then
		--非提前结束公共CD状态且公共CD中、引导法术中
			Feral_InGCD = 1
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
		if (Feral_FindEnemyCombatLogIntervalTime and GetTime() - Feral_FindEnemyCombatLogIntervalTime > 1) or not Feral_FindEnemyCombatLogIntervalTime then
			Feral_FindEnemyCombatLogIntervalTime = GetTime()
			local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(d)
			if UnitPlayerOrPetInParty(name) and ((DA_GetNovaDistance("player", name) <= 30 and DA_GetLineOfSight("player", name)) or not WoWAssistantUnlocked) then
			--过滤其他无关玩家
				if Feral_EnemyCache and not DA_UnitIsInTable(h, Feral_EnemyCache) and not UnitIsDeadOrGhost("player") then
					Feral_FindEnemyIntervalTime = nil
					--通过战斗记录监测,如果受到队友伤害的目标没在Feral_EnemyCache内,则无视扫描目标间隔,重新扫描所有目标
				end
				if Feral_EnemyCacheHasThreat and not DA_UnitIsInTable(h, Feral_EnemyCacheHasThreat) and not UnitIsDeadOrGhost("player") then
					Feral_FindEnemyCombatLogUnitGUID = h
					--通过战斗记录监测,将受到队友伤害的目标写入Feral_EnemyCacheHasThreat内
				end
			end
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_CAST_SUCCESS" and l == 320823 then
		C_Timer.After(0.1, function()
			Feral_FindEnemyIntervalTime = nil
		end)
		--通过战斗记录监测,如果召唤了实验型松鼠炸弹,则0.1秒后无视扫描目标间隔,重新扫描所有目标
	end
	
	if event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_REGEN_DISABLED" then
		--战斗状态改变时重置攻击我的敌对玩家控制目标表格
		Feral_FindEnemyCombatLogAttackMeUnitCache = {}
	end
	
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and (b == "SPELL_DAMAGE" or b == "SWING_DAMAGE") and h == UnitGUID("player") and (not IsInInstance() or C_PvP.IsActiveBattlefield()) then
		if WoWAssistantUnlocked then
			local GUID = d
			local thisUnit = GetObjectWithGUID(GUID)
			local UnitInCache = nil
			
			Feral_FindEnemyCombatLogAttackMeUnitCache = Feral_FindEnemyCombatLogAttackMeUnitCache or {}
			
			if UnitPlayerControlled(thisUnit) and not DA_UnitIsInTable(GUID, Feral_FindEnemyCombatLogAttackMeUnitCache) and not DamagerEngineGetIgnoreUnit(thisUnit) and not Feral_GetTargetNotVisible(thisUnit) and DA_GetTargetCanAttack(thisUnit, Shred_SpellID) then
				local X1,Y1,Z1 = ObjectPosition(thisUnit)
				table.insert(Feral_FindEnemyCombatLogAttackMeUnitCache, {
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
	
	Feral_Time = Feral_Time or GetTime()
	if GetTime() - Feral_Time > 0.05 then
		DA_Clear_Rooted = 1
		DA_Clear_Deceleration = 1
		Feral_Time = nil
		
		Feral_AutoDPS_ShredTargetS = nil
		Feral_AutoDPS_RakeTarget = nil
		Feral_AutoDPS_MoonfireTarget = nil
		Feral_AutoDPS_RipTarget = nil
		Feral_AutoDPS_DPSTarget = nil
		Feral_ClearEnrageTarget = nil
		DamagerEngine_AutoDPS_SinglePriorityTatgetExists = nil
		DamagerEngineInterruptSpell = nil
		DamagerEngineInterruptSpellTarget = nil
		DamagerEngineControlInterruptSpell = nil
		DamagerEngineControlInterruptSpellTarget = nil
		DamagerEngine_IsNotInterruptibleSpell = nil
		Feral_CastSpellIng = nil
		Feral_SelfSaveIng = nil
		Feral_RipFlashWithFerociousBiteUnit = nil
		Feral_BloodseekerVinesUnit = nil
		Feral_EnemyCacheHasThreatUnitDying = nil
		Feral_EnemyCount = 0
		
		FeralSpellGCD = FeralSpellGCD or 1250
		
		PlayerPowerNow = UnitPower("player", 3)
		PlayerPowerMaximum = UnitPowerMax("player", 3)
		PlayerPowerScale = PlayerPowerNow / PlayerPowerMaximum
		PlayerPowerVacancy = PlayerPowerMaximum - PlayerPowerNow
		ComboPoints = GetComboPoints("player","target")
		PlayerHealthScale = UnitHealth("player") / UnitHealthMax("player")
		--print(PlayerPowerNow)
		
		if FeralSaves.FeralOption_Other_ShowDebug then
			if not FeralSwitchStatusText:IsShown() and not FeralCycleStartFlash then
				FeralSwitchStatusText:Show()
			end
			if Feral_Enemy_SumHealthScale then
				if Feral_Enemy_SumHealthScale >= 0.7 then
					Feral_DeBugEnemyCount:SetTextColor(1, 1 - Feral_Enemy_SumHealthScale, 0)
				else
					Feral_DeBugEnemyCount:SetTextColor(Feral_Enemy_SumHealthScale * 2, 1 - Feral_Enemy_SumHealthScale, 0)
				end
			end
			
			if Feral_DoNotDPS and not FeralCycleStartFlash then
				FeralSwitchStatusText:SetTextColor(1, 0, 0)
			elseif (Feral_ManualCasting or Feral_ManualCursorCasting) and not FeralCycleStartFlash then
				FeralSwitchStatusText:SetTextColor(0.5, 0, 0.5)
			elseif Feral_InGCD and not FeralCycleStartFlash then
				FeralSwitchStatusText:SetTextColor(1, 1, 0)
			elseif FeralSaves.FeralOption_TargetFilter == 2 and not FeralCycleStartFlash then
				FeralSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
			elseif FeralSaves.FeralOption_TargetFilter == 3 and not FeralCycleStartFlash then
				FeralSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
			elseif FeralSaves.FeralOption_TargetFilter == 1 and not FeralCycleStartFlash then
				FeralSwitchStatusText:SetTextColor(0, 1, 1)
			end
		elseif FeralSwitchStatusText then
			FeralSwitchStatusText:Hide()
			Feral_DeBugEnemyCount:Hide()
			Feral_DeBugSpellIcon:Hide()
		end
		
		if Feral_ManualCasting then
			Feral_ManualCastingTime = Feral_ManualCastingTime or GetTime()
			if GetTime() - Feral_ManualCastingTime < FeralManualCastingDelayTime or UnitCastingInfo("player") then
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
				Feral_ManualCasting = nil
				Feral_ManualCastingTime = nil
			end
		end
		if Feral_ManualCursorCasting then
			Feral_ManualCursorCastingTime = Feral_ManualCursorCastingTime or GetTime()
			if GetTime() - Feral_ManualCursorCastingTime < FeralManualCursorCastingDelayTime and SpellIsTargeting() then
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
				Feral_ManualCursorCasting = nil
				Feral_ManualCursorCastingTime = nil
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
			Feral_UseConcoctionKissOfDeath()
			--[制剂：死亡之吻]
		end
		
		if Feral_InGCD then return end
		
		Feral_DoNotDPSAura = nil
		Feral_DoNotDPSAuraCache = {
			--{Name = "熊形态", ID = 5487, Instance = "德鲁伊-测试"}, 
			{Name = "进食饮水", ID = 167152, Instance = "进食"}, 
			{Name = "饮水", ID = 175787, Instance = "进食"}, 
			{Name = "喝水", ID = 192001, Instance = "进食"}, 
			{Name = "食物和饮水", ID = 192002, Instance = "进食"}, 
			{Name = "食物和饮料", ID = 327786, Instance = "进食"}, 
			{Name = "影遁", ID = 58984, Instance = "种族天赋"}, 
			{Name = "鲜血与荣耀", ID = 320102, Instance = "伤逝剧场-无堕者哈夫"}, 
		}
		for i=1, #Feral_DoNotDPSAuraCache do
			local name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID = AuraUtil.FindAuraByName(Feral_DoNotDPSAuraCache[i].Name, "player", "HELPFUL")
			if name then
				Feral_DoNotDPSAura = 1
				break
			end
		end
		if (GetShapeshiftFormID() and GetShapeshiftFormID() ~= 1 and GetShapeshiftFormID() ~= 5) or IsMounted() or UnitIsDeadOrGhost("player") or Feral_DoNotDPSAura or not HasFullControl() or (C_Spell.GetSpellLossOfControlCooldown(Regrowth_SpellID) > 0 and C_Spell.GetSpellLossOfControlCooldown(Shred_SpellID) > 0) or GetCurrentKeyBoardFocus() then
			Feral_DoNotDPS = 1
			Feral_DeBugEnemyCount:Hide()
			Feral_DeBugSpellIcon:Hide()
			return
		else
			Feral_DoNotDPS = nil
		end
		--非DPS状态指示
		
		Feral_FindEnemy()
		--遍历附近敌对目标
		
		Feral_FindEnemyInEnemyCache()
		--从Feral_EnemyCache遍历附近可攻击的敌对目标
		
		if WoWAssistantUnlocked then
			if (Feral_ObjectIsInTableTime and GetTime() - Feral_ObjectIsInTableTime > 1) or not Feral_ObjectIsInTableTime then
				Feral_ObjectIsInTableTime = GetTime()
				if DA_ObjectIsInTable(173729, Feral_EnemyCache) then
					--存在傲慢具象
					Feral_ManifestationOfPrideExists = 1
				else
					Feral_ManifestationOfPrideExists = nil
				end
			end
		else
			if DA_ObjectIsInTable(173729, Feral_EnemyCache) then
				--存在傲慢具象
				Feral_ManifestationOfPrideExists = 1
			else
				Feral_ManifestationOfPrideExists = nil
			end
		end
		
		if (Feral_GetNoUsePowerfulSpell and GetTime() - Feral_GetNoUsePowerfulSpell > 0.5) or not Feral_GetNoUsePowerfulSpell then
			Feral_GetNoUsePowerfulSpell = GetTime()
			if DamagerEngineGetNoUsePowerfulSpell(Feral_EnemyCacheHasThreatIn20) then
			--存在特定目标情况时不用爆发技能
				Feral_NoUsePowerfulSpell = 1
			else
				Feral_NoUsePowerfulSpell = nil
			end
		end
		
		DamagerEngine_PlayerInEnemyCache = nil
		if Feral_FindEnemyCombatLogAttackMeUnitCache and #Feral_FindEnemyCombatLogAttackMeUnitCache > 0 and (not IsInInstance() or C_PvP.IsActiveBattlefield()) then
			--Feral_FindEnemyCombatLogAttackMeUnitCache表中的目标大于0个且(不在副本或在战场)时
			for k, v in ipairs(Feral_EnemyCacheHasThreat) do
				if UnitIsPlayer(v.Unit) then
					DamagerEngine_PlayerInEnemyCache = 1
					break
					--Feral_EnemyCacheHasThreat表中有玩家存在
				end
			end
		end
		
		for i = #Feral_EnemyCacheHasThreat, 1, -1 do
			DamagerEngineRemoveNoAttackAurasUnit(Feral_EnemyCacheHasThreat, Feral_EnemyCacheHasThreat[i].Unit, i)
			--从Feral_EnemyCacheHasThreat表中移除某些的目标
		end
		
		Feral_FindEnemyCacheNoThreat()
		--查找无辜目标
	
		name_PredatorySwiftness, icon_PredatorySwiftness, count_PredatorySwiftness, dispelType_PredatorySwiftness, duration_PredatorySwiftness, expires_PredatorySwiftness, caster_PredatorySwiftness, isStealable_PredatorySwiftness, nameplateShowPersonal_PredatorySwiftness, spellID_PredatorySwiftness = AuraUtil.FindAuraByName(DA_GetSpellInfo(69369), "player", "HELPFUL")
		--掠食者的迅捷
		name_Bloodtalons, icon_Bloodtalons, count_Bloodtalons, dispelType_Bloodtalons, duration_Bloodtalons, expires_Bloodtalons, caster_Bloodtalons, isStealable_Bloodtalons, nameplateShowPersonal_Bloodtalons, spellID_Bloodtalons = AuraUtil.FindAuraByName(DA_GetSpellInfo(145152), "player", "HELPFUL")
		--血腥爪击
		name_Rake, icon_Rake, count_Rake, dispelType_Rake, duration_Rake, expires_Rake, caster_Rake, isStealable_Rake, nameplateShowPersonal_Rake, spellID_Rake = AuraUtil.FindAuraByName(DA_GetSpellInfo(Rake_SpellID), "target", "HARMFUL")
		--斜掠
		if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Rake_SpellID), "target", "HARMFUL")) ~= "player" then
			name_Rake, icon_Rake, count_Rake, dispelType_Rake, duration_Rake, expires_Rake, caster_Rake, isStealable_Rake, nameplateShowPersonal_Rake, spellID_Rake = nil
		end
		name_Rip, icon_Rip, count_Rip, dispelType_Rip, duration_Rip, expires_Rip, caster_Rip, isStealable_Rip, nameplateShowPersonal_Rip, spellID_Rip = AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), "target", "HARMFUL")
		--割裂
		if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), "target", "HARMFUL")) ~= "player" then
			name_Rip, icon_Rip, count_Rip, dispelType_Rip, duration_Rip, expires_Rip, caster_Rip, isStealable_Rip, nameplateShowPersonal_Rip, spellID_Rip = nil
		end
		name_Clearcasting, icon_Clearcasting, count_Clearcasting, dispelType_Clearcasting, duration_Clearcasting, expires_Clearcasting, caster_Clearcasting, isStealable_Clearcasting, nameplateShowPersonal_Clearcasting, spellID_Clearcasting = AuraUtil.FindAuraByName(DA_GetSpellInfo(135700), "player", "HELPFUL")
		--清晰预兆
		name_Berserk, icon_Berserk, count_Berserk, dispelType_Berserk, duration_Berserk, expires_Berserk, caster_Berserk, isStealable_Berserk, nameplateShowPersonal_Berserk, spellID_Berserk = AuraUtil.FindAuraByName(DA_GetSpellInfo(Berserk_SpellID), "player", "HELPFUL")
		--狂暴
		timeLeft_Berserk = expires_Berserk and expires_Berserk > GetTime() and (expires_Berserk - GetTime()) or 0
		--狂暴剩余时间
		name_IncarnationKingOfTheJungle, icon_IncarnationKingOfTheJungle, count_IncarnationKingOfTheJungle, dispelType_IncarnationKingOfTheJungle, duration_IncarnationKingOfTheJungle, expires_IncarnationKingOfTheJungle, caster_IncarnationKingOfTheJungle, isStealable_IncarnationKingOfTheJungle, nameplateShowPersonal_IncarnationKingOfTheJungle, spellID_IncarnationKingOfTheJungle = AuraUtil.FindAuraByName(DA_GetSpellInfo(Incarnation_Avatar_of_Ashamane_SpellID), "player", "HELPFUL")
		--化身
		timeLeft_IncarnationKingOfTheJungle = expires_IncarnationKingOfTheJungle and expires_IncarnationKingOfTheJungle > GetTime() and (expires_IncarnationKingOfTheJungle - GetTime()) or 0
		--化身剩余时间
		name_ScentOfBlood, icon_ScentOfBlood, count_ScentOfBlood, dispelType_ScentOfBlood, duration_ScentOfBlood, expires_ScentOfBlood, caster_ScentOfBlood, isStealable_ScentOfBlood, nameplateShowPersonal_ScentOfBlood, spellID_ScentOfBlood = AuraUtil.FindAuraByName(DA_GetSpellInfo(210664), "player", "HELPFUL")
		--血之气息
		name_Thrash, icon_Thrash, count_Thrash, dispelType_Thrash, duration_Thrash, expires_Thrash, caster_Thrash, isStealable_Thrash, nameplateShowPersonal_Thrash, spellID_Thrash = AuraUtil.FindAuraByName(DA_GetSpellInfo(Thrash_SpellID), "target", "HARMFUL")
		--痛击
		timeLeft_Thrash = expires_Thrash and expires_Thrash > GetTime() and (expires_Thrash - GetTime()) or 0
		--痛击DEBUFF剩余时间
		if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Thrash_SpellID), "target", "HARMFUL")) ~= "player" or timeLeft_Thrash <= 3 then
			name_Thrash, icon_Thrash, count_Thrash, dispelType_Thrash, duration_Thrash, expires_Thrash, caster_Thrash, isStealable_Thrash, nameplateShowPersonal_Thrash, spellID_Thrash = nil
		end
		name_AshamanesRip, icon_AshamanesRip, count_AshamanesRip, dispelType_AshamanesRip, duration_AshamanesRip, expires_AshamanesRip, caster_AshamanesRip, isStealable_AshamanesRip, nameplateShowPersonal_AshamanesRip, spellID_AshamanesRip = AuraUtil.FindAuraByName(DA_GetSpellInfo(210705), "target", "HARMFUL")
		--阿莎曼的撕扯
		if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(210705), "target", "HARMFUL")) ~= "player" then
			name_AshamanesRip, icon_AshamanesRip, count_AshamanesRip, dispelType_AshamanesRip, duration_AshamanesRip, expires_AshamanesRip, caster_AshamanesRip, isStealable_AshamanesRip, nameplateShowPersonal_AshamanesRip, spellID_AshamanesRip = nil
		end
		name_ApexPredator, icon_ApexPredator, count_ApexPredator, dispelType_ApexPredator, duration_ApexPredator, expires_ApexPredator, caster_ApexPredator, isStealable_ApexPredator, nameplateShowPersonal_ApexPredator, spellID_ApexPredator = AuraUtil.FindAuraByName(DA_GetSpellInfo(391882), "player", "HELPFUL")
		--顶级捕食者
		name_Moonfire, icon_Moonfire, count_Moonfire, dispelType_Moonfire, duration_Moonfire, expires_Moonfire, caster_Moonfire, isStealable_Moonfire, nameplateShowPersonal_Moonfire, spellID_Moonfire = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), "target", "HARMFUL")
			--月火术
		if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), "target", "HARMFUL")) ~= "player" then
			name_Moonfire, icon_Moonfire, count_Moonfire, dispelType_Moonfire, duration_Moonfire, expires_Moonfire, caster_Moonfire, isStealable_Moonfire, nameplateShowPersonal_Moonfire, spellID_Moonfire = nil
		end
		name_TigersFury, icon_TigersFury, count_TigersFury, dispelType_TigersFury, duration_TigersFury, expires_TigersFury, caster_TigersFury, isStealable_TigersFury, nameplateShowPersonal_TigersFury, spellID_TigersFury = AuraUtil.FindAuraByName(DA_GetSpellInfo(Tiger_Fury_SpellID), "player", "HELPFUL")
		--猛虎之怒
		timeLeft_TigersFury = expires_TigersFury and expires_TigersFury > GetTime() and (expires_TigersFury - GetTime()) or 0
		--猛虎之怒剩余时间
		name_FeralInstinct, icon_FeralInstinct, count_FeralInstinct, dispelType_FeralInstinct, duration_FeralInstinct, expires_FeralInstinct, caster_FeralInstinct, isStealable_FeralInstinct, nameplateShowPersonal_FeralInstinct, spellID_FeralInstinct = AuraUtil.FindAuraByName(DA_GetSpellInfo(210649), "player", "HELPFUL")
		--野性本能
		name_Sabertooth, icon_Sabertooth, count_Sabertooth, dispelType_Sabertooth, duration_Sabertooth, expires_Sabertooth, caster_Sabertooth, isStealable_Sabertooth, nameplateShowPersonal_Sabertooth, spellID_Sabertooth = AuraUtil.FindAuraByName(DA_GetSpellInfo(391722), "target", "HARMFUL")
			--剑齿利刃
		if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(391722), "target", "HARMFUL")) ~= "player" then
			name_Sabertooth, icon_Sabertooth, count_Sabertooth, dispelType_Sabertooth, duration_Sabertooth, expires_Sabertooth, caster_Sabertooth, isStealable_Sabertooth, nameplateShowPersonal_Sabertooth, spellID_Sabertooth = nil
		end
		timeLeft_Sabertooth = expires_Sabertooth and expires_Sabertooth > GetTime() and (expires_Sabertooth - GetTime()) or 0
		--剑齿利刃DEBUFF剩余时间
		name_Ravage, icon_Ravage, count_Ravage, dispelType_Ravage, duration_Ravage, expires_Ravage, caster_Ravage, isStealable_Ravage, nameplateShowPersonal_Ravage, spellID_Ravage = AuraUtil.FindAuraByName('毁灭', "player", "HELPFUL")
		--毁灭
		name_BloodseekerVines, icon_BloodseekerVines, count_BloodseekerVines, dispelType_BloodseekerVines, duration_BloodseekerVines, expires_BloodseekerVines, caster_BloodseekerVines, isStealable_BloodseekerVines, nameplateShowPersonal_BloodseekerVines, spellID_BloodseekerVines = AuraUtil.FindAuraByName('觅血缠藤', "target", "HARMFUL")
			--觅血缠藤
		if select(7, AuraUtil.FindAuraByName('觅血缠藤', "target", "HARMFUL")) ~= "player" then
			name_BloodseekerVines, icon_BloodseekerVines, count_BloodseekerVines, dispelType_BloodseekerVines, duration_BloodseekerVines, expires_BloodseekerVines, caster_BloodseekerVines, isStealable_BloodseekerVines, nameplateShowPersonal_BloodseekerVines, spellID_BloodseekerVines = nil
		end

		for k, v in ipairs(Feral_EnemyCacheHasThreatIn7) do
			DamagerEngineGetInterruptSpell(v.Unit)
			--获取常规技能打断
		end
		for k, v in ipairs(Feral_EnemyCacheHasThreat) do
			DamagerEngineGetControlInterruptSpell(v.Unit)
			--获取控制技能打断
		end
		
		for k, v in ipairs(Feral_EnemyCacheS) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) and (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
			--获取不攻击BUFF、判断目标是否可以攻击
				local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(v.Unit)
				local timeLeft = endTime and endTime - GetTime() * 1000
				--剩余施法时间(单位:毫秒)
				local castTime = endTime and endTime - startTime
				--施法总时间(单位:毫秒)
				Feral_AutoDPS_ShredTargetS_Switch = 1
				if v.UnitName == "爆炸物" and timeLeft and timeLeft > 3000 and #Feral_EnemyCacheS < 3 then
					--爆炸剩余施法时间大于3秒且特殊目标小于3则不攻击
					Feral_AutoDPS_ShredTargetS_Switch = nil
				end
				if Feral_AutoDPS_ShredTargetS_Switch then
					Feral_AutoDPS_ShredTargetS = v.Unit
					--特殊目标撕碎
					break
				end
			end
		end
		
		for k, v in ipairs(Feral_EnemyCacheHasThreat) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_ShredTargetS and (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
			--获取不攻击BUFF、判断目标是否可以攻击
				DamagerEngineGetSinglePriorityUnit(v.Unit)
				--获取优先击杀目标
			end
		end
		
		--Feral_EnemyCount = #Feral_EnemyCacheHasThreat
		Feral_EnemyCount = #Feral_EnemyCacheHasThreatIn7
		
		if DamagerEngine_AutoDPS_SinglePriorityTatgetExists then
		--优先击杀目标,单体输出,不AOE
			local Unit = DamagerEngine_AutoDPS_DPSTarget
			
			local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), Unit, "HARMFUL")
			--割裂
			if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), Unit, "HARMFUL")) ~= "player" then
				name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
			end
			local timeLeft1 = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
			--DEBUFF剩余时间
			if (not name1 or (duration1 and timeLeft1 < duration1 * 0.25)) and ((UnitHealthMax(Unit) - UnitHealth(Unit) > UnitHealthMax("player") * 0.01) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #Feral_DamagerAssigned <= 1) and (UnitHealth(Unit) > UnitHealthMax("player") * 1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #Feral_DamagerAssigned <= 1) then
				--print("割裂 - "..v.UnitName)
				Feral_AutoDPS_RipTarget = Unit
				--割裂目标
			end
			
			local name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = AuraUtil.FindAuraByName(DA_GetSpellInfo(155722), Unit, "HARMFUL")
			--斜掠
			if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(155722), Unit, "HARMFUL")) ~= "player" then
				name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = nil
			end
			if (not name2 or (expires2 and expires2 - GetTime() < 2)) and ((UnitHealthMax(Unit) - UnitHealth(Unit) > UnitHealthMax("player") * 0.01) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #Feral_DamagerAssigned <= 1) and (UnitHealth(Unit) > UnitHealthMax("player") * 0.1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #Feral_DamagerAssigned <= 1) then
				--print("斜掠 - "..v.UnitName)
				Feral_AutoDPS_RakeTarget = Unit
				--斜掠目标
			end
			
			local name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), Unit, "HARMFUL")
			--月火术
			if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), Unit, "HARMFUL")) ~= "player" then
				name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = nil
			end
			if IsPlayerSpell(155580) and (not name2 or (expires2 and expires2 - GetTime() < 2)) and ((UnitHealthMax(Unit) - UnitHealth(Unit) > UnitHealthMax("player") * 0.01) or not IsInInstance() or C_PvP.IsActiveBattlefield() or #Feral_DamagerAssigned <= 1) and (UnitHealth(Unit) > UnitHealthMax("player") * 0.1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #Feral_DamagerAssigned <= 1) then
				--print("月火术 - "..v.UnitName)
				Feral_AutoDPS_MoonfireTarget = Unit
				--月火术目标
			end
			Feral_AutoDPS_DPSTarget = Unit
			
			Feral_EnemyCount = 1
			--单体输出,不AOE
		end
		if FeralSaves.FeralOption_TargetFilter ~= 2 then
			--自动选择目标模式
			
			for k, v in ipairs(Feral_EnemyCacheHasThreat) do
				if v.UnitHealth < UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR then
					--print("即将死亡 - "..v.UnitName)
					Feral_EnemyCacheHasThreatUnitDying = v.Unit
					--检测是否有单位即将死亡
					break
				end
			end
			
			if not DamagerEngine_AutoDPS_SinglePriorityTatgetExists then
				for k, v in ipairs(Feral_EnemyCacheHasThreat) do
					if (ComboPoints >= 5 or v.UnitHealthScale < 0.25) and not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_RipTarget and (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
					--获取不攻击BUFF、判断目标是否可以攻击
						if string.match(UnitName(v.Unit), "训练假人") then
							v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
							v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							TargetHealthScale = v.UnitHealth / v.UnitHealthMax
						end
						if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
						--[矶石宝库]部分小怪初始血量为80%,70%,60%
							local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), v.Unit, "HARMFUL")
							--割裂
							if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), v.Unit, "HARMFUL")) ~= "player" then
								name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
							end
							local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
							--DEBUFF剩余时间
							if duration1 and timeLeft < duration1 * 0.25 then
								Feral_RipCanFlash = 1
								if v.UnitHealthScale < 0.25 then
									--Feral_RipFlashWithFerociousBiteUnit = v.Unit
									--9.0凶猛撕咬已经无法刷新割裂
								end
							else
								Feral_RipCanFlash = nil
							end
							if IsPlayerSpell(285381) and Feral_EnemyCount >= 3 then
								--选择[原始之怒]天赋且敌对目标大于等于3时,割裂血量要求为普通割裂的1/3
								if (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or (#DamagerEngine_DamagerAssigned <= 3 and v.UnitHealth > UnitHealthMax("player") * 1 * SDPHR) or C_PvP.IsActiveBattlefield() then
									Feral_HealthControl = nil
								else
									Feral_HealthControl = 1
								end
							else
								if (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or (#DamagerEngine_DamagerAssigned <= 3 and v.UnitHealth > UnitHealthMax("player") * 3 * SDPHR) or C_PvP.IsActiveBattlefield() then
									Feral_HealthControl = nil
								else
									Feral_HealthControl = 1
								end
							end
							
							if (not name1 or Feral_RipCanFlash) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.1) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								--print("割裂 - "..v.UnitName)
								Feral_AutoDPS_RipTarget = v.Unit
								--割裂目标
								break
							end
						end
					end
				end
				
				for k, v in ipairs(Feral_EnemyCacheHasThreat) do
					if (ComboPoints < 5 or IsStealthed()) and not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_RakeTarget and (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
					--获取不攻击BUFF、判断目标是否可以攻击
						if string.match(UnitName(v.Unit), "训练假人") then
							v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
							v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							TargetHealthScale = v.UnitHealth / v.UnitHealthMax
						end
						if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
						--[矶石宝库]部分小怪初始血量为80%,70%,60%
							local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(155722), v.Unit, "HARMFUL")
							--斜掠
							if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(155722), v.Unit, "HARMFUL")) ~= "player" then
								name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
							end
							local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
							--DEBUFF剩余时间
							if spellID1 == 155722 and (timeLeft < duration1 * 0.2 or (C_PvP.IsActiveBattlefield() and UnitIsPlayer(v.Unit) and not AuraUtil.FindAuraByName(DA_GetSpellInfo(58180), v.Unit, "HARMFUL"))) then
								Feral_RakeCanFlash = 1
							else
								Feral_RakeCanFlash = nil
							end
							if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
								Feral_HealthControl = nil
							else
								Feral_HealthControl = 1
							end
							if (not name1 or Feral_RakeCanFlash) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								--print("斜掠 - "..v.UnitName)
								Feral_AutoDPS_RakeTarget = v.Unit
								--斜掠目标
								break
							end
						end
					end
				end
			
				for k, v in ipairs(Feral_EnemyCacheHasThreat) do
					if IsPlayerSpell(439528) and IsPlayerSpell(440120) and not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_BloodseekerVinesUnit and (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
					--学习了英雄天赋[兴荣生长]及[爆裂增生],获取不攻击BUFF、判断目标是否可以攻击
						if string.match(UnitName(v.Unit), "训练假人") then
							v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
							v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							TargetHealthScale = v.UnitHealth / v.UnitHealthMax
						end
						if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
						--[矶石宝库]部分小怪初始血量为80%,70%,60%
							local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('觅血缠藤', v.Unit, "HARMFUL")
							--觅血缠藤
							if select(7, AuraUtil.FindAuraByName('觅血缠藤', v.Unit, "HARMFUL")) ~= "player" then
								name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
							end
							local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
							--DEBUFF剩余时间
							if timeLeft >= 0.5 then
								Feral_BloodseekerVinesUnit = v.Unit
								--觅血缠藤目标
								break
							end
						end
					end
				end
				
				if DA_IsSpellInRange(Shred_SpellID, "target") == 1 then
					for k, v in ipairs(Feral_EnemyCacheHasThreat) do
						if (ComboPoints < 5 or DA_IsSpellInRange(Shred_SpellID, "target") ~= 1) and IsPlayerSpell(155580) and not IsStealthed() and not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_MoonfireTarget then
						--获取不攻击BUFF、判断目标是否可以攻击
							if string.match(UnitName(v.Unit), "训练假人") then
								v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
								v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
								Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
								TargetHealthScale = v.UnitHealth / v.UnitHealthMax
							end
							if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
							--[矶石宝库]部分小怪初始血量为80%,70%,60%
								local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), v.Unit, "HARMFUL")
								--月火术
								if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), v.Unit, "HARMFUL")) ~= "player" then
									name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
								end
								local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
								--DEBUFF剩余时间
								if spellID1 == Moonfire_SpellID and timeLeft < duration1 * 0.2 then
									Feral_MoonfireCanFlash = 1
								else
									Feral_MoonfireCanFlash = nil
								end
								if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
									Feral_HealthControl = nil
								else
									Feral_HealthControl = 1
								end
								
								if (not name1 or Feral_MoonfireCanFlash) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
									--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
									--print("月火术 - "..v.UnitName)
									Feral_AutoDPS_MoonfireTarget = v.Unit
									--月火术目标
									break
								end
							end
						end
					end
				elseif PlayerPowerScale > 0.85 then
					for k, v in ipairs(Feral_MoonfireEnemyCacheHasThreat) do
						if IsPlayerSpell(155580) and not IsStealthed() and not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_MoonfireTarget then
						--获取不攻击BUFF、判断目标是否可以攻击
							if string.match(UnitName(v.Unit), "训练假人") then
								v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
								v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
								Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
								TargetHealthScale = v.UnitHealth / v.UnitHealthMax
							end
							if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
							--[矶石宝库]部分小怪初始血量为80%,70%,60%
								local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), v.Unit, "HARMFUL")
								--月火术
								if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), v.Unit, "HARMFUL")) ~= "player" then
									name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
								end
								local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
								--DEBUFF剩余时间
								if spellID1 == Moonfire_SpellID and timeLeft < duration1 * 0.2 then
									Feral_MoonfireCanFlash = 1
								else
									Feral_MoonfireCanFlash = nil
								end
								if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
									Feral_HealthControl = nil
								else
									Feral_HealthControl = 1
								end
								
								if (not name1 or Feral_MoonfireCanFlash) and ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
									--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
									--print("月火术 - "..v.UnitName)
									Feral_AutoDPS_MoonfireTarget = v.Unit
									--月火术目标
									break
								end
							end
						end
					end
					if not Feral_AutoDPS_MoonfireTarget then
						--Feral_MoonfireEnemyCacheHasThreat中的所有目标都已经有月火术DEBUFF的情况下,PlayerPowerScale > 0.85则重复使用月火术
						for k, v in ipairs(Feral_MoonfireEnemyCacheHasThreat) do
							if IsPlayerSpell(155580) and not IsStealthed() and not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_MoonfireTarget then
							--获取不攻击BUFF、判断目标是否可以攻击
								if string.match(UnitName(v.Unit), "训练假人") then
									v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
									v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
									Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
									TargetHealthScale = v.UnitHealth / v.UnitHealthMax
								end
								if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
								--[矶石宝库]部分小怪初始血量为80%,70%,60%
									local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), v.Unit, "HARMFUL")
									--月火术
									if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), v.Unit, "HARMFUL")) ~= "player" then
										name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
									end
									local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
									--DEBUFF剩余时间
									if spellID1 == Moonfire_SpellID and timeLeft < duration1 * 0.2 then
										Feral_MoonfireCanFlash = 1
									else
										Feral_MoonfireCanFlash = nil
									end
									if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (v.UnitHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
										Feral_HealthControl = nil
									else
										Feral_HealthControl = 1
									end
									
									if ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
										--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
										--print("月火术 - "..v.UnitName)
										Feral_AutoDPS_MoonfireTarget = v.Unit
										--月火术目标
										break
									end
								end
							end
						end
					end
				end
				
				for k, v in ipairs(Feral_EnemyCacheHasThreat) do
					if not DamagerEngineGetNoAttackAuras(v.Unit) and not Feral_AutoDPS_DPSTarget then
					--获取不攻击BUFF、判断目标是否可以攻击
						if string.match(UnitName(v.Unit), "训练假人") then
							v.UnitHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
							v.UnitHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
							TargetHealthScale = v.UnitHealth / v.UnitHealthMax
						end
						if TargetHealthScale ~= 0.8 and TargetHealthScale ~= 0.7 and TargetHealthScale ~= 0.6 then
						--[矶石宝库]部分小怪初始血量为80%,70%,60%
							if (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
								if ((v.UnitHealthMax - v.UnitHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), v.Unit, "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (v.UnitHealth > UnitHealthMax("player") * 0.1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
									--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
									--print("循环输出目标 - "..v.UnitName)
									Feral_AutoDPS_DPSTarget = v.Unit
									--循环输出目标
									break
								end
							end
						end
					end
				end
			
				for k, v in ipairs(Feral_EnemyCacheHasThreat) do
					if not DamagerEngineGetNoAttackAuras(v.Unit) then
					--获取不攻击BUFF
						if DA_UnitHasEnrage(v.Unit) and (v.UnitHealth > UnitHealthMax("player") * 1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
							--print("驱散激怒效果 - "..v.UnitName)
							Feral_ClearEnrageTarget = v.Unit
							--驱散激怒效果目标
							break
						end
					end
				end
				
				for k, v in ipairs(Feral_EnemyCacheS2) do
					if not DamagerEngineGetNoAttackAuras(v.Unit) then
					--获取不攻击BUFF、判断目标是否可以攻击
						if (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
							--print("循环输出目标 - "..v.UnitName)
							Feral_AutoDPS_DPSTarget = v.Unit
							--部分特殊目标先打血高的
							break
						end
					end
				end
				
				for k, v in ipairs(Feral_EnemyCacheS3) do
					if not DamagerEngineGetNoAttackAuras(v.Unit) then
					--获取不攻击BUFF、判断目标是否可以攻击
						if (DA_GetFacing("player", v.Unit) or not WoWAssistantUnlocked) then
							--print("循环输出目标 - "..v.UnitName)
							Feral_AutoDPS_DPSTarget = v.Unit
							--部分特殊目标先打血低的
							break
						end
					end
				end
				
			end
		end
		
		if FeralSaves.FeralOption_TargetFilter == 2 then
			--手动选择目标模式
			if UnitExists("target") and UnitHealth("target") / UnitHealthMax("target") ~= 0.8 and UnitHealth("target") / UnitHealthMax("target") ~= 0.7 and UnitHealth("target") / UnitHealthMax("target") ~= 0.6 then --[矶石宝库]部分小怪初始血量为80%,70%,60%
				local status = UnitThreatSituation("player", "target")
				local TargetHealth = UnitHealth("target")
				local TargetHealthMax = UnitHealthMax("target")
				local TargetHealthScale = TargetHealth / TargetHealthMax
		
				if string.match(UnitName("target"), "训练假人") then
					TargetHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
					TargetHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
					Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
					TargetHealthScale = TargetHealth / TargetHealthMax
				end
			
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
				and (DA_GetLineOfSight("player", "target") or not WoWAssistantUnlocked) and UnitExists("target") and not UnitIsDeadOrGhost("target") and (not UnitIsFriend("target", "player") or UnitIsEnemy("target", "player")) and UnitPhaseReason("target")~=0 and UnitPhaseReason("target")~=1 and UnitCanAttack("player","target") then
					
					if (ComboPoints >= 5 or TargetHealthScale < 0.25) and not DamagerEngineGetNoAttackAuras("target") and not Feral_AutoDPS_RipTarget and (DA_GetFacing("player",  "target") or not WoWAssistantUnlocked) and DA_IsSpellInRange(Shred_SpellID, "target") == 1 then
					--获取不攻击BUFF、判断目标是否可以攻击
						local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), "target", "HARMFUL")
						--割裂
						if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Rip_SpellID), "target", "HARMFUL")) ~= "player" then
							name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
						end
						local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
						--DEBUFF剩余时间
						if duration1 and timeLeft < duration1 * 0.25 then
							Feral_RipCanFlash = 1
							if TargetHealthScale < 0.25 then
								--Feral_RipFlashWithFerociousBiteUnit = "target"
								--9.0凶猛撕咬已经无法刷新割裂
							end
						else
							Feral_RipCanFlash = nil
						end
						
						if IsPlayerSpell(285381) and Feral_EnemyCount >= 3 then
							--选择[原始之怒]天赋且敌对目标大于等于3时,割裂血量要求为普通割裂的1/3
							if (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or (#DamagerEngine_DamagerAssigned <= 3 and TargetHealth > UnitHealthMax("player") * 1 * SDPHR) or C_PvP.IsActiveBattlefield() then
								Feral_HealthControl = nil
							else
								Feral_HealthControl = 1
							end
						else
							if (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 6 * SDPHR) or (#DamagerEngine_DamagerAssigned <= 3 and TargetHealth > UnitHealthMax("player") * 3 * SDPHR) or C_PvP.IsActiveBattlefield() then
								Feral_HealthControl = nil
							else
								Feral_HealthControl = 1
							end
						end
						
						if (not name1 or Feral_RipCanFlash) and ((TargetHealthMax - TargetHealth > UnitHealthMax("player") * 0.1) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
							--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
							Feral_AutoDPS_RipTarget = "target"
							--割裂目标
						end
					end
					
					if (ComboPoints < 5 or IsStealthed()) and not DamagerEngineGetNoAttackAuras("target") and not Feral_AutoDPS_RakeTarget and (DA_GetFacing("player",  "target") or not WoWAssistantUnlocked) and DA_IsSpellInRange(Shred_SpellID, "target") == 1 then
					--获取不攻击BUFF、判断目标是否可以攻击
						local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(155722), "target", "HARMFUL")
						--斜掠
						if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(155722), "target", "HARMFUL")) ~= "player" then
							name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
						end
						local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
						--DEBUFF剩余时间
						if spellID1 == 155722 and (timeLeft < duration1 * 0.2 or (C_PvP.IsActiveBattlefield() and UnitIsPlayer("target") and not AuraUtil.FindAuraByName(DA_GetSpellInfo(58180), "target", "HARMFUL"))) then
							Feral_RakeCanFlash = 1
						else
							Feral_RakeCanFlash = nil
						end
						if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
							Feral_HealthControl = nil
						else
							Feral_HealthControl = 1
						end
						
						if (not name1 or Feral_RakeCanFlash) and ((TargetHealthMax - TargetHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
							--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
							Feral_AutoDPS_RakeTarget = "target"
							--斜掠目标
						end
					end

					if DA_IsSpellInRange(Shred_SpellID, "target") == 1 then
						if (ComboPoints < 5 or DA_IsSpellInRange(Shred_SpellID, "target") ~= 1) and IsPlayerSpell(155580) and not IsStealthed() and not DamagerEngineGetNoAttackAuras("target") and not Feral_AutoDPS_MoonfireTarget then
						--获取不攻击BUFF、判断目标是否可以攻击
							local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), "target", "HARMFUL")
							--月火术
							if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), "target", "HARMFUL")) ~= "player" then
								name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
							end
							local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
							--DEBUFF剩余时间
							if spellID1 == Moonfire_SpellID and timeLeft < duration1 * 0.2 then
								Feral_MoonfireCanFlash = 1
							else
								Feral_MoonfireCanFlash = nil
							end
							if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
								Feral_HealthControl = nil
							else
								Feral_HealthControl = 1
							end
							
							if (not name1 or Feral_MoonfireCanFlash) and ((TargetHealthMax - TargetHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								Feral_AutoDPS_MoonfireTarget = "target"
								--月火术目标
							end
						end
					elseif PlayerPowerScale > 0.85 and Feral_GetMoonfireTargetCanAttack("target") then
						if IsPlayerSpell(155580) and not IsStealthed() and not DamagerEngineGetNoAttackAuras("target") and not Feral_AutoDPS_MoonfireTarget then
						--获取不攻击BUFF、判断目标是否可以攻击
							local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), "target", "HARMFUL")
							--月火术
							if select(7, AuraUtil.FindAuraByName(DA_GetSpellInfo(Moonfire_SpellID), "target", "HARMFUL")) ~= "player" then
								name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = nil
							end
							local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
							--DEBUFF剩余时间
							if spellID1 == Moonfire_SpellID and timeLeft < duration1 * 0.2 then
								Feral_MoonfireCanFlash = 1
							else
								Feral_MoonfireCanFlash = nil
							end
							if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 then
								Feral_HealthControl = nil
							else
								Feral_HealthControl = 1
							end
							
							if (not name1 or Feral_MoonfireCanFlash or PlayerPowerScale > 0.85) and ((TargetHealthMax - TargetHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and not Feral_HealthControl then
								--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
								Feral_AutoDPS_MoonfireTarget = "target"
								--月火术目标
							end
						end
					end
					
					if (DA_GetFacing("player",  "target") or not WoWAssistantUnlocked) then
						if ((TargetHealthMax - TargetHealth > UnitHealthMax("player") * 0.05) or AuraUtil.FindAuraByName(DA_GetSpellInfo(445262), "target", "HELPFUL") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and (TargetHealth > UnitHealthMax("player") * 0.1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) and DA_IsSpellInRange(Shred_SpellID, "target") == 1 and not DamagerEngineGetNoAttackAuras("target") then
							--(445262)为驭雷栖巢虚空石畸体的[虚空壳壁],BUFF效果为吸收所有伤害
							Feral_AutoDPS_DPSTarget = "target"
							--循环输出目标
						end
					end
					
					if DA_UnitHasEnrage("target") and (TargetHealth > UnitHealthMax("player") * 1 or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2) then
						Feral_ClearEnrageTarget = "target"
						--驱散激怒效果目标
					end
				end
			end
		end
		
		TargetHealth, TargetHealthScale = 0, 0
		if Feral_AutoDPS_DPSTarget then
			TargetHealth = UnitHealth(Feral_AutoDPS_DPSTarget)
			TargetHealthScale = UnitHealth(Feral_AutoDPS_DPSTarget) / UnitHealthMax(Feral_AutoDPS_DPSTarget)
		end
		
		if Feral_AutoDPS_DPSTarget and string.match(UnitName(Feral_AutoDPS_DPSTarget), "训练假人") then
			TargetHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 100
			TargetHealthMax = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
			Feral_Enemy_SumHealth = UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 200
			TargetHealthScale = TargetHealth / TargetHealthMax
		end
		
		local RegrowthTarget = nil
		local RegrowthTargetHealthScale = 0
		if DamagerEngine_GroupMember and #DamagerEngine_GroupMember > 1 then
			for k, v in ipairs(DamagerEngine_GroupMember) do
				if not Feral_GetTargetNotVisible(v.Unit) and DA_IsSpellInRange(Regrowth_SpellID, v.Unit) == 1 and (DA_GetLineOfSight("player", v.Unit) or not WoWAssistantUnlocked) and not UnitIsCharmed(v.Unit) and UnitReaction("player", v.Unit) > 4 and UnitIsConnected(v.Unit) and UnitCanAssist("player", v.Unit) and UnitIsVisible(v.Unit) and UnitPhaseReason(v.Unit)~=0 and UnitPhaseReason(v.Unit)~=1 and (UnitInRange(v.Unit) or not IsInGroup()) then
					RegrowthTarget = v.Unit
					break
				end
			end
		else
			RegrowthTarget = "player"
		end
		if RegrowthTarget then
			RegrowthTargetHealthScale = UnitHealth(RegrowthTarget) / UnitHealthMax(RegrowthTarget)
			if PlayerHealthScale < 0.9 and PlayerHealthScale - RegrowthTargetHealthScale < 0.1 then
			--玩家血量低于90%时,队友血量比玩家血量低10%以内,则优先治疗玩家
				RegrowthTarget = "player"
			end
		end
		
		if IsPlayerSpell(102543) then
			start1, duration1 = DA_GetSpellCooldown(113)
			start2, duration2 = DA_GetSpellCooldown(Incarnation_Avatar_of_Ashamane_SpellID)
			if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Incarnation_Avatar_of_Ashamane_SpellID)) > 3 or not IsPlayerSpell(Incarnation_Avatar_of_Ashamane_SpellID) then
				BerserkCD = 1
			elseif duration2 == 0 then
				BerserkCD = nil
			end
			--化身CD判断
		else
			start1, duration1 = DA_GetSpellCooldown(113)
			start2, duration2 = DA_GetSpellCooldown(Berserk_SpellID)
			if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Berserk_SpellID)) > 3 or not IsPlayerSpell(Berserk_SpellID) then
				BerserkCD = 1
			elseif duration2 == 0 then
				BerserkCD = nil
			end
			--狂暴CD判断
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
		
		start2, duration2 = DA_GetSpellCooldown(Survival_Instincts_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Survival_Instincts_SpellID)) > 3 or not IsPlayerSpell(Survival_Instincts_SpellID) then
			SurvivalInstinctsCD = 1
		elseif duration2 == 0 then
			SurvivalInstinctsCD = nil
		end
		--生存本能CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Skull_Bash_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Skull_Bash_SpellID)) > 3 or not IsPlayerSpell(Skull_Bash_SpellID) then
			SkullBashCD = 1
		elseif duration2 == 0 then
			SkullBashCD = nil
		end
		--迎头痛击CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Incapacitating_Roar_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Incapacitating_Roar_SpellID) or not IsPlayerSpell(Incapacitating_Roar_SpellID) then
			Incapacitating_RoarCD = 1
		elseif duration2 == duration then
			Incapacitating_RoarCD = nil
		end
		--夺魂咆哮CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Mighty_Bash_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Mighty_Bash_SpellID) or not IsPlayerSpell(Mighty_Bash_SpellID) then
			MightyBashCD = 1
		elseif duration2 == duration then
			MightyBashCD = nil
		end
		--蛮力猛击CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Remove_Corruption_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Remove_Corruption_SpellID) or not IsPlayerSpell(Remove_Corruption_SpellID) then
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
		
		start2, duration2 = DA_GetSpellCooldown(Soothe_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Soothe_SpellID) or select(2, DA_GetSpellCooldown(Soothe_SpellID)) > 3 or not IsPlayerSpell(Soothe_SpellID) then
			SootheCD = 1
		elseif duration2 == duration then
			SootheCD = nil
		end
		--安抚CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Convoke_the_Spirits_SpellID)
		if (duration2 ~= duration and GetTime() - start2 > 0.5) or not DA_IsUsableSpell(Convoke_the_Spirits_SpellID) or not IsPlayerSpell(Convoke_the_Spirits_SpellID) or not FeralSaves.FeralOption_Attack_AutoCovenant or DamagerEngine_NoCastingAuras or DamagerEngine_NoChannelAuras then
			--延迟0.5秒进CD
			ConvokeTheSpiritsCD = 1
		elseif duration2 == duration then
			ConvokeTheSpiritsCD = nil
		end
		--万灵之召CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Adaptive_Swarm_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Adaptive_Swarm_SpellID) or not IsPlayerSpell(Adaptive_Swarm_SpellID) then
			AdaptiveSwarmCD = 1
		elseif duration2 == duration then
			AdaptiveSwarmCD = nil
		end
		--激变蜂群CD判断
		
		start2, duration2 = DA_GetSpellCooldown(22570)
		if duration2 ~= duration or not DA_IsUsableSpell(22570) or not IsPlayerSpell(22570) then
			MaimCD = 1
		elseif duration2 == duration then
			MaimCD = nil
		end
		--割碎CD判断
		
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
		
		if FeralSaves.FeralOption_Attack_AutoIronbark and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
		--自动保命
			if C_PvP.IsActiveBattlefield() then
			--PVP
				if PlayerHealthScale <= 0.3 and UnitAffectingCombat("player") and IsPlayerSpell(Renewal_SpellID) and not RenewalCD and not IsStealthed() then
					DA_CastSpellByName('熊形态甘霖治疗石宏')
					--熊形态甘霖治疗石宏
					Feral_SetDebugInfo("甘霖")
					Feral_CastSpellIng = 1
					Feral_SelfSaveIng = 1
				elseif PlayerHealthScale <= 0.5 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not FrenziedRegenerationCD then
					DA_CastSpellByName('熊形态狂暴回复宏')
					--熊形态狂暴回复宏
					Feral_SetDebugInfo("狂暴回复")
					Feral_CastSpellIng = 1
					Feral_SelfSaveIng = 1
				elseif PlayerHealthScale <= 0.8 and UnitAffectingCombat("player") and IsPlayerSpell(441689) and GetShapeshiftFormID() == 1 and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not FrenziedRegenerationCD and not IsStealthed() then
					DA_CastSpellByID(Frenzied_Regeneration_SpellID, "player")
					--狂暴回复
					Feral_SetDebugInfo("狂暴回复")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.8 and not UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and DA_IsUsableSpell(Rejuvenation_SpellID) and not IsStealthed() and not AuraUtil.FindAuraByName(DA_GetSpellInfo(Rejuvenation_SpellID), "player", "HELPFUL") and IsPlayerSpell(774) and not WrathCD then
					DA_CastSpellByID(Rejuvenation_SpellID)
					--回春术
					Feral_SetDebugInfo("回春术")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.5 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName(DA_GetSpellInfo(Survival_Instincts_SpellID), "player", "HELPFUL") and IsPlayerSpell(Survival_Instincts_SpellID) and not SurvivalInstinctsCD and not IsStealthed() then
					DA_CastSpellByID(Survival_Instincts_SpellID, "player")
					--生存本能
					Feral_SetDebugInfo("生存本能")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.7 and UnitAffectingCombat("player") and not BarkskinCD and not IsStealthed() then
					DA_CastSpellByID(Barkskin_SpellID, "player")
					--树皮术
					Feral_SetDebugInfo("树皮术")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.8 and not UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Feral_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合自己
					Feral_SetDebugInfo("愈合")
					Feral_CastSpellIng = 1
				elseif RegrowthTargetHealthScale <= 0.9 and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and expires_PredatorySwiftness and expires_PredatorySwiftness - GetTime() > 0.25 and (not Feral_AutoDPS_DPSTarget or PlayerPowerVacancy >= 40) and not IsStealthed() and not HealerEngine_GetNoHealAuras(RegrowthTarget) then
					if UnitGUID(RegrowthTarget) == UnitGUID("player") then
						DA_CastSpellByID(Regrowth_SpellID)
						--愈合自己
					elseif UnitGUID(RegrowthTarget) == UnitGUID("party1") then
						DA_CastSpellByName('队友1愈合宏')
						--队友1愈合宏
					elseif UnitGUID(RegrowthTarget) == UnitGUID("party2") then
						DA_CastSpellByName('队友2愈合宏')
						--队友2愈合宏
					elseif UnitGUID(RegrowthTarget) == UnitGUID("party3") then
						DA_CastSpellByName('队友3愈合宏')
						--队友3愈合宏
					elseif UnitGUID(RegrowthTarget) == UnitGUID("party4") then
						DA_CastSpellByName('队友4愈合宏')
						--队友4愈合宏
					end
					--愈合
					Feral_SetDebugInfo("愈合")
					Feral_CastSpellIng = 1
				end
			else
			--非PVP
				if PlayerHealthScale <= 0.4 and UnitAffectingCombat("player") and C_Item.IsUsableItem(5512) and GetItemCooldown(5512) == 0 and not IsStealthed() then
					DA_UseItem(5512)
					--治疗石
					Feral_CastSpellIng = 1
				end
				if PlayerHealthScale <= 0.5 and UnitAffectingCombat("player") and IsPlayerSpell(Renewal_SpellID) and not RenewalCD and not IsStealthed() then
					DA_CastSpellByID(Renewal_SpellID, "player")
					--甘霖
					Feral_SetDebugInfo("甘霖")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.5 and UnitAffectingCombat("player") and IsPlayerSpell(441689) and GetShapeshiftFormID() == 1 and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not FrenziedRegenerationCD and not IsStealthed() then
					DA_CastSpellByID(Frenzied_Regeneration_SpellID, "player")
					--狂暴回复
					Feral_SetDebugInfo("狂暴回复")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.6 and UnitAffectingCombat("player") and IsPlayerSpell(Survival_Instincts_SpellID) and not AuraUtil.FindAuraByName(DA_GetSpellInfo(Survival_Instincts_SpellID), "player", "HELPFUL") and not SurvivalInstinctsCD and not IsStealthed() then
					DA_CastSpellByID(Survival_Instincts_SpellID, "player")
					--生存本能
					Feral_SetDebugInfo("生存本能")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.7 and UnitAffectingCombat("player") and IsPlayerSpell(Barkskin_SpellID) and not BarkskinCD and not IsStealthed() then
					DA_CastSpellByID(Barkskin_SpellID, "player")
					--树皮术
					Feral_SetDebugInfo("树皮术")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.3 and UnitAffectingCombat("player") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Feral_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合自己
					Feral_SetDebugInfo("愈合")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.7 and not UnitAffectingCombat("player") and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and Feral_IsCanMovingCast(Regrowth_SpellID) and not IsStealthed() and not DamagerEngine_NoCastingAuras and not HealerEngine_GetNoHealAuras("player") then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合自己
					Feral_SetDebugInfo("愈合")
					Feral_CastSpellIng = 1
				elseif PlayerHealthScale <= 0.8 and IsPlayerSpell(Regrowth_SpellID) and not WrathCD and DA_IsUsableSpell(Regrowth_SpellID) and expires_PredatorySwiftness and expires_PredatorySwiftness - GetTime() > 0.25 and (not Feral_AutoDPS_DPSTarget or PlayerPowerVacancy >= 40) and not IsStealthed() and not HealerEngine_GetNoHealAuras('player') then
					DA_CastSpellByID(Regrowth_SpellID)
					--愈合自己
					Feral_SetDebugInfo("愈合")
					Feral_CastSpellIng = 1
				end
			end
		end
		
		if UnitIsEnemy('target', "player") and DA_GetUnitDistance('target') <= 5 then
		--敌方目标在5码范围内则不解定身
			DA_Clear_Rooted = nil
		end
		if UnitIsEnemy('target', "player") and DA_GetUnitDistance('target') <= 7 then
		--敌方目标在7码范围内则不解减速
			DA_Clear_Deceleration = nil
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
		if FeralSaves.FeralOption_Other_ClearRoot and UnitAffectingCombat("player") and C_Spell.GetSpellLossOfControlCooldown(Regrowth_SpellID) == 0 then
			local speed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
			local Rooted, timeRemaining, spellID = DA_CheckPlayerRooted()
			if ((Rooted and timeRemaining and timeRemaining >= 0.35 and DA_Clear_Rooted) or (not IsSwimming() and speed ~= 0 and speed ~= 2.5 and speed ~= 4.5 and DA_GetUnitSpeed('player') <= 90 and DA_Clear_Deceleration)) then
			--被定身减速
				--print('被定身减速')
				if not UnitChannelInfo("player") and not IsFalling() and not IsFlying() and not UnitOnTaxi("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not Feral_SelfSaveIng then
					if (GetShapeshiftFormID() == 1 or AuraUtil.FindAuraByName('猎豹形态', "player", "HELPFUL")) and not IsStealthed() then
					--猎豹形态下直接通过取消变形解除定身
						--print('取消变形解除定身')
						DA_Cancelform()
						--print('取消变形3')
					elseif (GetShapeshiftFormID() == 5 or AuraUtil.FindAuraByName('熊形态', "player", "HELPFUL")) and not IsStealthed() then
					--熊形态下直接通过取消变形解除定身
						--print('取消变形解除定身')
						DA_Cancelform()
						--print('取消变形4')
					elseif select(2, DA_GetSpellCooldown(768)) ~= 0 and select(2, DA_GetSpellCooldown(Bear_Form_SpellID)) == 0 and not IsStealthed() then
					--取消变形后猎豹形态公共CD,但是熊形态没有公共CD,则通过熊形态解除定身
						--print('熊形态解除定身')
						DA_CastSpellByID(Bear_Form_SpellID, "player")
						--熊形态
						Feral_SetDebugInfo("熊形态")
						Feral_CastSpellIng = 1
					elseif not IsStealthed() then
					--非猎豹形态下直接通过猎豹形态解除定身
						--print('猎豹形态解除定身')
						DA_CastSpellByID(768, "player")
						--猎豹形态
						Feral_SetDebugInfo("猎豹形态")
						Feral_CastSpellIng = 1
					end
				end
			end
		end
		
		if not Feral_CastSpellIng and not Feral_ChannelSpellIng and not Feral_SelfSaveIng and GetShapeshiftFormID() ~= 1 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") then
			DA_CastSpellByID(768, "player")
			--猎豹形态
			Feral_SetDebugInfo("猎豹形态")
			Feral_CastSpellIng = 1
		end
		
		if FeralSaves.FeralOption_Auras_ClearCurse or FeralSaves.FeralOption_Auras_ClearPoison or FeralSaves.FeralOption_Auras_ClearMouseover then 
			if IsInRaid() then
				--团队
				if (Feral_ScanUnitAuras_Time and GetTime() - Feral_ScanUnitAuras_Time > 2) or not Feral_ScanUnitAuras_Time then
					Feral_ScanUnitAuras_Time = GetTime()
					--团队中2秒才检测一次,降低CPU占用
					for i=1, GetNumGroupMembers() do
						unitid = "raid"..i
						Feral_ScanUnitAuras(unitid)
						--增减益监测
					end
				end
			elseif IsInGroup() then
				--小队
				for i=1, GetNumGroupMembers() - 1 do
					unitid = "party"..i
					Feral_ScanUnitAuras(unitid)
					--增减益监测
				end
				unitid = "player"
				Feral_ScanUnitAuras(unitid)
				unitid = "focus"
				if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
					Feral_ScanUnitAuras(unitid)
				end
				--增减益监测
			else
				unitid = "player"
				Feral_ScanUnitAuras(unitid)
				unitid = "focus"
				if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
					Feral_ScanUnitAuras(unitid)
				end
				--增减益监测
			end
		end
		
		if FeralSaves.FeralOption_Auras_AutoInterrupt then
		--自动打断
			if DamagerEngineInterruptSpell and IsPlayerSpell(Skull_Bash_SpellID) and (DA_GetFacing("player", DamagerEngineInterruptSpellTarget) or not WoWAssistantUnlocked) and not SkullBashCD and not IsStealthed() and not Feral_ChannelSpellIng then
				DA_TargetUnit(DamagerEngineInterruptSpellTarget)
				if UnitIsUnit('target',DamagerEngineInterruptSpellTarget) then
					DA_CastSpellByID(Skull_Bash_SpellID)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("迎头痛击")
				--迎头痛击
			end
			--if DamagerEngineControlInterruptSpell and IsPlayerSpell(Incapacitating_Roar_SpellID) and (SkullBashCD or DamagerEngine_IsNotInterruptibleSpell) and not Incapacitating_RoarCD and not IsStealthed() and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
				--DA_CastSpellByID(Incapacitating_Roar_SpellID)
				--Feral_CastSpellIng = 1
				--Feral_SetDebugInfo("夺魂咆哮")
				--夺魂咆哮(用于打断[迎头痛击]无法打断的技能,会自动变熊,弃用)
			--end
			if DamagerEngineControlInterruptSpell and IsPlayerSpell(Mighty_Bash_SpellID) and (DA_GetFacing("player", DamagerEngineControlInterruptSpellTarget) or not WoWAssistantUnlocked) and (SkullBashCD or DamagerEngine_IsNotInterruptibleSpell) and not MightyBashCD and not IsStealthed() and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
				DA_TargetUnit(DamagerEngineControlInterruptSpellTarget)
				if UnitIsUnit('target', DamagerEngineControlInterruptSpellTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Mighty_Bash_SpellID), DamagerEngineControlInterruptSpellTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("蛮力猛击")
				--蛮力猛击(用于打断[迎头痛击]无法打断的技能)
			end
		end
		
		if FeralSaves.FeralOption_Other_AutoRebirth and IsPlayerSpell(Rebirth_SpellID) then
			Feral_DeadTankUnitid = Feral_GetTankAssignedDead()
			Feral_DeadHealerUnitid = Feral_GetHealerAssignedDead()
			Feral_DeadDamagerUnitid = Feral_GetDamagerAssignedDead()
			if Feral_DeadTankUnitid and not RebirthCD and UnitAffectingCombat("player") and Feral_IsCanMovingCast(Rebirth_SpellID) and not DamagerEngine_NoCastingAuras and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
				--DA_CancelShapeshiftForm()
				DA_TargetUnit(Feral_DeadTankUnitid)
				if UnitIsUnit('target',Feral_DeadTankUnitid) then
					DA_CastSpellByID(Rebirth_SpellID)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("复生")
			end
			--复生坦克
			if Feral_DeadHealerUnitid and #DamagerEngine_GroupMember <= 7 and #DamagerEngine_TankAssigned >= 1 and not RebirthCD and UnitAffectingCombat("player") and Feral_IsCanMovingCast(Rebirth_SpellID) and not DamagerEngine_NoCastingAuras and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
				--DA_CancelShapeshiftForm()
				DA_TargetUnit(Feral_DeadHealerUnitid)
				if UnitIsUnit('target',Feral_DeadHealerUnitid) then
					DA_CastSpellByID(Rebirth_SpellID)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("复生")
			end
			--复生治疗(附近队友不大于7人)
			if Feral_DeadDamagerUnitid and UnitExists("boss1") and #DamagerEngine_GroupMember <= 7 and #DamagerEngine_TankAssigned >= 1 and not RebirthCD and UnitAffectingCombat("player") and Feral_IsCanMovingCast(Rebirth_SpellID) and not DamagerEngine_NoCastingAuras and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
				--DA_CancelShapeshiftForm()
				DA_TargetUnit(Feral_DeadDamagerUnitid)
				if UnitIsUnit('target',Feral_DeadDamagerUnitid) then
					DA_CastSpellByID(Rebirth_SpellID)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("复生")
			end
			--复生伤害输出(BOSS战,且附近队友不大于7人)
		end
		
		if not Feral_CastSpellIng and not Feral_ChannelSpellIng and not IsStealthed() then
		--特定目标控制
			for k, v in ipairs(Feral_ControlEnemyCache) do
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
								FeralSpellWillBeCast = 1
								--使用[群体缠绕]控制
							end
						elseif IsPlayerSpell(Entangling_Roots_SpellID) and DA_IsUsableSpell(Entangling_Roots_SpellID) and not WrathCD and DA_IsSpellInRange(Entangling_Roots_SpellID, v.Unit) and not DA_EntanglingRootsCastStart and ((Feral_IsCanMovingCast(Entangling_Roots_SpellID) and not DamagerEngine_NoCastingAuras) or select(4, DA_GetSpellInfo('纠缠根须')) == 0) then
							DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
							--选择特定控制目标宏
							if UnitIsUnit('target', v.Unit) then
								DA_CastSpellByID(Entangling_Roots_SpellID)
								FeralSpellWillBeCast = 1
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
								FeralSpellWillBeCast = 1
								--使用[群体缠绕]控制
							end
						elseif IsPlayerSpell(Entangling_Roots_SpellID) and DA_IsUsableSpell(Entangling_Roots_SpellID) and not WrathCD and DA_IsSpellInRange(Entangling_Roots_SpellID, v.Unit) and not DA_EntanglingRootsCastStart and ((Feral_IsCanMovingCast(Entangling_Roots_SpellID) and not DamagerEngine_NoCastingAuras) or select(4, DA_GetSpellInfo('纠缠根须')) == 0) then
							DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
							--选择特定控制目标宏
							if UnitIsUnit('target', v.Unit) then
								DA_CastSpellByID(Entangling_Roots_SpellID)
								FeralSpellWillBeCast = 1
								--使用[纠缠根须]控制
							end
						end
					end
					
					break
				end
			end
		end
		
		if Feral_AutoDPS_ShredTargetS and IsPlayerSpell(Shred_SpellID) and DA_IsUsableSpell(Shred_SpellID) and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
			DA_TargetUnit(Feral_AutoDPS_ShredTargetS)
			if UnitIsUnit('target',Feral_AutoDPS_ShredTargetS) then
				DA_CastSpellByID(Shred_SpellID)
			end
			Feral_SpellCastSentShredTargetS = 1
			Feral_CastSpellIng = 1
			Feral_SetDebugInfo("撕碎")
		end
		--特殊目标撕碎
		
		--print(TalentCheck)
		--print(PowerCheck)
		--print(ComboPointsCheck)
		--print(BuffCheck)
		--print(DeBuffCheck)
		
		Feral_GetDirectSingleDPSItemCD(Feral_AutoDPS_DPSTarget)
		--判断单体伤害饰品CD
		Feral_GetDirectAoeDPSItemCD(Feral_AutoDPS_DPSTarget)
		--判断AOE伤害饰品CD
			
		
		if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Feral_Enemy_SumHealth and Feral_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 7 * SDPHR) then
			Feral_SumHealthControl = nil
		else
			Feral_SumHealthControl = 1
		end
		if not Feral_SumHealthControl and IsPlayerSpell(Convoke_the_Spirits_SpellID) and FeralSaves.FeralOption_Attack_AutoCovenant and (not Feral_ManifestationOfPrideExists or Feral_EnemyCount >= 6) and not Feral_NoUsePowerfulSpell and not ConvokeTheSpiritsCD and not IsStealthed() and ComboPoints <= 3 and timeLeft_TigersFury < 10 and timeLeft_TigersFury > 3 and not DamagerEngine_NoCastingAuras and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng then
			DA_TargetUnit(Feral_AutoDPS_DPSTarget)
			if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
				DA_CastSpellByName(DA_GetSpellInfo(Convoke_the_Spirits_SpellID), Feral_AutoDPS_DPSTarget)
			end
			Feral_CastSpellIng = 1
			Feral_ChannelSpellIng = 1
			C_Timer.After(0.75, function()
				Feral_ChannelSpellIng = nil
			end)
			Feral_SetDebugInfo("万灵之召")
		end
		--万灵之召
		
		if UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Feral_Enemy_SumHealth and Feral_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 8.5 * SDPHR) then
			Feral_SumHealthControl = nil
		else
			Feral_SumHealthControl = 1
		end
		if not Feral_SumHealthControl and not DirectSingleDPSItemCD and FeralSaves.FeralOption_Attack_AutoAccessories and Feral_AutoDPS_DPSTarget and not IsStealthed() and not Feral_ChannelSpellIng then
			DA_TargetUnit(Feral_AutoDPS_DPSTarget)
			if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
				DA_UseItem(DirectSingleDPSItemID)
			end
			--使用单体伤害饰品
		end
		
		if not Feral_SumHealthControl and not DirectAoeDPSItemCD and FeralSaves.FeralOption_Attack_AutoAccessories and Feral_AutoDPS_DPSTarget and not IsStealthed() and not Feral_ChannelSpellIng then
			DA_TargetUnit(Feral_AutoDPS_DPSTarget)
			if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
				DA_UseItem(DirectAoeDPSItemID)
			end
			--使用AOE伤害饰品
		end
		
		if not Feral_SumHealthControl and FeralSaves.FeralOption_Attack_AutoAccessories and Feral_AutoDPS_DPSTarget and not IsStealthed() and not Feral_ChannelSpellIng then
			Feral_UseAttributesEnhancedItem()
			--使用属性增强饰品
			Feral_UseConcoctionKissOfDeath()
			--[制剂：死亡之吻]
		end
		
		Feral_UseMistcallerOcarina()
		--[唤雾者的陶笛]
		
		if not Feral_CastSpellIng and not Feral_ChannelSpellIng and IsPlayerSpell(Adaptive_Swarm_SpellID) then
			if not Feral_SumHealthControl and not AdaptiveSwarmCD and not IsStealthed() and PlayerPowerVacancy >= 40 and Feral_AutoDPS_DPSTarget then
				DA_TargetUnit(Feral_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
					DA_CastSpellByName(DA_GetSpellInfo(Adaptive_Swarm_SpellID), Feral_AutoDPS_DPSTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("激变蜂群")
				--激变蜂群
			end
		end
			
		if Feral_ClearEnrageTarget and not SootheCD and IsPlayerSpell(Soothe_SpellID) and UnitAffectingCombat("player") and FeralSaves.FeralOption_Auras_ClearEnrage and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
			DA_TargetUnit(Feral_ClearEnrageTarget)
			if UnitIsUnit('target',Feral_ClearEnrageTarget) then
				DA_CastSpellByID(Soothe_SpellID)
			end
			--安抚
			Feral_CastSpellIng = 1
			Feral_SetDebugInfo("安抚")
		end
	
		if (UnitExists("boss1") and select(2, IsInInstance()) == "raid") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Feral_Enemy_SumHealth and Feral_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 20 * SDPHR) then
			Feral_SumHealthControl = nil
		else
			Feral_SumHealthControl = 1
		end
		if not BerserkCD and IsPlayerSpell(Berserk_SpellID) and UnitAffectingCombat("player") and PlayerPowerNow >= 20 and not name_Clearcasting and (Feral_EnemyCount >= 2 or not C_PvP.IsActiveBattlefield()) and not Feral_SumHealthControl and FeralSaves.FeralOption_Attack_AutoBerserk and (not Feral_ManifestationOfPrideExists or Feral_EnemyCount >= 6) and not Feral_NoUsePowerfulSpell and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
			DA_CastSpellByID(Berserk_SpellID)
			Feral_CastSpellIng = 1
			--print("技能:狂暴、化身：丛林之王")
		end
		--狂暴、化身：丛林之王
		
		if not BerserkingCD and IsPlayerSpell(Berserking_SpellID) and UnitAffectingCombat("player") and PlayerPowerNow >= 20 and not name_Clearcasting and (Feral_EnemyCount >= 2 or not C_PvP.IsActiveBattlefield()) and not Feral_SumHealthControl and FeralSaves.FeralOption_Attack_AutoAccessories and (not Feral_ManifestationOfPrideExists or Feral_EnemyCount >= 6) and not Feral_NoUsePowerfulSpell and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
			DA_CastSpellByID(Berserking_SpellID)
			Feral_CastSpellIng = 1
			--print("技能:狂暴(种族特长)")
		end
		--狂暴(种族特长)
		
		if IsPlayerSpell(Tiger_Fury_SpellID) and not Feral_ChannelSpellIng then
			start1, duration1 = DA_GetSpellCooldown(113)
			start2, duration2 = DA_GetSpellCooldown(Tiger_Fury_SpellID)
			if duration2 == 0 
			and Feral_AutoDPS_DPSTarget 
			and (
			(not name_Clearcasting and PlayerPowerVacancy >= 60) 
			--没有清晰预兆且能量缺口>=60
			or PlayerPowerNow < 40
			--能量<40
			or timeLeft_Berserk >= 10 
			--狂暴时间>=10
			or timeLeft_IncarnationKingOfTheJungle >= 10 
			--化身时间>=10
			or (IsPlayerSpell(202021) and not name_TigersFury and Feral_EnemyCount >= 2 and PlayerPowerVacancy >= 20)
			--掠食者天赋下,没有猛虎之怒BUFF且目标>=2且能量缺口>=20
			) then
				DA_CastSpellByID(Tiger_Fury_SpellID, "player")
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("猛虎之怒")
			end
			--猛虎之怒
		end
		
		if C_PvP.IsActiveBattlefield() and Feral_AutoDPS_DPSTarget and IsPlayerSpell(22570) and not MaimCD and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not IsStealthed() then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			TalentCheck = 1
			
			PowerCheck = 1
			
			if ComboPoints >= 5 then
				ComboPointsCheck = 1
			end
			
			if not DA_GetStunned(Feral_AutoDPS_DPSTarget) and not DA_GetImmunityStuns(Feral_AutoDPS_DPSTarget)
			--目标没有被昏迷,且不存在免疫昏迷BUFF,且:(
			and ((DA_GetDiminishingStuns(Feral_AutoDPS_DPSTarget) <= 0) 
			--昏迷递减层数为0,或
			or (RegrowthTargetHealthScale <= 0.4 and DA_GetDiminishingStuns(Feral_AutoDPS_DPSTarget) <= 1) 
			--有队友血量低于40%,且昏迷递减层数小于等于1)
			or (RegrowthTargetHealthScale <= 0.2 and DA_GetDiminishingStuns(Feral_AutoDPS_DPSTarget) <= 2) 
			--有队友血量低于20%,且昏迷递减层数小于等于2)
			) then
				BuffCheck = 1
			end
			
			if (
			(caster_Rip == "player" and (expires_Rip and expires_Rip - GetTime() > 5)) 
			--存在割裂DEBUFF且大于5秒,或:
			or (Feral_EnemyCount >= 3 and caster_Rip == "player" and (expires_Rip and expires_Rip - GetTime() > 3))
			--多目标时割裂DEBUFF大于3秒,或:
			or (not Feral_AutoDPS_RipTarget)
			--不需要割裂时
			or (RegrowthTargetHealthScale <= 0.4 and DA_GetDiminishingStuns(Feral_AutoDPS_DPSTarget) <= 1) 
			--有队友血量低于40%,且昏迷递减层数小于等于1)
			or (RegrowthTargetHealthScale <= 0.2 and DA_GetDiminishingStuns(Feral_AutoDPS_DPSTarget) <= 2) 
			--有队友血量低于20%,且昏迷递减层数小于等于2)
			) then
				DeBuffCheck = 1
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
					DA_CastSpellByID(22570, Feral_AutoDPS_DPSTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("割碎")
				--print("技能:割碎")
			end
		end
		--割碎
		
		if IsPlayerSpell(Ferocious_Bite_SpellID) and DA_IsUsableSpell(Ferocious_Bite_SpellID) and Feral_AutoDPS_DPSTarget and (not Feral_AutoDPS_RipTarget or Feral_RipFlashWithFerociousBiteUnit) and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not IsStealthed() then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			
			TalentCheck = 1
			
			if (PlayerPowerNow >= 50 or Feral_RipFlashWithFerociousBiteUnit or Feral_BloodseekerVinesUnit or name_BloodseekerVines or name_Ravage or not IsPlayerSpell(441835))
			--能量大于50,或割裂可以被凶猛撕咬刷新,或有觅血缠藤,或有英雄天赋[毁灭]BUFF,或者没有学习英雄天赋[毁灭]
			or ((name_Berserk or name_IncarnationKingOfTheJungle) and PlayerPowerNow >= 37.5) 
			--狂暴、化身：丛林之王时,能量大于37.5
			or (name_ApexPredator and (timeLeft_Sabertooth <= 0.5 or Feral_EnemyCount >= 3)) then
			--顶级捕食者BUFF且(剑齿利刃DEBUFF剩余时间小于0.5秒或目标大于等于3)
				PowerCheck = 1
			end
			
			if (ComboPoints >= 5) 
			or (TargetHealth < UnitHealthMax("player") * 0.1 and ComboPoints >= 3) 
			--血量小于玩家最大血量的10%且连击点大于等于3
			or (Feral_RipFlashWithFerociousBiteUnit and ComboPoints >=1)
			--割裂可以被凶猛撕咬刷新的情况下,连击点大于等于1
			or (name_ApexPredator and (timeLeft_Sabertooth <= 0.5 or Feral_EnemyCount >= 3)) then
			--顶级捕食者BUFF且(剑齿利刃DEBUFF剩余时间小于0.5秒或目标大于等于3)
				ComboPointsCheck = 1
			end
			
			BuffCheck = 1
			
			if (timeLeft_Sabertooth <= 0.5 or PlayerPowerScale > 0.85 or (Feral_BloodseekerVinesUnit and (expires_Rip and expires_Rip - GetTime() > 3)) or ((name_Berserk or name_IncarnationKingOfTheJungle) and PlayerPowerScale > 0.4)) 
			--不存在剑齿利刃DEBUFF,或能量大于85%,或目标大于等于2,或(狂暴化身状态,且能量大于50%)时
			and (
			(caster_Rip == "player" and ((expires_Rip and expires_Rip - GetTime() > 7) or Feral_RipFlashWithFerociousBiteUnit)) 
			--存在割裂DEBUFF且大于7秒或割裂可以被凶猛撕咬刷新,或:
			or (Feral_EnemyCount >= 3 and caster_Rip == "player" and ((expires_Rip and expires_Rip - GetTime() > 3) or Feral_RipFlashWithFerociousBiteUnit)) 
			--多目标时割裂DEBUFF大于3秒,或:
			or (not Feral_AutoDPS_RipTarget and (Feral_EnemyCount < 3 or IsPlayerSpell(391709) or name_Ravage))
			) then
			--不需要割裂时,且(目标小于3,或选择[野性难驯]天赋,或有英雄天赋[毁灭]BUFF)
				DeBuffCheck = 1
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				if name_BloodseekerVines then
					Feral_AutoDPS_DPSTarget_FerociousBite = 'target'
				elseif Feral_RipFlashWithFerociousBiteUnit then
					Feral_AutoDPS_DPSTarget_FerociousBite = Feral_RipFlashWithFerociousBiteUnit
				elseif Feral_BloodseekerVinesUnit then
					Feral_AutoDPS_DPSTarget_FerociousBite = Feral_BloodseekerVinesUnit
				else
					Feral_AutoDPS_DPSTarget_FerociousBite = Feral_AutoDPS_DPSTarget
				end
				DA_TargetUnit(Feral_AutoDPS_DPSTarget_FerociousBite)
				if UnitIsUnit('target', Feral_AutoDPS_DPSTarget_FerociousBite) then
					DA_CastSpellByID(Ferocious_Bite_SpellID, Feral_AutoDPS_DPSTarget_FerociousBite)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("凶猛撕咬")
				--print("技能:凶猛撕咬")
			end
		end
		--凶猛撕咬
		
		if Feral_AutoDPS_RipTarget and IsPlayerSpell(Primal_Wrath_SpellID) and DA_IsUsableSpell(Primal_Wrath_SpellID) and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not IsStealthed() then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			TalentCheck = 1
			
			if Feral_EnemyCount >= 3 then
			--3个及目标以上
				if IsPlayerSpell(285381) then
					TalentCheck = 1
				end
				
				if PlayerPowerNow >= 20 then
					PowerCheck = 1
				end
			
				if ComboPoints >= 5 then
					ComboPointsCheck = 1
				end
			
				BuffCheck = 1
				
				if Feral_EnemyCount >= #Feral_EnemyCacheHasThreatIn20 * 0.4 then
					DeBuffCheck = 1
				end
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_RipTarget)
				if UnitIsUnit('target', Feral_AutoDPS_RipTarget) then
					DA_CastSpellByID(Primal_Wrath_SpellID, Feral_AutoDPS_RipTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("原始之怒")
				--print("技能:原始之怒")
			end
		end
		--原始之怒
		
		if Feral_AutoDPS_RipTarget and IsPlayerSpell(Rip_SpellID) and DA_IsUsableSpell(Rip_SpellID) and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not IsStealthed() then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			TalentCheck = 1
			
			PowerCheck = 1
			
			if Feral_EnemyCount < 3 or not IsPlayerSpell(285381) then
			--3个以下目标,或没有学习[原始之怒]天赋
				if ComboPoints >= 5 then
					ComboPointsCheck = 1
				end
			end
				
			BuffCheck = 1
			
			DeBuffCheck = 1
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_RipTarget)
				if UnitIsUnit('target', Feral_AutoDPS_RipTarget) then
					DA_CastSpellByID(Rip_SpellID, Feral_AutoDPS_RipTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("割裂")
				--print("技能:割裂")
			end
		end
		--割裂
		
		if C_PvP.IsActiveBattlefield() or (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5 * SDPHR) or (#DamagerEngine_DamagerAssigned <= 3 and (TargetHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 2.5 * SDPHR)) then
			Feral_SumHealthControl = nil
		else
			Feral_SumHealthControl = 1
		end
		if Feral_AutoDPS_DPSTarget and IsPlayerSpell(Feral_Frenzy_SpellID) and DA_IsSpellInRange(Feral_Frenzy_SpellID, Feral_AutoDPS_DPSTarget) == 1 and DA_IsUsableSpell(Feral_Frenzy_SpellID) and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not Feral_SumHealthControl and not IsStealthed() then
			start1, duration1 = DA_GetSpellCooldown(113)
			start2, duration2 = DA_GetSpellCooldown(Feral_Frenzy_SpellID)
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			if  Feral_EnemyCount == 1 and duration2 == duration1 then
			--1个目标
				TalentCheck = 1
				
				if PlayerPowerVacancy >= 40 or (name_Berserk or name_IncarnationKingOfTheJungle) then
					PowerCheck = 1
				end
				
				if ComboPoints <= 2 then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			elseif Feral_EnemyCount >= 2 and duration2 == duration1 then
			--2个目标以上
				TalentCheck = 1
				
				if PlayerPowerVacancy >= 40 then
					PowerCheck = 1
				end
				
				if ComboPoints <= 2 then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Feral_Frenzy_SpellID, Feral_AutoDPS_DPSTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("野性狂乱")
				--print("技能:野性狂乱")
			end
		end
		--野性狂乱
		
		start2, duration2 = DA_GetSpellCooldown(Tiger_Fury_SpellID)
		TigersFuryCD = duration2 - (GetTime() - start2)
		if not Feral_EnemyCacheHasThreatUnitDying 
		--没有即将死亡的单位
		and (Feral_EnemyCount >= 2 or BerserkCD) 
		--2个目标以上或狂暴CD中,防止单目标下因为野蛮挥砍没用完导致不施放狂暴
		and DA_GetSpellCharges(Brutal_Slash_SpellID) <= 2 
		--野蛮挥砍剩余次数小于等于2
		and ((not name_Clearcasting and IsPlayerSpell(16864)) or not IsPlayerSpell(16864)) 
		--洞察秋毫天赋下,没有清晰预兆BUFF
		and not name_TigersFury 
		--没有猛虎之怒BUFF
		and not name_FeralInstinct then
		--没有野性本能BUFF
			Feral_WaitBuff = 1
		else
			Feral_WaitBuff = nil
		end
		if UnitExists("boss1") or not IsInInstance() or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or (Feral_Enemy_SumHealth and Feral_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 5.5 * SDPHR) or #DamagerEngine_DamagerAssigned <= 2 or #Feral_MayNextAttackEnemyCache <= 4 or Feral_EnemyCount >= 3 or DA_GetSpellCharges(Brutal_Slash_SpellID) >= 2 then
			Feral_SumHealthControl = nil
		else
			Feral_SumHealthControl = 1
		end
		
		ThrashDistance = 8
		if Feral_UnitWithNoAttackAurasUnitDecide("player", ThrashDistance + 2.5) then
			NoAttackUnitTooClose = 1
		else
			NoAttackUnitTooClose = nil
		end
		if IsPlayerSpell(Thrash_SpellID) and DA_IsUsableSpell("痛击") and not NoAttackUnitTooClose and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng and ((Feral_EnemyCount < #Feral_EnemyCacheHasThreatIn20 * 0.6) or not IsPlayerSpell(Brutal_Slash_SpellID) or DA_GetSpellCharges(Brutal_Slash_SpellID) <= 2) then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			if Feral_EnemyCount >= 5 then
			--5个以上目标
				TalentCheck = 1
				
				if (PlayerPowerNow >= 45) 
				--当前能量值
				or (PlayerPowerNow >= 25 or (name_Berserk or name_IncarnationKingOfTheJungle)) 
				--狂暴
				or (PlayerPowerNow >= 10 and name_Clearcasting) then
				--清晰预兆
					PowerCheck = 1
				end
				
				if ComboPoints < 5 
				or (not Feral_AutoDPS_RipTarget and not IsPlayerSpell(285381) and not IsPlayerSpell(391709) and not name_Ravage) then
				--5星不用割裂,且没有学习[原始之怒]天赋,,且没有学习[野性难驯]天赋,且没有英雄天赋[毁灭]BUFF时(注:2个目标以上不会用[凶猛撕咬]消除5星,除非选择[野性难驯]天赋,或有英雄天赋[毁灭]BUFF)
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				if (not name_Thrash or (count_Clearcasting and count_Clearcasting >= 2) or (IsPlayerSpell(Brutal_Slash_SpellID) and (DA_GetSpellCharges(Brutal_Slash_SpellID) == 0 or Feral_WaitBuff or Feral_SumHealthControl))) then
				--痛击
					DeBuffCheck = 1
				end
			elseif Feral_EnemyCount >= 3 and not IsStealthed() then
			--3-4个目标
				TalentCheck = 1
				
				if (PlayerPowerNow >= 45) 
				--当前能量值
				or (PlayerPowerNow >= 25 or (name_Berserk or name_IncarnationKingOfTheJungle)) 
				--狂暴
				or (PlayerPowerNow >= 10 and name_Clearcasting) then
				--清晰预兆
					PowerCheck = 1
				end
				
				if ComboPoints < 5 
				or (not Feral_AutoDPS_RipTarget and not IsPlayerSpell(285381) and not IsPlayerSpell(391709) and not name_Ravage) then
				--5星不用割裂,且没有学习[原始之怒]天赋,,且没有学习[野性难驯]天赋,且没有英雄天赋[毁灭]BUFF时(注:2个目标以上不会用[凶猛撕咬]消除5星,除非选择[野性难驯]天赋,或有英雄天赋[毁灭]BUFF)
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
					
				if (not name_Thrash or (name_Clearcasting and count_Clearcasting >= 2) or (not Feral_AutoDPS_RakeTarget and IsPlayerSpell(Brutal_Slash_SpellID))) then
				--痛击
					DeBuffCheck = 1
				end
			elseif Feral_EnemyCount == 2 and not IsStealthed() then
			--2个目标以内
				TalentCheck = 1
				
				if (PlayerPowerNow >= 45) 
				--当前能量值
				or name_Clearcasting
				--清晰预兆
				or (PlayerPowerNow >= 25 or (name_Berserk or name_IncarnationKingOfTheJungle)) then
				--狂暴
					PowerCheck = 1
				end
				
				if ComboPoints < 5 then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				if not name_Thrash then
				--痛击
					DeBuffCheck = 1
				end
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_CastSpellByName("痛击")
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("痛击")
				--print("技能:痛击")
			end
		end
		--痛击
		
		if not IsPlayerSpell(Brutal_Slash_SpellID) and DA_IsUsableSpell("横扫") and not NoAttackUnitTooClose and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			if Feral_EnemyCount >= 5 then
			--5个目标以上
				if not IsPlayerSpell(Brutal_Slash_SpellID) then
					TalentCheck = 1
				end
				
				if name_Clearcasting or (name_Berserk or name_IncarnationKingOfTheJungle) or name_ScentOfBlood or PlayerPowerNow >= 40 then
					PowerCheck = 1
				end
				
				if ComboPoints < 5 
				or (not Feral_AutoDPS_RipTarget and not IsPlayerSpell(285381) and not IsPlayerSpell(391709) and not name_Ravage) then
				--5星不用割裂,且没有学习[原始之怒]天赋,,且没有学习[野性难驯]天赋,且没有英雄天赋[毁灭]BUFF时(注:2个目标以上不会用[凶猛撕咬]消除5星,除非选择[野性难驯]天赋,或有英雄天赋[毁灭]BUFF)
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				if (name_Thrash or not IsPlayerSpell(Thrash_SpellID)) then
					DeBuffCheck = 1
				end
			elseif Feral_EnemyCount >= 3 and not IsStealthed() then
			--3-4个目标
				if not IsPlayerSpell(Brutal_Slash_SpellID) then
					TalentCheck = 1
				end
				
				if name_Clearcasting or (name_Berserk or name_IncarnationKingOfTheJungle) or name_ScentOfBlood or PlayerPowerNow >= 40 then
					PowerCheck = 1
				end
				
				if ComboPoints < 5 
				or (not Feral_AutoDPS_RipTarget and not IsPlayerSpell(285381) and not IsPlayerSpell(391709) and not name_Ravage) then
				--5星不用割裂,且没有学习[原始之怒]天赋,,且没有学习[野性难驯]天赋,且没有英雄天赋[毁灭]BUFF时(注:2个目标以上不会用[凶猛撕咬]消除5星,除非选择[野性难驯]天赋,或有英雄天赋[毁灭]BUFF)
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				if (name_Thrash or not IsPlayerSpell(Thrash_SpellID)) and (not Feral_AutoDPS_RakeTarget and not Feral_AutoDPS_MoonfireTarget) then
					DeBuffCheck = 1
				end
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_CastSpellByName("横扫")
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("横扫")
				--print("技能:横扫")
			end
		end
		--横扫
		
		if IsPlayerSpell(Brutal_Slash_SpellID) and DA_IsUsableSpell("野蛮挥砍") and not NoAttackUnitTooClose and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng and (not IsStealthed() or Feral_EnemyCount > 4 or (name_Berserk or name_IncarnationKingOfTheJungle)) and not Feral_WaitBuff and not Feral_SumHealthControl then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			if Feral_EnemyCount >= 2 then
			--2个目标以上
				if IsPlayerSpell(Brutal_Slash_SpellID) and DA_GetSpellCharges(Brutal_Slash_SpellID) > 0 then
					TalentCheck = 1
				end
				
				if name_Clearcasting or (name_Berserk or name_IncarnationKingOfTheJungle) or name_ScentOfBlood or PlayerPowerNow >= 30 then
					PowerCheck = 1
				end
				
				if ComboPoints < 5 
				or (not Feral_AutoDPS_RipTarget and not IsPlayerSpell(285381) and not IsPlayerSpell(391709) and not name_Ravage) then
				--5星不用割裂,且没有学习[原始之怒]天赋,,且没有学习[野性难驯]天赋,且没有英雄天赋[毁灭]BUFF时(注:2个目标以上不会用[凶猛撕咬]消除5星,除非选择[野性难驯]天赋,或有英雄天赋[毁灭]BUFF)
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				if (name_Thrash or not IsPlayerSpell(Thrash_SpellID)) or (Feral_EnemyCount >= #Feral_EnemyCacheHasThreatIn20 * 0.6 and DA_GetSpellCharges(Brutal_Slash_SpellID) >= 3) then
					DeBuffCheck = 1
				end
			elseif Feral_EnemyCount == 1 then
			--1个目标
				if IsPlayerSpell(Brutal_Slash_SpellID) and DA_GetSpellCharges(Brutal_Slash_SpellID) > 0 then
					TalentCheck = 1
				end
				
				PowerCheck = 1
				
				if ComboPoints < 5 then
					ComboPointsCheck = 1
				end
				
				if name_TigersFury or name_Clearcasting or (name_Berserk or name_IncarnationKingOfTheJungle) then
					BuffCheck = 1
				end
				
				if (not Feral_AutoDPS_RakeTarget and not Feral_AutoDPS_MoonfireTarget) then
					DeBuffCheck = 1
				end
			end
			--print(TalentCheck)
			--print(PowerCheck)
			--print(ComboPointsCheck)
			--print(BuffCheck)
			--print(DeBuffCheck)
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_CastSpellByName("野蛮挥砍")
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("野蛮挥砍")
				--print("技能:野蛮挥砍")
			end
		end
		--野蛮挥砍
		
		if IsPlayerSpell(Shred_SpellID) and DA_IsUsableSpell(Shred_SpellID) and Feral_AutoDPS_RakeTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			if Feral_EnemyCount <= 2 then
			--1-2个目标
				TalentCheck = 1
				
				PowerCheck = 1
				
				if ComboPoints < 5 or IsStealthed() then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			elseif Feral_EnemyCount <= 4 or NoAttackUnitTooClose then
			--4个目标以内
				TalentCheck = 1
				
				PowerCheck = 1
				
				if ComboPoints < 5 or IsStealthed() then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			elseif not IsPlayerSpell(Thrash_SpellID) then
			--4个目标以上,没有学习痛击天赋
				TalentCheck = 1
				
				PowerCheck = 1
				
				if ComboPoints < 5 or IsStealthed() then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_RakeTarget)
				if UnitIsUnit('target', Feral_AutoDPS_RakeTarget) then
					DA_CastSpellByID(Rake_SpellID, Feral_AutoDPS_RakeTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("斜掠")
				--print("技能:斜掠")
			end
		end
		--斜掠
		
		if IsPlayerSpell(Moonfire_SpellID) and DA_IsUsableSpell(Moonfire_SpellID) and Feral_AutoDPS_MoonfireTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng and not IsStealthed() then
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			if Feral_EnemyCount <= 2 then
			--1-2个目标
				if IsPlayerSpell(155580) then
					TalentCheck = 1
				end
				
				PowerCheck = 1
				
				if ComboPoints < 5 or DA_IsSpellInRange(Shred_SpellID, "target") ~= 1 then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			elseif Feral_EnemyCount <= 4 or NoAttackUnitTooClose then
			--4个目标以内
				if IsPlayerSpell(155580) then
					TalentCheck = 1
				end
				
				PowerCheck = 1
				
				if ComboPoints < 5 or DA_IsSpellInRange(Shred_SpellID, "target") ~= 1 then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			elseif not IsPlayerSpell(Thrash_SpellID) then
			--4个目标以上,没有学习痛击天赋
				TalentCheck = 1
				
				PowerCheck = 1
				
				if ComboPoints < 5 or IsStealthed() then
					ComboPointsCheck = 1
				end
				
				BuffCheck = 1
				
				DeBuffCheck = 1
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_MoonfireTarget)
				if UnitIsUnit('target', Feral_AutoDPS_MoonfireTarget) then
					DA_CastSpellByName("月火术", Feral_AutoDPS_MoonfireTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("月火术")
				--print("技能:月火术")
			end
		end
		--月火术
		
		if (Feral_EnemyCount <= 2 or NoAttackUnitTooClose or not IsPlayerSpell(Thrash_SpellID)) and IsPlayerSpell(Shred_SpellID) and DA_IsUsableSpell(Shred_SpellID) and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng then
		--2个目标以内
			TalentCheck = nil
			PowerCheck = nil
			ComboPointsCheck = nil
			BuffCheck = nil
			DeBuffCheck = nil
			
			TalentCheck = 1
			
			PowerCheck = 1
			
			if ComboPoints < 5 or PlayerPowerScale > 0.85 or IsStealthed() then
				ComboPointsCheck = 1
			end
			
			BuffCheck = 1
			
			if (not Feral_AutoDPS_RakeTarget and not Feral_AutoDPS_MoonfireTarget and ((name_Thrash or not IsPlayerSpell(Thrash_SpellID)) or NoAttackUnitTooClose or Feral_EnemyCount <= 2)) 
			or IsStealthed() then
			--斜掠、月火术
				DeBuffCheck = 1
			end
			if TalentCheck and PowerCheck and ComboPointsCheck and BuffCheck and DeBuffCheck then
				DA_TargetUnit(Feral_AutoDPS_DPSTarget)
				if UnitIsUnit('target', Feral_AutoDPS_DPSTarget) then
					DA_CastSpellByID(Shred_SpellID, Feral_AutoDPS_DPSTarget)
				end
				Feral_CastSpellIng = 1
				Feral_SetDebugInfo("撕碎")
				--print("技能:撕碎")
			end
		end
		--撕碎
		
		if IsPlayerSpell(Thrash_SpellID) and DA_IsUsableSpell("痛击") and not NoAttackUnitTooClose and Feral_AutoDPS_DPSTarget and not Feral_CastSpellIng and not Feral_ChannelSpellIng and PlayerPowerScale > 0.85 and not IsStealthed() then
		--所有施法判断不通过且能量过高时
			DA_CastSpellByName("痛击")
			Feral_CastSpellIng = 1
			Feral_SetDebugInfo("痛击")
			--print("技能:空闲:痛击")
		end
		--痛击
		
		if FeralSaves.FeralOption_TargetFilter ~= 2 and not IsStealthed() then
			if WoWAssistantUnlocked then
				if not DA_GetFacing("player", "target", 60) or DA_IsSpellInRange(Shred_SpellID, "target") ~= 1 then
					for k, v in ipairs(Feral_EnemyCacheHasThreat) do
						if DA_GetFacing("player", v.Unit, 60) and DA_IsSpellInRange(Shred_SpellID, v.Unit) == 1 then
							DA_TargetUnit(v.Unit)
							--print("重新选择目标:"..v.Unit)
							StartAttack()
							break
						end
					end
				end
			else
				if DA_IsSpellInRange(Shred_SpellID, "target") ~= 1 then
					for k, v in ipairs(Feral_EnemyCacheHasThreat) do
						if DA_IsSpellInRange(Shred_SpellID, v.Unit) == 1 then
							DA_TargetUnit(v.Unit)
							--print("重新选择目标:"..v.Unit)
							break
						end
					end
				end
			end
		end
		--施放技能后如果目标在普通近战攻击角度外,则选择近战普通攻击角度内的目标(60°内)
		
		if Feral_EnemyCount == 0 or DamagerEngineGetNoAttackAuras("target") then
		--没有可攻击目标时关闭自动攻击
			StopAttack()
		end
		if UnitAffectingCombat("player") and Feral_EnemyCount >= 1 and not DamagerEngineGetNoAttackAuras("target") and DA_IsSpellInRange(Shred_SpellID, "target") == 1 and not Feral_IsAttackAction() then
		--意外停止自动攻击后自动恢复自动攻击
			StartAttack()
		end
		
		if FeralSaves.FeralOption_Other_ShowDebug then
			Feral_DeBugEnemyCount:SetText(Feral_EnemyCount)
			if Feral_EnemyCount == 0 then
				Feral_DeBugEnemyCount:Hide()
			else
				Feral_DeBugEnemyCount:Show()
			end
			if not Feral_CastSpellIng and not Feral_ChannelSpellIng then
				Feral_DeBugSpellIcon:Hide()
			else
				Feral_DeBugSpellIcon:Show()
			end
		else
			Feral_DeBugEnemyCount:Hide()
			Feral_DeBugSpellIcon:Hide()
		end
	end
end

function Feral_IsAttackAction()
	--获取是否激活了自动攻击
	local active = nil
	for i = 1, 120 do
		if IsAttackAction(i) and IsCurrentAction(i) then
			active = 1
			--print("Slot " .. i .. ":", GetActionText(i), x)
			break
		end
	end
	if active then
		return true
	else
		return false
	end
end

function Feral_GetTankAssignedDead()
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

function Feral_GetHealerAssignedDead()
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

function Feral_GetDamagerAssignedDead()
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

function Feral_IsCanMovingCast(spellID)
	--获取是否可以成功移动读条
	--if (not EWT and HackEnabled("MovingCast")) or (EWT and IsHackEnabled("MovingCast")) then return true end
	if not IsPlayerMoving() and not IsFalling() then	
		return true
	else
		return false
	end
end

function Feral_GetTargetNotVisible(Unit)
	--判断目标是否在视野中
	if Feral_TargetNotVisible then
		for k, v in ipairs(Feral_TargetNotVisible) do
			if v == UnitGUID(Unit) then
				--print(UnitName(Unit).." :不在视野中")
				return true
			end
		end
	end
end

function Feral_GetMoonfireTargetCanAttack(Unit)
	--判断月火术(猎豹形态)目标是否可以攻击
	if DA_IsSpellInRange(5176, Unit) == 1 and (DA_GetLineOfSight("player", Unit) or not WoWAssistantUnlocked) and not UnitIsDeadOrGhost(Unit) and (not UnitIsFriend(Unit, "player") or UnitIsEnemy(Unit, "player")) and UnitPhaseReason(Unit)~=0 and UnitPhaseReason(Unit)~=1 and UnitCanAttack("player",Unit) then
		--print(UnitName(Unit).." :可以攻击")
		return true
	else
		return false
	end
end

function Feral_FindEnemy()
	--遍历附近敌对目标
	if WoWAssistantUnlocked then
		if UnitAffectingCombat("player") or (Feral_EnemyCacheHasThreat and #Feral_EnemyCacheHasThreat > 0) then
			--战斗中
			Feral_FindEnemyControlTime = tonumber(FeralSaves.TraversalObjectInterval)
		else
			--非战斗
			if FeralSaves.FeralOption_TargetFilter == 3 then
				Feral_FindEnemyControlTime = tonumber(FeralSaves.TraversalObjectInterval)
			else
				Feral_FindEnemyControlTime = tonumber(FeralSaves.TraversalObjectInterval) * 4
			end
		end
		if Feral_FindEnemyControlTime < 0.1 then
			Feral_FindEnemyControlTime = 0.1
		end
		if (Feral_FindEnemyIntervalTime and GetTime() - Feral_FindEnemyIntervalTime > Feral_FindEnemyControlTime) or not Feral_FindEnemyIntervalTime then
			Feral_FindEnemyIntervalTime = GetTime()
			
			Feral_EnemyCache = {}
			Feral_MayNextAttackEnemyCache = {}
			
			if GetObjectCount() > 0 then
				local MX,MY,MZ = ObjectPosition("player")
				for i = 1, GetObjectCount() do
					local thisUnit = GetObjectWithIndex(i)
					if UnitExists(thisUnit) and UnitCreatureType(thisUnit) ~= "小动物" and UnitCreatureType(thisUnit) ~= "野生宠物" and UnitIsVisible(thisUnit) then
						local X1,Y1,Z1 = ObjectPosition(thisUnit)
						if DA_GetNovaDistance("player", thisUnit) < 60 and UnitExists(thisUnit) and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit) ~= 0 and UnitPhaseReason(thisUnit) ~= 1 and UnitCanAttack("player",thisUnit) then			
							if math.abs(MZ - Z1) < 10 or DA_GetLineOfSight("player", thisUnit) then
								--排除与玩家高度坐标相差10以上且不在视野中的单位
								if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
								--战场中只将玩家目标列入表格
									table.insert(Feral_MayNextAttackEnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									}) --60码内所有敌对目标写入表格
									if DA_GetNovaDistance("player", thisUnit) < 45 then
										table.insert(Feral_EnemyCache, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
											UnitPositionX = X1,
											UnitPositionY = Y1,
											UnitPositionZ = Z1,
										}) --45码内所有敌对目标写入表格
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

function Feral_FindEnemyInEnemyCache()
	--从Feral_EnemyCache遍历附近可攻击的敌对目标
	
	Feral_Enemy_SumHealth = 0
	Feral_Enemy_SumHealthMax = 0
	Feral_Enemy_SumHealthScale = 0
	
	Feral_Heals_SumHealthTank = 0
	Feral_Heals_SumHealthMaxTank = 0
	Feral_Heals_SumHealthScaleTank = 1
	Feral_Heals_SumHealthHealer = 0
	Feral_Heals_SumHealthMaxHealer = 0
	Feral_Heals_SumHealthScaleHealer = 1
	Feral_Heals_SumHealthDamager = 0
	Feral_Heals_SumHealthMaxDamager = 0
	Feral_Heals_SumHealthScaleDamager = 1
	
	Feral_EnemyCacheS = {}
	Feral_EnemyCacheS2 = {}
	Feral_EnemyCacheS3 = {}
	Feral_EnemyCacheHasThreat = {}
	Feral_EnemyCacheHasThreatIn7 = {}
	Feral_EnemyCacheHasThreatIn20 = {}
	Feral_MoonfireEnemyCacheHasThreat = {}
	
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
			Feral_Heals_SumHealthTank = Feral_Heals_SumHealthTank + v.UnitHealth
			Feral_Heals_SumHealthMaxTank = Feral_Heals_SumHealthMaxTank + v.UnitHealthMax
		end
		Feral_Heals_SumHealthScaleTank = Feral_Heals_SumHealthTank / Feral_Heals_SumHealthMaxTank
		--print("坦克总剩余血量: "..Feral_Heals_SumHealthTank)
		--print("坦克总血量: "..Feral_Heals_SumHealthMaxTank)
		--print("坦克总血量比例: "..Feral_Heals_SumHealthScaleTank)
	end
	if #DamagerEngine_HealerAssigned > 0 then
		--治疗血量信息
		for k, v in ipairs(DamagerEngine_HealerAssigned) do
			Feral_Heals_SumHealthHealer = Feral_Heals_SumHealthHealer + v.UnitHealth
			Feral_Heals_SumHealthMaxHealer = Feral_Heals_SumHealthMaxHealer + v.UnitHealthMax
		end
		Feral_Heals_SumHealthScaleHealer = Feral_Heals_SumHealthHealer / Feral_Heals_SumHealthMaxHealer
		--print("治疗总剩余血量: "..Feral_Heals_SumHealthHealer)
		--print("治疗总血量: "..Feral_Heals_SumHealthMaxHealer)
		--print("治疗总血量比例: "..Feral_Heals_SumHealthScaleHealer)
	end
	if #DamagerEngine_DamagerAssigned > 0 then
		--伤害输出血量信息
		for k, v in ipairs(DamagerEngine_DamagerAssigned) do
			Feral_Heals_SumHealthDamager = Feral_Heals_SumHealthDamager + v.UnitHealth
			Feral_Heals_SumHealthMaxDamager = Feral_Heals_SumHealthMaxDamager + v.UnitHealthMax
		end
		Feral_Heals_SumHealthScaleDamager = Feral_Heals_SumHealthDamager / Feral_Heals_SumHealthMaxDamager
		--print("伤害输出总剩余血量: "..Feral_Heals_SumHealthDamager)
		--print("伤害输出总血量: "..Feral_Heals_SumHealthMaxDamager)
		--print("伤害输出总血量比例: "..Feral_Heals_SumHealthScaleDamager)
	end
	--获取治疗目标总体血量信息
	
	if not WoWAssistantUnlocked then
		Feral_EnemyCache = {}
		Feral_MayNextAttackEnemyCache = {}
		Feral_ControlEnemyCache = {}
		if IsActiveBattlefieldArena() then
		--竞技场中
			for ism = 1, 5 do
				local thisUnit = "arena"..ism
				if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) then
					if UnitExists(thisUnit) and UnitCreatureType(thisUnit) ~= "小动物" and UnitCreatureType(thisUnit) ~= "野生宠物" and UnitIsVisible(thisUnit) then
						if DA_IsSpellInRange(5176, thisUnit) == 1 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then
							if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
								--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
								table.insert(Feral_ControlEnemyCache, {
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
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_EnemyCache) then 
									table.insert(Feral_EnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									}) --所有敌对的队友目标目标写入表格
								end
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_MayNextAttackEnemyCache) then 
									table.insert(Feral_MayNextAttackEnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									})--所有敌对的队友目标目标写入表格
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
						if DA_IsSpellInRange(5176, thisUnit) == 1 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then			
							if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
								--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
								table.insert(Feral_ControlEnemyCache, {
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
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_EnemyCache) then 
									table.insert(Feral_EnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									}) --所有敌对的队友目标目标写入表格
								end
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_MayNextAttackEnemyCache) then 
									table.insert(Feral_MayNextAttackEnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									})--所有敌对的队友目标目标写入表格
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
							if DA_IsSpellInRange(5176, thisUnit) == 1 and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) then
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
									--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
									table.insert(Feral_ControlEnemyCache, {
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
									if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_EnemyCache) then 
										table.insert(Feral_EnemyCache, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
										}) --所有敌对的姓名版目标写入表格
									end
									if not DA_UnitIsInTable(UnitGUID(thisUnit), Feral_MayNextAttackEnemyCache) then 
										table.insert(Feral_MayNextAttackEnemyCache, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
										})--所有敌对的姓名版目标写入表格
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
	for k, v in ipairs(Feral_EnemyCache) do
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
			--重新获取Feral_EnemyCache表中单位状态
			if IsPlayerSpell(155580) and not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit) and Feral_GetMoonfireTargetCanAttack(v.Unit) then
				--月火术(猎豹形态)
				--排除忽略的目标、不在视野中的目标外的可攻击目标
				
				if (((status and UnitAffectingCombat(v.Unit)) 
				--单位有仇恨且在战斗中
				or DamagerEngineGetNoThreatUnit(v.Unit) 
				--单位是无仇恨类特殊目标
				or (UnitIsPlayer(v.Unit..'target') and IsInInstance()) 
				--单位的目标是玩家且在副本中
				or (v.UnitGUID == Feral_FindEnemyCombatLogUnitGUID and not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit)) 
				--单位是队友攻击的目标
				or (FeralSaves.FeralOption_TargetFilter == 3 and not UnitIsTapDenied(v.Unit) and green == 0)) 
				--所有目标模式且单位不是灰名且单位是红名
				and ((not UnitIsPlayer(v.Unit) and not UnitPlayerControlled(v.Unit)) or (IsInInstance() and not C_PvP.IsActiveBattlefield())))
				--以上所有判断都要符合:单位不是玩家和玩家控制的单位，副本中除外(避免不攻击被心灵控制的目标)
				or (UnitIsPlayer(v.Unit) and C_PvP.IsActiveBattlefield())
				--单位是玩家且在战场/竞技场中
				or DA_UnitIsInTable(v.UnitGUID, Feral_FindEnemyCombatLogAttackMeUnitCache) then
				--单位是攻击我的目标
					table.insert(Feral_MoonfireEnemyCacheHasThreat, {
						Unit = v.Unit,
						UnitName = v.UnitName,
						UnitGUID = v.UnitGUID,
						UnitHealth = v.UnitHealth,
						UnitHealthMax = v.UnitHealthMax,
						UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
						UnitPositionX = v.UnitPositionX,
						UnitPositionY = v.UnitPositionY,
						UnitPositionZ = v.UnitPositionZ,
					}) --有仇恨敌对目标写入表格
				end
			end
			--if not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit) and ((IsPlayerSpell(106839) and DA_IsSpellInRange(106839, v.Unit)) or (not IsPlayerSpell(106839) and DA_IsSpellInRange(5176, v.Unit))) then
			if not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit) and DA_GetUnitDistance(v.Unit) <= 20 then
				--排除忽略的目标、不在视野中的目标外的可攻击目标
				if (((status and UnitAffectingCombat(v.Unit)) 
				--单位有仇恨且在战斗中
				or DamagerEngineGetNoThreatUnit(v.Unit) 
				--单位是无仇恨类特殊目标
				or (UnitIsPlayer(v.Unit..'target') and IsInInstance()) 
				--单位的目标是玩家且在副本中
				or (v.UnitGUID == Feral_FindEnemyCombatLogUnitGUID and not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit)) 
				--单位是队友攻击的目标
				or (FeralSaves.FeralOption_TargetFilter == 3 and not UnitIsTapDenied(v.Unit) and green == 0)) 
				--所有目标模式且单位不是灰名且单位是红名
				and ((not UnitIsPlayer(v.Unit) and not UnitPlayerControlled(v.Unit)) or (IsInInstance() and not C_PvP.IsActiveBattlefield())))
				--以上所有判断都要符合:单位不是玩家和玩家控制的单位，副本中除外(避免不攻击被心灵控制的目标)
				or (UnitIsPlayer(v.Unit) and C_PvP.IsActiveBattlefield())
				--单位是玩家且在战场/竞技场中
				or DA_UnitIsInTable(v.UnitGUID, Feral_FindEnemyCombatLogAttackMeUnitCache) then
				--单位是攻击我的目标
					table.insert(Feral_EnemyCacheHasThreatIn20, {
						Unit = v.Unit,
						UnitName = v.UnitName,
						UnitGUID = v.UnitGUID,
						UnitHealth = v.UnitHealth,
						UnitHealthMax = v.UnitHealthMax,
						UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
						UnitPositionX = v.UnitPositionX,
						UnitPositionY = v.UnitPositionY,
						UnitPositionZ = v.UnitPositionZ,
					}) --20码(调用LibRangeCheck是20码)内可攻击目标写入表格    ----20码(未解锁是[迎头痛击]距离13码,如果未学习[迎头痛击]则是[月火术]距离40码)内可攻击目标写入表格
					--if IsPlayerSpell(106839) and IsPlayerSpell(102401) and DA_IsSpellInRange(106839, v.Unit) and not DA_IsSpellInRange(49376, v.Unit) then
					if DA_GetUnitDistance(v.Unit) <= 7 then
						table.insert(Feral_EnemyCacheHasThreatIn7, {
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
			if not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit) and DA_GetTargetCanAttack(v.Unit, Shred_SpellID) then
				--排除忽略的目标、不在视野中的目标外的可攻击目标
				if DA_IsSpecialEnemy(v.Unit) then
					--特殊敌对目标,不计入AOE目标数量
					table.insert(Feral_EnemyCacheS, {
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
					or (v.UnitGUID == Feral_FindEnemyCombatLogUnitGUID and not DamagerEngineGetIgnoreUnit(v.Unit) and not Feral_GetTargetNotVisible(v.Unit)) 
					--单位是队友攻击的目标
					or (FeralSaves.FeralOption_TargetFilter == 3 and not UnitIsTapDenied(v.Unit) and green == 0)) 
					--所有目标模式且单位不是灰名且单位是红名
					and ((not UnitIsPlayer(v.Unit) and not UnitPlayerControlled(v.Unit)) or (IsInInstance() and not C_PvP.IsActiveBattlefield())))
					--以上所有判断都要符合:单位不是玩家和玩家控制的单位，副本中除外(避免不攻击被心灵控制的目标)
					or (UnitIsPlayer(v.Unit) and C_PvP.IsActiveBattlefield())
					--单位是玩家且在战场/竞技场中
					or DA_UnitIsInTable(v.UnitGUID, Feral_FindEnemyCombatLogAttackMeUnitCache) then
					--单位是攻击我的目标
						table.insert(Feral_EnemyCacheHasThreat, {
							Unit = v.Unit,
							UnitName = v.UnitName,
							UnitGUID = v.UnitGUID,
							UnitHealth = v.UnitHealth,
							UnitHealthMax = v.UnitHealthMax,
							UnitHealthScale = v.UnitHealth / v.UnitHealthMax,
							UnitPositionX = v.UnitPositionX,
							UnitPositionY = v.UnitPositionY,
							UnitPositionZ = v.UnitPositionZ,
						}) --有仇恨敌对目标写入表格
					end
				end
			end
			if v.UnitGUID == Feral_FindEnemyCombatLogUnitGUID then
				--print(v.UnitName)
				Feral_FindEnemyCombatLogUnitGUID = nil
			end
		end
	end
	
	for k, v in ipairs(Feral_EnemyCacheHasThreat) do
		--从有仇恨敌对目标表格中判断优先击杀目标
		if DamagerEngineGetPriorityUnit(v.Unit) then
			--先打血高的特殊目标(非单体输出,可AOE)
			table.insert(Feral_EnemyCacheS2, {
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
			table.insert(Feral_EnemyCacheS3, {
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
	
	if #Feral_EnemyCacheS > 0 then
		table.sort(Feral_EnemyCacheS, function(a, b) return a.UnitHealth > b.UnitHealth end)
		--血量从高到低排序(优先打血高的)
	end
	if #Feral_EnemyCacheS2 > 0 then
		table.sort(Feral_EnemyCacheS2, function(a, b) return a.UnitHealth > b.UnitHealth end)
		--血量从高到低排序(优先打血高的)
	end
	if #Feral_EnemyCacheS3 > 0 then
		table.sort(Feral_EnemyCacheS3, function(a, b) return a.UnitHealth < b.UnitHealth end)
		--血量从低到高排序(优先打血低的)
	end
	if #Feral_EnemyCacheHasThreat > 0 then
		if DA_GetHasActiveAffix('崩裂') or UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or select(3, GetInstanceInfo()) == 167 or select(3, GetInstanceInfo()) == 208 then
			--大秘境词缀存在[崩裂]或BOSS战斗或不在副本或在战场/竞技场或伤害输出职责不超过2人或在托加斯特，罪魂之塔时,血量从低到高排序(优先打血低的)
			table.sort(Feral_EnemyCacheHasThreat, function(a, b) return a.UnitHealth < b.UnitHealth end)
		else
			table.sort(Feral_EnemyCacheHasThreat, function(a, b) return a.UnitHealth > b.UnitHealth end)
			--血量从高到低排序(优先打血高的)
		end
		for k, v in ipairs(Feral_EnemyCacheHasThreat) do
			Feral_Enemy_SumHealth = Feral_Enemy_SumHealth + v.UnitHealth
			Feral_Enemy_SumHealthMax = Feral_Enemy_SumHealthMax + v.UnitHealthMax
		end
		Feral_Enemy_SumHealthScale = Feral_Enemy_SumHealth / Feral_Enemy_SumHealthMax
		--获取附近敌对目标的总剩余血量
		--print(Feral_Enemy_SumHealth)
		--print(Feral_Enemy_SumHealthMax)
		--print(Feral_Enemy_SumHealthScale)
	end
	if #Feral_MoonfireEnemyCacheHasThreat > 0 then
		if DA_GetHasActiveAffix('崩裂') or UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or select(3, GetInstanceInfo()) == 167 or select(3, GetInstanceInfo()) == 208 then
			--大秘境词缀存在[崩裂]或BOSS战斗或不在副本或在战场/竞技场或伤害输出职责不超过2人或在托加斯特，罪魂之塔时,血量从低到高排序(优先打血低的)
			table.sort(Feral_MoonfireEnemyCacheHasThreat, function(a, b) return a.UnitHealth < b.UnitHealth end)
		else
			table.sort(Feral_MoonfireEnemyCacheHasThreat, function(a, b) return a.UnitHealth > b.UnitHealth end)
			--血量从高到低排序(优先打血高的)
		end
	end
end

function Feral_UnitWithNoAttackAurasUnitDecide(Unit, Distance)
	--获取是否有无辜目标与Unit距离小于Distance
	if WoWAssistantUnlocked then
		local UnitTooNear = nil
		if not Unit then return end
		if UnitExists(Unit) and UnitIsVisible(Unit) then
			local X, Y, Z = ObjectPosition(Unit)
			for k, v in ipairs(Feral_EnemyCacheNoThreat) do
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

function Feral_FindEnemyCacheNoThreat()
	--查找无辜目标
	Feral_EnemyCacheNoThreat = {}
	for k, v in ipairs(Feral_EnemyCache) do
		--从附近所有敌对目标中查找无辜目标
		if UnitExists(v.Unit) and UnitIsVisible(v.Unit) then
		
			Feral_UnitHasThreat = nil
			for k2, v2 in ipairs(Feral_EnemyCacheHasThreat) do
				if v.UnitGUID == v2.UnitGUID then
					--仇恨表中的目标不算无辜目标
					Feral_UnitHasThreat = 1
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
			--单位的目标是玩家且在副本中
			or (UnitPlayerControlled(v.Unit) and (C_PvP.IsActiveBattlefield() or (Feral_FindEnemyCombatLogAttackMeUnitCache and #Feral_FindEnemyCombatLogAttackMeUnitCache > 0))) then
			--玩家控制的目标(战场内或攻击我的玩家控制目标大于0),不算无辜目标
				Feral_UnitHasThreat = 1
			end
			
			if not Feral_UnitHasThreat or select(2, DamagerEngineGetNoAttackAuras(v.Unit)) == "NoAttack" then
				--判断不算无辜目标的单位、因Auras不要攻击的单位写入表格
				table.insert(Feral_EnemyCacheNoThreat, {
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

FeralCycleFrame:SetScript("OnEvent", Feral_OnEvent)
FeralCycleFrame:SetScript("OnUpdate", Feral_OnEvent)