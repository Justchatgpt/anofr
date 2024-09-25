--灯塔系统
--SetCVar("scriptProfile", 1)
Restoration = CreateFrame("Frame")
Restoration:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
Restoration:RegisterEvent("UNIT_SPELLCAST_FAILED")
Restoration:RegisterEvent("UNIT_SPELLCAST_SENT")
Restoration:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
Restoration:RegisterEvent("UI_ERROR_MESSAGE")
Restoration:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
Restoration:RegisterEvent("CURSOR_CHANGED")
Restoration:RegisterEvent("UNIT_SPELLCAST_START")
Restoration:RegisterEvent("UNIT_HEAL_PREDICTION")
Restoration:RegisterEvent("PLAYER_TARGET_CHANGED")

Restoration.DBM = {}

local SDPHR = 0.25
--当前版本玩家单体DPS与玩家血量的比值(SingleDPS_PlayerHealthMax_Ratio)
--7.0版本后期:0.35
--8.0版本初期:0.075

function Restoration_SetDebugInfo(spell)
	local name, rank, icon = DA_GetSpellInfo(spell)
	--print('使用:'..spell)
	if icon then
		Restoration_DeBugSpellIcon.Texture:SetTexture(icon)
	end
end

function Restoration.DBM:getBars()
    if DBM then
        if not Restoration.DBM.Timer then
            Restoration.DBM.Timer = {}
        else
            wipe(Restoration.DBM.Timer)
        end

        for bar in pairs(DBT.bars) do
			--"DBM-StatusBarTimers\DBT.lua"   function DBT:CreateBar(timer, id, icon, huge, small, color, isDummy, colorType, inlineIcon, keep, fade, countdown, countdownMax)
			--colorType:(1-小怪入场, 2-AOE, 3-点名技能, 4-打断, 5-剧情, 6-阶段转换, 7-自定义)
            local number = tonumber(string.match(bar.id ,"%d+"))
            local timer = tonumber(string.format("%.1f", bar.timer))
			if (number and number > 100) or not number then
				if not number then number = '无' end
				--print('DBM:'..bar.id..' '..DA_GetSpellLink(number).." 技能ID:"..number.." 剩余时间:"..timer.."秒 类型:"..bar.colorType)
				table.insert(Restoration.DBM.Timer, {id = bar.id, timer = timer, spellid = number, Type = bar.colorType})
			end
        end
    end
end

function Restoration.DBM:getAoe()
    if DBM then
		Restoration.DBM:getBars()
		RestorationDBMWillAoeLoop = nil
		for i = 1, #Restoration.DBM.Timer do
			if Restoration.DBM.Timer[i].spellid then
				local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(Restoration.DBM.Timer[i].spellid)
				if not castingTime then
					castingTime = 0
				else
					castingTime = castingTime / 1000
				end
				local PlayerPowerScale = UnitPower("player", 0) / UnitPowerMax("player", 0)
				local PlayerPowerScaleControlTime = (1 - PlayerPowerScale) / 0.1
				if RestorationSaves.RestorationOption_Effect == 1 then
					--强力
					Restoration_DBMControlTime = 12.5 - castingTime - PlayerPowerScaleControlTime
				elseif RestorationSaves.RestorationOption_Effect == 2 then
					--正常
					Restoration_DBMControlTime = 10 - castingTime - PlayerPowerScaleControlTime
				else
					--省蓝
					Restoration_DBMControlTime = 7.5 - castingTime - PlayerPowerScaleControlTime
				end
				if Restoration.DBM.Timer[i].timer and Restoration.DBM.Timer[i].timer < Restoration_DBMControlTime then
					if Restoration.DBM.Timer[i].Type == 2 then
						--print(DA_GetSpellInfo(spellID).." ID:"..spellID.." 剩余时间:"..Restoration.DBM.Timer[i].timer)
						RestorationDBMWillAoe = 1
						RestorationDBMWillAoeLoop = 1
						break
					end
					for ii = 1, #HealerEngineAlertSpellAOECache do
						if spellID == HealerEngineAlertSpellAOECache[ii].ID then
							--print(DA_GetSpellInfo(spellID).." ID:"..spellID.." 剩余时间:"..Restoration.DBM.Timer[i].timer)
							RestorationDBMWillAoe = 1
							RestorationDBMWillAoeLoop = 1
							break
						end
					end
				end
			end
		end
		if not RestorationDBMWillAoeLoop then
			RestorationDBMWillAoe = nil
		end
	end
end

function Restoration.DBM:PrintTimer()
    if DBM then
		Restoration.DBM:getBars()
		for i = 1, #Restoration.DBM.Timer do
			if Restoration.DBM.Timer[i].spellid then
				local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(Restoration.DBM.Timer[i].spellid)
				if not spellID then spellID = '无' end
				print('DBM:'..Restoration.DBM.Timer[i].id..' '..DA_GetSpellLink(spellID).." 技能ID:"..spellID.." 剩余时间:"..Restoration.DBM.Timer[i].timer.."秒 类型:"..Restoration.DBM.Timer[i].Type)
			end
		end
	end
end

function Restoration_UseAttributesEnhancedItem()
	--使用属性增强饰品
	for i = 13, 14 do
		local ItemID = _G["AttributesEnhancedItemID"..i]
		local slotID = nil
		if ItemID and C_Item.IsUsableItem(ItemID) and DA_GetItemCooldown(ItemID) == 0 then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			--UseInventoryItem(slotID, "player")
			DA_UseItem(slotID)
			return true
		end
	end
end

function Restoration_UseConcoctionKissOfDeath()
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

function Restoration_GetDirectSingleHealItemCD(Unit)
	--判断单体治疗饰品CD
	if not Unit then return end
	DirectSingleHealItemCD = 1
	for i = 13, 14 do
		local ItemID = _G["DirectSingleHealItemID"..i]
		local slotID = nil
		if ItemID and C_Item.IsUsableItem(ItemID) and DA_GetItemCooldown(ItemID) == 0 and (C_Item.IsItemInRange(ItemID, Unit) or C_Item.IsItemInRange(ItemID, Unit) == nil) and UnitAffectingCombat("player") then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			DirectSingleHealItemCD = nil
			DirectSingleHealItemID = ItemID
			DirectSingleHealSlotID = slotID
		end
	end
end
function Restoration_UseDirectSingleHealItem(unitid, guid)
	--使用单体治疗饰品
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_UseItem(DirectSingleHealSlotID)
		end
	end
end

function Restoration_UseDirectAoeHealItem()
	--使用群体治疗饰品
	Restoration_DirectAoeHealItemTarget = nil
	if #HealsUnitPriority >= 1 then
		local unitid = HealsUnitPriority[1].UnitID
		local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
		if UnitHealthScale <= 0.05 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.1 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.15 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.2 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.25 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.3 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.35 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.4 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.45 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.5 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.55 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.6 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.65 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.7 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.75 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.8 then
			Restoration_DirectAoeHealItemTarget = unitid
		elseif UnitHealthScale <= 0.85 then
			Restoration_DirectAoeHealItemTarget = unitid
		end
	end
	if not Restoration_DirectAoeHealItemTarget then
		Restoration_DirectAoeHealItemTarget = "player"
	end
	
	for i = 13, 14 do
		local ItemID = _G["DirectAoeHealItemID"..i]
		local slotID = nil
		if ItemID == 178783 and (UnitHealth(Restoration_DirectAoeHealItemTarget)/UnitHealthMax(Restoration_DirectAoeHealItemTarget) > 0.4 or UnitHealth("player")/UnitHealthMax("player") < 0.3) then
			--目标血量高于40%或者自己血量低于30%则不使用[虹吸护命匣碎片]
			ItemID = nil
		end
		if ItemID and C_Item.IsUsableItem(ItemID) and DA_GetItemCooldown(ItemID) == 0 and (C_Item.IsItemInRange(ItemID, Restoration_DirectAoeHealItemTarget) or C_Item.IsItemInRange(ItemID, Restoration_DirectAoeHealItemTarget) == nil) then
			if i == 13 then
				slotID = 13
			elseif i == 14 then
				slotID = 14
			end
			DA_TargetUnit(Restoration_DirectAoeHealItemTarget)
			if UnitIsUnit('target', unitid) then
				DA_UseItem(slotID)
			end
			return
		end
	end
end

function Restoration_UseCarafeofSearingLight()
	--[灼光之瓶]
	if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.9 and UnitAffectingCombat("player") then
		CanUseCarafeofSearingLight = 1
	else
		CanUseCarafeofSearingLight = nil
	end
	--灼光之瓶指示
	if C_Item.IsEquippedItem(151960) and GetItemCooldown(151960) == 0 and CanUseCarafeofSearingLight and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		CarafeofSearingLightTarget = GetRestoration_EnemyCacheByHealth("HIGH")
		--获取施法目标
		if CarafeofSearingLightTarget then
			if RestorationSaves.RestorationOption_Other_AutoTargetIng then
				DA_TargetUnit(CarafeofSearingLightTarget)
			end
			DA_UseItem(151960, CarafeofSearingLightTarget)
			--使用灼光之瓶
		end
	end
end

function Restoration_UseVitalityResonator()
	--[生命共鸣器]
	if NumGroupMembers > 8 then
	--团队
		if (Health90 >= 4 and Health80 >= 2) or Health80 >= 4 or Health70 >= 3 or Health55 >= 2 then
			CanUseVitalityResonator = 1
		else
			CanUseVitalityResonator = nil
		end
	else
	--小队
		if (Health90 >= 2 and Health80 >= 1) or Health80 >= 2 or Health70 >= 1 or Health55 >= 1 then
			CanUseVitalityResonator = 1
		else
			CanUseVitalityResonator = nil
		end
	end
	--生命共鸣器指示
	if C_Item.IsEquippedItem(151970) and GetItemCooldown(151970) == 0 and CanUseVitalityResonator and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		VitalityResonatorTarget = GetRestoration_EnemyCacheByHealth("HIGH")
		--获取施法目标
		if VitalityResonatorTarget then
			if RestorationSaves.RestorationOption_Other_AutoTargetIng then
				DA_TargetUnit(VitalityResonatorTarget)
			end
			DA_UseItem(151970, VitalityResonatorTarget)
			--使用生命共鸣器
		end
	end
end

function Restoration_UseSoullettingRuby()
	--[释魂红玉]
	if NumGroupMembers > 8 then
	--团队
		if (Health90 >= 4 and Health80 >= 2) or Health80 >= 4 or Health70 >= 3 or Health55 >= 2 then
			CanUseSoullettingRuby = 1
		else
			CanUseSoullettingRuby = nil
		end
	else
	--小队
		if (Health90 >= 2 and Health80 >= 1) or Health80 >= 2 or Health70 >= 1 or Health55 >= 1 then
			CanUseSoullettingRuby = 1
		else
			CanUseSoullettingRuby = nil
		end
	end
	--释魂红玉指示
	if C_Item.IsEquippedItem(178809) and GetItemCooldown(178809) == 0 and CanUseSoullettingRuby and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		SoullettingRubyTarget = GetRestoration_EnemyCacheByHealth("VacancyHIGH")
		--获取施法目标
		if SoullettingRubyTarget then
			if RestorationSaves.RestorationOption_Other_AutoTargetIng then
				DA_TargetUnit(SoullettingRubyTarget)
			end
			DA_UseItem(178809, SoullettingRubyTarget)
			--使用释魂红玉
		end
	end
end

function Restoration_UseVialofSpectralEssence()
	--[鬼灵精华之瓶]
	if NumGroupMembers > 8 then
	--团队
		if (Health90 >= 4 and Health80 >= 2) or Health80 >= 4 or Health70 >= 3 or Health55 >= 2 then
			CanUseVialofSpectralEssence = 1
		else
			CanUseVialofSpectralEssence = nil
		end
	else
	--小队
		if (Health90 >= 2 and Health80 >= 1) or Health80 >= 2 or Health70 >= 1 or Health55 >= 1 then
			CanUseVialofSpectralEssence = 1
		else
			CanUseVialofSpectralEssence = nil
		end
	end
	--鬼灵精华之瓶指示
	if C_Item.IsEquippedItem(178810) and GetItemCooldown(178810) == 0 and CanUseVialofSpectralEssence and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		SoullettingRubyTarget = GetRestoration_EnemyCacheByHealth("LOW")
		--获取施法目标
		if SoullettingRubyTarget then
			if RestorationSaves.RestorationOption_Other_AutoTargetIng then
				DA_TargetUnit(SoullettingRubyTarget)
			end
			DA_UseItem(178810, SoullettingRubyTarget)
			--使用鬼灵精华之瓶
		end
	end
end

function Restoration_UseSunbloodAmethyst()
	--[阳血紫晶]
	if NumGroupMembers > 8 then
	--团队
		if (Health90 >= 4 and Health80 >= 2) or Health80 >= 4 or Health70 >= 3 or Health55 >= 2 then
			CanUseSunbloodAmethyst = 1
		else
			CanUseSunbloodAmethyst = nil
		end
	else
	--小队
		if (Health90 >= 2 and Health80 >= 1) or Health80 >= 2 or Health70 >= 1 or Health55 >= 1 then
			CanUseSunbloodAmethyst = 1
		else
			CanUseSunbloodAmethyst = nil
		end
	end
	--阳血紫晶指示
	if C_Item.IsEquippedItem(178826) and GetItemCooldown(178826) == 0 and CanUseSunbloodAmethyst and not UnitChannelInfo("player") and not Restoration_CanNotMovingCast() and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		SoullettingRubyTarget = GetRestoration_EnemyCacheByHealth("LOW")
		--获取施法目标
		if SoullettingRubyTarget then
			if RestorationSaves.RestorationOption_Other_AutoTargetIng then
				DA_TargetUnit(SoullettingRubyTarget)
			end
			DA_UseItem(178826, SoullettingRubyTarget)
			--使用阳血紫晶
		end
	end
end

function Restoration_UseDarkmoonDeckRepose()
	--[暗月套牌：休憩]
	if not AuraUtil.FindAuraByName('休憩之四', "player", "HELPFUL") and not AuraUtil.FindAuraByName('休憩之五', "player", "HELPFUL") and not AuraUtil.FindAuraByName('休憩之六', "player", "HELPFUL") and not AuraUtil.FindAuraByName('休憩之七', "player", "HELPFUL") and not AuraUtil.FindAuraByName('休憩之八', "player", "HELPFUL") then
		return
	end
	local CountVar = 3
	if NumGroupMembers > 8 then
	--团队
		if (Health90 >= 4 and Health80 >= 2) or Health80 >= 5 or Health70 >= 4 or Health55 >= 3 then
			CanUseRestoration_UseDarkmoonDeckRepose = 1
		else
			CanUseRestoration_UseDarkmoonDeckRepose = nil
		end
		CountVar = 4
	else
	--小队
		if (Health90 >= 2 and Health80 >= 1) or Health80 >= 3 or Health70 >= 2 or Health55 >= 2 then
			CanUseRestoration_UseDarkmoonDeckRepose = 1
		else
			CanUseRestoration_UseDarkmoonDeckRepose = nil
		end
		CountVar = 3
	end
	--暗月套牌：休憩指示
	if C_Item.IsEquippedItem(173078) and GetItemCooldown(173078) == 0 and CanUseRestoration_UseDarkmoonDeckRepose and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		if WoWAssistantUnlocked then
			local X, Y, Z, UnitID = Restoration_GetEfflorescencePosition(7, CountVar)
			if UnitID then
				Restoration_Mouselooking1 = nil
				Restoration_Mouselooking2 = nil
				Restoration_MouselookingUnitExists = nil
				if IsMouseButtonDown(1) then
					Restoration_Mouselooking1 = 1
					--防止鼠标左键弹起导致视角问题
				end
				if IsMouselooking() then
					Restoration_Mouselooking2 = 1
					--防止鼠标右键弹起导致视角问题
				end
				if UnitExists("target") then
					ClearTarget()
					Restoration_MouselookingUnitExists = 1
					--防止丢失目标
				end
				ClickPosition(X, Y, Z)
				DA_FaceToUnit(UnitID)
				DA_UseItem(173078)
				--使用暗月套牌：休憩
				if Restoration_Mouselooking1 then
					CameraOrSelectOrMoveStart()
					--模拟鼠标左键按下
				end
				if Restoration_Mouselooking2 then
					MouselookStart()
					--模拟鼠标右键按下
				end
				if Restoration_MouselookingUnitExists then
					TargetLastTarget()
					--选回目标
				end
			end
		else
			DA_UseItem(173078)
			--使用暗月套牌：休憩
		end
	end
end

function GetRestoration_EnemyCacheByHealth(sort)
	--按血量高低获取敌对单位
	local Cache = CloneTable(Restoration_EnemyCache) or {}
	local Unit = nil
	Restoration_NotUnlockedEnemy_SumHealth = 0
	for k, v in ipairs(Cache) do
		Restoration_NotUnlockedEnemy_SumHealth = Restoration_NotUnlockedEnemy_SumHealth + v.UnitHealth
	end
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
		Unit = Cache[1].Unit
		Cache = nil
		return Unit
	end
end

function Restoration_OnEvent(self, event, ...)
	if not RestorationCycleStart then return end
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
			if RestorationCycleStart == 1 and DA_GetSpecialization() ~= 105 then
				RestorationSwitchStatusText:SetTextColor(1, 0, 0)
				RestorationSwitchStatusText:Hide()
				RestorationCycleStart = nil
				Swiftmend_CenarionWard = nil
				Swiftmend_CenarionWard_Sequence2 = nil
			end
		end)
	end
	if event == "CURSOR_CHANGED" 
	and ((C_Spell.IsCurrentSpell(Rebirth_SpellID) and not RestorationSaves.RestorationOption_Other_AutoRebirth) 
	--[复生]
	or C_Spell.IsCurrentSpell(50769) 
	--[起死回生]
	or (C_Spell.IsCurrentSpell(Efflorescence_SpellID) and not RestorationSaves.RestorationOption_Heals_AutoEfflorescence) 
	--[百花齐放]
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
			RestorationManualCursorCastingDelayTime = 1
		else
			RestorationManualCursorCastingDelayTime = 3
		end
		ManualCursorCasting = 1
		RestorationManualCursorCastingTime = GetTime()
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
			if (spellID == Rebirth_SpellID and not RestorationSaves.RestorationOption_Other_AutoRebirth) or spellID == 50769 then
				RestorationManualCastingDelayTime = 1.5
			else
				if C_PvP.IsActiveBattlefield() then
					RestorationManualCastingDelayTime = 0.25
				else
					RestorationManualCastingDelayTime = 1
				end
			end
			RestorationSpell = nil
			--print(name)
			--print(DA_SelfCastSpellName)
			if name == DA_SelfCastSpellName then RestorationSpell = 1 end
			-- if spellID == Lifebloom_SpellID or spellID == 188550 then RestorationSpell = 1 end --生命绽放(正式服[蔓生绽放]天赋会改变[生命绽放]法术ID为188550,且IsPlayerSpell(188550)为假,且会和DA_GetAssignSpellIDs获取到的[生命绽放]法术ID不一致)
			-- if spellID == Rejuvenation_SpellID then RestorationSpell = 1 end --回春术
			-- if spellID == Regrowth_SpellID then RestorationSpell = 1 end --愈合
			-- if spellID == Nourish_SpellID then RestorationSpell = 1 end --滋养
			-- if spellID == Swiftmend_SpellID then RestorationSpell = 1 end --迅捷治愈
			-- if spellID == Cenarion_Ward_SpellID then RestorationSpell = 1 end --塞纳里奥结界
			-- if spellID == Wild_Growth_SpellID then RestorationSpell = 1 end --野性成长
			-- if spellID == Innervate_SpellID then RestorationSpell = 1 end --激活
			-- if spellID == Incarnation_Tree_of_Life_SpellID then RestorationSpell = 1 end --化身：生命之树
			-- if spellID == Flourish_SpellID then RestorationSpell = 1 end --繁盛
			-- if spellID == Nature_Swiftness_SpellID then RestorationSpell = 1 end --自然迅捷
			-- if spellID == Convoke_the_Spirits_SpellID and RestorationSaves.RestorationOption_Heals_AutoCovenant then RestorationSpell = 1 end --万灵之召
			-- if spellID == 323546 then RestorationSpell = 1 end --饕餮狂乱
			-- if spellID == Berserking_SpellID then RestorationSpell = 1 end --狂暴(种族特长)
			-- if spellID == Renewal_SpellID then RestorationSpell = 1 end --甘霖
			-- if spellID == Overgrowth_SpellID then RestorationSpell = 1 end --过度生长
			-- if spellID == Soothe_SpellID and RestorationSaves.RestorationOption_Auras_ClearEnrage then RestorationSpell = 1 end --安抚
			-- if spellID == Tranquility_SpellID or spellID == 157982 and RestorationSaves.RestorationOption_Heals_AutoTranquility then RestorationSpell = 1 end --宁静(引导类技能开始后,引导产生治疗的法术ID也要加上)
			-- if spellID == Barkskin_SpellID then RestorationSpell = 1 end --树皮术
			-- if spellID == Ironbark_SpellID then RestorationSpell = 1 end --铁木树皮
			-- if spellID == Invigorate_SpellID then RestorationSpell = 1 end --鼓舞
			-- if spellID == Grove_Guardians_SpellID then RestorationSpell = 1 end --林莽卫士
			-- if spellID == Thorns_SpellID then RestorationSpell = 1 end --荆棘术
			-- if spellID == Efflorescence_SpellID and RestorationSaves.RestorationOption_Heals_AutoEfflorescence then RestorationSpell = 1 end --百花齐放
			-- if spellID == Nature_Cure_SpellID and RestorationSaves.RestorationOption_Auras_ClearCurse and RestorationSaves.RestorationOption_Auras_ClearMagic and RestorationSaves.RestorationOption_Auras_ClearPoison then RestorationSpell = 1 end --自然之愈
			-- if spellID == Rebirth_SpellID and RestorationSaves.RestorationOption_Other_AutoRebirth then RestorationSpell = 1 end --复生
			-- if spellID == 319454 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --野性之心
			-- if spellID == 93402 and not IsActiveBattlefieldArena() and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --阳炎术
			-- if spellID == 8921 and not IsActiveBattlefieldArena() and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --月火术
			-- if spellID == 5176 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --愤怒
			-- if spellID == 197628 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --星火术
			-- if spellID == 197626 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --星涌术
			-- if spellID == 768 and not C_PvP.IsActiveBattlefield() and not IsInRaid() and not UnitExists('boss1') and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --猎豹形态
			-- if spellID == 1822 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --斜掠
			-- if spellID == 5221 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --撕碎
			-- if spellID == 106830 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --痛击
			-- if spellID == 106785 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --横扫
			-- if spellID == 1079 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --割裂
			-- if spellID == 22568 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --凶猛撕咬
			-- if spellID == 22570 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --割碎
			-- if spellID == 124974 and RestorationSaves.RestorationOption_Other_AutoDPS then RestorationSpell = 1 end --自然的守护
			-- if spellID == Bear_Form_SpellID and RestorationSaves.RestorationOption_Other_ClearRoot and RestorationSpellBearFormClearRoot then RestorationSpell = 1 end --熊形态
			if not RestorationSpell then
				local start, duration = DA_GetSpellCooldown(113)
				local start2, duration2 = DA_GetSpellCooldown(spellID)
				if (duration2 == duration or duration2 == 0) and DA_IsUsableSpell(spellID) and (IsPlayerSpell(spellID) or name == "野性冲锋") then
					ManualCasting = 1
					if UnitCastingInfo("player") == '愈合' or UnitCastingInfo("player") == '滋养' or UnitCastingInfo("player") == '野性成长' or ((UnitCastingInfo("player") == '愤怒' or UnitCastingInfo("player") == '星火术') and RestorationSaves.RestorationOption_Other_AutoDPS) then
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
				RestorationManualCastingTime = GetTime()
			end
			if event == "UNIT_SPELLCAST_SUCCEEDED" and (IsPlayerSpell(spellID) or name == "野性冲锋" or name == "生命绽放") then
				if spellID == Entangling_Roots_SpellID or spellID == Hibernate_SpellID or spellID == Cyclone_SpellID then
					--纠缠根须、休眠、旋风,延迟0.1秒取消手动施法指示
					C_Timer.After(0.1, function()
						ManualCasting = nil
					end)
				else
					ManualCasting = nil
				end
			end
		end
	end
	if event == "UNIT_SPELLCAST_SENT" and a == "player" then
		RestorationTargetNotVisibleUnit = b
		local name, rank, icon, castingTime, minRange, maxRange, spellID = DA_GetSpellInfo(eid)
		if spellID == Tranquility_SpellID then
			--宁静保护,防止发包宁静技能之后,后续技能中断宁静
			RestorationSpellWillBeChannel = 1
			if not ClearWillBeChannel_C_TimerIng then
				ClearWillBeChannel_C_TimerIng = 1
				C_Timer.After(1, function()
				--发包1秒后保护结束
					RestorationSpellWillBeChannel = nil
					ClearWillBeChannel_C_TimerIng = nil
				end)
			end
		end
		if spellID == Convoke_the_Spirits_SpellID then
			--万灵之召保护,防止发包万灵之召技能之后,后续技能中断万灵之召
			RestorationSpellWillBeChannel = 1
			if not ClearWillBeChannel_C_TimerIng then
				ClearWillBeChannel_C_TimerIng = 1
				C_Timer.After(1, function()
				--发包1秒后保护结束
					RestorationSpellWillBeChannel = nil
					ClearWillBeChannel_C_TimerIng = nil
				end)
			end
		end
		if spellID == 93402 or spellID == 8921 or spellID == 5176 or spellID == 5211 or spellID == 1822 or spellID == 5221 or spellID == 1079 or spellID == 22568 or spellID == 197628 or spellID == 197626 then
			--自动输出技能
			RestorationAutoDPSSpellSent = 1
		else
			RestorationAutoDPSSpellSent = nil
		end
	end
	if b == "SPELL_AURA_APPLIED" and d == UnitGUID("Player") then
		if l == 102352 and IsPlayerSpell(392410) and not RestorationHeals_SwiftmendCD and RestorationSaves.RestorationOption_Heals_HealTank then
			Swiftmend_CenarionWard = 1
			Swiftmend_CenarionWard_Sequence2 = 1
			C_Timer.After(3, function()
				if not RestorationHeals_SwiftmendCD then
				--3秒后如果迅捷治愈没有进入CD,则自动清除迅捷治愈延长塞纳里奥结界赋值,避免因其他原因无法施放迅捷治愈导致卡技能
					Swiftmend_CenarionWard = nil
					Swiftmend_CenarionWard_Sequence2 = nil
				end
			end)
			--装备[翡翠灌注]时,成功触发了塞纳里奥结界治疗,且迅捷治愈没有CD，为迅捷治愈延长塞纳里奥结界赋值
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
		if spellID == Tranquility_SpellID then
			C_Timer.After(1, function()
			--宁静施法成功,1秒后保护结束
				RestorationSpellWillBeChannel = nil
			end)
		end
		if spellID == Convoke_the_Spirits_SpellID then
			C_Timer.After(1, function()
			--万灵之召施法成功,1秒后保护结束
				RestorationSpellWillBeChannel = nil
			end)
		end
		if spellID == Grove_Guardians_SpellID then
			Restoration_Casted_Grove_Guardians = 1
			C_Timer.After(0.5, function()
			--林莽卫士施法成功,0.5秒内不再施放
				Restoration_Casted_Grove_Guardians = nil
			end)
		end
		if spellID == Wild_Growth_SpellID then
			RestorationSingleItemSwitch = nil
			--防止饰品和其他爆发性小技能一起开,施放一次野性成长后重置
		end
		if spellID == Overgrowth_SpellID and not IsPlayerSpell(392301) then
			Overgrowth_NoCastLifebloom = 1
			C_Timer.After(15, function()
			--不能对两个目标使用[生命绽放]时,过度生长施法成功,15秒后才施放下一个生命绽放,以免重新施放生命绽放浪费技能
				Overgrowth_NoCastLifebloom = nil
			end)
		end
		if spellID == Swiftmend_SpellID then
			Swiftmend_CenarionWard = nil
			--成功施放了迅捷治愈，清除迅捷治愈延长塞纳里奥结界赋值
			C_Timer.After(14.5, function()
				if IsPlayerSpell(392410) and RestorationSaves.RestorationOption_Heals_HealTank and Swiftmend_CenarionWard_Sequence2 then
					Swiftmend_CenarionWard = 1
					C_Timer.After(3, function()
						if not RestorationHeals_SwiftmendCD then
						--3秒后如果迅捷治愈没有进入CD,则自动清除迅捷治愈延长塞纳里奥结界赋值,避免因其他原因无法施放迅捷治愈导致卡技能
							Swiftmend_CenarionWard = nil
							Swiftmend_CenarionWard_Sequence2 = nil
						end
					end)
				end
				Swiftmend_CenarionWard_Sequence2 = nil
			end)
		end
		if select(2, DA_GetSpellCooldown(113)) * 1000 > 0 then
			RestorationHeals_SpellGCD = select(2, DA_GetSpellCooldown(113)) * 1000
			--获取公共CD时间
		end
		if spellID == Efflorescence_SpellID then
			Restoration_DestroyTotem = nil
			--防止正常模式下施放百花齐放后刚好进入[低法力指示]，导致Restoration_DestroyTotem ~= nil，导致不停施放百花齐放
		end
		if spellID == 5487 and RestorationSpellBearFormClearRoot and not IsStealthed() and not Restoration_SelfSaveIng then
			RestorationSpellBearFormClearRoot = nil
			DA_Cancelform()
			--print('取消变形4')
		end
	end
	if event == "UI_ERROR_MESSAGE" and (b == "目标不在视野中" or b == "你的视线被遮挡了" or b == "无效的目标" or b == "你必须面对目标。") then
		--print("UI_ERROR_MESSAGE: "..RestorationTargetNotVisibleUnit.." 不在视野中")
		if UnitExists(RestorationTargetNotVisibleUnit) then
			RestorationHeals_TargetNotVisible = RestorationHeals_TargetNotVisible or {}
			local guid = UnitGUID(RestorationTargetNotVisibleUnit)
			if not DA_UnitIsInTable(guid, RestorationHeals_TargetNotVisible) then
				--目标不在表格内
				table.insert(RestorationHeals_TargetNotVisible, {
					Unit = RestorationTargetNotVisibleUnit, 
					UnitGUID = guid, 
				})  --写入表格内
				--print('不在视野目标 ['..RestorationTargetNotVisibleUnit..'] 写入表格')
			end
			if not ClearTargetNotVisibleTable_C_TimerIng then
				ClearTargetNotVisibleTable_C_TimerIng = 1
				if IsActiveBattlefieldArena() then
					ClearTargetNotVisibleTableAfterTime = 0.5
				else
					ClearTargetNotVisibleTableAfterTime = 1.5
				end
				C_Timer.After(ClearTargetNotVisibleTableAfterTime, function()
					--print('清空TargetNotVisibleTable')
					RestorationHeals_TargetNotVisible = {}
					ClearTargetNotVisibleTable_C_TimerIng = nil
				end)
			end
		end
	end
	if event == "UI_ERROR_MESSAGE" and RestorationAutoDPSSpellSent and RestorationSaves.RestorationOption_Other_AutoDPS then
		if b == "你必须面对目标。" then
			RestorationAutoDPSTargetNotFacing = 1
			RestorationAutoDPSTargetNotFacingTime = GetTime()
			
		end
		if (b == "目标不在视野中" or b == "你的视线被遮挡了") then
			RestorationAutoDPSTargetNotVisible = 1
			RestorationAutoDPSTargetNotVisibleTime = GetTime()
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_DAMAGE" and string.sub(d, 1, 6) == "Player" and Restoration_EnemyCache and #Restoration_EnemyCache < 1 and not UnitIsDeadOrGhost("player") then
		if (Restoration_FindEnemyCombatLogIntervalTime and GetTime() - Restoration_FindEnemyCombatLogIntervalTime > 1) or not Restoration_FindEnemyCombatLogIntervalTime then
			Restoration_FindEnemyCombatLogIntervalTime = GetTime()
			if WoWAssistantUnlocked and RestorationSaves.RestorationOption_Other_AutoDPS and RestorationStatusRestorationHealsParty then
				--EasyWoWToolbox或者FireHack已载入
				local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(d)
				if UnitPlayerOrPetInParty(name) and DA_GetNovaDistance("player", name) <= 30 and DA_GetLineOfSight("player", name) then
				--过滤其他无关玩家
					if GetObjectCount() > 0 then
						local MX,MY,MZ = ObjectPosition("player")
						for i = 1, GetObjectCount() do
							local thisUnit = GetObjectWithIndex(i)
							if UnitExists(thisUnit) then
								local X1,Y1,Z1 = ObjectPosition(thisUnit)
								if DA_IsSpellInRange(5176, thisUnit) == 1 and UnitGUID(thisUnit) == h and not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) and DA_GetLineOfSight("player", thisUnit) and not DamagerEngineGetIgnoreUnit(thisUnit) then
									--通过战斗记录发现敌对目标
									if math.abs(MZ - Z1) < 10 or DA_GetLineOfSight("player", thisUnit) then
										--排除与玩家高度坐标相差10以上且不在视野中的单位
										table.insert(Restoration_EnemyCache, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
											UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
										}) --写入表格内
										Restoration_DoDPS = 1
										--print(UnitName(thisUnit))
										break
									end
								end
							end
						end
					end
				end
			end
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_CAST_SUCCESS" and l == 320823 then
		C_Timer.After(0.1, function()
			Restoration_FindEnemyIntervalTime = nil
		end)
		--通过战斗记录监测,如果召唤了实验型松鼠炸弹,则0.1秒后无视扫描目标间隔,重新扫描所有目标
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_CAST_SUCCESS" and m == '百花齐放' and d == UnitGUID("player") then
		--通过战斗记录监测,如果玩家自己施放了百花齐放,则10秒内不在都认为不需要再次施放百花齐放
		--print('施放了百花齐放')
		Restoration_Cast_Success_Efflorescence = 1
		if not ClearCast_Success_Efflorescence_C_TimerIng then
			ClearCast_Success_Efflorescence_C_TimerIng = 1
			C_Timer.After(10, function()
				--print('百花齐放10秒保护期结束')
				Restoration_Cast_Success_Efflorescence = nil
				ClearCast_Success_Efflorescence_C_TimerIng = nil
			end)
		end
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" and b == "SPELL_HEAL" and m == '百花齐放' and d == UnitGUID("player") then
		--通过战斗记录监测,如果5秒没有受到玩家自己的百花齐放治疗,则认为可以再次施放百花齐放
		--print('有玩家受到自己的百花齐放治疗')
		Restoration_LastEfflorescenceHealTime = GetTime()
	end
	
	--if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "UNIT_HEAL_PREDICTION" or event == "UNIT_SPELLCAST_START" or not RestorationIntervalTime then
	--COMBAT_LOG_EVENT_UNFILTERED及子事件性能不及UNIT_SPELLCAST_系列事件,事件多时偶尔会产生延迟影响代码执行 2024-8-4
	if event == "UNIT_HEAL_PREDICTION" or event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_SUCCEEDED" or not RestorationIntervalTime then
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo("player")
		if endTime then
			GCDtimeLeft = endTime/1000 - GetTime()
			--剩余施法时间
		end
		if name and not TQMark then
		--读条技能
			GCDMarkTime = GCDMarkTime or GetTime()
			--开始施法时间
			GCDCastTime = (endTime - startTime)/1000
			--读条技能时长
		elseif not TQMark then
		--瞬发技能
			GCDMarkTime = GCDMarkTime or GetTime()
			--开始施法时间
			GCDCastTime = GCDCastTime or select(2, DA_GetSpellCooldown(113))
			--瞬发技能公共CD
		end
		if GCDMarkTime and GCDCastTime and GetTime() - GCDMarkTime > GCDCastTime - 0.5 then
		--提前0.5秒结束公共CD状态
			--关闭公共CD状态标识
			Restoration_InGCD = nil
			TQMark = 1
			--提前量区间标记
		end
		if event == "UNIT_SPELLCAST_START" and a == 'player' then
			Restoration_SpellID = c
			Restoration_SpellCastID = b
			--print("开始施放: "..DA_GetSpellInfo(c))
			--获取法术名字及该法术GUID
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
		if event == "UNIT_HEAL_PREDICTION" and UnitCastingInfo("player") and Restoration_SpellCastID and not Restoration_HealsUnit then
			--当引发了"UNIT_HEAL_PREDICTION"事件,且玩家正在施法
			--print("触发'UNIT_HEAL_PREDICTION'事件")
			Restoration_SpellCastID = nil
			--玩家施放的直接治疗法术会将Restoration_SpellCastID清空,避免该法术施法途中被其他玩家引发的'UNIT_HEAL_PREDICTION'事件给下面的Restoration_HealsUnit赋值,保证Restoration_HealsUnit的赋值为玩家直接治疗法术的施法目标
			local name, text, texture, startTimeMS, endTimeMS, isTradeSkill, castID, notInterruptible, spellId = UnitCastingInfo("player")
			if spellId and (spellId == Regrowth_SpellID or spellId == Nourish_SpellID) then
				--玩家施放的是直接治疗法术,则给Restoration_HealsUnit赋值
				Restoration_HealsUnit = a
				--print("治疗目标:"..UnitName(Restoration_HealsUnit)..', 预计治疗量:'..UnitGetIncomingHeals(Restoration_HealsUnit, "player")..", 血量缺口:"..UnitHealthMax(Restoration_HealsUnit) - UnitHealth(Restoration_HealsUnit))
				--获取被治疗的目标
			else
				--print('正在施放的法术不是直接治疗法术')
			end
		end
		if not UnitCastingInfo("player") and Restoration_HealsUnit then
			--法术施法结束后将Restoration_HealsUnit清空,以便下一次施法时判断
			Restoration_HealsUnit = nil
			--print('清空Restoration_HealsUnit')
		end
		
		if Restoration_HealsUnit and UnitLevel(Restoration_HealsUnit) < UnitLevel("player") - 5 then
		--如果被治疗目标的等级低于玩家等级5级以上,则按血量打断过量治疗
			if UnitCastingInfo("player") == '愈合' and GCDtimeLeft and GCDtimeLeft < 0.5 and Restoration_HealsUnit and UnitHealth(Restoration_HealsUnit)/UnitHealthMax(Restoration_HealsUnit) > 0.9 and DA_IsSpellInRange(Restoration_SpellID, Restoration_HealsUnit) == 1 and ((not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn) or HealerEngineHeals_HealAurasNoOver) and not HealerEngine_GetSpecialHealsUnit(Restoration_HealsUnit) then
			--愈合施法剩余时间小于0.5秒时,开始检查过量治疗,目标血量大于90%则无视该目标 2024-8-10-test
				DA_SpellStopCasting()
				--print('中断施法'..' 剩余读条时间: '..GCDtimeLeft)
			end
		else
		--如果被治疗目标的等级不低于玩家等级5级,则通过UnitGetIncomingHeals判断打断过量治疗
			if UnitCastingInfo("player") == '愈合' and GCDtimeLeft and GCDtimeLeft < 0.5 and Restoration_HealsUnit and UnitGetIncomingHeals(Restoration_HealsUnit, "player") and UnitGetIncomingHeals(Restoration_HealsUnit, "player") > (UnitHealthMax(Restoration_HealsUnit) - UnitHealth(Restoration_HealsUnit)) * 1.5 and DA_IsSpellInRange(Restoration_SpellID, Restoration_HealsUnit) == 1 and ((not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn) or HealerEngineHeals_HealAurasNoOver) and not HealerEngine_GetSpecialHealsUnit(Restoration_HealsUnit) then
			--愈合施法剩余时间小于0.5秒时,开始检查过量治疗,目标即将受到的治疗大于损失的血量的1.5倍则无视该目标
				DA_SpellStopCasting()
				--print('中断施法'..' 剩余读条时间: '..GCDtimeLeft)
			end
		end
		if Restoration_HealsUnit and UnitLevel(Restoration_HealsUnit) < UnitLevel("player") - 5 then
		--如果被治疗目标的等级低于玩家等级5级以上,则按血量打断过量治疗
			if UnitCastingInfo("player") == '滋养' and GCDtimeLeft and GCDtimeLeft < 0.5 and Restoration_HealsUnit and UnitHealth(Restoration_HealsUnit)/UnitHealthMax(Restoration_HealsUnit) > 0.9 and DA_IsSpellInRange(Restoration_SpellID, Restoration_HealsUnit) == 1 and ((not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn) or HealerEngineHeals_HealAurasNoOver) and not HealerEngine_GetSpecialHealsUnit(Restoration_HealsUnit) then
			--滋养施法剩余时间小于0.5秒时,开始检查过量治疗,目标血量大于90%则无视该目标 2024-8-10-test
				DA_SpellStopCasting()
				--print('中断施法'..' 剩余读条时间: '..GCDtimeLeft)
			end
		else
		--如果被治疗目标的等级不低于玩家等级5级,则通过UnitGetIncomingHeals判断打断过量治疗
			if UnitCastingInfo("player") == '滋养' and GCDtimeLeft and GCDtimeLeft < 0.5 and Restoration_HealsUnit and UnitGetIncomingHeals(Restoration_HealsUnit, "player") and UnitGetIncomingHeals(Restoration_HealsUnit, "player") > (UnitHealthMax(Restoration_HealsUnit) - UnitHealth(Restoration_HealsUnit)) * 1.5 and DA_IsSpellInRange(Restoration_SpellID, Restoration_HealsUnit) == 1 and ((not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn) or HealerEngineHeals_HealAurasNoOver) and not HealerEngine_GetSpecialHealsUnit(Restoration_HealsUnit) then
			--滋养施法剩余时间小于0.5秒时,开始检查过量治疗,目标即将受到的治疗大于损失的血量的1.5倍则无视该目标
				DA_SpellStopCasting()
				--print('中断施法'..' 剩余读条时间: '..GCDtimeLeft)
			end
		end
		
		if (not TQMark and select(2, DA_GetSpellCooldown(113)) ~= 0) or UnitChannelInfo("player") then
		--非提前结束公共CD状态且公共CD中、引导法术中
			Restoration_InGCD = 1
			--启动公共CD状态标识
		end
		if select(2, DA_GetSpellCooldown(113)) == 0 and not name then
		--非公共CD中且不在读条中(中断施法监测)
			GCDCastTime = nil
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
			GCDCastTime = nil
			--重新读取公共CD
			GCDMarkTime = nil
			--重新读取开始施法时间
			TQMark = nil
			--终止提前结束公共CD状态
		end
		--公共CD指示
	end
end

function Restoration_OnUpdate(self, event, ...)
	if not RestorationCycleStart then return end
	
	Restoration_WriteSumHealthTimelineCache()
	--总剩余血量时间轴写入缓存
	if RestorationSaves.RestorationOption_Other_ShowCastlInfo then
		if not RestorationSwitchStatusText:IsShown() and not RestorationCycleStartFlash then
			RestorationSwitchStatusText:Show()
		end
		if Restoration_Enemy_SumHealthScale then
			if Restoration_Enemy_SumHealthScale >= 0.7 then
				Restoration_DeBugEnemyCount:SetTextColor(1, 1 - Restoration_Enemy_SumHealthScale, 0)
			else
				Restoration_DeBugEnemyCount:SetTextColor(Restoration_Enemy_SumHealthScale * 2, 1 - Restoration_Enemy_SumHealthScale, 0)
			end
		end
		if RestorationHeals_DoNotHeals and not RestorationCycleStartFlash then
			RestorationSwitchStatusText:SetTextColor(1, 0, 0)
		elseif RestorationHeals_DoNotHealsLowMana and not RestorationCycleStartFlash then
			RestorationSwitchStatusText:SetTextColor(0, 0, 1)
		elseif (ManualCasting or ManualCursorCasting) and not RestorationCycleStartFlash then
			RestorationSwitchStatusText:SetTextColor(0.5, 0, 0.5)
		elseif Restoration_InGCD and not RestorationCycleStartFlash then
			RestorationSwitchStatusText:SetTextColor(1, 1, 0)
		elseif RestorationSaves.RestorationOption_Effect == 1 then
			RestorationSwitchStatusText:SetTextColor(1, 0.49, 0.04)
		elseif RestorationSaves.RestorationOption_Effect == 3 then
			RestorationSwitchStatusText:SetTextColor(0.53, 0.81, 0.98)
		else
			RestorationSwitchStatusText:SetTextColor(0, 1, 0)
		end
	elseif RestorationSwitchStatusText then
		RestorationSwitchStatusText:Hide()
		Restoration_DeBugEnemyCount:Hide()
		Restoration_DeBugSpellIcon:Hide()
	end
	if ManualCasting then
		RestorationManualCastingTime = RestorationManualCastingTime or GetTime()
		if GetTime() - RestorationManualCastingTime < RestorationManualCastingDelayTime or UnitCastingInfo("player") then
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
			ManualCasting = nil
			RestorationManualCastingTime = nil
		end
	end
	if ManualCursorCasting then
		RestorationManualCursorCastingTime = RestorationManualCursorCastingTime or GetTime()
		if GetTime() - RestorationManualCursorCastingTime < RestorationManualCursorCastingDelayTime and SpellIsTargeting() then
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
			ManualCursorCasting = nil
			RestorationManualCursorCastingTime = nil
		end
	end
	if RestorationAutoDPSTargetNotFacing then
		if GetTime() - RestorationAutoDPSTargetNotFacingTime > 1.5 then
			RestorationAutoDPSTargetNotFacing = nil
			RestorationAutoDPSTargetNotFacingTime = nil
		end
	end
	if RestorationAutoDPSTargetNotVisible then
		if GetTime() - RestorationAutoDPSTargetNotVisibleTime > 1.5 then
			RestorationAutoDPSTargetNotVisible = nil
			RestorationAutoDPSTargetNotVisibleTime = nil
		end
	end
	DA_TargetVisibleTime = DA_TargetVisibleTime or GetTime()
	if GetTime() - DA_TargetVisibleTime > 1.5 then
		DA_TargetVisibleTime = nil
		DA_CanNotTargetNearest = nil
		DA_Start_TargetNearest_Unit = nil
		DA_traversedGUIDs_Last = nil
	end
	
	-- if RestorationSaves.RestorationOption_Effect == 3 then
	-- 	--省蓝模式
	-- 	local Scale = 0.05
	-- 	GetAddOnCPUUsageTime = GetAddOnCPUUsageTime or GetTime()
	-- 	if GetTime() - GetAddOnCPUUsageTime > Scale + Scale then
	-- 		WoWAssistant_CPUUsage1 = GetAddOnCPUUsage("WoWAssistantPX") / Scale
	-- 		GetAddOnCPUUsageTime = nil
	-- 		GetAddOnCPUUsageTime2 = GetAddOnCPUUsageTime2 or GetTime()
	-- 	end
	-- 	if GetAddOnCPUUsageTime2 and GetTime() - GetAddOnCPUUsageTime2 > Scale then
	-- 		GetAddOnCPUUsageTime2 = nil
	-- 		UpdateAddOnCPUUsage()
	-- 		WoWAssistant_CPUUsage2 = GetAddOnCPUUsage("WoWAssistantPX") / Scale
	-- 		WoWAssistant_CPUUsage = WoWAssistant_CPUUsage2 - WoWAssistant_CPUUsage1
	-- 		--print(WoWAssistant_CPUUsage)
	-- 		if WoWAssistant_CPUUsage > 50 then
	-- 			WoWAssistant_CPUUsageHigh = 1
	-- 		else
	-- 			WoWAssistant_CPUUsageHigh = nil
	-- 		end
	-- 	end
	-- else
	-- 	WoWAssistant_CPUUsageHigh = nil
	-- end
	--以上代码有反映会导致卡顿,暂时停用
	
	Restoration_TraversalHealthInterval = tonumber(RestorationSaves.TraversalHealthInterval)
	if Restoration_TraversalHealthInterval < 0.01 then
		Restoration_TraversalHealthInterval = 0.01
	end
	RestorationIntervalTime = RestorationIntervalTime or GetTime()
	if GetTime() - RestorationIntervalTime > Restoration_TraversalHealthInterval or Restoration_DoDPS then
		DA_Clear_Rooted = 1
		DA_Clear_Deceleration = 1
		RestorationIntervalTime = nil
		RestorationSpellWillBeCast = nil
		RestorationDPSSpellWillBeCast = nil
		RestorationUnitHasAuras = nil
		RestorationUseItem = nil
		if WoWAssistant_CPUUsageHigh then
			--print("占用过高")
			return
		else
			--print("正常")
		end
		
		Restoration_EnemyCount = 0
		
		local PlayerHealthScale = 0
		PlayerHealthScale = UnitHealth("player") / UnitHealthMax("player")
		
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
		
		Restoration_OnEvent(self, event, ...)
		
		Restoration_GetNoCastingAuras()
		--不要读条Auras监测
		if RestorationHeals_NoCastingAuras then
		--防止因为施法队列导致OnEvent中断一次读条后,继续读条
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				DA_SpellStopCasting()
				--读条时遇到不要读条施法则中断施法
			end
		end
		
		if C_Item.IsEquippedItem(215174) and AuraUtil.FindAuraByName(DA_GetSpellInfo(435493), "player", "HELPFUL") then
		--装备了[制剂：死亡之吻],且存在[制剂：死亡之吻]BUFF
			Restoration_UseConcoctionKissOfDeath()
			--[制剂：死亡之吻]
		end
		
		--DA_InteractUnitSituation(DA_InteractUnitSituationCache)
		--从DA_InteractUnitSituationCache表查找需要互动的单位进行互动
		
		RestorationNeedHealsCount = 0
		--总计需要治疗的单位
		
		HealsUnitPriority = {}
		EfflorescenceUnitPriority = {}
		Restoration_FindSpecialHealsUnit()
		--遍历附近特殊治疗目标
		Restoration_TraversalHealth()
		--遍历血量
		if not Restoration_DoDPS then
			Restoration_FindEnemy()
			--遍历附近敌对目标
		else
			Restoration_DoDPS = nil
		end
		
		for i = #Restoration_EnemyCache, 1, -1 do
			DamagerEngineRemoveNoAttackAurasUnit(Restoration_EnemyCache, Restoration_EnemyCache[i].Unit, i)
			--从Restoration_EnemyCache表中移除某些目标
		end
		
		if RestorationSaves.RestorationOption_Other_AutoDPS then
			if GetShapeshiftFormID() == 1 then
				Restoration_EnemyCount = #Restoration_EnemyCacheIn7
			else
				Restoration_EnemyCount = #Restoration_EnemyCache
			end
		end
		
		if RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation and #Restoration_SpecialHealsCache <= 0 then
			Restoration.DBM:getAoe()
			--通过DBM计时条获取AOE技能预警
		else
			RestorationDBMWillAoe = nil
		end
		
		RestorationHeals_DoNotHealsAura = nil
		local DoNotHealsAuraCache = {
			--{Name = "熊形态", ID = 5487, Instance = "德鲁伊-测试"}, 
			{Name = "进食饮水", ID = 167152, Instance = "进食"}, 
			{Name = "饮水", ID = 175787, Instance = "进食"}, 
			{Name = "喝水", ID = 192001, Instance = "进食"}, 
			{Name = "饮用", ID = 369162, Instance = "进食"}, 
			{Name = "食物和饮水", ID = 192002, Instance = "进食"}, 
			{Name = "食物和饮料", ID = 327786, Instance = "进食"}, 
			{Name = "影遁", ID = 58984, Instance = "种族天赋"}, 
			{Name = "鲜血与荣耀", ID = 320102, Instance = "伤逝剧场-无堕者哈夫"}, 
		}
		for i=1, #DoNotHealsAuraCache do
			local name, icon, count, dispelType, duration, expires, caster, isStealable, nameplateShowPersonal, spellID = AuraUtil.FindAuraByName(DoNotHealsAuraCache[i].Name, "player", "HELPFUL")
			if name then
				RestorationHeals_DoNotHealsAura = 1
				break
			end
		end
	
		if WoWAssistantUnlocked then
			if (RestorationObjectIsInTableTime and GetTime() - RestorationObjectIsInTableTime > 1) or not RestorationObjectIsInTableTime then
				RestorationObjectIsInTableTime = GetTime()
				if Restoration_EnemyCache and DA_ObjectIsInTable(173729, Restoration_EnemyCache) then
					--存在傲慢具象
					Restoration_ManifestationOfPrideExists = 1
				else
					Restoration_ManifestationOfPrideExists = nil
				end
			end
		else
			if Restoration_EnemyCache and DA_ObjectIsInTable(173729, Restoration_EnemyCache) then
				--存在傲慢具象
				Restoration_ManifestationOfPrideExists = 1
			else
				Restoration_ManifestationOfPrideExists = nil
			end
		end
			
		if (RestorationGetNoUsePowerfulSpellTime and GetTime() - RestorationGetNoUsePowerfulSpellTime > 0.5) or not RestorationGetNoUsePowerfulSpellTime then
			RestorationGetNoUsePowerfulSpellTime = GetTime()
			if DamagerEngineGetNoUsePowerfulSpell(Restoration_EnemyCache) then
			--不用爆发技能
				Restoration_NoUsePowerfulSpell = 1
			else
				Restoration_NoUsePowerfulSpell = nil
			end
		end
		
		if (GetShapeshiftFormID() and GetShapeshiftFormID() ~= 2 and GetShapeshiftFormID() ~= 36) or IsStealthed() or IsMounted() or UnitIsDeadOrGhost("player") or RestorationHeals_DoNotHealsAura or not HasFullControl() or UnitChannelInfo("player") or (C_Spell.GetSpellLossOfControlCooldown(8921) > 0 and C_Spell.GetSpellLossOfControlCooldown(Regrowth_SpellID) > 0) or GetCurrentKeyBoardFocus() then
			RestorationHeals_DoNotHeals = 1
			--Restoration_DeBugEnemyCount:Hide()
			--Restoration_DeBugSpellIcon:Hide()
		else
			RestorationHeals_DoNotHeals = nil
		end
		--非治疗状态指示
		if ThreatHealth40 == 0 and Health25 == 0 and not RestorationHeals_Grove_Guardians and not RestorationHeals_WildGrowth and not RestorationHeals_WildGrowth2 and not RestorationUnitHasAuras and not HealerEngine_UnitHasHealAurasWarn and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
			if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.1 then
				RestorationHeals_DoNotHealsLowMana = 1
			else
				RestorationHeals_DoNotHealsLowMana = nil
			end
			if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.15 then
				RestorationHeals_DoNotDPSLowMana = 1
			else
				RestorationHeals_DoNotDPSLowMana = nil
			end
		else
			RestorationHeals_DoNotHealsLowMana = nil
			RestorationHeals_DoNotDPSLowMana = nil
		end
		--超低蓝量状态指示
		
		if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.35 and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
			RestorationHeals_LowMana = 1
		else
			RestorationHeals_LowMana = nil
		end
		--35%低法力指示
		
		if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.25 and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
			RestorationHeals_LowMana2 = 1
		else
			RestorationHeals_LowMana2 = nil
		end
		--25%低法力指示
		
		if not RestorationHeals_DoNotHeals and IsInGroup() and not IsInRaid() and DA_GetHasActiveAffix('受难') then
			local SpecialUnitID, Cont = DA_GetHealsSpecialExists('受难之魂')
			if SpecialUnitID then
				if (SpecialUnitPlayTime and GetTime() - SpecialUnitPlayTime > 15) or not SpecialUnitPlayTime then
					SpecialUnitPlayTime = nil
					PlaySoundFile("Interface\\AddOns\\WoWAssistantPX\\Media\\SpecialUnit.ogg", "Master")
				end
				SpecialUnitPlayTime = SpecialUnitPlayTime or GetTime()
			end
			if RestorationSaves.RestorationOption_Auras_ClearCurse or RestorationSaves.RestorationOption_Auras_ClearMagic or RestorationSaves.RestorationOption_Auras_ClearPoison then
				--开启了自动驱散DEBUFF
				if SpecialUnitID and AuraUtil.FindAuraByName('诅咒之魂', 'focus', "HARMFUL") then
					--print('已设置受难之魂为焦点')
				end
				if SpecialUnitID and not AuraUtil.FindAuraByName('诅咒之魂', 'focus', "HARMFUL") then
					--if UnitIsUnit('target', SpecialUnitID) then
					if UnitName('target') == '受难之魂' then
						--print('已选中[受难之魂],尝试设置为焦点')
						DA_pixel_target_frame.texture:SetColorTexture(0.47, 0, 0)
						--设置当前目标为焦点
					else
						--print('发现[受难之魂],尝试选择附近的盟友')
						DA_TargetUnit(SpecialUnitID)
					end
					return
					--暂不治疗
				end
			end
		end
		
		if (AuraUtil.FindAuraByName('激活', "player", "HELPFUL") and select(6, AuraUtil.FindAuraByName('激活', "player", "HELPFUL")) - GetTime() > 2) or (AuraUtil.FindAuraByName('希望象征', "player", "HELPFUL") and select(6, AuraUtil.FindAuraByName('希望象征', "player", "HELPFUL")) - GetTime() > 2) or (UnitPower("player", 0) / UnitPowerMax("player", 0) >= 0.975 and UnitAffectingCombat("player")) then
			RestorationHeals_Innervate = 1
		else
			RestorationHeals_Innervate = nil
		end
		--激活状态、满蓝状态指示
		
		if AuraUtil.FindAuraByName('节能施法', "player", "HELPFUL") and select(6, AuraUtil.FindAuraByName('节能施法', "player", "HELPFUL")) - GetTime() > 2 and (UnitCastingInfo("player") ~= '愈合' or select(3, AuraUtil.FindAuraByName('节能施法', "player", "HELPFUL")) > 1) then
			RestorationHeals_Clearcasting = 1
		else
			RestorationHeals_Clearcasting = nil
		end
		--节能施法状态指示
		
		if IsPlayerSpell(Regrowth_SpellID) and select(4, DA_GetSpellInfo('愈合')) <= 0 then
			RestorationHeals_Instant_Regrowth = 1
		else
			RestorationHeals_Instant_Regrowth = nil
		end
		--[愈合]可瞬发指示
		
		if IsPlayerSpell(48438) and select(4, DA_GetSpellInfo('野性成长')) <= 0 then
			RestorationHeals_Instant_WildGrowth = 1
		else
			RestorationHeals_Instant_WildGrowth = nil
		end
		--[野性成长]可瞬发指示
		
		if IsPlayerSpell(50464) and select(4, DA_GetSpellInfo('滋养')) <= 0 then
			RestorationHeals_Instant_Nourish_Regrowth = 1
		else
			RestorationHeals_Instant_Nourish_Regrowth = nil
		end
		--[滋养]可瞬发指示
		
		local start, duration = DA_GetSpellCooldown(113)
		local start2, duration2 = DA_GetSpellCooldown(Nature_Cure_SpellID)
		if duration2 ~= duration and (start2 + duration2) - GetTime() > 0 then
			Restoration_NatureCureCD_RemainingCooldown  = (start2 + duration2) - GetTime()
		else
			Restoration_NatureCureCD_RemainingCooldown = 0
		end
		--print(Restoration_NatureCureCD_RemainingCooldown)
		if duration2 ~= duration or (ThreatHealth25 and ThreatHealth25 >= 1) or not DA_IsUsableSpell(Nature_Cure_SpellID) or not IsPlayerSpell(Nature_Cure_SpellID) then
			Restoration_NatureCureCD = 1
		elseif duration2 == duration then
			Restoration_NatureCureCD = nil
		end
		--自然之愈CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Soothe_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Soothe_SpellID)) > 3 or not IsPlayerSpell(Soothe_SpellID) then
			SootheCD = 1
		elseif duration2 == duration then
			SootheCD = nil
		end
		--安抚CD判断
		
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
		
		start2, duration2 = DA_GetSpellCooldown(Cenarion_Ward_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Cenarion_Ward_SpellID) or not IsPlayerSpell(Cenarion_Ward_SpellID) or not UnitAffectingCombat("player") then
			RestorationHeals_CenarionWardCD = 1
		elseif duration2 == duration then
			RestorationHeals_CenarionWardCD = nil
		end
		--塞纳里奥结界CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Swiftmend_SpellID)
		if (duration2 ~= duration and GetTime() - start2 > 0.5) or AuraUtil.FindAuraByName('丛林之魂', "player", "HELPFUL") or not IsPlayerSpell(Swiftmend_SpellID) or not UnitAffectingCombat("player") then
			--延迟0.5秒进CD,为了避免技能施放后,因为技能生效延迟影响化身血量的判断
			RestorationHeals_SwiftmendCD = 1
		elseif duration2 == duration then
			RestorationHeals_SwiftmendCD = nil
		end
		--迅捷治愈CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Wild_Growth_SpellID)
		if duration2 ~= duration and GetTime() - start2 <= 1.5 then
			WildGrowthCDBenignPart_15 = 1
		else
			WildGrowthCDBenignPart_15 = nil
		end
		if duration2 ~= duration and GetTime() - start2 <= 2.5 then
			WildGrowthCDBenignPart_25 = 1
		else
			WildGrowthCDBenignPart_25 = nil
		end
		if duration2 ~= duration and GetTime() - start2 <= 3.5 then
			WildGrowthCDBenignPart_35 = 1
		else
			WildGrowthCDBenignPart_35 = nil
		end
		if duration2 ~= duration and GetTime() - start2 <= 6 then
			WildGrowthCDBenignPart_60 = 1
		else
			WildGrowthCDBenignPart_60 = nil
		end
		if duration2 ~= duration or (NumGroupMembers <= 8 and Health30 and Health30 >= 1) or UnitCastingInfo("player") == '野性成长' or not DA_IsUsableSpell(Wild_Growth_SpellID) or not IsPlayerSpell(Wild_Growth_SpellID) or (HealerEngine_UnitHasHealAurasWarn and RestorationStatusRestorationHealsParty and #HealerEngineHeals_HealAurasUnitCount < 2 and not RestorationHeals_Instant_WildGrowth) then
			WildGrowthCD = 1
		elseif duration2 == duration then
			WildGrowthCD = nil
		end
		--野性成长CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Tranquility_SpellID)
		local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('化身', "player", "HELPFUL")
		--化身Buff
		if (duration2 ~= duration and GetTime() - start2 > 0.5) or (expires1 and expires1 - GetTime() > duration1 - 3) or (ThreatHealth25 and ThreatHealth25 >= 1) or not IsPlayerSpell(Tranquility_SpellID) or IsPlayerMoving() or (HealerEngine_UnitHasHealAurasWarn and RestorationStatusRestorationHealsParty and #HealerEngineHeals_HealAurasUnitCount < 3) or not RestorationSaves.RestorationOption_Heals_AutoTranquility or RestorationHeals_NoCastingAuras or RestorationHeals_NoChannelAuras or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			--延迟0.5秒进CD
			TranquilityCD = 1
		elseif duration2 == duration then
			TranquilityCD = nil
		end
		--宁静CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Innervate_SpellID)
		if duration2 ~= 0 or not IsPlayerSpell(Innervate_SpellID) or AuraUtil.FindAuraByName('傲慢', "player", "HARMFUL") or AuraUtil.FindAuraByName('希望象征', "player", "HELPFUL") or (select(3, AuraUtil.FindAuraByName('节能施法', "player", "HELPFUL")) and select(3, AuraUtil.FindAuraByName('节能施法', "player", "HELPFUL")) >= 2) or (Restoration_ManifestationOfPrideExists and not RestorationHeals_DoNotHealsLowMana) or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			InnervateCD = 1
		elseif duration2 == duration then
			InnervateCD = nil
		end
		--激活CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Barkskin_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Barkskin_SpellID)) > 3 or not IsPlayerSpell(Barkskin_SpellID) or not RestorationSaves.RestorationOption_Heals_AutoIronbark then
			BarkskinCD = 1
		elseif duration2 == 0 then
			BarkskinCD = nil
		end
		--树皮术CD判断
		
		start2, duration2 = DA_GetSpellCooldown(124974)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(124974)) > 3 or not IsPlayerSpell(124974) or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			NatureVigilCD = 1
		elseif duration2 == 0 then
			NatureVigilCD = nil
		end
		--自然的守护CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Berserking_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Berserking_SpellID)) > 3 or not IsPlayerSpell(Berserking_SpellID) or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			BerserkingCD = 1
		elseif duration2 == 0 then
			BerserkingCD = nil
		end
		--狂暴(种族特长)CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Rebirth_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Soothe_SpellID)) > 3 or not IsPlayerSpell(Rebirth_SpellID) or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			RebirthCD = 1
		elseif duration2 == duration then
			RebirthCD = nil
		end
		--复生CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Nature_Swiftness_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Nature_Swiftness_SpellID)) > 3 or not IsPlayerSpell(Nature_Swiftness_SpellID) or AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") then
			NaturesSwiftnessCD = 1
		elseif duration2 == 0 then
			NaturesSwiftnessCD = nil
		end
		--自然迅捷CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Ironbark_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Ironbark_SpellID)) > 3 or not IsPlayerSpell(Ironbark_SpellID) or not RestorationSaves.RestorationOption_Heals_AutoIronbark then
			IronbarkCD = 1
		elseif duration2 == 0 then
			IronbarkCD = nil
		end
		--铁木树皮CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Incarnation_Tree_of_Life_SpellID)
		if duration2 ~= duration or AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") or not IsPlayerSpell(Incarnation_Tree_of_Life_SpellID) or not RestorationSaves.RestorationOption_Heals_AutoIncarnationTreeofLife or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			IncarnationTreeofLifeCD = 1
		elseif duration2 == duration and not AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") then
			IncarnationTreeofLifeCD = nil
		end
		--化身：生命之树CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Flourish_SpellID)
		if duration2 ~= duration or (ThreatHealth25 and ThreatHealth25 >= 1) or UnitChannelInfo("player") or AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") or not IsPlayerSpell(Flourish_SpellID) or (HealerEngine_UnitHasHealAurasWarn and RestorationStatusRestorationHealsParty and #HealerEngineHeals_HealAurasUnitCount < 2) or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			FlourishCD = 1
		elseif duration2 == duration then
			FlourishCD = nil
		end
		--繁盛CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Overgrowth_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Overgrowth_SpellID)) > 3 or not DA_IsUsableSpell('过度生长') or not IsPlayerSpell(Overgrowth_SpellID) or not UnitAffectingCombat("player") then
			OvergrowthCD = 1
		elseif duration2 == duration then
			OvergrowthCD = nil
		end
		--过度生长CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Convoke_the_Spirits_SpellID)
		if (duration2 ~= duration and GetTime() - start2 > 0.5) or not DA_IsUsableSpell('万灵之召') or not IsPlayerSpell(Convoke_the_Spirits_SpellID) or not RestorationSaves.RestorationOption_Heals_AutoCovenant or RestorationHeals_NoCastingAuras or RestorationHeals_NoChannelAuras or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			--延迟0.5秒进CD
			ConvokeTheSpiritsCD = 1
		elseif duration2 == duration then
			ConvokeTheSpiritsCD = nil
		end
		--万灵之召CD判断
		
		start2, duration2 = DA_GetSpellCooldown(338035)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(338035)) > 3 or not DA_IsUsableSpell('自省冥想') or not IsPlayerSpell(338035) or not RestorationSaves.RestorationOption_Heals_AutoCovenant or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			LoneMeditationCD = 1
		elseif duration2 == 0 then
			LoneMeditationCD = nil
		end
		--自省冥想CD判断
		
		start2, duration2 = DA_GetSpellCooldown(323546)
		if duration2 ~= 0 or not DA_IsUsableSpell('饕餮狂乱') or not IsPlayerSpell(323546) or not RestorationSaves.RestorationOption_Heals_AutoCovenant or (Restoration_Enemy_SumHealth < UnitHealthMax("player") * 3.5 and Restoration_Enemy_SumHealth ~= 0.9527 and not C_PvP.IsActiveBattlefield()) then
			RavenousFrenzyCD = 1
		elseif duration2 == duration then
			RavenousFrenzyCD = nil
		end
		--饕餮狂乱CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Invigorate_SpellID)
		if duration2 ~= duration or not DA_IsUsableSpell(Invigorate_SpellID) or not IsPlayerSpell(Invigorate_SpellID) or not UnitAffectingCombat("player") then
			RestorationHeals_InvigorateCD = 1
		elseif duration2 == duration then
			RestorationHeals_InvigorateCD = nil
		end
		--鼓舞CD指示
		
		start2, duration2 = DA_GetSpellCooldown(Grove_Guardians_SpellID)
		if duration2 ~= 0 or select(2, DA_GetSpellCooldown(Grove_Guardians_SpellID)) > 3 or not IsPlayerSpell(Grove_Guardians_SpellID) or (not UnitAffectingCombat("player") and DA_GetSpellCharges(Grove_Guardians_SpellID) < 3) or Restoration_Casted_Grove_Guardians then
			Grove_GuardiansCD = 1
		elseif duration2 == 0 then
			Grove_GuardiansCD = nil
		end
		--林莽卫士CD判断
		
		start2, duration2 = DA_GetSpellCooldown(Thorns_SpellID)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(Thorns_SpellID)) > 3 or not DA_IsUsableSpell('荆棘术') or not IsPlayerSpell(Thorns_SpellID) or not UnitAffectingCombat("player") then
			ThornsCD = 1
		elseif duration2 == duration then
			ThornsCD = nil
		end
		--荆棘术CD判断
		
		start2, duration2 = DA_GetSpellCooldown(102359)
		if duration2 ~= duration or select(2, DA_GetSpellCooldown(102359)) > 3 or not DA_IsUsableSpell('群体缠绕') or not IsPlayerSpell(102359) then
			Mass_EntanglementCD = 1
		elseif duration2 == duration then
			Mass_EntanglementCD = nil
		end
		--群体缠绕CD判断
			
		local start, duration = DA_GetSpellCooldown(113)
		local start2, duration2 = DA_GetSpellCooldown(197626)
		if duration2 ~= duration or not DA_IsUsableSpell(197626) or not IsPlayerSpell(197626) then
			StarsurgeCD = 1
		elseif duration2 == duration then
			StarsurgeCD = nil
		end
		--星涌术CD指示

		local start, duration = DA_GetSpellCooldown(113)
		local start2, duration2 = DA_GetSpellCooldown(319454)
		if duration2 ~= duration or not DA_IsUsableSpell(319454) or not IsPlayerSpell(319454) then
			HeartOfTheWildCD = 1
		elseif duration2 == duration then
			HeartOfTheWildCD = nil
		end
		--野性之心CD指示
		
		local start, duration = DA_GetSpellCooldown(113)
		local start2, duration2 = DA_GetSpellCooldown(5176)
		if duration2 ~= duration or not DA_IsUsableSpell(5176) or not IsPlayerSpell(5176) then
			WrathCD = 1
		elseif duration2 == duration then
			WrathCD = nil
		end
		--愤怒CD指示(自然系法术被打断)
		
		RestorationHeals_SpellGCD = RestorationHeals_SpellGCD or 1250
		--local _, _, _, castingTime = DA_GetSpellInfo(5185) --治疗之触
		--if IsPlayerSpell(102351) and castingTime <= RestorationHeals_SpellGCD + 100 and not RestorationHeals_Clearcasting and RestorationSaves.RestorationOption_Effect ~= 1 and (RestorationSaves.RestorationOption_Effect == 3 or RestorationHeals_LowMana) then
		--	RestorationHeals_Abundance = 1
		--else
		--	RestorationHeals_Abundance = nil
		--end
		Abundance_Count = select(3, AuraUtil.FindAuraByName('丰饶', "player", "HELPFUL"))
		if Abundance_Count and Abundance_Count >= 5 then
			RestorationHeals_Abundance = 1
		else
			RestorationHeals_Abundance = nil
		end
		--丰饶指示
		
		Reforestation_Count = select(3, AuraUtil.FindAuraByName('森林再生', "player", "HELPFUL"))
		if IsPlayerSpell(392356) and Reforestation_Count and Reforestation_Count >= 2 then
			Reforestation_Will_IncarnationTreeofLife = 1
		else
			Reforestation_Will_IncarnationTreeofLife = nil
		end
		--森林再生叠加2层即将化身指示
		
		RangeCheckTime = RangeCheckTime or GetTime()
		if GetTime() - RangeCheckTime > 1 then
		--距离监测时间间隔
			if IsInRaid() then
				IsInRange = nil
				for i=1, GetNumGroupMembers() do
					if DA_IsSpellInRange(Regrowth_SpellID, "raid"..i) == 1 and UnitPhaseReason("raid"..i)~=0 and UnitPhaseReason("raid"..i)~=1 then
						if UnitGUID("raid"..i) ~= UnitGUID("player") then
							IsInRange = 1
						end
					end
				end
				if IsInRange then
					IsNoRange = nil
				else
					IsNoRange = 1
				end
			elseif IsInGroup() then
				IsInRange = nil
				for i=1, GetNumGroupMembers() - 1 do
					if DA_IsSpellInRange(Regrowth_SpellID, "party"..i) == 1 and UnitPhaseReason("party"..i)~=0 and UnitPhaseReason("party"..i)~=1 then
						IsInRange = 1
					end
				end
				if IsInRange then
					IsNoRange = nil
				else
					IsNoRange = 1
				end
			else
				IsNoRange = nil
			end
			RangeCheckTime = nil
		end
		if IsNoRange and RestorationSaves.RestorationOption_Other_NoRange then
			if (RangeCheckPlayTime and GetTime() - RangeCheckPlayTime > 10) or not RangeCheckPlayTime then
				RangeCheckPlayTime = nil
				PlaySoundFile("Interface\\AddOns\\WoWAssistant\\Media\\Toofar.ogg", "Master")
				FlashClientIcon()
			end
			RangeCheckPlayTime = RangeCheckPlayTime or GetTime()
		end
		--距离过远指示
		
		if (Restoration_UnitIsDeadOrGhost or UnitIsDeadOrGhost("player")) and RestorationSaves.RestorationOption_Other_Dead then
			if (Restoration_UnitIsDeadOrGhostPlayTime and GetTime() - Restoration_UnitIsDeadOrGhostPlayTime > 30) or not Restoration_UnitIsDeadOrGhostPlayTime then
				Restoration_UnitIsDeadOrGhostPlayTime = nil
				PlaySoundFile("Interface\\AddOns\\WoWAssistant\\Media\\Pdead.ogg", "Master")
				FlashClientIcon()
			end
			Restoration_UnitIsDeadOrGhostPlayTime = Restoration_UnitIsDeadOrGhostPlayTime or GetTime()
		end
		--阵亡指示
		
		if Restoration_CanNotMovingCast() then
			HealthScaleVariables = 0.7
		else
			HealthScaleVariables = 0.4
		end
		if C_PvP.IsActiveBattlefield() then
		--战场/竞技场中
			if UnitHealth("player") / UnitHealthMax("player") <= 0.3 and UnitAffectingCombat("player") and not RenewalCD and not IsStealthed() and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				DA_CastSpellByName('熊形态甘霖治疗石宏')
				--熊形态甘霖治疗石宏
				Restoration_RefreshRaidCastlInfo("player", Renewal_SpellID)
				RestorationSpellWillBeCast = 1
				Restoration_SelfSaveIng = 1
			elseif Restoration_SelfSaveIng and GetShapeshiftFormID() == 5 and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") then
				Restoration_SelfSaveIng = nil
				DA_Cancelform()
				--print('取消变形8')
			end
		else
		--非战场/竞技场
			if UnitHealth("player") / UnitHealthMax("player") <= HealthScaleVariables and UnitAffectingCombat("player") and not RenewalCD and not IsStealthed() and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				DA_CastSpellByID(Renewal_SpellID, "player")
				Restoration_RefreshRaidCastlInfo("player", Renewal_SpellID)
				RestorationSpellWillBeCast = 1
			end
		end
		--甘霖指示
		
		if C_PvP.IsActiveBattlefield() then
		--战场/竞技场中
			if PlayerHealthScale <= 0.4 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not FrenziedRegenerationCD then
				DA_CastSpellByName('熊形态狂暴回复宏')
				--熊形态狂暴回复宏
				Restoration_RefreshRaidCastlInfo("player", 22842)
				RestorationSpellWillBeCast = 1
				Restoration_SelfSaveIng = 1
			elseif Restoration_SelfSaveIng and GetShapeshiftFormID() == 5 and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") then
				Restoration_SelfSaveIng = nil
				DA_Cancelform()
				--print('取消变形9')
			end
		end
		
		if Restoration_CanNotMovingCast() then
			HealthScaleVariables = 0.75
		else
			HealthScaleVariables = 0.45
		end
		if C_PvP.IsActiveBattlefield() then
		--战场/竞技场中
			if UnitHealth("player") / UnitHealthMax("player") <= 0.35 and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and UnitAffectingCombat("player") and C_Item.IsUsableItem(5512) and GetItemCooldown(5512) == 0 then
				DA_UseItem(5512)
				--治疗石
			end
		else
		--非战场/竞技场
			if UnitHealth("player") / UnitHealthMax("player") <= HealthScaleVariables and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and UnitAffectingCombat("player") and C_Item.IsUsableItem(5512) and GetItemCooldown(5512) == 0 then
				DA_UseItem(5512)
				--治疗石
			end
		end
		
		if UnitHealth("player") / UnitHealthMax("player") <= HealthScaleVariables and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and UnitAffectingCombat("player") and C_Item.IsUsableItem(177278) and GetItemCooldown(177278) == 0 then
			--DA_UseItem(177278)
			--静谧之瓶
		end
		
		if not Swiftmend_CenarionWard and (RestorationSaves.RestorationOption_Auras_ClearCurse or RestorationSaves.RestorationOption_Auras_ClearMagic or RestorationSaves.RestorationOption_Auras_ClearPoison or RestorationSaves.RestorationOption_Auras_ClearMouseover) then
			Restoration_ScanUnitAuras()
			--DEBUFF驱散
			if IsInGroup() and not IsInRaid() and DA_GetHasActiveAffix('受难') then
				local SpecialUnitID, Cont = DA_GetHealsSpecialExists('受难之魂')
				if SpecialUnitID and not Restoration_NatureCureCD then
					if not Restoration_GetHealBurstingAfflictedSoul('focus', Cont) then
						--经判断,不治疗焦点目标,即[受难之魂]
						--print('经判断,不治疗[受难之魂]')
						return
					end
				end
			end
		end
		
		if ((PlayerHealthScale <= 0.5 and #Restoration_EnemyCacheInMelee >= 1) or (PlayerHealthScale <= 0.7 and #Restoration_EnemyCacheInMelee >= 2)) and UnitAffectingCombat("player") and not ThornsCD and Mass_EntanglementCD then
			if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				DA_TargetUnit('player')
				if UnitIsUnit('target','player') then
					DA_CastSpellByID(Thorns_SpellID)
				end
				Restoration_RefreshRaidCastlInfo("player", Thorns_SpellID)
			end
		end
		--荆棘术
		
		if IsActiveBattlefieldArena() then
			if #Restoration_EnemyCacheIn7 <= 0 then
			--竞技场中7码内没有敌方,则不解定身
				DA_Clear_Rooted = nil
			end
			if DA_UnitIsArenaChosen('player') <= 0 and Health40 >= 1 then
			--竞技场中没有敌方选择玩家为目标,且有友方低于40%血量则不解减速
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
		if RestorationSaves.RestorationOption_Other_ClearRoot and UnitAffectingCombat("player") and C_Spell.GetSpellLossOfControlCooldown(Regrowth_SpellID) == 0 then
			local speed, groundSpeed, flightSpeed, swimSpeed = GetUnitSpeed("player")
			local Rooted, timeRemaining, spellID = DA_CheckPlayerRooted()
			if ((Rooted and timeRemaining and timeRemaining >= 1 and DA_Clear_Rooted) or (not IsSwimming() and speed ~= 0 and speed ~= 2.5 and speed ~= 4.5 and DA_GetUnitSpeed('player') <= 70 and DA_Clear_Deceleration)) then
			--被定身减速
				--print('被定身减速')
				if not UnitChannelInfo("player") and not IsFalling() and not IsFlying() and not UnitOnTaxi("player") and not Restoration_SelfSaveIng and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					if IsPlayerSpell(33891) and AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") then
					--学习了[化身]天赋后,化身：生命之树形态下直接通过'/cast !化身：生命之树'解除定身
						--print('化身解除定身')
						DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
						RestorationSpellWillBeCast = 1
					elseif (GetShapeshiftFormID() == 1 or AuraUtil.FindAuraByName('猎豹形态', "player", "HELPFUL")) and not IsStealthed() then
					--猎豹形态下直接通过取消变形解除定身
						--print('取消变形解除定身')
						DA_Cancelform()
						--print('取消变形3')
					elseif RestorationSaves.RestorationOption_Other_AutoDPS and not C_PvP.IsActiveBattlefield() and not IsInRaid() and not UnitExists('boss1') and #Restoration_EnemyCacheIn7 >= 1 and not Restoration_HeartOfTheWildDPS_GetNeedHeals() and not IsStealthed() then
						--print('猎豹形态解除定身')
						DA_CastSpellByID(768)
						Restoration_RefreshRaidCastlInfo("player", 768)
						RestorationSpellWillBeCast = 1
					elseif not GetShapeshiftFormID() and not IsStealthed() then
					--人形态时通过变熊形态解除定身
						--print('熊形态解除定身')
						DA_CastSpellByID(Bear_Form_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Bear_Form_SpellID)
						RestorationSpellWillBeCast = 1
						RestorationSpellBearFormClearRoot = 1
					end
				end
			elseif RestorationSpellBearFormClearRoot and not Restoration_SelfSaveIng and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") then
				if AuraUtil.FindAuraByName('熊形态', "player", "HELPFUL") then
					DA_Cancelform()
					--print('取消变形6')
					RestorationSpellBearFormClearRoot = nil
				end
			end
		elseif RestorationSpellBearFormClearRoot and not Restoration_SelfSaveIng and not AuraUtil.FindAuraByName('狂暴回复', "player", "HELPFUL") then
			if AuraUtil.FindAuraByName('熊形态', "player", "HELPFUL") then
				DA_Cancelform()
				--print('取消变形7')
				RestorationSpellBearFormClearRoot = nil
			end
		end
		
		
		local PSMV = 1
		--可移动施放的保命技能默认控制数,非移动状态时为+1,移动状态为0,提高非移动状态使用的门槛
		if Restoration_CanNotMovingCast() and not AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") and not AuraUtil.FindAuraByName('自然迅捷', "player", "HELPFUL") then
		--移动状态控制数 = 0
			PSMV = 0
		end
		
		if RestorationSaves.RestorationOption_Heals_AutoCovenant then
			if C_PvP.IsActiveBattlefield() then
			--战场/竞技场中
				if (((Health40 >= 1+PSMV or Health30 >= 1) and #Restoration_EnemyCacheInMelee <= 0) or Health25 >= 1) and UnitAffectingCombat("player") and NotTranquilityIng and not ConvokeTheSpiritsCD then
					if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
						DA_CastSpellByName('万灵之召')
						Restoration_RefreshRaidCastlInfo("player", Convoke_the_Spirits_SpellID)
					end
					RestorationSpellWillBeCast = 1
					RestorationTranquilityWillBeCast = 1
					if not ClearWillBeCast_C_TimerIng then
						ClearWillBeCast_C_TimerIng = 1
						C_Timer.After(0.25, function()
							RestorationTranquilityWillBeCast = nil
							ClearWillBeCast_C_TimerIng = nil
						end)
					end
				end
			else
			--非战场/竞技场
				if NumGroupMembers > 25 then
				--40人队伍
					if ((Health70 >= 5 and Health55 >= 3 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 6 or Health40 >= 5 or Health25 >= 4) and UnitAffectingCombat("player") and NotTranquilityIng and not ConvokeTheSpiritsCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByName('万灵之召')
							Restoration_RefreshRaidCastlInfo("player", Convoke_the_Spirits_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				elseif NumGroupMembers > 20 then
				--21-25人队伍
					if ((Health70 >= 5 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 5 or Health40 >= 5 or Health25 >= 3) and UnitAffectingCombat("player") and NotTranquilityIng and not ConvokeTheSpiritsCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByName('万灵之召')
							Restoration_RefreshRaidCastlInfo("player", Convoke_the_Spirits_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				elseif NumGroupMembers > 15 then
				--16-20人队伍
					if ((Health70 >= 4 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 4 or Health40 >= 4 or Health25 >= 3) and UnitAffectingCombat("player") and NotTranquilityIng and not ConvokeTheSpiritsCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByName('万灵之召')
							Restoration_RefreshRaidCastlInfo("player", Convoke_the_Spirits_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				elseif NumGroupMembers > 8 then
				--9-15人队伍
					if ((Health70 >= 3+PSMV and Health55 >= 2+PSMV and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 3+PSMV or Health40 >= 3+PSMV or Health25 >= 2+PSMV) and UnitAffectingCombat("player") and NotTranquilityIng and not ConvokeTheSpiritsCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByName('万灵之召')
							Restoration_RefreshRaidCastlInfo("player", Convoke_the_Spirits_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				else
				--5人队伍
					if ((Health70 >= 2+PSMV and Health55 >= 1+PSMV and RestorationHeals_SwiftmendCD) or (Health55 >= 3+PSMV and RestorationHeals_SwiftmendCD) or Health40 >= 2+PSMV or Health25 >= 1+PSMV) and UnitAffectingCombat("player") and NotTranquilityIng and not ConvokeTheSpiritsCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByName('万灵之召')
							Restoration_RefreshRaidCastlInfo("player", Convoke_the_Spirits_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				end
			end
			--万灵之召
			
			if NumGroupMembers > 25 then
			--40人队伍
				if ((Health70 >= 5 and Health55 >= 3 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 6 or Health40 >= 5 or Health25 >= 4) and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RavenousFrenzyCD then
					DA_CastSpellByName('饕餮狂乱')
					Restoration_RefreshRaidCastlInfo("player", 323546)
				end
			elseif NumGroupMembers > 20 then
			--21-25人队伍
				if ((Health70 >= 5 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 5 or Health40 >= 5 or Health25 >= 3) and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RavenousFrenzyCD then
					DA_CastSpellByName('饕餮狂乱')
					Restoration_RefreshRaidCastlInfo("player", 323546)
				end
			elseif NumGroupMembers > 15 then
			--16-20人队伍
				if ((Health70 >= 4 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 4 or Health40 >= 4 or Health25 >= 3) and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RavenousFrenzyCD then
					DA_CastSpellByName('饕餮狂乱')
					Restoration_RefreshRaidCastlInfo("player", 323546)
				end
			elseif NumGroupMembers > 8 then
			--9-15人队伍
				if ((Health70 >= 3 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 3 or Health40 >= 3 or Health25 >= 2) and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RavenousFrenzyCD then
					DA_CastSpellByName('饕餮狂乱')
					Restoration_RefreshRaidCastlInfo("player", 323546)
				end
			else
			--5人队伍
				if ((Health70 >= 2 and Health55 >= 1) or Health55 >= 3 or Health40 >= 2 or Health25 >= 1) and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RavenousFrenzyCD then
					DA_CastSpellByName('饕餮狂乱')
					Restoration_RefreshRaidCastlInfo("player", 323546)
				end
			end
			--饕餮狂乱
		end
		
		if RestorationSaves.RestorationOption_Heals_AutoTranquility then
			if GCDMarkTime then
				TranquilitySecond = 2
			else
				TranquilitySecond = 1
			end
			if Restoration_GetSumHealthScaleFallRatio(0.01) then
				--print("掉血超过1%")
			end
			if Restoration_GetSumHealthScaleFallRatio(0.01, 1 + TranquilitySecond, TranquilitySecond) then
				--print(Restoration_GetSumHealthScaleContrastToTimeline(TranquilitySecond))
				--print(TranquilitySecond.."秒前: "..RestorationHeals_SumHealthScaleTimelineCache[TranquilitySecond].SumHealthScale)
				--print("当前: "..Restoration_HealsUnit_SumHealthScale)
			end
			--for k, v in ipairs(RestorationHeals_SumHealthScaleTimelineCache) do 
				--print(k..' 秒前血量比例: '..v.SumHealthScale)
			--end
			if IsInRaid() then
				--团队
				if ((not Restoration_GetSumHealthScaleFallRatio(0.01, 1 + TranquilitySecond, TranquilitySecond) and Restoration_HealsUnit_SumHealthScale > 0.4 and Health25 <= 0) or (Restoration_GetSumHealthScaleContrastToTimeline(TranquilitySecond) ~= "Fall")) then
					--2+GCD秒前到1+GCD秒前之间[总剩余血量比例]下降比例没超过1%且当前[总剩余血量比例]大于40%且没有血量低于25%的玩家,或当前[总剩余血量比例]比1+GCD秒前没有下降,则不宁静
					NoTranquilityForSumHealthScaleFallFilter = 1
				else
					--print("可宁静")
					NoTranquilityForSumHealthScaleFallFilter = nil
				end
			else
				--非团队
				if ((not Restoration_GetSumHealthScaleFallRatio(0.01, 1 + TranquilitySecond, TranquilitySecond) and Restoration_HealsUnit_SumHealthScale > 0.6 and Health40 <= 0) or ((Restoration_GetSumHealthScaleContrastToTimeline(TranquilitySecond) ~= "Fall") and Health25 <= 0)) then
					--2+GCD秒前到1+GCD秒前之间[总剩余血量比例]下降比例没超过1%且当前[总剩余血量比例]大于60%且没有血量低于40%的玩家,或当前[总剩余血量比例]比1+GCD秒前没有下降且没有血量低于25%的玩家,则不宁静
					NoTranquilityForSumHealthScaleFallFilter = 1
				else
					--print("可宁静")
					NoTranquilityForSumHealthScaleFallFilter = nil
				end
			end
			if NumGroupMembers > 25 then
			--40人队伍
				if ((Health70 >= 8 and Health55 >= 3 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 8 or Health40 >= 7 or Health25 >= 6) and not NoTranquilityForSumHealthScaleFallFilter and UnitAffectingCombat("player") and NotTranquilityIng and not TranquilityCD then
					if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
						DA_CastSpellByID(Tranquility_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
					end
					RestorationSpellWillBeCast = 1
					RestorationTranquilityWillBeCast = 1
					if not ClearWillBeCast_C_TimerIng then
						ClearWillBeCast_C_TimerIng = 1
						C_Timer.After(0.25, function()
							RestorationTranquilityWillBeCast = nil
							ClearWillBeCast_C_TimerIng = nil
						end)
					end
				end
			elseif NumGroupMembers > 20 then
			--21-25人队伍
				if ((Health70 >= 8 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 7 or Health40 >= 6 or Health25 >= 5) and not NoTranquilityForSumHealthScaleFallFilter and UnitAffectingCombat("player") and NotTranquilityIng and not TranquilityCD then
					if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
						DA_CastSpellByID(Tranquility_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
					end
					RestorationSpellWillBeCast = 1
					RestorationTranquilityWillBeCast = 1
					if not ClearWillBeCast_C_TimerIng then
						ClearWillBeCast_C_TimerIng = 1
						C_Timer.After(0.25, function()
							RestorationTranquilityWillBeCast = nil
							ClearWillBeCast_C_TimerIng = nil
						end)
					end
				end
			elseif NumGroupMembers > 15 then
			--16-20人队伍
				if ((Health70 >= 7 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 6 or Health40 >= 5 or Health25 >= 4) and not NoTranquilityForSumHealthScaleFallFilter and UnitAffectingCombat("player") and NotTranquilityIng and not TranquilityCD then
					if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
						DA_CastSpellByID(Tranquility_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
					end
					RestorationSpellWillBeCast = 1
					RestorationTranquilityWillBeCast = 1
					if not ClearWillBeCast_C_TimerIng then
						ClearWillBeCast_C_TimerIng = 1
						C_Timer.After(0.25, function()
							RestorationTranquilityWillBeCast = nil
							ClearWillBeCast_C_TimerIng = nil
						end)
					end
				end
			elseif NumGroupMembers > 8 then
			--9-15人队伍
				if ((Health70 >= 6 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 5 or Health40 >= 4 or Health25 >= 3) and not NoTranquilityForSumHealthScaleFallFilter and UnitAffectingCombat("player") and NotTranquilityIng and not TranquilityCD then
					if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
						DA_CastSpellByID(Tranquility_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
					end
					RestorationSpellWillBeCast = 1
					RestorationTranquilityWillBeCast = 1
					if not ClearWillBeCast_C_TimerIng then
						ClearWillBeCast_C_TimerIng = 1
						C_Timer.After(0.25, function()
							RestorationTranquilityWillBeCast = nil
							ClearWillBeCast_C_TimerIng = nil
						end)
					end
				end
			else
			--5人队伍
				if ((Health70 >= 4 and Health55 >= 1) or Health55 >= 4 or Health40 >= 3 or Health25 >= 3) and not NoTranquilityForSumHealthScaleFallFilter and UnitAffectingCombat("player") and NotTranquilityIng and not TranquilityCD then
					if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
						DA_CastSpellByID(Tranquility_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
					end
					RestorationSpellWillBeCast = 1
					RestorationTranquilityWillBeCast = 1
					if not ClearWillBeCast_C_TimerIng then
						ClearWillBeCast_C_TimerIng = 1
						C_Timer.After(0.25, function()
							RestorationTranquilityWillBeCast = nil
							ClearWillBeCast_C_TimerIng = nil
						end)
					end
				end
			end
			--宁静指示
			if RestorationSaves.RestorationOption_Effect == 1 or IsPlayerSpell(197073) then
				if NumGroupMembers > 25 then
				--40人队伍
					if ((Health70 >= 6 and Health55 >= 3 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 7 or Health40 >= 6 or Health25 >= 5) and UnitAffectingCombat("player") and not TranquilityCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByID(Tranquility_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				elseif NumGroupMembers > 20 then
				--21-25人队伍
					if ((Health70 >= 6 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 6 or Health40 >= 5 or Health25 >= 4) and UnitAffectingCombat("player") and not TranquilityCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByID(Tranquility_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				elseif NumGroupMembers > 15 then
				--16-20人队伍
					if ((Health70 >= 5 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 5 or Health40 >= 4 or Health25 >= 4) and UnitAffectingCombat("player") and not TranquilityCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByID(Tranquility_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				elseif NumGroupMembers > 8 then
				--9-15人队伍
					if ((Health70 >= 4 and Health55 >= 2 and WildGrowthCD and not WildGrowthCDBenignPart_25) or Health55 >= 4 or Health40 >= 3 or Health25 >= 3) and UnitAffectingCombat("player") and not TranquilityCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByID(Tranquility_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				else
				--5人队伍
					if ((Health70 >= 4 and Health55 >= 1) or Health55 >= 4 or Health40 >= 3 or Health25 >= 3) and UnitAffectingCombat("player") and not TranquilityCD then
						if not RestorationHeals_DoNotHeals and UnitCastingInfo("player") ~= '愈合' and UnitCastingInfo("player") ~= '野性成长' and UnitCastingInfo("player") ~= '滋养' then
							Restoration_UseAttributesEnhancedItem()
							--使用属性增强饰品
							Restoration_UseConcoctionKissOfDeath()
							--[制剂：死亡之吻]
							DA_CastSpellByID(Tranquility_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Tranquility_SpellID)
						end
						RestorationSpellWillBeCast = 1
						RestorationTranquilityWillBeCast = 1
						if not ClearWillBeCast_C_TimerIng then
							ClearWillBeCast_C_TimerIng = 1
							C_Timer.After(0.25, function()
								RestorationTranquilityWillBeCast = nil
								ClearWillBeCast_C_TimerIng = nil
							end)
						end
					end
				end
			end
			--宁静指示(强力模式)(平常心)
		end
		
		if not NaturesSwiftnessCD and UnitAffectingCombat("player") and (Health55 >= 1+PSMV or Health40 >= 1) and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
			DA_CastSpellByID(Nature_Swiftness_SpellID)
			Restoration_RefreshRaidCastlInfo("player", Nature_Swiftness_SpellID)
		end
		--自然迅捷指示
		
		if NumGroupMembers > 25 then
		--40人队伍
			if (Health80 >= 6 or Health70 >= 6 or Health55 >= 5 or Health40 >= 4) and WildGrowthCDBenignPart_35 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					if Restoration_UseAttributesEnhancedItem() then
						--属性增强装备可用，使用饰品
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
					elseif not LoneMeditationCD then
						--属性增强装备不可用，使用自省冥想
						DA_CastSpellByName('自省冥想')
						Restoration_RefreshRaidCastlInfo("player", 338035)
					end
				end
			end
		elseif NumGroupMembers > 20 then
		--21-25人队伍
			if (Health80 >= 6 or Health70 >= 5 or Health55 >= 4 or Health40 >= 3) and WildGrowthCDBenignPart_35 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					if Restoration_UseAttributesEnhancedItem() then
						--属性增强装备可用，使用饰品
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
					elseif not LoneMeditationCD then
						--属性增强装备不可用，使用自省冥想
						DA_CastSpellByName('自省冥想')
						Restoration_RefreshRaidCastlInfo("player", 338035)
					end
				end
			end
		elseif NumGroupMembers > 15 then
		--16-20人队伍
			if (Health80 >= 5 or Health70 >= 4 or Health55 >= 4 or Health40 >= 3) and WildGrowthCDBenignPart_35 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					if Restoration_UseAttributesEnhancedItem() then
						--属性增强装备可用，使用饰品
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
					elseif not LoneMeditationCD then
						--属性增强装备不可用，使用自省冥想
						DA_CastSpellByName('自省冥想')
						Restoration_RefreshRaidCastlInfo("player", 338035)
					end
				end
			end
		elseif NumGroupMembers > 8 then
		--9-15人队伍
			if (Health80 >= 4 or Health70 >= 3 or Health55 >= 3 or Health40 >= 2) and WildGrowthCDBenignPart_35 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					if Restoration_UseAttributesEnhancedItem() then
						--属性增强装备可用，使用饰品
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
					elseif not LoneMeditationCD then
						--属性增强装备不可用，使用自省冥想
						DA_CastSpellByName('自省冥想')
						Restoration_RefreshRaidCastlInfo("player", 338035)
					end
				end
			end
		else
		--5人队伍
			if (Health80 >= 3 or Health70 >= 2 or Health55 >= 2 or Health40 >= 1) and WildGrowthCDBenignPart_35 and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					if Restoration_UseAttributesEnhancedItem() then
						--属性增强装备可用，使用饰品
						Restoration_UseAttributesEnhancedItem()
						--使用属性增强饰品
						Restoration_UseConcoctionKissOfDeath()
						--[制剂：死亡之吻]
					elseif not LoneMeditationCD then
						--属性增强装备不可用，使用自省冥想
						DA_CastSpellByName('自省冥想')
						Restoration_RefreshRaidCastlInfo("player", 338035)
					end
				end
			end
		end
		--使用属性增强饰品
		
		if NumGroupMembers > 25 then
		--40人队伍
			if (Health80 >= 6 or Health70 >= 6 or Health55 >= 5 or Health40 >= 4) and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationUseItem = 1
					Restoration_UseDirectAoeHealItem()
				end
			end
		elseif NumGroupMembers > 20 then
		--21-25人队伍
			if (Health80 >= 6 or Health70 >= 5 or Health55 >= 5 or Health40 >= 4) and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationUseItem = 1
					Restoration_UseDirectAoeHealItem()
				end
			end
		elseif NumGroupMembers > 15 then
		--16-20人队伍
			if (Health80 >= 5 or Health70 >= 4 or Health55 >= 4 or Health40 >= 3) and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationUseItem = 1
					Restoration_UseDirectAoeHealItem()
				end
			end
		elseif NumGroupMembers > 8 then
		--9-15人队伍
			if (Health80 >= 4 or Health70 >= 3 or Health55 >= 3 or Health40 >= 2) and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationUseItem = 1
					Restoration_UseDirectAoeHealItem()
				end
			end
		else
		--5人队伍
			if (Health80 >= 3 or Health70 >= 2 or Health55 >= 2 or Health40 >= 1) and UnitAffectingCombat("player") and not AuraUtil.FindAuraByName('繁盛', "player", "HELPFUL") then
				if not RestorationHeals_DoNotHeals and not RestorationSingleItemSwitch and not UnitChannelInfo("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationUseItem = 1
					Restoration_UseDirectAoeHealItem()
				end
			end
		end
		--使用群体治疗饰品
		
		if RestorationSaves.RestorationOption_Heals_AutoIncarnationTreeofLife then
			if C_PvP.IsActiveBattlefield() then
			--战场/竞技场中
				if (((Health55 >= 1+PSMV or Health40 >= 1) and #Restoration_EnemyCacheInMelee >= 1) or Health30 >= 1) and UnitAffectingCombat("player") and not IncarnationTreeofLifeCD then
					if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
						RestorationSingleItemSwitch = 1
						DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
						Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
						RestorationSpellWillBeCast = 1
					end
				end
			else
			--非战场/竞技场
				if IsInRaid() then
					--团队
					if ((not Restoration_GetSumHealthScaleFallRatio(0.01, 2, 1) and Restoration_HealsUnit_SumHealthScale > 0.4 and Health25 <= 0) or (Restoration_GetSumHealthScaleContrastToTimeline(1) ~= "Fall")) then
						--2秒前到1秒前之间[总剩余血量比例]下降比例没超过1%且当前[总剩余血量比例]大于40%且没有血量低于25%的玩家,或当前[总剩余血量比例]比1+GCD秒前没有下降,则不化身
						NoIncarnationTreeofLifeForSumHealthScaleFallFilter = 1
					else
						--print("可化身")
						NoIncarnationTreeofLifeForSumHealthScaleFallFilter = nil
					end
				else
					--非团队
					if ((not Restoration_GetSumHealthScaleFallRatio(0.01, 2, 1) and Restoration_HealsUnit_SumHealthScale > 0.6 and Health40 <= 0) or (Restoration_GetSumHealthScaleContrastToTimeline(1) ~= "Fall")) then
						--2秒前到1秒前之间[总剩余血量比例]下降比例没超过1%且当前[总剩余血量比例]大于60%且没有血量低于40%的玩家,或当前[总剩余血量比例]比1+GCD秒前没有下降,则不化身
						NoIncarnationTreeofLifeForSumHealthScaleFallFilter = 1
					else
						--print("可化身")
						NoIncarnationTreeofLifeForSumHealthScaleFallFilter = nil
					end
				end
				if NumGroupMembers > 25 then
				--40人队伍
					if (Health70 >= 6 or Health55 >= 5 or Health40 >= 4 or Health25 >= 3) and not NoIncarnationTreeofLifeForSumHealthScaleFallFilter and UnitAffectingCombat("player") and not IncarnationTreeofLifeCD then
						if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
							RestorationSingleItemSwitch = 1
							DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
							RestorationSpellWillBeCast = 1
						end
					end
				elseif NumGroupMembers > 20 then
				--21-25人队伍
					if (Health70 >= 5 or Health55 >= 5 or Health40 >= 3 or Health25 >= 3) and not NoIncarnationTreeofLifeForSumHealthScaleFallFilter and UnitAffectingCombat("player") and not IncarnationTreeofLifeCD then
						if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
							RestorationSingleItemSwitch = 1
							DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
							RestorationSpellWillBeCast = 1
						end
					end
				elseif NumGroupMembers > 15 then
				--16-20人队伍
					if (Health70 >= 4 or Health55 >= 4 or Health40 >= 3 or Health25 >= 3) and not NoIncarnationTreeofLifeForSumHealthScaleFallFilter and UnitAffectingCombat("player") and not IncarnationTreeofLifeCD then
						if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
							RestorationSingleItemSwitch = 1
							DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
							RestorationSpellWillBeCast = 1
						end
					end
				elseif NumGroupMembers > 8 then
				--9-15人队伍
					if (Health70 >= 4+PSMV or Health55 >= 3+PSMV or Health40 >= 2+PSMV or Health25 >= 2+PSMV) and not NoIncarnationTreeofLifeForSumHealthScaleFallFilter and UnitAffectingCombat("player") and not IncarnationTreeofLifeCD then
						if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
							RestorationSingleItemSwitch = 1
							DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
							RestorationSpellWillBeCast = 1
						end
					end
				else
				--5人队伍
					if ((Health80 >= 4+PSMV and Health70 >= 2+PSMV) or Health70 >= 3+PSMV or Health55 >= 2+PSMV or ((Health40 >= 1+PSMV and RestorationHeals_SwiftmendCD) or Health40 >= 2+PSMV) or ((Health25 >= 1+PSMV and RestorationHeals_SwiftmendCD) or Health25 >= 2)) and not NoIncarnationTreeofLifeForSumHealthScaleFallFilter and UnitAffectingCombat("player") and not IncarnationTreeofLifeCD then
						if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
							RestorationSingleItemSwitch = 1
							DA_CastSpellByID(Incarnation_Tree_of_Life_SpellID)
							Restoration_RefreshRaidCastlInfo("player", Incarnation_Tree_of_Life_SpellID)
							RestorationSpellWillBeCast = 1
						end
					end
				end
			end
			--化身指示
		end
		
		if NumGroupMembers > 25 then
		--40人队伍
			if (Health70 >= 5 or Health55 >= 4 or Health40 >= 4 or Health25 >= 3) and UnitAffectingCombat("player") and not BerserkingCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Berserking_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Berserking_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		elseif NumGroupMembers > 20 then
		--21-25人队伍
			if (Health70 >= 5 or Health55 >= 4 or Health40 >= 3 or Health25 >= 3) and UnitAffectingCombat("player") and not BerserkingCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Berserking_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Berserking_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		elseif NumGroupMembers > 15 then
		--16-20人队伍
			if (Health70 >= 4 or Health55 >= 3 or Health40 >= 3 or Health25 >= 3) and UnitAffectingCombat("player") and not BerserkingCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Berserking_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Berserking_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		elseif NumGroupMembers > 8 then
		--9-15人队伍
			if (Health70 >= 3 or Health55 >= 3 or Health40 >= 2 or Health25 >= 2) and UnitAffectingCombat("player") and not BerserkingCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Berserking_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Berserking_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		else
		--5人队伍
			if ((Health80 >= 3 and Health70 >= 2) or Health70 >= 3 or Health55 >= 2 or ((Health40 >= 1 and RestorationHeals_SwiftmendCD) or Health40 >= 2) or ((Health25 >= 1 and RestorationHeals_SwiftmendCD) or Health25 >= 2)) and UnitAffectingCombat("player") and not BerserkingCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Berserking_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Berserking_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		end
		--狂暴(种族特长)指示
		
		if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
			local Grove_GuardiansNumber = Restoration_GetGrove_GuardiansNumber()
			local Variables = 0
			--默认强力模式不加控制数
			if RestorationSaves.RestorationOption_Effect ~= 1 then
			--非强力模式加1个控制数
				Variables = 1
			end
			if NumGroupMembers > 8 then
			--9人以上
				if Grove_GuardiansNumber <= 0 then
				--不存在林莽卫士
					if (Health80 >= 4+Variables or Health70 >= 3+Variables or Health55 >= 3+Variables or Health40 >= 3+Variables or #HealerEngineHeals_HealAurasUnitCount >= 5+Variables) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif (Health80 < 3+Variables and Health70 < 2+Variables and Health55 < 2+Variables and Health40 < 2+Variables and #HealerEngineHeals_HealAurasUnitCount < 4+Variables) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				elseif Grove_GuardiansNumber <= 1 then
				--存在1个林莽卫士
					if (Health80 >= 5+Variables or Health70 >= 4+Variables or Health55 >= 4+Variables or Health40 >= 4+Variables or #HealerEngineHeals_HealAurasUnitCount >= 6+Variables) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif (Health80 < 4+Variables and Health70 < 3+Variables and Health55 < 3+Variables and Health40 < 3+Variables and #HealerEngineHeals_HealAurasUnitCount < 5+Variables) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				elseif Grove_GuardiansNumber <= 2 then
				--存在2个林莽卫士
					if (Health80 >= 6+Variables or Health70 >= 5+Variables or Health55 >= 5+Variables or Health40 >= 5+Variables or #HealerEngineHeals_HealAurasUnitCount >= 7+Variables) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif (Health80 < 5+Variables and Health70 < 4+Variables and Health55 < 4+Variables and Health40 < 4+Variables and #HealerEngineHeals_HealAurasUnitCount < 6+Variables) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				end
			elseif NumGroupMembers > 3 then
			--4-8人
				if Grove_GuardiansNumber <= 0 then
				--不存在林莽卫士
					if ((Health90 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 3 or Health80 >= 3 or Health70 >= 2 or Health55 >= 1 or Health40 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 3) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif not ((Health90 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 2 or Health80 >= 2 or Health70 >= 1 or Health55 >= 1 or Health40 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 2) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				elseif Grove_GuardiansNumber <= 1 then
				--存在1个林莽卫士
					if ((Health90 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 5 or Health80 >= 4 or Health70 >= 3 or Health55 >= 2 or Health40 >= 2 or Health25 >= 2 or #HealerEngineHeals_HealAurasUnitCount >= 4) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif not ((Health90 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 4 or Health80 >= 3 or Health70 >= 2 or Health55 >= 1 or Health40 >= 1 or Health25 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 3) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				elseif Grove_GuardiansNumber <= 2 then
				--存在2个林莽卫士
					if ((Health90 >= 2 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 5 or Health80 >= 5 or Health70 >= 4 or Health55 >= 3 or Health40 >= 2 or Health25 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 5) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif not ((Health90 >= 2 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 4 or Health80 >= 4 or Health70 >= 3 or Health55 >= 2 or Health40 >= 1 or Health25 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 4) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				end
			else
			--1-3人
				if Grove_GuardiansNumber <= 0 then
				--不存在林莽卫士
					if ((Health99 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 1) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif not ((Health99 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health90 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 1) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				elseif Grove_GuardiansNumber <= 1 then
				--存在1个林莽卫士
					if ((Health90 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health80 >= 2 or Health70 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 2) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif not ((Health90 >= 1 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health80 >= 2 or Health70 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 1) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				elseif Grove_GuardiansNumber <= 2 then
				--存在2个林莽卫士
					if ((Health90 >= 2 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health70 >= 2 or Health55 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 3) and not Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = 1
					elseif not ((Health90 >= 2 and DA_GetSpellCharges(Grove_Guardians_SpellID) >= 3) or Health70 >= 2 or Health55 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 2) or Grove_GuardiansCD then
						RestorationHeals_Grove_Guardians = nil
					end
				end
			end
		end
		--林莽卫士指示
		
		if C_PvP.IsActiveBattlefield() then
		--战场/竞技场中
			if not Restoration_InGCD and not RestorationHeals_DoNotHeals and (not Restoration_CanNotMovingCast() or RestorationHeals_Instant_WildGrowth) and not Swiftmend_CenarionWard and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				if NumGroupMembers > 4 then
				--团队
					if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.5 and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
					--法力低于50%
						if Health80 >= 5 and (Health40 == 0 or RestorationHeals_Instant_WildGrowth) and Health25 <= 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif not (Health80 >= 4 and (Health40 == 0 or RestorationHeals_Instant_WildGrowth) and Health25 <= 0 and not WildGrowthCD) then
							RestorationHeals_WildGrowth = nil
						end
					else
					--法力高于50%
						if Health80 >= 3 and (Health40 == 0 or RestorationHeals_Instant_WildGrowth) and Health25 <= 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif not (Health80 >= 2 and (Health40 == 0 or RestorationHeals_Instant_WildGrowth) and Health25 <= 0 and not WildGrowthCD) then
							RestorationHeals_WildGrowth = nil
						end
					end
				else
				--小队
					if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.5 and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
					--法力低于50%
						if Health70 >= 1 and (Health55 == 0 or RestorationHeals_Instant_WildGrowth) and Health30 <= 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif not (Health70 >= 1 and (Health55 == 0 or RestorationHeals_Instant_WildGrowth) and Health30 <= 0 and not WildGrowthCD) then
							RestorationHeals_WildGrowth = nil
						end
					else
					--法力高于50%
						if Health90 >= 1 and (Health55 == 0 or RestorationHeals_Instant_WildGrowth) and Health30 <= 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif not (Health90 >= 1 and (Health55 == 0 or RestorationHeals_Instant_WildGrowth) and Health30 <= 0 and not WildGrowthCD) then
							RestorationHeals_WildGrowth = nil
						end
					end
				end
			end
			--野性成长指示
		else
		--非战场/竞技场
			if not Restoration_InGCD and not RestorationHeals_DoNotHeals and (not Restoration_CanNotMovingCast() or RestorationHeals_Instant_WildGrowth) and not Swiftmend_CenarionWard and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.5 and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
				--法力低于50%
					if NumGroupMembers > 8 then
					--团队
						if (Health80 >= 6 or Health70 >= 5 or Health55 >= 5 or Health40 >= 5 or #HealerEngineHeals_HealAurasUnitCount >= 7 or RestorationHeals_AlertSpellAOEWildGrowth) and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif (Health80 < 5 and Health70 < 4 and Health55 < 4 and Health40 < 4 and #HealerEngineHeals_HealAurasUnitCount < 6 and not RestorationHeals_AlertSpellAOEWildGrowth) or WildGrowthCD then
							RestorationHeals_WildGrowth = nil
						end
					else
					--小队
						if (Health80 >= 3 or Health70 >= 2 or Health55 >= 2 or Health40 >= 2 or #HealerEngineHeals_HealAurasUnitCount >= 4 or RestorationHeals_AlertSpellAOEWildGrowth) and Health30 == 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif (Health80 < 2 and Health70 < 1 and Health55 < 1 and Health40 < 1 and #HealerEngineHeals_HealAurasUnitCount < 3 and not RestorationHeals_AlertSpellAOEWildGrowth) or Health30 ~= 0 or WildGrowthCD then
							RestorationHeals_WildGrowth = nil
						end
					end
				else
				--法力高于50%
					if NumGroupMembers > 8 then
					--团队
						if (Health80 >= 5 or Health70 >= 4 or Health55 >= 4 or Health40 >= 4 or #HealerEngineHeals_HealAurasUnitCount >= 6 or RestorationHeals_AlertSpellAOEWildGrowth) and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif (Health80 < 4 and Health70 < 3 and Health55 < 3 and Health40 < 3 and #HealerEngineHeals_HealAurasUnitCount < 5 and not RestorationHeals_AlertSpellAOEWildGrowth) or WildGrowthCD then
							RestorationHeals_WildGrowth = nil
						end
					else
					--小队
						if (Health90 >= 3 or Health80 >= 2 or Health70 >= 2 or Health55 >= 1 or Health40 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 3 or RestorationHeals_AlertSpellAOEWildGrowth) and Health30 == 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth = 1
						elseif (Health90 < 2 and Health80 < 1 and Health70 < 1 and Health55 < 1 and Health40 < 1 and #HealerEngineHeals_HealAurasUnitCount < 2 and not RestorationHeals_AlertSpellAOEWildGrowth) or Health30 ~= 0 or WildGrowthCD then
							RestorationHeals_WildGrowth = nil
						end
					end
				end
			end
			--野性成长指示
			if not Restoration_InGCD and not RestorationHeals_DoNotHeals and (not Restoration_CanNotMovingCast() or RestorationHeals_Instant_WildGrowth) and not Swiftmend_CenarionWard and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				if UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.5 and not AuraUtil.FindAuraByName('激活', "player", "HELPFUL") then
				--法力低于50%
					if NumGroupMembers > 8 then
					--团队
						if (Health90 >= 7 or Health80 >= 5 or Health70 >= 4 or Health55 >= 4 or Health40 >= 4 or #HealerEngineHeals_HealAurasUnitCount >= 6 or RestorationHeals_AlertSpellAOEWildGrowth) and not WildGrowthCD then
							RestorationHeals_WildGrowth2 = 1
						elseif (Health90 < 6 and Health80 < 4 and Health70 < 3 and Health55 < 3 and Health40 < 3 and #HealerEngineHeals_HealAurasUnitCount < 5 and not RestorationHeals_AlertSpellAOEWildGrowth) or WildGrowthCD then
							RestorationHeals_WildGrowth2 = nil
						end
					else
					--小队
						if (Health90 >= 3 or Health80 >= 2 or Health70 >= 2 or Health55 >= 2 or Health40 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 3 or RestorationHeals_AlertSpellAOEWildGrowth) and Health30 == 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth2 = 1
						elseif (Health90 < 2 and Health80 < 1 and Health70 < 1 and Health55 < 1 and Health40 < 1 and #HealerEngineHeals_HealAurasUnitCount < 2 and not RestorationHeals_AlertSpellAOEWildGrowth) or Health30 ~= 0 or WildGrowthCD then
							RestorationHeals_WildGrowth2 = nil
						end
					end
				else
				--法力高于50%
					if NumGroupMembers > 8 then
					--团队
						if (Health90 >= 6 or Health80 >= 4 or Health70 >= 3 or Health55 >= 3 or Health40 >= 3 or #HealerEngineHeals_HealAurasUnitCount >= 5 or RestorationHeals_AlertSpellAOEWildGrowth) and not WildGrowthCD then
							RestorationHeals_WildGrowth2 = 1
						elseif (Health90 < 5 and Health80 < 3 and Health70 < 2 and Health55 < 2 and Health40 < 2 and #HealerEngineHeals_HealAurasUnitCount < 4 and not RestorationHeals_AlertSpellAOEWildGrowth) or WildGrowthCD then
							RestorationHeals_WildGrowth2 = nil
						end
					else
					--小队
						if (Health90 >= 3 or Health80 >= 2 or Health70 >= 2 or Health55 >= 1 or Health40 >= 1 or #HealerEngineHeals_HealAurasUnitCount >= 2 or RestorationHeals_AlertSpellAOEWildGrowth) and Health30 == 0 and not WildGrowthCD then
							RestorationHeals_WildGrowth2 = 1
						elseif (Health90 < 2 and Health80 < 1 and Health70 < 1 and Health55 < 1 and Health40 < 1 and #HealerEngineHeals_HealAurasUnitCount < 1 and not RestorationHeals_AlertSpellAOEWildGrowth) or Health30 ~= 0 or WildGrowthCD then
							RestorationHeals_WildGrowth2 = nil
						end
					end
				end
			end
			--野性成长指示(强力模式)
		end
		
		if IsPlayerSpell(274902) then
			if NumGroupMembers > 8 then
			--团队
				if Health90 >= 6 or Health80 >= 5 or Health70 >= 4 or #HealerEngineHeals_HealAurasUnitCount >= 5 or RestorationHeals_AlertSpellAOEWildGrowth then
					RestorationHeals_Photosynthesis = 1
				else
					RestorationHeals_Photosynthesis = nil
				end
			else
			--小队
				if Health90 >= 4 or Health80 >= 3 or Health70 >= 2 or #HealerEngineHeals_HealAurasUnitCount >= 2 or RestorationHeals_AlertSpellAOEWildGrowth then
					RestorationHeals_Photosynthesis = 1
				else
					RestorationHeals_Photosynthesis = nil
				end
			end
		end
		--光合作用指示
		
		if NumGroupMembers > 25 then
		--40人队伍
			if (Health80 >= 8 or Health70 >= 6 or Health55 >= 6 or Health40 >= 5) and (UnitHasWildGrowthCount > 3 and UnitHasWildGrowthtimeLeft >= 1 or UnitCastingInfo("player") == '野性成长') and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					if UnitHasWildGrowthtimeLeft > 0 then
						DA_CastSpellByID(Flourish_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		elseif NumGroupMembers > 20 then
		--21-25人队伍
			if (Health80 >= 7 or Health70 >= 6 or Health55 >= 5 or Health40 >= 4) and (UnitHasWildGrowthCount > 3 and UnitHasWildGrowthtimeLeft >= 1 or UnitCastingInfo("player") == '野性成长') and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					if UnitHasWildGrowthtimeLeft > 0 then
						DA_CastSpellByID(Flourish_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		elseif NumGroupMembers > 15 then
		--16-20人队伍
			if (Health80 >= 7 or Health70 >= 5 or Health55 >= 5 or Health40 >= 4) and (UnitHasWildGrowthCount > 3 and UnitHasWildGrowthtimeLeft >= 1 or UnitCastingInfo("player") == '野性成长') and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					if UnitHasWildGrowthtimeLeft > 0 then
						DA_CastSpellByID(Flourish_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		elseif NumGroupMembers > 8 then
		--9-15人队伍
			if (Health80 >= 6 or Health70 >= 5 or Health55 >= 4 or Health40 >= 3) and (UnitHasWildGrowthCount > 3 and UnitHasWildGrowthtimeLeft >= 1 or UnitCastingInfo("player") == '野性成长') and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					if UnitHasWildGrowthtimeLeft > 0 then
						DA_CastSpellByID(Flourish_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		else
		--5人队伍
			if (Health80 >= 4+PSMV or Health70 >= 3+PSMV or Health55 >= 2+PSMV or Health40 >= 2+PSMV) and (UnitHasWildGrowthCount > 2+PSMV and UnitHasWildGrowthtimeLeft >= 1 or UnitCastingInfo("player") == '野性成长') and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					if UnitHasWildGrowthtimeLeft > 0 then
						DA_CastSpellByID(Flourish_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		end
		--繁盛指示1
		
		if NumGroupMembers > 8 then
		--团队
			if ((((Health90 >= 7 and Health80 >= 3) or Health80 >= 5 or Health70 >= 4 or Health55 >= 3) and UnitHasWildGrowthCount > 3 and UnitHasWildGrowthtimeLeft >= 1) or ((UnitRejuvenation90 >= 4 or UnitRejuvenation80 >= 3) and UnitRejuvenation70 >= 2 and UnitHasWildGrowthCount > 3 and UnitHasWildGrowthtimeLeft >= 1) or (UnitHasTranquility and UnitHasTranquilitytimeLeft >= 1)) and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Flourish_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		else
		--小队
			if ((((Health90 >= 4+PSMV and Health80 >= 1+PSMV) or Health80 >= 3+PSMV or Health70 >= 2+PSMV or Health55 >= 2+PSMV) and UnitHasWildGrowthCount > 2+PSMV and UnitHasWildGrowthtimeLeft >= 1) or ((UnitRejuvenation90 >= 3+PSMV or UnitRejuvenation80 >= 2+PSMV) and UnitRejuvenation70 >= 1+PSMV and UnitHasWildGrowthCount > 2+PSMV and UnitHasWildGrowthtimeLeft >= 1)) and UnitAffectingCombat("player") and not FlourishCD then
				if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					RestorationSingleItemSwitch = 1
					DA_CastSpellByID(Flourish_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Flourish_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		end
		--繁盛指示2
		
		if GetUnitSpeed("player") == 0 then
			Restoration_StandingStartTime = Restoration_StandingStartTime or GetTime()
			Restoration_IsStanding = Restoration_IsStanding or false
			if not Restoration_IsStanding then
				Restoration_IsStanding = true
				Restoration_StandingStartTime = GetTime()
			end
			if GetTime() - Restoration_StandingStartTime >= 1 then
				--print('玩家超过1秒未移动')
				Restoration_IsStanding_AWhile = true
			end
		else
			Restoration_IsStanding_AWhile = false
			Restoration_IsStanding = false
			Restoration_StandingStartTime = 0
		end

		local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('百花齐放', "player", "HELPFUL")
		--百花齐放Buff
		if ((expires1 and expires1 - GetTime() <= 1) or not expires1 or Restoration_CheckEfflorescence()) and not Swiftmend_CenarionWard and UnitAffectingCombat("player") and (#HealsUnitPriority <= 0 or Health99 <= 0) and DA_IsUsableSpell(Efflorescence_SpellID) and IsPlayerSpell(Efflorescence_SpellID) and (not HealerEngine_UnitHasHealAurasWarn or RestorationStatusRestorationHealsRaid or #HealerEngineHeals_HealAurasUnitCount >= 2) and (Restoration_Enemy_SumHealth > UnitHealthMax("player") * 3.5 or Restoration_Enemy_SumHealth == 0.9527 or C_PvP.IsActiveBattlefield()) and RestorationSaves.RestorationOption_Heals_AutoEfflorescence then
			if not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_DoNotHealsLowMana and not RestorationHeals_AlertSpellAOEWillWildGrowth then
				if (Restoration_IsStanding_AWhile or C_PvP.IsActiveBattlefield()) and UnitHasCastLifebloom then
					DA_CastSpellByID(Efflorescence_SpellID, "player")
					Restoration_RefreshRaidCastlInfo("player", Efflorescence_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
		end
		--百花齐放指示
		
		if RestorationSaves.RestorationOption_Other_AutoRebirth then
			Restoration_DeadTankUnitid = Restoration_GetTankAssignedDead()
			Restoration_DeadHealerUnitid = Restoration_GetHealerAssignedDead()
			Restoration_DeadDamagerUnitid = Restoration_GetDamagerAssignedDead()
			if Restoration_DeadTankUnitid and not RebirthCD and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				if not NaturesSwiftnessCD then
					DA_CastSpellByID(Nature_Swiftness_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Nature_Swiftness_SpellID)
					--自然迅捷
				end
				if ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('复生')) == 0) then
					DA_TargetUnit(Restoration_DeadTankUnitid)
					if UnitIsUnit('target', Restoration_DeadTankUnitid) then
						DA_CastSpellByID(Rebirth_SpellID)
					end
					Restoration_RefreshRaidCastlInfo(Restoration_DeadTankUnitid, Rebirth_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
			--复生坦克指示
			if Restoration_DeadHealerUnitid and UnitExists("boss1") and Health40 < 1 and NumGroupMembers <= 7 and #DamagerEngine_TankAssigned >= 1 and not RebirthCD and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				if not NaturesSwiftnessCD then
					DA_CastSpellByID(Nature_Swiftness_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Nature_Swiftness_SpellID)
					--自然迅捷
				end
				if ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('复生')) == 0) then
					DA_TargetUnit(Restoration_DeadHealerUnitid)
					if UnitIsUnit('target', Restoration_DeadHealerUnitid) then
						DA_CastSpellByID(Rebirth_SpellID)
					end
					Restoration_RefreshRaidCastlInfo(Restoration_DeadHealerUnitid, Rebirth_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
			--复生治疗指示(BOSS战,且附近队友不大于7人)
			if Restoration_DeadDamagerUnitid and UnitExists("boss1") and Health40 < 1 and NumGroupMembers <= 7 and #DamagerEngine_TankAssigned >= 1 and not RebirthCD and UnitAffectingCombat("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
				if not NaturesSwiftnessCD then
					DA_CastSpellByID(Nature_Swiftness_SpellID)
					Restoration_RefreshRaidCastlInfo("player", Nature_Swiftness_SpellID)
					--自然迅捷
				end
				if ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('复生')) == 0) then
					DA_TargetUnit(Restoration_DeadDamagerUnitid)
					if UnitIsUnit('target', Restoration_DeadDamagerUnitid) then
						DA_CastSpellByID(Rebirth_SpellID)
					end
					Restoration_RefreshRaidCastlInfo(Restoration_DeadDamagerUnitid, Rebirth_SpellID)
					RestorationSpellWillBeCast = 1
				end
			end
			--复生伤害输出指示(BOSS战,且附近队友不大于7人)
		end
		
		if not Restoration_InGCD and not IsStealthed() and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn and not RestorationUnitHasAuras then
		--特定目标控制
			for k, v in ipairs(Restoration_ControlEnemyCache) do
				if DA_ObjectId(v.Unit) == 111111 then
				--多恩诺加尔-顺劈训练假人(测试)控制逻辑:
				
					--print("控制目标 - "..UnitName(v.Unit))
					if (#HealsUnitPriority == 0 or Health40 == 0) and not RestorationAutoDPSTargetNotVisible then
						if not AuraUtil.FindAuraByName('纠缠根须', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('群体缠绕', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('变形术', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('恐惧', v.Unit, "HARMFUL") then
						--没有纠缠根须等控制效果
							if IsPlayerSpell(102359) and DA_IsUsableSpell(102359) and not Mass_EntanglementCD and DA_IsSpellInRange(102359, v.Unit) then
								DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
								--选择特定控制目标宏
								if UnitIsUnit('target', v.Unit) then
									DA_CastSpellByID(102359)
									RestorationSpellWillBeCast = 1
									--使用[群体缠绕]控制
								end
							elseif IsPlayerSpell(Entangling_Roots_SpellID) and DA_IsUsableSpell(Entangling_Roots_SpellID) and not WrathCD and DA_IsSpellInRange(Entangling_Roots_SpellID, v.Unit) and not DA_EntanglingRootsCastStart and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('纠缠根须')) == 0) then
								DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
								--选择特定控制目标宏
								if UnitIsUnit('target', v.Unit) then
									DA_CastSpellByID(Entangling_Roots_SpellID)
									RestorationSpellWillBeCast = 1
									--使用[纠缠根须]控制
								end
							end
						end
					end
					
					break
				end
				
				if DA_ObjectId(v.Unit) == 165251 then
				--塞兹仙林的迷雾-幻影仙狐控制逻辑:
				
					--print("控制目标 - "..UnitName(v.Unit))
					if (#HealsUnitPriority == 0 or Health40 == 0) and not RestorationAutoDPSTargetNotVisible then
						if GetUnitSpeed(v.Unit) ~= 0 and not AuraUtil.FindAuraByName('纠缠根须', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('群体缠绕', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('变形术', v.Unit, "HARMFUL") and not AuraUtil.FindAuraByName('恐惧', v.Unit, "HARMFUL") then
						--幻影仙狐在移动,且没有纠缠根须等控制效果
							if IsPlayerSpell(102359) and DA_IsUsableSpell(102359) and not Mass_EntanglementCD and DA_IsSpellInRange(102359, v.Unit) then
								DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
								--选择特定控制目标宏
								if UnitIsUnit('target', v.Unit) then
									DA_CastSpellByID(102359)
									RestorationSpellWillBeCast = 1
									--使用[群体缠绕]控制
								end
							elseif IsPlayerSpell(Entangling_Roots_SpellID) and DA_IsUsableSpell(Entangling_Roots_SpellID) and not WrathCD and DA_IsSpellInRange(Entangling_Roots_SpellID, v.Unit) and not DA_EntanglingRootsCastStart and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('纠缠根须')) == 0) then
								DA_pixel_target_frame.texture:SetColorTexture(0.6, 0, 0)
								--选择特定控制目标宏
								if UnitIsUnit('target', v.Unit) then
									DA_CastSpellByID(Entangling_Roots_SpellID)
									RestorationSpellWillBeCast = 1
									--使用[纠缠根须]控制
								end
							end
						end
					end
					
					break
				end
			end
		end
		
		if NumGroupMembers >= 2 then
			--多人
			if (Restoration_HealsUnit_SumHealthVacancy > UnitHealthMax("player") or (Health55 >= 1 and RestorationHeals_DoNotHealsLowMana)) and UnitAffectingCombat("player") and UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.9 and not InnervateCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					DA_TargetUnit('player')
					if UnitIsUnit('target','player') then
						DA_CastSpellByID(Innervate_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Innervate_SpellID)
				end
			end
		else
			--单人
			if (Restoration_HealsUnit_SumHealthVacancy > UnitHealthMax("player") * 0.6 or (Health55 >= 1 and RestorationHeals_DoNotHealsLowMana)) and UnitAffectingCombat("player") and UnitPower("player", 0) / UnitPowerMax("player", 0) <= 0.9 and not InnervateCD then
				if not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					DA_TargetUnit('player')
					if UnitIsUnit('target','player') then
						DA_CastSpellByID(Innervate_SpellID)
					end
					Restoration_RefreshRaidCastlInfo("player", Innervate_SpellID)
				end
			end
		end
		--激活指示
		
		if RestorationSaves.RestorationOption_Other_AutoDPS and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not Swiftmend_CenarionWard and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth and not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn and not RestorationHeals_AlertSpellRejuvenationGUID and not RestorationHeals_AlertSpellGUID and not RestorationDBMWillAoe and not RestorationUnitHasAuras and not RestorationHeals_HealBreakoutSpellAOE and not HealerEngineHeals_HealBreakoutSpellUnitID and not RestorationHeals_AlertSpellBreakoutGUID then
		--特殊目标自动输出
		
			for k, v in ipairs(Restoration_EnemyCacheS) do
				if not DamagerEngineGetNoAttackAuras(v.Unit) then
				--获取不攻击BUFF、判断目标是否可以攻击
					local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(v.Unit)
					local timeLeft = endTime and endTime - GetTime() * 1000
					--剩余施法时间(单位:毫秒)
					local castTime = endTime and endTime - startTime
					--施法总时间(单位:毫秒)
					Restoration_AutoDPS_ShredTargetS_Switch = 1
					if v.UnitName == "爆炸物" and timeLeft and ((timeLeft > 5750) or (timeLeft > 5000 and Health75 > 0) or (timeLeft > 4500 and Health70 > 0) or (timeLeft > 3000 and Health55 > 0) or (timeLeft > 1500 and Health40 > 0) or (timeLeft > 1000 and Health25 > 0)) and #Restoration_EnemyCacheS < 3 then
						--爆炸剩余施法时间((大于5.75秒)或(大于5秒且有小于75%血量队友)或(大于4.5秒且有小于70%血量队友)或(大于3秒且有小于55%血量队友)或(大于1.5秒且有小于40%血量队友)或(大于1秒且有小于25%血量队友))且特殊目标小于3则不攻击
						Restoration_AutoDPS_ShredTargetS_Switch = nil
					end
					if Restoration_AutoDPS_ShredTargetS_Switch then
						Restoration_AutoDPS_MoonfireTargetS = v.Unit
						--特殊目标月火术
						break
					end
				end
			end
			
			if Restoration_AutoDPS_MoonfireTargetS and (#HealsUnitPriority == 0 or (Health80 < 1 and not HealerEngineHeals_AdvanceRejuvenation) or (Health25 < 1 and not HealerEngineHeals_AdvanceRejuvenation and (select(2, IsInInstance()) == "party" or select(2, IsInInstance()) == "raid"))) and not RestorationAutoDPSTargetNotVisible then
				if RestorationSaves.RestorationOption_Other_AutoTargetIng or not WoWAssistantUnlocked then
					DA_TargetUnit(Restoration_AutoDPS_MoonfireTargetS)
				end
				DA_CastSpellByID(8921, Restoration_AutoDPS_MoonfireTargetS)
				--特殊目标月火术
				RestorationSpellWillBeCast = 1
			end
		end
		
		if not SootheCD and UnitAffectingCombat("player") and RestorationSaves.RestorationOption_Auras_ClearEnrage and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not Swiftmend_CenarionWard and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth and not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn and not RestorationUnitHasAuras then
		--驱散激怒效果
			for k, v in ipairs(Restoration_EnemyCache) do
				if string.lower(string.sub(v.Unit, 1, 9)) ~= "nameplate" and not DamagerEngineGetNoAttackAuras(v.Unit) then
					--由于nameplate目标后导致后续选择单位出错,因此排除通过nameplate姓名板获取到的单位,且该单位没有不攻击的BUFF
					if DA_UnitHasEnrage(v.Unit) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 0.5 or not IsInInstance() or NumGroupMembers <= 3) then
						--print("驱散激怒效果 - "..UnitName(v.Unit))
						Restoration_ClearEnrageTarget = v.Unit
						--驱散激怒效果目标
						break
					end
				end
			end
			
			if Restoration_ClearEnrageTarget and (#HealsUnitPriority == 0 or Health40 == 0) and not RestorationAutoDPSTargetNotVisible then
				DA_TargetUnit(Restoration_ClearEnrageTarget)
				if UnitIsUnit('target', Restoration_ClearEnrageTarget) then
					DA_CastSpellByID(Soothe_SpellID)
				end
				--安抚
				RestorationSpellWillBeCast = 1
			end
		end
		
		if not GetCurrentKeyBoardFocus() and not Restoration_InGCD and (RestorationHeals_CenarionWardCD or RestorationHeals_SwiftmendCD or not IsPlayerSpell(102351) or not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank or not DamagerEngine_TankAssignedHasThreat) and not Swiftmend_CenarionWard and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		--空闲时自动输出
			--print('空闲时自动输出')
			if RestorationSaves.RestorationOption_Other_AutoDPS and not Restoration_HeartOfTheWildDPS_GetNeedHeals() and ((not RestorationHeals_Innervate and not RestorationHeals_DynamicHealOfBoss and not HealerEngineHeals_AdvanceRejuvenation) or #HealsUnitPriority <= 0) and not LifebloomTarget_In_HealsUnitPriority and not RestorationHeals_AlertSpellAOEWillWildGrowth and not RestorationUnitHasAuras and not HealerEngine_UnitHasHealAurasWarn and ((not HealerEngine_UnitHasHealAurasLow and not HealerEngine_UnitHasHealAuras and not RestorationHeals_AlertSpellRejuvenationGUID and not RestorationHeals_AlertSpellGUID and not RestorationDBMWillAoe and not RestorationHeals_HealBreakoutSpellAOE and not HealerEngineHeals_HealBreakoutSpellUnitID and not RestorationHeals_AlertSpellBreakoutGUID) or (RestorationHeals_DoNotHealsLowMana and IsPlayerSpell(289237))) then
				if not NatureVigilCD and not RestorationHeals_DoNotHeals and Restoration_HealsUnit_SumHealthScale <= 0.8 and UnitAffectingCombat("player") and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
					DA_CastSpellByID(124974)
					RestorationSpellWillBeCast = 1
					--自然的守护
				end
				Restoration_HeartOfTheWildDPS()
				--自动输出
				--print('自动输出')
			elseif RestorationSaves.RestorationOption_Other_AutoDPS and GetShapeshiftFormID() == 1 and not AuraUtil.FindAuraByName('急奔', "player", "HELPFUL") and DA_Clear_Rooted and not IsStealthed() and UnitAffectingCombat("player") and not C_PvP.IsActiveBattlefield() and not IsInRaid() and not UnitExists('boss1') then
			--开启DPS输出时,或需要治疗,或其他需要治疗或解DEBUFF的情况则取消猎豹形态
				DA_Cancelform()
				--print('取消变形1')
				--取消变形
			end
		end
		
		if AuraUtil.FindAuraByName('饕餮狂乱', "player", "HELPFUL") and UnitAffectingCombat("player") and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_DoNotHealsLowMana and not RestorationHeals_AlertSpellAOEWillWildGrowth and not RestorationUnitHasAuras and not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn and not RestorationDBMWillAoe and not RestorationHeals_HealBreakoutSpellAOE and not HealerEngineHeals_HealBreakoutSpellUnitID and not RestorationHeals_AlertSpellBreakoutGUID then
		--饕餮狂乱BUFF,在战斗状态空闲时自动使用技能
			if #HealsUnitPriority == 0 and not RestorationSaves.RestorationOption_Heals_HealTank then
				if AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") then
				--[化身：生命之树]状态
					if select(10, GetTalentInfo(1, 2, 1)) and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras then
					--选择了[滋养]天赋则使用[滋养]
						if RestorationSaves.RestorationOption_Other_AutoTargetIng then
							DA_TargetUnit("player")
						end
						DA_CastSpellByID(Nourish_SpellID, "player")
						Restoration_RefreshRaidCastlInfo("player", Nourish_SpellID)
						RestorationSpellWillBeCast = 1
					else
					--没选择[滋养]天赋则使用[回春术]
						if RestorationSaves.RestorationOption_Other_AutoTargetIng then
							DA_TargetUnit("player")
						end
						DA_CastSpellByID(Rejuvenation_SpellID, "player")
						Restoration_RefreshRaidCastlInfo("player", Rejuvenation_SpellID)
						RestorationSpellWillBeCast = 1
					end
				else
				--非[化身：生命之树]状态
					if not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras then
					--愈合
						if RestorationSaves.RestorationOption_Other_AutoTargetIng then
							DA_TargetUnit("player")
						end
						DA_CastSpellByID(Regrowth_SpellID, "player")
						Restoration_RefreshRaidCastlInfo("player", Regrowth_SpellID)
						RestorationSpellWillBeCast = 1
					else
					--回春术
						if RestorationSaves.RestorationOption_Other_AutoTargetIng then
							DA_TargetUnit("player")
						end
						DA_CastSpellByID(Rejuvenation_SpellID, "player")
						Restoration_RefreshRaidCastlInfo("player", Rejuvenation_SpellID)
						RestorationSpellWillBeCast = 1
					end
				end
			end
		end
		
		Restoration_AutoDPS_MoonfireTargetS = nil
		Restoration_ClearEnrageTarget = nil
		DamagerEngine_AutoDPS_SinglePriorityTatgetExists = nil
		DamagerEngineControlInterruptSpell = nil
		DamagerEngineControlInterruptSpellTarget = nil
		
		if (Restoration_Enemy_SumHealth > UnitHealthMax("player") * 3.5 or Restoration_Enemy_SumHealth == 0.9527 or C_PvP.IsActiveBattlefield()) and not Swiftmend_CenarionWard and not UnitChannelInfo("player") and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
			
			--Restoration_UseCarafeofSearingLight()
			--灼光之瓶
			
			--Restoration_UseVitalityResonator()
			--生命共鸣器
			
			--Restoration_UseSoullettingRuby()
			--释魂红玉
			
			--Restoration_UseVialofSpectralEssence()
			--鬼灵精华之瓶
			
			--Restoration_UseSunbloodAmethyst()
			--阳血紫晶
			
			--Restoration_UseOverflowingAnimaCage()
			--充盈的心能牢狱
			
			--Restoration_UseLingeringSunmote()
			--残留的太阳之尘

			--Restoration_UseDarkmoonDeckRepose()
			--暗月套牌：休憩
		end
		
		Restoration_DynamicHealOfBoss()
		--BOSS战斗动态使用法力
		
		RestorationStatusLhh:UpdateUnit()
		--施放常规技能
		
		if RestorationSaves.RestorationOption_Other_AutoDPS and RestorationSaves.RestorationOption_Other_ShowCastlInfo then
			Restoration_DeBugEnemyCount:SetText(Restoration_EnemyCount)
			if Restoration_EnemyCount == 0 then
				Restoration_DeBugEnemyCount:Hide()
			else
				Restoration_DeBugEnemyCount:Show()
			end
			if not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not Restoration_InGCD then
				Restoration_DeBugSpellIcon:Hide()
			elseif RestorationDPSSpellWillBeCast then
				Restoration_DeBugSpellIcon:Show()
			end
		else
			Restoration_DeBugEnemyCount:Hide()
			Restoration_DeBugSpellIcon:Hide()
		end
	end
	
	RestorationAdvanceRejuvenationTime = RestorationAdvanceRejuvenationTime or GetTime()
	if GetTime() - RestorationAdvanceRejuvenationTime > 1 then
		if RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation then
			HealerEngine_GetAdvanceRejuvenationUnit()
			--获取是否存在需要预铺回春的敌对目标
			Restoration_GetAdvanceRejuvenationAffixesCrack()
			--大秘境[崩裂]词缀时,判断是否有即将死亡的怪,以便提前回春
		else
			HealerEngineHeals_AdvanceRejuvenation = nil
			Restoration_AffixesCrackUnitDying = nil
		end
		RestorationAdvanceRejuvenationTime = nil
	end
end

function Restoration_DynamicHealOfBoss()
	--BOSS战斗动态使用法力
	if UnitGUID("boss1") and RestorationSaves.RestorationOption_Heals_DynamicHealOfBoss and #Restoration_SpecialHealsCache <= 0 then
		Restoration_BossHealthSum = 0
		Restoration_BossHealthMaxSum = 0
		Restoration_BossHealthScale = 1
		for i = 1, 10 do
			if UnitExists("boss"..i) and UnitCanAttack("player", "boss"..i) and not UnitIsDeadOrGhost("boss"..i) then
				Restoration_BossHealthSum = Restoration_BossHealthSum + UnitHealth("boss"..i)
				Restoration_BossHealthMaxSum = Restoration_BossHealthMaxSum + UnitHealthMax("boss"..i)
				--print(UnitName("boss"..i))
			end
		end
		Restoration_BossHealthScale = Restoration_BossHealthSum / Restoration_BossHealthMaxSum
		if UnitPower("player", 0) / UnitPowerMax("player", 0) - 0.15 > Restoration_BossHealthScale then
			RestorationHeals_DynamicHealOfBoss = 1
		else
			RestorationHeals_DynamicHealOfBoss = nil
		end
	else
		RestorationHeals_DynamicHealOfBoss = nil
	end
end

function Restoration_GetAdvanceRejuvenationAffixesCrack()
	--大秘境[崩裂]词缀时,判断是否有即将死亡的怪,以便提前回春
	Restoration_AffixesCrackUnitDying = nil
	Restoration_Affixes_Crack_IsBoss = nil
	if IsInGroup() and not IsInRaid() and DA_GetHasActiveAffix('崩裂') and #Restoration_SpecialHealsCache <= 0 then
		--存在[崩裂]词缀,且没有特殊治疗目标
		for i = 1, 10 do
			if UnitExists("boss"..i) and not UnitIsDeadOrGhost("boss"..i) then
				--BOSS战
				Restoration_Affixes_Crack_IsBoss = 1
			end
		end
		if not Restoration_Affixes_Crack_IsBoss and Restoration_EnemyCache then
			--非BOSS战,且存在敌对目标
			for k, v in ipairs(Restoration_EnemyCache) do
				if v.UnitHealth < UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 0.3 then
					--print("即将死亡 - "..v.UnitName)
					Restoration_AffixesCrackUnitDying = v.Unit
					--检测是否有单位即将死亡
					break
				end
			end
		end
	end
end

function Restoration_CrackArenaUnitDying()
	--竞技场中判断是否有即将死亡的敌方
	local ArenaIsDying = nil
	if IsActiveBattlefieldArena() then
		for ism = 1, 5 do
			local thisUnit = _G["arena"..ism]
			if UnitExists(thisUnit) and not UnitIsDeadOrGhost(thisUnit) then
				local UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit)
				if UnitHealthScale <= 0.2 and not DamagerEngineGetNoAttackAuras(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) and DA_IsSpellInRange(5176, thisUnit) == 1 then
					ArenaIsDying = thisUnit
					break
				end
			end
		end
	end
	return ArenaIsDying
end

function Restoration_GetTankAssignedDead()
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

function Restoration_GetHealerAssignedDead()
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

function Restoration_GetDamagerAssignedDead()
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

function Restoration_CanNotMovingCast()
	--获取是否不能移动读条
	if WoWAssistantUnlocked then
	--EasyWoWToolbox或者FireHack已载入
		--if (not EWT and HackEnabled("MovingCast")) or (EWT and IsHackEnabled("MovingCast")) then return false end
	end
	if IsPlayerMoving() or IsFalling() then	
		return true
	else
		return false
	end
end

function Restoration_GetSumHealthScaleFallRatio(ratio, second1, second2)
	--获取second1秒前到second2秒前之间[总剩余血量比例]下降比例是否超过ratio
	--(ratio取值范围:0~1)
	--(second取值范围:1~10,整数)
	if (not second1 or not second2 or second1 == 0 or second2 == 0) then
		if not second1 then second1 = 1 end
		if not second2 then second2 = 1 end
		if #RestorationHeals_SumHealthScaleTimelineCache >= math.max(second1, second2) then
			local t = RestorationHeals_SumHealthScaleTimelineCache[math.min(second1, second2)].SumHealthScale - RestorationHeals_SumHealthScaleTimelineCache[math.max(second1, second2)].SumHealthScale
			if t ~= 0 and (t~= print_cache or not print_cache) then
				print_cache = t
				--print(string.format("%.2f", t * 100).."% ("..math.max(second1, second2).."-"..math.min(second1, second2)..")")
			end
			if RestorationHeals_SumHealthScaleTimelineCache[math.max(second1, second2)].SumHealthScale - Restoration_HealsUnit_SumHealthScale >= ratio then
				return true
			else
				return false
			end
		end
	else
		if #RestorationHeals_SumHealthScaleTimelineCache >= math.max(second1, second2) then
			if RestorationHeals_SumHealthScaleTimelineCache[math.max(second1, second2)].SumHealthScale - RestorationHeals_SumHealthScaleTimelineCache[math.min(second1, second2)].SumHealthScale >= ratio then
				local t = RestorationHeals_SumHealthScaleTimelineCache[math.min(second1, second2)].SumHealthScale - RestorationHeals_SumHealthScaleTimelineCache[math.max(second1, second2)].SumHealthScale
				if t ~= 0 and (t~= print_cache or not print_cache) then
					print_cache = t
					--print(string.format("%.2f", t * 100).."% ("..math.max(second1, second2).."-"..math.min(second1, second2)..")")
				end
				return true
			else
				return false
			end
		end
	end
end

function Restoration_GetSumHealthScaleContrastToTimeline(second)
	--获取当前[总剩余血量比例]相对(second )秒前[总剩余血量比例]的变化信息(1~10秒内)
	--(second取值范围:1~10,整数)
	if #RestorationHeals_SumHealthScaleTimelineCache >= second then
		if Restoration_HealsUnit_SumHealthScale == RestorationHeals_SumHealthScaleTimelineCache[second].SumHealthScale then
			--print("相对"..(second).."秒前:不变")
			return "Equal"
		end
		if Restoration_HealsUnit_SumHealthScale > RestorationHeals_SumHealthScaleTimelineCache[second].SumHealthScale then
			--print("相对"..(second).."秒前:提高")
			return "Improve"
		end
		if Restoration_HealsUnit_SumHealthScale < RestorationHeals_SumHealthScaleTimelineCache[second].SumHealthScale then
			--print("相对"..(second).."秒前:下降")
			return "Fall"
		end
	end
end

function Restoration_GetUnitHealthScaleContrastToTimeline(second, unitid)
	--获取当前[单位剩余血量比例]相对(second)秒前[单位余血量比例]的变化信息(1~10秒内)
	--(second取值范围:1~10,整数)
	local GUID = UnitGUID(unitid)
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	if #RestorationHeals_HealsUnitTimelineCache >= second then
		for k, v in ipairs(RestorationHeals_HealsUnitTimelineCache[second].Cache) do
			if GUID == v.UnitGUID then
				if UnitHealthScale == v.UnitHealthScale then
					--print("相对"..(second).."秒前:不变")
					return "Equal"
				end
				if UnitHealthScale > v.UnitHealthScale then
					--print("相对"..(second).."秒前:提高")
					return "Improve"
				end
				if UnitHealthScale < v.UnitHealthScale then
					--print("相对"..(second).."秒前:下降")
					return "Fall"
				end
				break
			end
		end
	end
end

function Restoration_WriteSumHealthTimelineCache()
	--总剩余血量时间轴写入缓存
	if Restoration_HealsUnit_SumHealth and Restoration_HealsUnit_SumHealthMax and Restoration_HealsUnit_SumHealthScale then
		if (Restoration_WriteSumHealthTimelineCacheIntervalTime and GetTime() - Restoration_WriteSumHealthTimelineCacheIntervalTime > 1) or not Restoration_WriteSumHealthTimelineCacheIntervalTime then
			Restoration_WriteSumHealthTimelineCacheIntervalTime = GetTime()
			table.insert(RestorationHeals_SumHealthScaleTimelineCache, {
				Time = GetTime(),
				SumHealth = Restoration_HealsUnit_SumHealth, 
				SumHealthMax = Restoration_HealsUnit_SumHealthMax, 
				SumHealthScale = Restoration_HealsUnit_SumHealthScale, 
			}) --写入表格
			table.insert(RestorationHeals_HealsUnitTimelineCache, {
				Time = GetTime(),
				Cache = RestorationHeals_HealsUnitCache, 
			}) --写入表格
			table.sort(RestorationHeals_SumHealthScaleTimelineCache, function(a, b) return a.Time > b.Time end)
			table.sort(RestorationHeals_HealsUnitTimelineCache, function(a, b) return a.Time > b.Time end)
			for i = #RestorationHeals_SumHealthScaleTimelineCache, 1, -1 do
				if i > 10 then
					table.remove(RestorationHeals_SumHealthScaleTimelineCache, i)
				end
			end
			for i = #RestorationHeals_HealsUnitTimelineCache, 1, -1 do
				if i > 10 then
					table.remove(RestorationHeals_HealsUnitTimelineCache, i)
				end
			end
			if (Restoration_WriteSumHealthTimelineCacheIntervalTime2 and GetTime() - Restoration_WriteSumHealthTimelineCacheIntervalTime2 > 1) or not Restoration_WriteSumHealthTimelineCacheIntervalTime2 then
				Restoration_WriteSumHealthTimelineCacheIntervalTime2 = GetTime()
				for i = #RestorationHeals_SumHealthScaleTimelineCache, 1, -1 do
					--print(i.."秒前: "..RestorationHeals_SumHealthScaleTimelineCache[i].SumHealthScale)
				end
				for i = #RestorationHeals_HealsUnitTimelineCache, 1, -1 do
					for k, v in ipairs(RestorationHeals_HealsUnitTimelineCache[i].Cache) do
						--print(i.."秒前: "..v.UnitGUID.." "..v.UnitHealthScale)
					end
				end
			end
		end
	end
end

function Restoration_GetEfflorescencePosition(Distance, CountVar)
	--获取百花齐放位置
	if not WoWAssistantUnlocked then return end
	local CaChe = {}
	for k, v in ipairs(RestorationHeals_HealsUnitCache) do
		if DA_GetLineOfSight("player", v.Unit) and v.UnitHealthScale <= 0.975 and not UnitIsOtherPlayersPet(v.Unit) then
		--目标在视野中,且血量小于97.5%,且不是宠物
			local UnitCount = 1
			local CaChe2 = {}
			local X1,Y1,Z1 = ObjectPosition(v.Unit)
			table.insert(CaChe2, {
				UnitPositionX = X1,
				UnitPositionY = Y1,
				UnitPositionZ = Z1,
			}) --目标坐标写入表格,方便下一步计算几何中点
			for k2, v2 in ipairs(RestorationHeals_HealsUnitCache) do
				if UnitGUID(v.Unit) ~= UnitGUID(v2.Unit) and not UnitIsOtherPlayersPet(v2.Unit) and GetUnitSpeed(v.Unit) == 0 and GetUnitSpeed(v2.Unit) == 0 and not UnitIsDeadOrGhost(v2.Unit) and not UnitIsCharmed(v2.Unit) and UnitReaction("player", v2.Unit) > 4 and UnitIsConnected(v2.Unit) and UnitCanAssist("player", v2.Unit) and UnitIsVisible(v2.Unit) and UnitAffectingCombat(v2.Unit) then
					if DA_GetNovaDistance(v.Unit, v2.Unit) < Distance then
						UnitCount = UnitCount + 1
						local X,Y,Z = ObjectPosition(v2.Unit)
						table.insert(CaChe2, {
							UnitPositionX = X,
							UnitPositionY = Y,
							UnitPositionZ = Z,
						}) --该目标旁队友坐标写入表格,该表格仅用于计算几何中点
					end
				end
			end
			if UnitCount >= CountVar then
				--该单位加上附近的单位总数大于等于UnitCountVar
				local UnitPositionXSum = 0
				local UnitPositionYSum = 0
				local UnitPositionZSum = 0
				for k, v in ipairs(CaChe2) do
					UnitPositionXSum = UnitPositionXSum + v.UnitPositionX
					UnitPositionYSum = UnitPositionYSum + v.UnitPositionY
					UnitPositionZSum = UnitPositionZSum + v.UnitPositionZ
				end
				local X = UnitPositionXSum / #CaChe2
				local Y = UnitPositionYSum / #CaChe2
				local Z = UnitPositionZSum / #CaChe2
				--计算百花齐放范围内单位的几何中点
				if DA_GetNovaDistance(v.Unit, "player") < 39 then
					table.insert(CaChe, {UnitID = v.Unit, UnitCount = UnitCount, X = X, Y = Y, Z = Z})
				end
			end
		end
	end
	if #CaChe > 0 then
		table.sort(CaChe, function(a, b) return a.UnitCount > b.UnitCount end)
		return CaChe[1].X, CaChe[1].Y, CaChe[1].Z, CaChe[1].UnitID
	end
end

function Restoration_FindSpecialHealsUnit()
	--遍历附近特殊治疗目标
	if (Restoration_FindSpecialHealsUnitIntervalTime and GetTime() - Restoration_FindSpecialHealsUnitIntervalTime > 2) or not Restoration_FindSpecialHealsUnitIntervalTime then
		Restoration_FindSpecialHealsUnitIntervalTime = GetTime()
		Restoration_SpecialHealsCache = {}
		if WoWAssistantUnlocked then
			--EasyWoWToolbox或者FireHack已载入
			if GetObjectCount() > 0 then
				for i = 1, GetObjectCount() do
					local unitid = GetObjectWithIndex(i)
					if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
						if HealerEngine_GetSpecialHealsUnit(unitid) then
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
			end
		else
			if IsInRaid() then
				for i=1, GetNumGroupMembers() do
					local unitid = "raid"..i.."target"
					if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
						if HealerEngine_GetSpecialHealsUnit(unitid) then
							if #Restoration_SpecialHealsCache > 0 then
								for k, v in ipairs(Restoration_SpecialHealsCache) do
									if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
										table.insert(Restoration_SpecialHealsCache, {
											Unit = unitid, 
										}) --特殊治疗目标写入表格
									end
								end
							else
								table.insert(Restoration_SpecialHealsCache, {
									Unit = unitid, 
								}) --特殊治疗目标写入表格
							end
						end
					end
				end
				local unitid = "target"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "focus"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss1"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss2"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss3"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss4"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss5"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
			elseif IsInGroup() then
				for i=1, GetNumGroupMembers() - 1 do
					local unitid = "party"..i.."target"
					if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
						if HealerEngine_GetSpecialHealsUnit(unitid) then
							if #Restoration_SpecialHealsCache > 0 then
								for k, v in ipairs(Restoration_SpecialHealsCache) do
									if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
										table.insert(Restoration_SpecialHealsCache, {
											Unit = unitid, 
										}) --特殊治疗目标写入表格
									end
								end
							else
								table.insert(Restoration_SpecialHealsCache, {
									Unit = unitid, 
								}) --特殊治疗目标写入表格
							end
						end
					end
				end
				local unitid = "target"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "focus"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss1"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss2"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss3"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss4"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss5"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
			else
				local unitid = "target"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "focus"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss1"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss2"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss3"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss4"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
				local unitid = "boss5"
				if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					if HealerEngine_GetSpecialHealsUnit(unitid) then
						if #Restoration_SpecialHealsCache > 0 then
							for k, v in ipairs(Restoration_SpecialHealsCache) do
								if DA_ObjectId(v.Unit) ~= DA_ObjectId(unitid) then
									table.insert(Restoration_SpecialHealsCache, {
										Unit = unitid, 
									}) --特殊治疗目标写入表格
								end
							end
						else
							table.insert(Restoration_SpecialHealsCache, {
								Unit = unitid, 
							}) --特殊治疗目标写入表格
						end
					end
				end
			end
		end
	end
end

function Restoration_FindEnemy()
	--遍历附近敌对目标
	Restoration_EnemyCacheS = {}
	Restoration_EnemyCacheS2 = {}
	Restoration_EnemyCacheS3 = {}
	Restoration_EnemyCache = {}
	Restoration_EnemyCacheInMelee = {}
	Restoration_EnemyCacheIn7 = {}
	Restoration_ControlEnemyCache = {}
	DA_InteractUnitSituationCache = {}

	
	Restoration_Enemy_SumHealth = 0.9527
	if (RestorationStatusRestorationHealsParty or RestorationSaves.RestorationOption_Other_AutoDPS) then
		Restoration_Enemy_SumHealth = 0
		Restoration_Enemy_SumHealthMax = 0
		Restoration_Enemy_SumHealthScale = 0
		if IsActiveBattlefieldArena() then
		--竞技场中
			for ism = 1, 5 do
				local thisUnit = "arena"..ism
				if UnitExists(thisUnit) and not DA_UnitIsInTable(UnitGUID(thisUnit), DA_CanNotTargetNearest) then
					local status = UnitThreatSituation("player", thisUnit)
					if not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitIsVisible(thisUnit) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) and not UnitCanAssist("player", thisUnit) then
						if DA_IsSpellInRange(5176, thisUnit) == 1 then 
							if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
								--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
								table.insert(Restoration_ControlEnemyCache, {
									Unit = thisUnit, 
									UnitName = UnitName(thisUnit), 
									UnitGUID = UnitGUID(thisUnit), 
									UnitHealth = UnitHealth(thisUnit),
									UnitHealthMax = UnitHealthMax(thisUnit),
									UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
								}) --需要控制的特定目标写入表格
							end
							if not DamagerEngineGetIgnoreUnit(thisUnit) then
								if DA_IsSpecialEnemy(thisUnit) then
									--特殊敌对目标,不计入AOE目标数量
									if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheS) then 
										table.insert(Restoration_EnemyCacheS, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
											UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
										}) --特殊敌对目标写入表格
									end
								elseif (status and UnitAffectingCombat(thisUnit)) or DamagerEngineGetNoThreatUnit(thisUnit) or (UnitIsPlayer(thisUnit..'target') and IsInInstance()) then
									if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
									--战场中只将玩家目标列入表格
										if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCache) then 
											table.insert(Restoration_EnemyCache, {
												Unit = thisUnit, 
												UnitName = UnitName(thisUnit), 
												UnitGUID = UnitGUID(thisUnit), 
												UnitHealth = UnitHealth(thisUnit),
												UnitHealthMax = UnitHealthMax(thisUnit),
												UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
												UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
											}) --有仇恨敌对目标写入表格
										end
										if DA_IsSpellInRange(5221, thisUnit) == 1 then
											if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheInMelee) then 
												table.insert(Restoration_EnemyCacheInMelee, {
													Unit = thisUnit, 
													UnitName = UnitName(thisUnit), 
													UnitGUID = UnitGUID(thisUnit), 
													UnitHealth = UnitHealth(thisUnit),
													UnitHealthMax = UnitHealthMax(thisUnit),
													UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
													UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
												}) --近战范围内可攻击目标写入表格
											end
										end
										if DA_GetUnitDistance(thisUnit) <= 7 then
											if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheIn7) then 
												table.insert(Restoration_EnemyCacheIn7, {
													Unit = thisUnit, 
													UnitName = UnitName(thisUnit), 
													UnitGUID = UnitGUID(thisUnit), 
													UnitHealth = UnitHealth(thisUnit),
													UnitHealthMax = UnitHealthMax(thisUnit),
													UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
													UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
												})--7码内敌对的可攻击目标写入表格
											end
										end
									end
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
					local status = UnitThreatSituation("player", thisUnit)
					if not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitIsVisible(thisUnit) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) and not UnitCanAssist("player", thisUnit) then
						if DA_IsSpellInRange(5176, thisUnit) == 1 then 
							if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
								--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
								table.insert(Restoration_ControlEnemyCache, {
									Unit = thisUnit, 
									UnitName = UnitName(thisUnit), 
									UnitGUID = UnitGUID(thisUnit), 
									UnitHealth = UnitHealth(thisUnit),
									UnitHealthMax = UnitHealthMax(thisUnit),
									UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
									UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
								}) --需要控制的特定目标写入表格
							end
							if not DamagerEngineGetIgnoreUnit(thisUnit) then
								if DA_IsSpecialEnemy(thisUnit) then
									--特殊敌对目标,不计入AOE目标数量
									if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheS) then 
										table.insert(Restoration_EnemyCacheS, {
											Unit = thisUnit, 
											UnitName = UnitName(thisUnit), 
											UnitGUID = UnitGUID(thisUnit), 
											UnitHealth = UnitHealth(thisUnit),
											UnitHealthMax = UnitHealthMax(thisUnit),
											UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
											UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
										}) --特殊敌对目标写入表格
									end
								elseif (status and UnitAffectingCombat(thisUnit)) or DamagerEngineGetNoThreatUnit(thisUnit) or (UnitIsPlayer(thisUnit..'target') and IsInInstance()) then
									if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
									--战场中只将玩家目标列入表格
										if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCache) then 
											table.insert(Restoration_EnemyCache, {
												Unit = thisUnit, 
												UnitName = UnitName(thisUnit), 
												UnitGUID = UnitGUID(thisUnit), 
												UnitHealth = UnitHealth(thisUnit),
												UnitHealthMax = UnitHealthMax(thisUnit),
												UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
												UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
											}) --有仇恨敌对目标写入表格
										end
										if DA_IsSpellInRange(5221, thisUnit) == 1 then
											if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheInMelee) then 
												table.insert(Restoration_EnemyCacheInMelee, {
													Unit = thisUnit, 
													UnitName = UnitName(thisUnit), 
													UnitGUID = UnitGUID(thisUnit), 
													UnitHealth = UnitHealth(thisUnit),
													UnitHealthMax = UnitHealthMax(thisUnit),
													UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
													UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
												}) --近战范围内可攻击目标写入表格
											end
										end
										if DA_GetUnitDistance(thisUnit) <= 7 then
											if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheIn7) then 
												table.insert(Restoration_EnemyCacheIn7, {
													Unit = thisUnit, 
													UnitName = UnitName(thisUnit), 
													UnitGUID = UnitGUID(thisUnit), 
													UnitHealth = UnitHealth(thisUnit),
													UnitHealthMax = UnitHealthMax(thisUnit),
													UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
													UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
												})--7码内敌对的可攻击目标写入表格
											end
										end
									end
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
						local status = UnitThreatSituation("player", thisUnit)
						if not UnitIsDeadOrGhost(thisUnit) and (not UnitIsFriend(thisUnit, "player") or UnitIsEnemy(thisUnit, "player")) and UnitIsVisible(thisUnit) and UnitPhaseReason(thisUnit)~=0 and UnitPhaseReason(thisUnit)~=1 and UnitCanAttack("player",thisUnit) and not UnitCanAssist("player", thisUnit) then
							if DA_IsSpellInRange(5176, thisUnit) == 1 then 
								if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_ControlEnemyCache) and (DA_ObjectId(thisUnit) == 225982 or DA_ObjectId(thisUnit) == 165251) then
									--多恩诺加尔-顺劈训练假人(测试),塞兹仙林的迷雾-幻影仙狐
									table.insert(Restoration_ControlEnemyCache, {
										Unit = thisUnit, 
										UnitName = UnitName(thisUnit), 
										UnitGUID = UnitGUID(thisUnit), 
										UnitHealth = UnitHealth(thisUnit),
										UnitHealthMax = UnitHealthMax(thisUnit),
										UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
										UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
									}) --需要控制的特定目标写入表格
								end
								if not DamagerEngineGetIgnoreUnit(thisUnit) then
									if DA_IsSpecialEnemy(thisUnit) then
										--特殊敌对目标,不计入AOE目标数量
										if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheS) then 
											table.insert(Restoration_EnemyCacheS, {
												Unit = thisUnit, 
												UnitName = UnitName(thisUnit), 
												UnitGUID = UnitGUID(thisUnit), 
												UnitHealth = UnitHealth(thisUnit),
												UnitHealthMax = UnitHealthMax(thisUnit),
												UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
												UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
											}) --特殊敌对目标写入表格
										end
									elseif (status and UnitAffectingCombat(thisUnit)) or DamagerEngineGetNoThreatUnit(thisUnit) or (UnitIsPlayer(thisUnit..'target') and IsInInstance()) then
										if (UnitIsPlayer(thisUnit) or not C_PvP.IsActiveBattlefield()) then
										--战场中只将玩家目标列入表格
											if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCache) then 
												table.insert(Restoration_EnemyCache, {
													Unit = thisUnit, 
													UnitName = UnitName(thisUnit), 
													UnitGUID = UnitGUID(thisUnit), 
													UnitHealth = UnitHealth(thisUnit),
													UnitHealthMax = UnitHealthMax(thisUnit),
													UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
													UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
												}) --有仇恨敌对目标写入表格
											end
											if DA_IsSpellInRange(5221, thisUnit) == 1 then
												if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheInMelee) then 
													table.insert(Restoration_EnemyCacheInMelee, {
														Unit = thisUnit, 
														UnitName = UnitName(thisUnit), 
														UnitGUID = UnitGUID(thisUnit), 
														UnitHealth = UnitHealth(thisUnit),
														UnitHealthMax = UnitHealthMax(thisUnit),
														UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
														UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
													}) --近战范围内可攻击目标写入表格
												end
											end
											if DA_GetUnitDistance(thisUnit) <= 7 then
												if not DA_UnitIsInTable(UnitGUID(thisUnit), Restoration_EnemyCacheIn7) then 
													table.insert(Restoration_EnemyCacheIn7, {
														Unit = thisUnit, 
														UnitName = UnitName(thisUnit), 
														UnitGUID = UnitGUID(thisUnit), 
														UnitHealth = UnitHealth(thisUnit),
														UnitHealthMax = UnitHealthMax(thisUnit),
														UnitHealthScale = UnitHealth(thisUnit)/UnitHealthMax(thisUnit),
														UnitHealthVacancy = UnitHealthMax(thisUnit)-UnitHealth(thisUnit),
													})--7码内敌对的可攻击目标写入表格
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
		end
	end

	for k, v in ipairs(Restoration_EnemyCache) do
		--从有仇恨敌对目标表格中判断优先击杀目标
		if DamagerEngineGetPriorityUnit(v.Unit) then
			--先打血高的特殊目标(非单体输出,可AOE)
			table.insert(Restoration_EnemyCacheS2, {
				Unit = v.Unit,
				UnitName = v.UnitName,
				UnitGUID = v.UnitGUID,
				UnitHealth = v.UnitHealth,
				UnitHealthMax = v.UnitHealthMax,
				UnitHealthScale = v.UnitHealthScale,
				UnitHealthVacancy = v.UnitHealthVacancy,
			}) --目标写入表格
		end
		if DamagerEngineGetPriorityUnitReverseHealth(v.Unit) or DamagerEngineGetPriorityAttackAuras(v.Unit) then
			--先打血低的特殊目标(非单体输出,可AOE)
			table.insert(Restoration_EnemyCacheS3, {
				Unit = v.Unit,
				UnitName = v.UnitName,
				UnitGUID = v.UnitGUID,
				UnitHealth = v.UnitHealth,
				UnitHealthMax = v.UnitHealthMax,
				UnitHealthScale = v.UnitHealthScale,
				UnitHealthVacancy = v.UnitHealthVacancy,
			}) --目标写入表格
		end
	end
	if #Restoration_EnemyCacheS > 0 then
		table.sort(Restoration_EnemyCacheS, function(a, b) return a.UnitHealth > b.UnitHealth end)
		--血量从高到低排序(优先打血高的)
	end
	if #Restoration_EnemyCacheS2 > 0 then
		table.sort(Restoration_EnemyCacheS2, function(a, b) return a.UnitHealth > b.UnitHealth end)
		--血量从高到低排序(优先打血高的)
	end
	if #Restoration_EnemyCacheS3 > 0 then
		table.sort(Restoration_EnemyCacheS3, function(a, b) return a.UnitHealth < b.UnitHealth end)
		--血量从低到高排序(优先打血低的)
	end
	if #Restoration_EnemyCache > 0 then
		if (IsInGroup() and not IsInRaid() and DA_GetHasActiveAffix('崩裂')) or UnitExists("boss1") or not IsInInstance() or C_PvP.IsActiveBattlefield() or #DamagerEngine_DamagerAssigned <= 2 or select(3, GetInstanceInfo()) == 167 or select(3, GetInstanceInfo()) == 208 then
			--大秘境词缀存在[崩裂]或BOSS战斗或不在副本或在战场/竞技场或伤害输出职责不超过2人或在托加斯特，罪魂之塔时,血量从低到高排序(优先打血低的)
			table.sort(Restoration_EnemyCache, function(a, b) return a.UnitHealth < b.UnitHealth end)
		else
			table.sort(Restoration_EnemyCache, function(a, b) return a.UnitHealth > b.UnitHealth end)
			--血量从高到低排序(优先打血高的)
		end
		
		
		for k, v in ipairs(Restoration_EnemyCache) do
			Restoration_Enemy_SumHealth = Restoration_Enemy_SumHealth + v.UnitHealth
			Restoration_Enemy_SumHealthMax = Restoration_Enemy_SumHealthMax + v.UnitHealthMax
		end
		Restoration_Enemy_SumHealthScale = Restoration_Enemy_SumHealth / Restoration_Enemy_SumHealthMax
		--获取附近敌对目标的总剩余血量
		--print(Restoration_Enemy_SumHealth)
		--print(Restoration_Enemy_SumHealthMax)
		--print(Restoration_Enemy_SumHealthScale)
	end
end

function Restoration_TraversalHealth()
	Health25 = 0
	Health30 = 0
	Health40 = 0
	Health55 = 0
	Health70 = 0
	Health75 = 0
	Health80 = 0
	Health85 = 0
	Health90 = 0
	Health95 = 0
	Health99 = 0
	ThreatHealth25 = 0
	ThreatHealth30 = 0
	ThreatHealth40 = 0
	ThreatHealth55 = 0
	ThreatHealth70 = 0
	ThreatHealth75 = 0
	ThreatHealth80 = 0
	ThreatHealth85 = 0
	ThreatHealth90 = 0
	ThreatHealth95 = 0
	ThreatHealth99 = 0
	UnitRejuvenation25 = 0
	UnitRejuvenation30 = 0
	UnitRejuvenation40 = 0
	UnitRejuvenation55 = 0
	UnitRejuvenation70 = 0
	UnitRejuvenation75 = 0
	UnitRejuvenation80 = 0
	UnitRejuvenation85 = 0
	UnitRejuvenation90 = 0
	UnitRejuvenation95 = 0
	UnitRejuvenation99 = 0
	UnitHasCastLifebloomCount = 0
	UnitHasWildGrowthCount = 0
	UnitHasWildGrowthtimeLeft = 0
	NumGroupMembers = 0
	TradeDistanceUnit = 0
	FollowDistanceUnit = 0
	EfflorescenceGetReady = nil
	Restoration_UnitIsDeadOrGhost = nil
	UnitHasCastLifebloom = nil
	LeastUnitHasCastLifebloom = nil
	IsTranquilityIng = nil
	HealerEngine_UnitHasHealAurasLow = nil
	HealerEngine_UnitHasHealAuras = nil
	HealerEngine_UnitHasHealAurasWarn = nil
	DamagerEngine_GroupMember = {}
	DamagerEngine_TankAssigned = {}
	DamagerEngine_HealerAssigned = {}
	DamagerEngine_DamagerAssigned = {}
	DamagerEngine_TankAssignedDead = {}
	DamagerEngine_HealerAssignedDead = {}
	DamagerEngine_DamagerAssignedDead = {}
	HealerEngineHeals_AggroTarget = {}
	HealerEngineHeals_HealAurasUnitCount = {}
	RestorationHeals_HealsUnitCache = {}
	Restoration_HealsUnit_SumHealth = 0
	Restoration_HealsUnit_SumHealthMax = 0
	Restoration_HealsUnit_SumHealthScale = 1
	Restoration_HealsUnit_SumHealthVacancy = 0
	HealerEngineHeals_HealAurasNoOver = nil
	LifebloomTarget_In_HealsUnitPriority = nil
	
	if IsInRaid() then
		unitid = "focus"
		if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
			Restoration_GetHealth(unitid)
		end
		for i=1, GetNumGroupMembers() do
			unitid = "raid"..i
			Restoration_GetHealth(unitid)
		end
	elseif IsInGroup() then
		unitid = "player"
		Restoration_GetHealth(unitid)
		unitid = "focus"
		if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
			Restoration_GetHealth(unitid)
		end
		for i=1, GetNumGroupMembers() - 1 do
			unitid = "party"..i
			Restoration_GetHealth(unitid)
		end
	else
		unitid = "player"
		Restoration_GetHealth(unitid)
		unitid = "focus"
		if not UnitIsUnit('player', unitid) and not UnitInParty(unitid) and not UnitInRaid(unitid) then
			Restoration_GetHealth(unitid)
		end
	end

	RestorationNeedHealsCount = #HealsUnitPriority
	--总计需要治疗的单位数量(注:野性成长会将所有队友统计为需要治疗的单位)
	
	if Restoration_SpecialHealsCache and #Restoration_SpecialHealsCache > 0 and UnitAffectingCombat("player") then
		local HealsSpecial = nil
		local PlayerPowerScale = UnitPower("player", 0) / UnitPowerMax("player", 0)
		if IsInRaid() then
			--团队中
			local HealsSpecialIsBoss = nil
			for i = 1, 10 do
				local unitid = "boss"..i
				if UnitExists(unitid) and DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 then
					HealsSpecialIsBoss = 1
				end
			end
			if HealsSpecialIsBoss then
			--特殊治疗单位是BOSS,则控制BOSS治疗力度
				if (AuraUtil.FindAuraByName('灌注者的恩赐', "player", "HELPFUL") or RestorationHeals_Innervate) and Health25 <= 0 then
				--纳斯利亚堡-太阳之王的救赎-[灌注者的恩赐]BUFF或者[激活]BUFF,且没有血量低于25%的队友
					HealsSpecial = 1
				elseif PlayerPowerScale >= 0.7 and Health55 <= 0 then
				--玩家蓝量大于70%,且没有血量低于55%的队友
					HealsSpecial = 1
				elseif PlayerPowerScale >= 0.4 and Health70 <= 0 then
				--玩家蓝量大于40%,且没有血量低于70%的队友
					HealsSpecial = 1
				elseif Health75 <= 0 then
				--玩家蓝量小于40%,且没有血量低于75%的队友
					HealsSpecial = 1
				end
			elseif Health40 <= 0 then
			--特殊治疗单位不是BOSS,且没有血量低于40%的队友
				HealsSpecial = 1
			end
		else
			--非团队中
			if Health55 <= 0 then
			--没有血量低于55%的队友
				HealsSpecial = 1
			end
		end
		if HealsSpecial then
			for k, v in ipairs(Restoration_SpecialHealsCache) do
				Restoration_GetHealth(v.Unit)
				--特殊治疗目标
			end
		end
	end
	if #RestorationHeals_HealsUnitCache > 0 then
		for k, v in ipairs(RestorationHeals_HealsUnitCache) do
			Restoration_HealsUnit_SumHealth = Restoration_HealsUnit_SumHealth + v.UnitHealth
			Restoration_HealsUnit_SumHealthMax = Restoration_HealsUnit_SumHealthMax + v.UnitHealthMax
		end
		Restoration_HealsUnit_SumHealthScale = Restoration_HealsUnit_SumHealth / Restoration_HealsUnit_SumHealthMax
		Restoration_HealsUnit_SumHealthVacancy = Restoration_HealsUnit_SumHealthMax - Restoration_HealsUnit_SumHealth
		--获取治疗目标总体血量信息
		--print("总剩余血量: "..Restoration_HealsUnit_SumHealth)
		--print("总血量: "..Restoration_HealsUnit_SumHealthMax)
		--print("总血量比例: "..Restoration_HealsUnit_SumHealthScale)
		--print("总血量缺口: "..Restoration_HealsUnit_SumHealthVacancy)
	end
	
	if IsPlayerSpell(392301) then
	--可以对两个目标使用[生命绽放]时
		for k, v in ipairs(HealerEngineHeals_AggroTarget) do
			if UnitAffectingCombat(v) and DA_IsSpellInRange(Regrowth_SpellID, v) == 1 and AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL")) == "player" then
				LeastUnitHasCastLifebloom = 1
				--至少有一个仇恨目标身上有生命绽放
			end
		end
		if (not UnitHasCastLifebloom and not LeastUnitHasCastLifebloom) or UnitHasCastLifebloomCount <= 1 then
		--玩家没有施放生命绽放或者只施放了一个生命绽放
			NotRestorationHeals_UnitHasCastLifebloom = 1
			--没施放完生命绽放
		else
			NotRestorationHeals_UnitHasCastLifebloom = nil
			--已经施放完生命绽放
		end
	else
		if not UnitHasCastLifebloom then
			NotRestorationHeals_UnitHasCastLifebloom = 1
			--没施放完生命绽放
		else
			NotRestorationHeals_UnitHasCastLifebloom = nil
			--已经施放完生命绽放
		end
	end
	
	if not IsTranquilityIng then
		NotTranquilityIng = 1
	else
		NotTranquilityIng = nil
	end
	if #DamagerEngine_HealerAssigned >= 2 and not C_PvP.IsActiveBattlefield() then
		RestorationStatusRestorationHealsRaid = 1
		RestorationStatusRestorationHealsParty = nil
	else
		RestorationStatusRestorationHealsRaid = nil
		RestorationStatusRestorationHealsParty = 1
	end
	
	DamagerEngine_TankAssignedHasThreat = nil
	for k, v in ipairs(DamagerEngine_TankAssigned) do
		if UnitThreatSituation(v.Unit) and UnitThreatSituation(v.Unit) >= 2 then
			DamagerEngine_TankAssignedHasThreat = 1
			--检测是否有坦克处于仇恨状态
			break
		end
	end
	
	--print("<=25:"..Health25.."  ,  <=40:"..Health40.."  ,  <=55:"..Health55.."  ,  <=70:"..Health70.."  ,  <=75:"..Health75.."  ,  <=80:"..Health80.."  ,  <=90:"..Health90.."  ,  <=99:"..Health99)
	--print("<=25:"..ThreatHealth25.."  ,  <=40:"..ThreatHealth40.."  ,  <=55:"..ThreatHealth55.."  ,  <=70:"..ThreatHealth70.."  ,  <=75:"..ThreatHealth75.."  ,  <=80:"..ThreatHealth80.."  ,  <=90:"..ThreatHealth90.."  ,  <=99:"..ThreatHealth99)
	--print("<=25:"..UnitRejuvenation25.."  ,  <=40:"..UnitRejuvenation40.."  ,  <=55:"..UnitRejuvenation55.."  ,  <=70:"..UnitRejuvenation70.."  ,  <=75:"..UnitRejuvenation75.."  ,  <=80:"..UnitRejuvenation80.."  ,  <=90:"..UnitRejuvenation90.."  ,  <=99:"..UnitRejuvenation99)
	--print("治疗单位数量: "..NumGroupMembers)
	--for k, v in pairs(HealerEngineHeals_AggroTarget) do print("仇恨目标: "..v) end
	--for k, v in pairs(DamagerEngine_TankAssigned) do print("坦克: "..v.UnitName) end
	--for k, v in pairs(DamagerEngine_HealerAssigned) do print("治疗: "..v.UnitName) end
	--for k, v in pairs(DamagerEngine_DamagerAssigned) do print("DPS: "..v.UnitName) end
end

function Restoration_GetHealth(unitid)
	--if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and UnitCanAssist("player", unitid) then
	DamagerEngine_GetPosition(unitid)
	--判断职责并缓存(放在上面,避免IsSpellInRange无法判断死亡目标)
	local IsSpecialHealsUnit = nil
	IsSpecialHealsUnit = HealerEngine_GetSpecialHealsUnit(unitid)
	
	if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup() or UnitIsUnit('focus', unitid) or IsSpecialHealsUnit) then
		if select(8, UnitChannelInfo(unitid)) == Tranquility_SpellID or select(8, UnitChannelInfo(unitid)) == 64843 then
			if UnitGUID(unitid) ~= UnitGUID("player") then
				IsTranquilityIng = 1
			end
		end
		if WoWAssistantUnlocked then
			--EasyWoWToolbox或者FireHack已载入
			if not DA_GetLineOfSight("player", unitid) then
				--print(unitid.."不在视野中")
				return
			end
		end
		if DA_UnitIsInTable(UnitGUID(unitid), RestorationHeals_TargetNotVisible) then
			--print(unitid.."不在视野中")
			return
		end
		
		local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
		local UnitHealthDeficit = UnitHealthMax(unitid) - UnitHealth(unitid)
		local UnitThreat = UnitThreatSituation(unitid)
		local UnitRejuvenation = select(7, AuraUtil.FindAuraByName('回春术', unitid, "HELPFUL"))
		if select(7, AuraUtil.FindAuraByName('野性成长', unitid, "HELPFUL")) == "player" then
			UnitHasWildGrowthCount = UnitHasWildGrowthCount + 1
		end
		if not UnitIsDeadOrGhost(unitid) then
			NumGroupMembers = NumGroupMembers + 1
		end
		
		if WoWAssistantUnlocked then
			--EasyWoWToolbox或者FireHack已载入
			local X1,Y1,Z1 = ObjectPosition(unitid)
			table.insert(RestorationHeals_HealsUnitCache, {
					Unit = unitid, 
					UnitName = UnitName(unitid), 
					UnitGUID = UnitGUID(unitid), 
					UnitThreatSituation = UnitThreatSituation(unitid), 
					UnitHealth = UnitHealth(unitid),
					UnitHealthMax = UnitHealthMax(unitid),
					UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
					UnitPositionX = X1,
					UnitPositionY = Y1,
					UnitPositionZ = Z1,
				}) --治疗目标写入表格
		else
			table.insert(RestorationHeals_HealsUnitCache, {
					Unit = unitid, 
					UnitName = UnitName(unitid), 
					UnitGUID = UnitGUID(unitid), 
					UnitThreatSituation = UnitThreatSituation(unitid), 
					UnitHealth = UnitHealth(unitid),
					UnitHealthMax = UnitHealthMax(unitid),
					UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
					UnitPositionX = 0,
					UnitPositionY = 0,
					UnitPositionZ = 0,
				}) --治疗目标写入表格
		end
		
		if WrathCD then
			--print("自然系法术被打断")
			return
		end
		if HealerEngine_GetNoHealAuras(unitid) then
		--判断不治疗目标并缓存
			--print(unitid.."不治疗")
			return
		end
		
		if not IsSpecialHealsUnit then
		--单位不是特殊治疗目标才计算血量
			if UnitHealthScale <= 0.25 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health25 = Health25 + 1
				if UnitThreat == 3 then
					ThreatHealth25 = ThreatHealth25 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation25 = UnitRejuvenation25 + 1
				end
			end
			if UnitHealthScale <= 0.3 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health30 = Health30 + 1
				if UnitThreat == 3 then
					ThreatHealth30 = ThreatHealth30 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation30 = UnitRejuvenation30 + 1
				end
			end
			if UnitHealthScale <= 0.4 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health40 = Health40 + 1
				if UnitThreat == 3 then
					ThreatHealth40 = ThreatHealth40 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation40 = UnitRejuvenation40 + 1
				end
			end
			if UnitHealthScale <= 0.55 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health55 = Health55 + 1
				if UnitThreat == 3 then
					ThreatHealth55 = ThreatHealth55 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation55 = UnitRejuvenation55 + 1
				end
			end
			if UnitHealthScale <= 0.7 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health70 = Health70 + 1
				if UnitThreat == 3 then
					ThreatHealth70 = ThreatHealth70 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation70 = UnitRejuvenation70 + 1
				end
			end
			if UnitHealthScale <= 0.75 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health75 = Health75 + 1
				if UnitThreat == 3 then
					ThreatHealth75 = ThreatHealth75 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation75 = UnitRejuvenation75 + 1
				end
			end
			if UnitHealthScale <= 0.8 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health80 = Health80 + 1
				if UnitThreat == 3 then
					ThreatHealth80 = ThreatHealth80 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation80 = UnitRejuvenation80 + 1
				end
			end
			if UnitHealthScale <= 0.85 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health85 = Health85 + 1
				if UnitThreat == 3 then
					ThreatHealth85 = ThreatHealth85 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation85 = UnitRejuvenation85 + 1
				end
			end
			if UnitHealthScale <= 0.9 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health90 = Health90 + 1
				if UnitThreat == 3 then
					ThreatHealth90 = ThreatHealth90 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation90 = UnitRejuvenation90 + 1
				end
			end
			if UnitHealthScale <= 0.95 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health95 = Health95 + 1
				if UnitThreat == 3 then
					ThreatHealth95 = ThreatHealth95 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation95 = UnitRejuvenation95 + 1
				end
			end
			if UnitHealthScale <= 0.99 and UnitHealthScale > 0 and not UnitIsDeadOrGhost(unitid) then
				Health99 = Health99 + 1
				if UnitThreat == 3 then
					ThreatHealth99 = ThreatHealth99 + 1
				end
				if UnitRejuvenation == "player" then
					UnitRejuvenation99 = UnitRejuvenation99 + 1
				end
			end
		end
		
		HealerEngine_GetAggro(unitid)
		--判断仇恨并缓存
		Restoration_GetDirectSingleHealItemCD(unitid)
		--判断单体治疗装备CD
		
		--if CheckInteractDistance(unitid, 2) and GetUnitSpeed(unitid) == 0 then
			--TradeDistanceUnit = TradeDistanceUnit + 1
		--end
		--交易距离内目标检测-地心之战版本中战斗中已经无法获取正确值
		--if CheckInteractDistance(unitid, 4) then
			--FollowDistanceUnit = FollowDistanceUnit + 1
		--end
		--跟随距离内目标检测-地心之战版本中战斗中已经无法获取正确值
	
		HealerEngineHeals_HealBreakoutSpellUnitID = nil
		HealerEngine_GetHealAuras(unitid) -- 判断有无需要治疗Auras
		HealerEngine_GetHealAurasLow(unitid) -- 判断有无需要轻度治疗Auras
		HealerEngine_GetHealAurasWarn(unitid) -- 判断有无急需要治疗Auras
		
		UnitHasCastLifebloomUnitid = nil
		if select(7, AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL")) == "player" then
			UnitHasCastLifebloom = 1
			UnitHasCastLifebloomCount = UnitHasCastLifebloomCount + 1
			UnitHasCastLifebloomUnitid = unitid
		elseif not RestorationSaves.RestorationOption_Heals_AllRejuvenation and not RestorationHeals_Innervate and not RestorationHeals_DynamicHealOfBoss and not HealerEngineHeals_AdvanceRejuvenation and not Restoration_AffixesCrackUnitDying and not RestorationHeals_TimeConversionLowTime then
			if not NotRestorationHeals_UnitHasCastLifebloom and not HealerEngineHeals_HealAurasUnitID and not HealerEngineHeals_HealAurasLowHigh and not HealerEngineHeals_HealAurasWarnUnitID then
			--在已施放完生命绽放,没有需要治疗Auras,没有需要轻度治疗Auras,没有急需要治疗Auras的情况下,判断过量治疗
				if UnitGetIncomingHeals(unitid) > UnitHealthDeficit * 1.25 then
					--目标即将受到的治疗大于损失的血量的1.25倍则无视该目标
					--print(unitid)
					return
				end
				if (RestorationSaves.RestorationOption_Effect == 3 or (RestorationHeals_LowMana and RestorationSaves.RestorationOption_Effect ~= 1)) then
					if UnitHealthScale > 0.7 and UnitGetIncomingHeals(unitid) > UnitHealthMax("player") * 0.1 * (1 - UnitHealthScale) then
						--print(unitid)
						return
					end
				end
			end
		end
		if DamagerEngine_TankAssignedHasThreat and UnitHasCastLifebloomUnitid and RestorationSaves.RestorationOption_Effect ~= 3 and not RestorationHeals_LowMana and (UnitHasCastLifebloomCount < 2 or IsPlayerSpell(392301)) then
		--队伍中有坦克处于仇恨状态时,该单位有生命绽放
			local status = UnitThreatSituation(unitid)
			if not status or (status and status < 2) then
			--如果该生命绽放单位没有仇恨，则对其他单位进行判断,以便重新施放生命绽放
				UnitHasCastLifebloom = nil
			end
		end
		
		if IsInGroup() and not IsInRaid() and DA_GetHasActiveAffix('受难') then
			local SpecialUnitID, Cont = DA_GetHealsSpecialExists('受难之魂')
			if UnitName(unitid) == '受难之魂' and SpecialUnitID and Cont == 1 and UnitCastingInfo(unitid) then
				--只有一个[受难之魂]
				local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
				local remainingCastTime = endTime/1000 - GetTime()
				--print('[受难之魂]施法剩余时间: '..remainingCastTime)
				--print('自然之愈CD时间: '..Restoration_NatureCureCD_RemainingCooldown)
				if Restoration_NatureCureCD_RemainingCooldown < remainingCastTime - 1.5 and UnitHealthScale < 0.5 then
				--自然之愈CD时间 < [受难之魂]施法时间 - 1.5秒,且[受难之魂]血量小于50%,则不进行治疗,等自然之愈CD好了直接驱散
					--print('不治疗[受难之魂],等待直接驱散')
					return
				end
			end
		end
		RestorationStatusLhh:SetUnit(unitid, IsSpecialHealsUnit)
	else
		if UnitIsDeadOrGhost(unitid) then
			Restoration_UnitIsDeadOrGhost = 1
		end
	end
end

function Restoration_ScanUnitAuras()
	--DEBUFF驱散
	local Cache = RestorationHeals_HealsUnitCache or {}
	if #Cache > 0 then
		table.sort(Cache, function(a, b) return a.UnitHealth < b.UnitHealth end)
		--血量从低到高排序
	end
	for k, v in ipairs(Cache) do
		Restoration_ClearUnitAuras(v.Unit)
	end
	Cache = nil
end
		
function Restoration_CheckEfflorescence()
	--百花齐放施法检测
	Restoration_LastEfflorescenceHealTime = Restoration_LastEfflorescenceHealTime or 0
	if not Restoration_Cast_Success_Efflorescence and (GetTime() - Restoration_LastEfflorescenceHealTime > 3 or not AuraUtil.FindAuraByName('百花齐放', "player", "HELPFUL")) then
		--如果玩家没有施放百花齐放,且超过3秒没有受到玩家自己的百花齐放治疗或者没有施放
		--print("可以施放[百花齐放]")
		return true
	else
		return false
	end
end
		
function Restoration_GetGrove_GuardiansNumber()
	--获取当前林莽卫士数量
	local number = 0
	for i = 1, 5 do
		if GetTotemTimeLeft(i) > 2.5 then
			number = number + 1
		end
	end
	return number
end
		
function Restoration_GetHealBurstingAfflictedSoul(unitid, Cont)
	--获取是否治疗[受难之魂]
	local HealBursting = false
	if Cont == 2 then
		--存在2个[受难之魂]
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
		local remainingCastTime = endTime and endTime/1000 - GetTime()
		--print('[受难之魂]施法剩余时间: '..remainingCastTime)
		if select(7, AuraUtil.FindAuraByName('回春术', unitid, "HELPFUL")) == "player" and remainingCastTime and remainingCastTime > 4 then
			--焦点目标的[受难之魂]已有玩家施放的[回春术],且[受难之魂]施法剩余时间大于4秒,则直接刷爆,把驱散留给另一个[受难之魂]
			HealBursting = true
		end
	elseif Cont == 1 then
		--存在1个[受难之魂]
		local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
		local remainingCastTime = endTime and endTime/1000 - GetTime()
		local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
		--print('[受难之魂]施法剩余时间: '..remainingCastTime)
		if select(7, AuraUtil.FindAuraByName('回春术', unitid, "HELPFUL")) == "player"  and UnitHealthScale >= 0.5 and remainingCastTime and remainingCastTime > 4 then
			--焦点目标的[受难之魂]已有玩家施放的[回春术],且[受难之魂]血量大于50%,且施法剩余时间大于4秒,则直接刷爆
			HealBursting = true
		end
	end
	return HealBursting
end

function Restoration_HeartOfTheWildDPS_GetNeedHeals()
--判断是否需要治疗
	if #HealsUnitPriority == 0 or RestorationHeals_DoNotHealsLowMana then
		return false
	elseif IsInRaid() then
	--团队
		if Restoration_StarsurgeCanRisingMana() or Restoration_CrackArenaUnitDying() then
		--星涌术回蓝或者有竞技场敌方目标即将死亡
			if Health55 >= 1 then
				return true
			else
				return false
			end
		else
			if Health85 >= 1 then
				return true
			else
				return false
			end
		end
	else
	--小队
		if AuraUtil.FindAuraByName('野性之心', "player", "HELPFUL") then
		--有野性之心BUFF
			if Restoration_StarsurgeCanRisingMana() or Restoration_CrackArenaUnitDying() then
			--星涌术回蓝或者有竞技场敌方目标即将死亡
				if Health55 >= 1 then
					return true
				else
					return false
				end
			else
				if Health75 >= 1 then
					return true
				else
					return false
				end
			end
		else
		--无野性之心BUFF
			if Restoration_StarsurgeCanRisingMana() or Restoration_CrackArenaUnitDying() then
			--星涌术回蓝或者有竞技场敌方目标即将死亡
				if Health55 >= 1 then
					return true
				else
					return false
				end
			else
				if Health80 >= 1 then
					return true
				else
					return false
				end
			end
		end
	end
end

function Restoration_StarsurgeCanRisingMana()
--获取星涌术是否可以使用并回蓝
	if UnitPower("player", 0) / UnitPowerMax("player", 0) >= 0.95 then return false end
	if IsPlayerSpell(197626) and DA_IsUsableSpell(197626) and not StarsurgeCD and IsPlayerSpell(289237) then
		return true
	else
		return false
	end
end

function Restoration_HeartOfTheWildDPS()
	--自动输出
	
	if (#HealsUnitPriority == 0 or RestorationHeals_DoNotHealsLowMana or Restoration_StarsurgeCanRisingMana() or Restoration_CrackArenaUnitDying() or (AuraUtil.FindAuraByName('野性之心', "player", "HELPFUL") and Health75 == 0) or (Health80 == 0 and not RestorationSaves.RestorationOption_Heals_AllRejuvenation and not HealerEngineHeals_AdvanceRejuvenation and not Restoration_AffixesCrackUnitDying)) and not LifebloomTarget_In_HealsUnitPriority and not RestorationAutoDPSTargetNotVisible and (not RestorationSaves.RestorationOption_Heals_HealTank or (IsPlayerSpell(392410) and IsPlayerSpell(102351))) then

		Restoration_HeartOfTheWildDPSTarget_Balance = nil
		Restoration_AutoDPS_SunfireTarget = nil
		Restoration_AutoDPS_MoonfireTarget = nil
		Restoration_AutoDPS_MoonfireTargetMoveing = nil
		
		if not IsActiveBattlefieldArena() and not IsInRaid() then
		--竞技场中或者团队人数大于8人,则不使用月火术和阳炎术
			for k, v in ipairs(Restoration_EnemyCache) do
				if not DamagerEngineGetNoAttackAuras(v.Unit) then
					--获取不攻击BUFF
					if #Restoration_EnemyCache <= 3 or IsPlayerSpell(231050) then
						if not Restoration_AutoDPS_SunfireTarget and IsPlayerSpell(93402) and select(7, AuraUtil.FindAuraByName('阳炎术', v.Unit, "HARMFUL")) ~= "player" and ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.5) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 1 or not IsInInstance() or NumGroupMembers <= 3) then
							--print("阳炎术 - "..v.UnitName)
							Restoration_AutoDPS_SunfireTarget = v.Unit
							--阳炎术目标
							break
						end
					end
					if #Restoration_EnemyCache <= 3 then
						if not Restoration_AutoDPS_MoonfireTarget and IsPlayerSpell(8921) and select(7, AuraUtil.FindAuraByName('月火术', v.Unit, "HARMFUL")) ~= "player" and ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.05) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 1 or not IsInInstance() or NumGroupMembers <= 3) then
							--print("月火术 - "..v.UnitName)
							Restoration_AutoDPS_MoonfireTarget = v.Unit
							--月火术目标
							break
						end
					end
					if Restoration_CanNotMovingCast() then
						if not Restoration_AutoDPS_MoonfireTargetMoveing and IsPlayerSpell(8921) and select(7, AuraUtil.FindAuraByName('月火术', v.Unit, "HARMFUL")) ~= "player" and ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.05) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 1 or not IsInInstance() or NumGroupMembers <= 3) then
							--print("月火术 - "..v.UnitName)
							Restoration_AutoDPS_MoonfireTargetMoveing = v.Unit
							--月火术(移动状态)目标
							break
						end
					end
				end
			end
		end
		
		for k, v in ipairs(Restoration_EnemyCache) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) then
				--获取不攻击BUFF
				if WoWAssistantUnlocked then
				--EasyWoWToolbox或者FireHack已载入
					if DA_GetFacing("player", v.Unit) then
					--判断玩家是否面对目标
						if ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.05) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 0.2 or not IsInInstance() or NumGroupMembers <= 3) then
							--print("循环输出目标 - "..v.UnitName)
							Restoration_HeartOfTheWildDPSTarget_Balance = v.Unit
							--攻击目标
							break
						end
					end
				else
					if ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.05) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 0.2 or not IsInInstance() or NumGroupMembers <= 3) then
						--print("循环输出目标 - "..v.UnitName)
						Restoration_HeartOfTheWildDPSTarget_Balance = v.Unit
						--攻击目标
						break
					end
				end
			end
		end
		
		for k, v in ipairs(Restoration_EnemyCacheS2) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) then
			--获取不攻击BUFF、判断目标是否可以攻击
				if WoWAssistantUnlocked then
				--EasyWoWToolbox或者FireHack已载入
					if DA_GetFacing("player", v.Unit) then
						--print("循环输出目标 - "..v.UnitName)
						Restoration_HeartOfTheWildDPSTarget_Balance = v.Unit
						--先打血高的特殊目标(非单体输出,可AOE)
						break
					end
				else
					--print("循环输出目标 - "..v.UnitName)
					Restoration_HeartOfTheWildDPSTarget_Balance = v.Unit
					--先打血高的特殊目标(非单体输出,可AOE)
					break
				end
			end
		end
		
		for k, v in ipairs(Restoration_EnemyCacheS3) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) then
			--获取不攻击BUFF、判断目标是否可以攻击
				if WoWAssistantUnlocked then
				--EasyWoWToolbox或者FireHack已载入
					if DA_GetFacing("player", v.Unit) then
						--print("循环输出目标 - "..v.UnitName)
						Restoration_HeartOfTheWildDPSTarget_Balance = v.Unit
						--先打血低的特殊目标(非单体输出,可AOE)
						break
					end
				else
					--print("循环输出目标 - "..v.UnitName)
					Restoration_HeartOfTheWildDPSTarget_Balance = v.Unit
					--先打血低的特殊目标(非单体输出,可AOE)
					break
				end
			end
		end
		
		Restoration_HeartOfTheWildDPSTarget_Feral = nil
		for k, v in ipairs(Restoration_EnemyCacheInMelee) do
			if not DamagerEngineGetNoAttackAuras(v.Unit) then
				--获取不攻击BUFF
				if WoWAssistantUnlocked then
				--EasyWoWToolbox或者FireHack已载入
					if DA_GetFacing("player", v.Unit) then
					--判断玩家是否面对目标
						DamagerEngineGetSinglePriorityUnit(v.Unit)
						--获取优先击杀目标
						if DamagerEngine_AutoDPS_SinglePriorityTatgetExists then
						--优先击杀目标,单体输出,不AOE
							Restoration_HeartOfTheWildDPSTarget_Feral = DamagerEngine_AutoDPS_DPSTarget
							break
						elseif ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.05) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 0.2 or not IsInInstance() or NumGroupMembers <= 3) then
							Restoration_HeartOfTheWildDPSTarget_Feral = v.Unit
							--攻击目标
							break
						end
					end
				else
					DamagerEngineGetSinglePriorityUnit(v.Unit)
					--获取优先击杀目标
					if DamagerEngine_AutoDPS_SinglePriorityTatgetExists then
					--优先击杀目标,单体输出,不AOE
						Restoration_HeartOfTheWildDPSTarget_Feral = DamagerEngine_AutoDPS_DPSTarget
						break
					elseif ((UnitHealthMax(v.Unit) - UnitHealth(v.Unit) > UnitHealthMax("player") * 0.05) or not IsInInstance() or NumGroupMembers <= 3) and (UnitHealth(v.Unit) > UnitHealthMax("player") * 0.2 or not IsInInstance() or NumGroupMembers <= 3) then
						Restoration_HeartOfTheWildDPSTarget_Feral = v.Unit
						--攻击目标
						break
					end
				end
			end
		end
		
		if Restoration_HeartOfTheWildDPSTarget_Balance then
			--print("人形态循环输出目标 - "..UnitName(Restoration_HeartOfTheWildDPSTarget_Balance))
		end
		
		if Restoration_HeartOfTheWildDPSTarget_Feral then
			--print("猎豹形态循环输出目标 - "..UnitName(Restoration_HeartOfTheWildDPSTarget_Feral))
		end
		
		local ComboPoints = 0
		if Restoration_HeartOfTheWildDPSTarget_Balance then
			ComboPoints = GetComboPoints("player",Restoration_HeartOfTheWildDPSTarget_Balance)
		elseif Restoration_HeartOfTheWildDPSTarget_Feral then
			ComboPoints = GetComboPoints("player",Restoration_HeartOfTheWildDPSTarget_Feral)
		end
		local PlayerPowerNow = 0
		local PlayerPowerMaximum = 0
		local PlayerPowerScale = 0
		local PlayerPowerVacancy = 0
		PlayerPowerNow = UnitPower("player", 3)
		PlayerPowerMaximum = UnitPowerMax("player", 3)
		PlayerPowerScale = PlayerPowerNow / PlayerPowerMaximum
		PlayerPowerVacancy = PlayerPowerMaximum - PlayerPowerNow
		
		if GetShapeshiftFormID() ~= 1 and not AuraUtil.FindAuraByName('化身', "player", "HELPFUL") and DA_Clear_Rooted and Restoration_HeartOfTheWildDPSTarget_Feral and (PlayerPowerScale >= 0.9 or (Restoration_CanNotMovingCast() and StarsurgeCD)) and ((not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget) or RestorationHeals_DoNotDPSLowMana) and not Restoration_StarsurgeCanRisingMana() and not Restoration_CrackArenaUnitDying() and not C_PvP.IsActiveBattlefield() and not IsInRaid() and not UnitExists('boss1') then
			if IsPlayerSpell(449193) then
			--学习了[自如变形]天赋
				DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
				if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
					DA_CastSpellByID(5221)
				end
				RestorationSpellWillBeCast = 1
				RestorationDPSSpellWillBeCast = 1
				Restoration_SetDebugInfo("撕碎")
				--print("技能:撕碎")
			else
				DA_CastSpellByID(768)
				RestorationSpellWillBeCast = 1
				RestorationDPSSpellWillBeCast = 1
				Restoration_SetDebugInfo("猎豹形态")
				--print("技能:猎豹形态")
			end
		end
		
		if (not GetShapeshiftFormID() or GetShapeshiftFormID() == 2 or GetShapeshiftFormID() == 36) and GetShapeshiftFormID() ~= 1 and not RestorationHeals_DoNotHeals and UnitAffectingCombat("player") and not IsStealthed() and (not RestorationHeals_DoNotDPSLowMana or IsPlayerSpell(289237)) then
		--人形态自动输出
			if not RestorationAutoDPSTargetNotFacing and not RestorationAutoDPSTargetNotVisible then
				if Restoration_HeartOfTheWildDPSTarget_Balance then
				--判断玩家目标是否可以攻击
					local UseWrathStarfire = nil
					local PlayerPowerScale = UnitPower("player", 0) / UnitPowerMax("player", 0)
					local TargetHealth = UnitHealth(Restoration_HeartOfTheWildDPSTarget_Balance)
					local TargetHealthMax = UnitHealthMax(Restoration_HeartOfTheWildDPSTarget_Balance)
					local TargetHealthScale = TargetHealth / TargetHealthMax
					
					if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (Restoration_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 150 * SDPHR or Restoration_Enemy_SumHealth == 0.9527) then
						Restoration_HeartOfTheWildDPS_SumHealthControl = nil
					else
						Restoration_HeartOfTheWildDPS_SumHealthControl = 1
					end
					if not HeartOfTheWildCD and IsPlayerSpell(319454) and not name_HeartOfTheWild and not Restoration_HeartOfTheWildDPS_SumHealthControl and not Restoration_NoUsePowerfulSpell and (not RestorationHeals_DoNotDPSLowMana or IsPlayerSpell(289237)) then
						DA_CastSpellByName('野性之心')
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("野性之心")
						--print("技能:野性之心")
					end
					--野性之心
					
					if not StarsurgeCD and IsPlayerSpell(197626) and DA_IsUsableSpell(197626) and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and (not RestorationHeals_DoNotDPSLowMana or IsPlayerSpell(289237)) then
						DeBuffCheck = nil
						
						if IsInRaid() then
						--团队中
							if IsPlayerSpell(289237) and PlayerPowerScale < 0.975 and (not RestorationHeals_DynamicHealOfBoss or #HealsUnitPriority <= 0 or RestorationSaves.RestorationOption_Effect == 3) then
							--学习了[变形大师]输出回蓝天赋,且蓝量不高于97.5%,且(无需泄蓝,或没有玩家需要治疗,或省蓝模式)
								DeBuffCheck = 1
							end
						else
						--非团队中
							DeBuffCheck = 1
						end
						
						if DeBuffCheck then
							DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Balance)
							if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Balance) then
								DA_CastSpellByID(197626)
							end
							RestorationSpellWillBeCast = 1
							RestorationDPSSpellWillBeCast = 1
							Restoration_SetDebugInfo("星涌术")
							--print("技能:星涌术")
						end
					end
					--星涌术
					
					if DA_IsUsableSpell(93402) and IsPlayerSpell(93402) and Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTargetS and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not RestorationHeals_DoNotDPSLowMana then
						DeBuffCheck = nil
						
						DeBuffCheck = 1
						
						if DeBuffCheck then
							DA_TargetUnit(Restoration_AutoDPS_SunfireTarget)
							if UnitIsUnit('target', Restoration_AutoDPS_SunfireTarget) then
								DA_CastSpellByID(93402)
							end
							RestorationSpellWillBeCast = 1
							RestorationDPSSpellWillBeCast = 1
							Restoration_SetDebugInfo("阳炎术")
							--print("技能:阳炎术")
						end
					end
					--阳炎术
					
					if DA_IsUsableSpell(8921) and IsPlayerSpell(8921) and Restoration_AutoDPS_MoonfireTarget and not Restoration_AutoDPS_MoonfireTargetS and not Restoration_AutoDPS_SunfireTarget and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not RestorationHeals_DoNotDPSLowMana then
						DeBuffCheck = nil
						
						DeBuffCheck = 1
						
						if DeBuffCheck then
							DA_TargetUnit(Restoration_AutoDPS_MoonfireTarget)
							if UnitIsUnit('target', Restoration_AutoDPS_MoonfireTarget) then
								DA_CastSpellByID(8921)
							end
							RestorationSpellWillBeCast = 1
							RestorationDPSSpellWillBeCast = 1
							Restoration_SetDebugInfo("月火术")
							--print("技能:月火术")
						end
					end
					--月火术
					
					if DA_IsUsableSpell(8921) and IsPlayerSpell(8921) and Restoration_AutoDPS_MoonfireTargetMoveing and not Restoration_AutoDPS_MoonfireTargetS and not Restoration_AutoDPS_SunfireTarget and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not RestorationHeals_DoNotDPSLowMana then
						DeBuffCheck = nil
						
						DeBuffCheck = 1
						
						if DeBuffCheck then
							DA_TargetUnit(Restoration_AutoDPS_MoonfireTargetMoveing)
							if UnitIsUnit('target', Restoration_AutoDPS_MoonfireTargetMoveing) then
								DA_CastSpellByID(8921)
							end
							RestorationSpellWillBeCast = 1
							RestorationDPSSpellWillBeCast = 1
							Restoration_SetDebugInfo("月火术")
							--print("技能:月火术")
						end
					end
					--月火术(移动状态)
					
					if IsInRaid() then
					--团队中
						if IsPlayerSpell(289237) and PlayerPowerScale < 0.95 and (not RestorationHeals_DynamicHealOfBoss or PlayerPowerScale <= 0.35 or #HealsUnitPriority <= 0 or not IsPlayerSpell(197626) or RestorationSaves.RestorationOption_Effect == 3) then
						--学习了[变形大师]输出回蓝天赋,且蓝量不高于95%,且(无需泄蓝,或蓝量低于35%,或没有玩家需要治疗,或没有学习[星涌术],或省蓝模式)
							UseWrathStarfire = 1
						end
					else
					--非团队中
						UseWrathStarfire = 1
					end
					if UseWrathStarfire then
					--使用愤怒及星火术
						if ((#Restoration_EnemyCache <= 3 or Restoration_CrackArenaUnitDying() or (RestorationHeals_DoNotDPSLowMana and IsPlayerSpell(289237)) or (select(4, DA_GetSpellInfo('愤怒')) == 0 and C_PvP.IsActiveBattlefield())) and select(4, DA_GetSpellInfo('星火术')) ~= 0 and not WrathCD) or not IsPlayerSpell(197628) then
						--3个及以下目标且星火术不是瞬发状态且愤怒没有CD,或者没有学习星火术
							if DA_IsUsableSpell(5176) and IsPlayerSpell(5176) and ((not Restoration_AutoDPS_MoonfireTarget and not Restoration_AutoDPS_MoonfireTargetS and not Restoration_AutoDPS_SunfireTarget) or (RestorationHeals_DoNotDPSLowMana and IsPlayerSpell(289237))) and not RestorationAutoDPSTargetNotFacing and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('愤怒')) == 0) and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast then
								DeBuffCheck = nil
								
								DeBuffCheck = 1
								
								if DeBuffCheck then
									DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Balance)
									if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Balance) then
										DA_CastSpellByID(5176)
									end
									RestorationSpellWillBeCast = 1
									RestorationDPSSpellWillBeCast = 1
									Restoration_SetDebugInfo("愤怒")
									--print("技能:愤怒")
								end
							end
							--愤怒
						else
						--4个及以上目标
							if DA_IsUsableSpell(197628) and IsPlayerSpell(197628) and ((not Restoration_AutoDPS_MoonfireTarget and not Restoration_AutoDPS_MoonfireTargetS and not Restoration_AutoDPS_SunfireTarget) or (RestorationHeals_DoNotDPSLowMana and IsPlayerSpell(289237))) and not RestorationAutoDPSTargetNotFacing and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or select(4, DA_GetSpellInfo('星火术')) == 0) and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast then
								DeBuffCheck = nil
								
								DeBuffCheck = 1
								
								if DeBuffCheck then
									DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Balance)
									if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Balance) then
										DA_CastSpellByID(197628)
									end
									RestorationSpellWillBeCast = 1
									RestorationDPSSpellWillBeCast = 1
									Restoration_SetDebugInfo("星火术")
									--print("技能:星火术")
								end
							end
							--星火术
						end
					end
				end
			end
		end
		
		if GetShapeshiftFormID() == 1 and UnitAffectingCombat("player") and Restoration_HeartOfTheWildDPSTarget_Feral then
		--猎豹形态自动输出
			local TargetHealth = UnitHealth(Restoration_HeartOfTheWildDPSTarget_Feral)
			local TargetHealthMax = UnitHealthMax(Restoration_HeartOfTheWildDPSTarget_Feral)
			local TargetHealthScale = TargetHealth / TargetHealthMax
			
			if not RestorationAutoDPSTargetNotFacing and not RestorationAutoDPSTargetNotVisible then
				
				name_HeartOfTheWild, icon_HeartOfTheWild, count_HeartOfTheWild, dispelType_HeartOfTheWild, duration_HeartOfTheWild, expires_HeartOfTheWild, caster_HeartOfTheWild, isStealable_HeartOfTheWild, nameplateShowPersonal_HeartOfTheWild, spellID_HeartOfTheWild = AuraUtil.FindAuraByName('野性之心', "player", "HELPFUL")
				--野性之心
				name_Rake, icon_Rake, count_Rake, dispelType_Rake, duration_Rake, expires_Rake, caster_Rake, isStealable_Rake, nameplateShowPersonal_Rake, spellID_Rake = AuraUtil.FindAuraByName('斜掠', Restoration_HeartOfTheWildDPSTarget_Feral, "HARMFUL")
				--斜掠
				if select(7, AuraUtil.FindAuraByName('斜掠', Restoration_HeartOfTheWildDPSTarget_Feral, "HARMFUL")) ~= "player" then
					name_Rake, icon_Rake, count_Rake, dispelType_Rake, duration_Rake, expires_Rake, caster_Rake, isStealable_Rake, nameplateShowPersonal_Rake, spellID_Rake = nil
				end
				name_Rip, icon_Rip, count_Rip, dispelType_Rip, duration_Rip, expires_Rip, caster_Rip, isStealable_Rip, nameplateShowPersonal_Rip, spellID_Rip = AuraUtil.FindAuraByName('割裂', Restoration_HeartOfTheWildDPSTarget_Feral, "HARMFUL")
				--割裂
				if select(7, AuraUtil.FindAuraByName('割裂', Restoration_HeartOfTheWildDPSTarget_Feral, "HARMFUL")) ~= "player" then
					name_Rip, icon_Rip, count_Rip, dispelType_Rip, duration_Rip, expires_Rip, caster_Rip, isStealable_Rip, nameplateShowPersonal_Rip, spellID_Rip = nil
				end
				name_Thrash, icon_Thrash, count_Thrash, dispelType_Thrash, duration_Thrash, expires_Thrash, caster_Thrash, isStealable_Thrash, nameplateShowPersonal_Thrash, spellID_Thrash = AuraUtil.FindAuraByName('痛击', Restoration_HeartOfTheWildDPSTarget_Feral, "HARMFUL")
				--痛击
				timeLeft_Thrash = expires_Thrash and expires_Thrash > GetTime() and (expires_Thrash - GetTime()) or 0
				--痛击DEBUFF剩余时间
				if select(7, AuraUtil.FindAuraByName('痛击', Restoration_HeartOfTheWildDPSTarget_Feral, "HARMFUL")) ~= "player" or timeLeft_Thrash <= 3 then
					name_Thrash, icon_Thrash, count_Thrash, dispelType_Thrash, duration_Thrash, expires_Thrash, caster_Thrash, isStealable_Thrash, nameplateShowPersonal_Thrash, spellID_Thrash = nil
				end
		
				if UnitExists("boss1") or C_PvP.IsActiveBattlefield() or (Restoration_Enemy_SumHealth > UnitHealthMax("player") * #DamagerEngine_DamagerAssigned * 150 * SDPHR or Restoration_Enemy_SumHealth == 0.9527) then
					Restoration_HeartOfTheWildDPS_SumHealthControl = nil
				else
					Restoration_HeartOfTheWildDPS_SumHealthControl = 1
				end
				if not HeartOfTheWildCD and IsPlayerSpell(319454) and not name_HeartOfTheWild and not Restoration_HeartOfTheWildDPS_SumHealthControl and not Restoration_NoUsePowerfulSpell and not IsStealthed() then
					DA_CastSpellByName('野性之心')
					RestorationSpellWillBeCast = 1
					RestorationDPSSpellWillBeCast = 1
					Restoration_SetDebugInfo("野性之心")
					--print("技能:野性之心")
				end
				--野性之心
				
				if DA_IsUsableSpell(22568) and IsPlayerSpell(22568) and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not IsStealthed() then
					PowerCheck = nil
					ComboPointsCheck = nil
					DeBuffCheck = nil
					
					if PlayerPowerNow >= 25 then
						PowerCheck = 1
					end
					
					if (ComboPoints >= 5) 
					or (TargetHealth < UnitHealthMax("player") * 0.075 and ComboPoints >= 3)  then
					--血量小于玩家最大血量的7.5%且连击点大于等于3
						ComboPointsCheck = 1
					end
					
					if (caster_Rip == "player" and (expires_Rip and expires_Rip - GetTime() > 5)) 
					--割裂
					or not IsPlayerSpell(1079) 
					or TargetHealth < UnitHealthMax("player") * 0.075 then
					--目标血量低
						DeBuffCheck = 1
					end
					
					if PowerCheck and ComboPointsCheck and DeBuffCheck then
						DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
						if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
							DA_CastSpellByID(22568)
						end
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("凶猛撕咬")
						--print("技能:凶猛撕咬")
					end
				end
				--凶猛撕咬
				
				if DA_IsUsableSpell(1079) and IsPlayerSpell(1079) and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not IsStealthed() then
					PowerCheck = nil
					ComboPointsCheck = nil
					DeBuffCheck = nil
					
					PowerCheck = 1
					
					if ComboPoints >= 5 then
						ComboPointsCheck = 1
					end
					
					if not name_Rip or (expires_Rip and expires_Rip - GetTime() < 2) then
						DeBuffCheck = 1
					end
					
					if PowerCheck and ComboPointsCheck and DeBuffCheck then
						DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
						if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
							DA_CastSpellByID(1079)
						end
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("割裂")
						--print("技能:割裂")
					end
				end
				--割裂
				
				if DA_IsUsableSpell(1822) and IsPlayerSpell(1822) and #Restoration_EnemyCacheIn7 <= 2 and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast then
					PowerCheck = nil
					ComboPointsCheck = nil
					DeBuffCheck = nil
					
					PowerCheck = 1
					
					if ComboPoints < 5 or IsStealthed() then
						ComboPointsCheck = 1
					end
					
					if not name_Rake or (expires_Rake and expires_Rake - GetTime() < 2) then
						DeBuffCheck = 1
					end
					
					if PowerCheck and ComboPointsCheck and DeBuffCheck then
						DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
						if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
							DA_CastSpellByID(1822)
						end
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("斜掠")
						--print("技能:斜掠")
					end
				end
				--斜掠
				
				if DA_IsUsableSpell(106830) and IsPlayerSpell(106832) and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not IsStealthed() then
					PowerCheck = nil
					ComboPointsCheck = nil
					DeBuffCheck = nil

					if PlayerPowerNow >= 40 then
						PowerCheck = 1
					end
					
					if ComboPoints < 5 then
						ComboPointsCheck = 1
					end
					
					if not name_Thrash 
					and ((name_Rake and #Restoration_EnemyCacheIn7 <= 2)
					or #Restoration_EnemyCacheIn7 >= 3) then
						DeBuffCheck = 1
					end
					if PowerCheck and ComboPointsCheck and DeBuffCheck then
						DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
						if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
							DA_CastSpellByID(106830)
						end
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("痛击")
						--print("技能:痛击")
					end
				end
				--痛击
				
				if DA_IsUsableSpell(106785) and #Restoration_EnemyCacheIn7 >= 2 and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast and not IsStealthed() then
					PowerCheck = nil
					ComboPointsCheck = nil
					DeBuffCheck = nil

					if PlayerPowerNow >= 35 then
						PowerCheck = 1
					end
					
					if ComboPoints < 5 then
						ComboPointsCheck = 1
					end
					
					if (name_Rake and (name_Thrash or not IsPlayerSpell(106832)) and #Restoration_EnemyCacheIn7 <= 2)
					or (#Restoration_EnemyCacheIn7 >= 3 and (name_Thrash or not IsPlayerSpell(106832))) then
						DeBuffCheck = 1
					end
					
					if PowerCheck and ComboPointsCheck and DeBuffCheck then
						DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
						if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
							DA_CastSpellByID(106785)
						end
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("横扫")
						--print("技能:横扫")
					end
				end
				--横扫
				
				if DA_IsUsableSpell(5221) and IsPlayerSpell(5221) and #Restoration_EnemyCacheIn7 <= 1 and not RestorationSpellWillBeCast and not RestorationDPSSpellWillBeCast then
					PowerCheck = nil
					ComboPointsCheck = nil
					DeBuffCheck = nil
					
					PowerCheck = 1
					
					if ComboPoints < 5 or PlayerPowerScale > 0.9 or IsStealthed() then
						ComboPointsCheck = 1
					end
					
					BuffCheck = 1
					
					if name_Rake or not IsPlayerSpell(1822) then
						DeBuffCheck = 1
					end
					
					if PowerCheck and ComboPointsCheck and DeBuffCheck then
						DA_TargetUnit(Restoration_HeartOfTheWildDPSTarget_Feral)
						if UnitIsUnit('target', Restoration_HeartOfTheWildDPSTarget_Feral) then
							DA_CastSpellByID(5221)
						end
						RestorationSpellWillBeCast = 1
						RestorationDPSSpellWillBeCast = 1
						Restoration_SetDebugInfo("撕碎")
						--print("技能:撕碎")
					end
				end
				--撕碎
			end
		end
	else
		if DA_IsCastingSpell(5176) or DA_IsCastingSpell(197628) then
		--需要治疗时,正在读条愤怒或星火术
			local CastTime = 0
			local _, _, _, startTime, endTime = UnitCastingInfo('player')
			CastTime = endTime and endTime/1000 - GetTime()
			--剩余施法时间
			if CastTime >= 0.5 then
				DA_SpellStopCasting()
				--中断施法
			end
		end
		if GetShapeshiftFormID() == 1 and not AuraUtil.FindAuraByName('急奔', "player", "HELPFUL") and DA_Clear_Rooted and not IsStealthed() and UnitAffectingCombat("player") and not C_PvP.IsActiveBattlefield() and not IsInRaid() and not UnitExists('boss1') then
			DA_Cancelform()
			--print('取消变形5')
		end
	end
	
		
	local ComboPoints = 0
	if Restoration_HeartOfTheWildDPSTarget_Balance then
		ComboPoints = GetComboPoints("player",Restoration_HeartOfTheWildDPSTarget_Balance)
	elseif Restoration_HeartOfTheWildDPSTarget_Feral then
		ComboPoints = GetComboPoints("player",Restoration_HeartOfTheWildDPSTarget_Feral)
	end
	if Restoration_HeartOfTheWildDPS_GetNeedHeals() or (UnitPower("player", 3) < 20 and ComboPoints < 5) or (#Restoration_EnemyCacheIn7 <= 0 and (Restoration_HeartOfTheWildDPSTarget_Balance or Restoration_AutoDPS_SunfireTarget or Restoration_AutoDPS_MoonfireTarget or Restoration_AutoDPS_MoonfireTargetMoveing)) then
		if GetShapeshiftFormID() == 1 and not AuraUtil.FindAuraByName('急奔', "player", "HELPFUL") and DA_Clear_Rooted and (not RestorationHeals_DoNotDPSLowMana or IsPlayerSpell(289237) or #Restoration_EnemyCacheIn7 <= 0) and (not Restoration_CanNotMovingCast() or (IsPlayerSpell(197626) and not StarsurgeCD) or ((Restoration_AutoDPS_SunfireTarget or Restoration_AutoDPS_MoonfireTarget or Restoration_AutoDPS_MoonfireTargetMoveing) and not RestorationHeals_DoNotDPSLowMana)) and not IsStealthed() and UnitAffectingCombat("player") and not C_PvP.IsActiveBattlefield() and not IsInRaid() and not UnitExists('boss1') then
			DA_Cancelform()
			--print('取消变形2')
		end
		--需要治疗,或7码范围内没有可攻击的敌对单位且有人形态可以攻击的单位
	end
end

Restoration:SetScript("OnEvent", Restoration_OnEvent)
Restoration:SetScript("OnUpdate", Restoration_OnUpdate)