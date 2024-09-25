--插件快捷键函数

function DA_UpdateBindingsText()
	BINDING_HEADER_WoWAssistant_Config = "设置"
	BINDING_NAME_WoWAssistant_Config = "打开设置菜单"
	BINDING_NAME_WoWAssistant_Start = "启动"
	BINDING_NAME_WoWAssistant_Stop = "停止"
	BINDING_NAME_WoWAssistant_Toggle = "切换启动/停止"
	BINDING_NAME_WoWAssistant_Replace = "切换目标设置或治疗效能设置"
	BINDING_NAME_WoWAssistant_Replace1 = "切换到智能目标或强力治疗"
	BINDING_NAME_WoWAssistant_Replace2 = "切换到手动目标或正常治疗"
	BINDING_NAME_WoWAssistant_Replace3 = "切换到所有目标或省蓝治疗"
    if DA_GetSpecialization() == 102 or DA_GetSpecialization() == 103 then
        --伤害输出专精
		BINDING_NAME_WoWAssistant_Replace = "切换目标设置"
		BINDING_NAME_WoWAssistant_Replace1 = "切换到智能选择目标"
		BINDING_NAME_WoWAssistant_Replace2 = "切换到手动选择目标"
		BINDING_NAME_WoWAssistant_Replace3 = "切换到所有目标模式"
    elseif DA_GetSpecialization() == 105 then
        --治疗专精
		BINDING_NAME_WoWAssistant_Replace = "切换治疗效能设置"
		BINDING_NAME_WoWAssistant_Replace1 = "切换到强力治疗效能"
		BINDING_NAME_WoWAssistant_Replace2 = "切换到正常治疗效能"
		BINDING_NAME_WoWAssistant_Replace3 = "切换到省蓝治疗效能"
    end
end

local DA_BindingsFrame = CreateFrame("Frame")
DA_BindingsFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
DA_BindingsFrame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
DA_BindingsFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
DA_BindingsFrame:SetScript("OnEvent", DA_UpdateBindingsText)

function DA_SlashCommands(DA)
	--插件设置命令
	DA = string.lower(DA)
	if DA_GetSpecialization() == 105 then
		--恢复
		if not RestorationOption then return end
		if not RestorationOption.ready then RestorationOption:Init() end
		if not RestorationOption:IsShown() then RestorationOption:Show() end
	elseif DA_GetSpecialization() == 103 then
		--野性
		if not FeralOption then return end
		if not FeralOption.ready then FeralOption:Init() end
		if not FeralOption:IsShown() then FeralOption:Show() end
	elseif DA_GetSpecialization() == 102 then
		--平衡
		if not BalanceOption then return end
		if not BalanceOption.ready then BalanceOption:Init() end
		if not BalanceOption:IsShown() then BalanceOption:Show() end
	else
		print("魔兽小助手暂不支持该专精。")
	end
end

SLASH_DA1 = "/da"
SlashCmdList["DA"] = DA_SlashCommands

--设置
function WoWAssistant_BeConfig()
	if DA_GetSpecialization() == 102 then
		if not BalanceOption then return end
		if not BalanceOption.ready then BalanceOption:Init() end
		if not BalanceOption:IsShown() then BalanceOption:Show() else BalanceOption:Hide() end
	end
	
	if DA_GetSpecialization() == 103 then
		if not FeralOption then return end
		if not FeralOption.ready then FeralOption:Init() end
		if not FeralOption:IsShown() then FeralOption:Show() else FeralOption:Hide() end
	end
	
	if DA_GetSpecialization() == 105 then
		if not RestorationOption then return end
		if not RestorationOption.ready then RestorationOption:Init() end
		if not RestorationOption:IsShown() then RestorationOption:Show() else RestorationOption:Hide() end
	end
end

--启动
function WoWAssistant_BeStart()
	if DA_GetSpecialization() ~= 102 and DA_GetSpecialization() ~= 103 and DA_GetSpecialization() ~= 105 then PlaySound(SOUNDKIT.IG_MAINMENU_OPEN) print("魔兽小助手暂不支持该专精。") return end
	
	if DA_GetSpecialization() == 102 then
	--平衡专精
		StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
			text = "请先开启Lua解锁器", 
			timeout = 3,
			exclusive = 1,
			whileDead = 1,
			hideOnEscape = 1
		}
		
		for i = 1, 5 do
			if _G["StaticPopup"..i] and _G["StaticPopup"..i]:IsShown() and _G["StaticPopup"..i].which == "ADDON_ACTION_FORBIDDEN" then
				StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
					text = ADDON_ACTION_FORBIDDEN, 
					button1 = DISABLE, 
					button2 = IGNORE_DIALOG, 
					OnAccept = function(self, data)
						DisableAddOn(data);
						ReloadUI();
					end, 
					timeout = 0, 
					exclusive = 1, 
					whileDead = 1, 
					hideOnEscape = 1
				}
				return
			end
		end
		
		StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = nil
		
		if not BalanceCycleStart then
		
			StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = nil
		
			PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
			
			BalanceCycleStart = 1
			DA_pixel_frame.texture:SetColorTexture(0.1, 0.9, 0.4)
			
			Balance_EnemyCacheS = {}
			Balance_EnemyCacheS2 = {}
			Balance_EnemyCacheS3 = {}
			Balance_EnemyCacheHasThreat = {}
			Balance_EnemyCache = {}
			Balance_FindEnemyCombatLogAttackMeUnitCache = {}
			Balance_TankAssigned = {}
			Balance_HealerAssigned = {}
			Balance_DamagerAssigned = {}
			Balance_Enemy_SumHealth = 0
			Balance_AutoDPS_MoonfireTargetS = nil
			Balance_AutoDPS_SunfireTarget = nil
			Balance_AutoDPS_MoonfireTarget = nil
			Balance_AutoDPS_DPSTarget = nil
			Balance_AutoDPS_DPSTarget2 = nil
			Balance_DoDPS = nil
			Balance_FindEnemyIntervalTime = nil
			
			if BalanceSaves.BalanceOption_Other_ShowDebug then
				if BalanceSaves.BalanceOption_TargetFilter == 2 and not BalanceCycleStartFlash then
					BalanceSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
				elseif BalanceSaves.BalanceOption_TargetFilter == 3 and not BalanceCycleStartFlash then
					BalanceSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
				elseif BalanceSaves.BalanceOption_TargetFilter == 1 and not BalanceCycleStartFlash then
					BalanceSwitchStatusText:SetTextColor(1, 0.55, 0.3)
				end
				BalanceSwitchStatusText:Show()
				C_Timer.After(0.15, function()
					BalanceSwitchStatusText:Hide()
				end)
				C_Timer.After(0.3, function()
					BalanceSwitchStatusText:Show()
				end)
				C_Timer.After(0.45, function()
					BalanceSwitchStatusText:Hide()
				end)
				C_Timer.After(0.55, function()
					BalanceSwitchStatusText:Show()
				end)
				C_Timer.After(0.65, function()
					BalanceSwitchStatusText:Show()
				end)
			elseif BalanceSwitchStatusText then
				BalanceSwitchStatusText:Hide()
			end
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
			text = "请先开启Lua解锁器", 
			timeout = 3,
			exclusive = 1,
			whileDead = 1,
			hideOnEscape = 1
		}
		
		for i = 1, 5 do
			if _G["StaticPopup"..i] and _G["StaticPopup"..i]:IsShown() and _G["StaticPopup"..i].which == "ADDON_ACTION_FORBIDDEN" then
				StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
					text = ADDON_ACTION_FORBIDDEN, 
					button1 = DISABLE, 
					button2 = IGNORE_DIALOG, 
					OnAccept = function(self, data)
						DisableAddOn(data);
						ReloadUI();
					end, 
					timeout = 0, 
					exclusive = 1, 
					whileDead = 1, 
					hideOnEscape = 1
				}
				return
			end
		end
		
		StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = nil
		
		if not FeralCycleStart then
		
			StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = nil
		
			PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
			
			FeralCycleStart = 1
			DA_pixel_frame.texture:SetColorTexture(0.1, 0.9, 0.4)
			
			Feral_Affixes_Crack = nil
			
			Feral_Enemy_SumHealth = 0
			
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
			Feral_MoonfireEnemyCacheHasThreat = {}
			Feral_FindEnemyCombatLogAttackMeUnitCache = {}
			
			Feral_TankAssigned = {}
			Feral_HealerAssigned = {}
			Feral_DamagerAssigned = {}
	
			Feral_AutoDPS_ShredTargetS = nil
			Feral_AutoDPS_RakeTargetS = nil
			Feral_AutoDPS_MoonfireTargetS = nil
			Feral_AutoDPS_RipTargetS = nil
			Feral_AutoDPS_DPSTarget = nil
			Feral_AutoDPS_SinglePriorityTatgetExists = nil
			FeralInterruptSpell = nil
			FeralInterruptSpellTarget = nil
			Feral_CastSpellIng = nil
			Feral_RipFlashWithFerociousBiteUnit = nil
			Feral_EnemyCacheHasThreatUnitDying = nil
			Feral_EnemyCount = 0
			
			Feral_DoDPS = nil
			Feral_FindEnemyIntervalTime = nil
			
			if FeralSaves.FeralOption_Other_ShowDebug then
				if FeralSaves.FeralOption_TargetFilter == 2 and not FeralCycleStartFlash then
					FeralSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
				elseif FeralSaves.FeralOption_TargetFilter == 3 and not FeralCycleStartFlash then
					FeralSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
				elseif FeralSaves.FeralOption_TargetFilter == 1 and not FeralCycleStartFlash then
					FeralSwitchStatusText:SetTextColor(0, 1, 1)
				end
				FeralSwitchStatusText:Show()
				C_Timer.After(0.15, function()
					FeralSwitchStatusText:Hide()
				end)
				C_Timer.After(0.3, function()
					FeralSwitchStatusText:Show()
				end)
				C_Timer.After(0.45, function()
					FeralSwitchStatusText:Hide()
				end)
				C_Timer.After(0.55, function()
					FeralSwitchStatusText:Show()
				end)
				C_Timer.After(0.65, function()
					FeralSwitchStatusText:Show()
				end)
			elseif FeralSwitchStatusText then
				FeralSwitchStatusText:Hide()
			end
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
			text = "请先开启Lua解锁器", 
			timeout = 3,
			exclusive = 1,
			whileDead = 1,
			hideOnEscape = 1
		}
		
		for i = 1, 5 do
			if _G["StaticPopup"..i] and _G["StaticPopup"..i]:IsShown() and _G["StaticPopup"..i].which == "ADDON_ACTION_FORBIDDEN" then
				StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
					text = ADDON_ACTION_FORBIDDEN, 
					button1 = DISABLE, 
					button2 = IGNORE_DIALOG, 
					OnAccept = function(self, data)
						DisableAddOn(data);
						ReloadUI();
					end, 
					timeout = 0, 
					exclusive = 1, 
					whileDead = 1, 
					hideOnEscape = 1
				}
				return
			end
		end
		
		StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = nil
		
		if not RestorationCycleStart then
		
			PlaySound(SOUNDKIT.IG_QUEST_LIST_OPEN)
			
			RestorationCycleStart = 1
			DA_pixel_frame.texture:SetColorTexture(0.1, 0.9, 0.4)
			
			RestorationHeals_SumHealthScaleTimelineCache = {}
			RestorationHeals_HealsUnitTimelineCache = {}
			
			if RestorationSaves.RestorationOption_Other_ShowCastlInfo then
				RestorationCycleStartFlash = 1
				RestorationSwitchStatusText:SetTextColor(0, 1, 0)
				RestorationSwitchStatusText:Show()
				C_Timer.After(0.15, function()
					RestorationSwitchStatusText:Hide()
				end)
				C_Timer.After(0.3, function()
					RestorationSwitchStatusText:Show()
				end)
				C_Timer.After(0.45, function()
					RestorationSwitchStatusText:Hide()
				end)
				C_Timer.After(0.55, function()
					RestorationSwitchStatusText:Show()
				end)
				C_Timer.After(0.65, function()
					RestorationSwitchStatusText:Show()
					RestorationCycleStartFlash = nil
				end)
			elseif RestorationSwitchStatusText then
				RestorationSwitchStatusText:Hide()
			end
		end
	end
end

--停止
function WoWAssistant_BeStop()
	if DA_GetSpecialization() == 102 then
	--平衡专精
		if BalanceCycleStart == 1 then
		
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
			
			BalanceCycleStart = nil
			DA_pixel_frame.texture:SetColorTexture(0.3, 0.4, 0.9)
			
			Balance_DeBugEnemyCount:Hide()
			Balance_DeBugSpellIcon:Hide()
			
			if BalanceSaves.BalanceOption_Other_ShowDebug then
				BalanceSwitchStatusText:SetTextColor(1, 0, 0)
				C_Timer.After(0.15, function()
					BalanceSwitchStatusText:Hide()
				end)
				C_Timer.After(0.3, function()
					BalanceSwitchStatusText:Show()
				end)
				C_Timer.After(0.45, function()
					BalanceSwitchStatusText:Hide()
				end)
				C_Timer.After(0.55, function()
					BalanceSwitchStatusText:Show()
				end)
				C_Timer.After(0.65, function()
					BalanceSwitchStatusText:Hide()
				end)
			elseif BalanceSwitchStatusText then
				BalanceSwitchStatusText:Hide()
			end
			
			StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
				text = ADDON_ACTION_FORBIDDEN, 
				button1 = DISABLE, 
				button2 = IGNORE_DIALOG, 
				OnAccept = function(self, data)
					DisableAddOn(data);
					ReloadUI();
				end, 
				timeout = 0, 
				exclusive = 1, 
				whileDead = 1, 
				hideOnEscape = 1
			}
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		if FeralCycleStart == 1 then
		
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
			
			FeralCycleStart = nil
			DA_pixel_frame.texture:SetColorTexture(0.3, 0.4, 0.9)
			
			Feral_DeBugEnemyCount:Hide()
			Feral_DeBugSpellIcon:Hide()
			
			StopAttack()
			
			if FeralSaves.FeralOption_Other_ShowDebug then
				FeralSwitchStatusText:SetTextColor(1, 0, 0)
				C_Timer.After(0.15, function()
					FeralSwitchStatusText:Hide()
					StopAttack()
				end)
				C_Timer.After(0.3, function()
					FeralSwitchStatusText:Show()
					StopAttack()
				end)
				C_Timer.After(0.45, function()
					FeralSwitchStatusText:Hide()
					StopAttack()
				end)
				C_Timer.After(0.55, function()
					FeralSwitchStatusText:Show()
					StopAttack()
				end)
				C_Timer.After(0.65, function()
					FeralSwitchStatusText:Hide()
					StopAttack()
				end)
			elseif FeralSwitchStatusText then
				FeralSwitchStatusText:Hide()
			end
			
			StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
				text = ADDON_ACTION_FORBIDDEN, 
				button1 = DISABLE, 
				button2 = IGNORE_DIALOG, 
				OnAccept = function(self, data)
					DisableAddOn(data);
					ReloadUI();
				end, 
				timeout = 0, 
				exclusive = 1, 
				whileDead = 1, 
				hideOnEscape = 1
			}
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		if RestorationCycleStart == 1 then
		
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION)
			
			RestorationCycleStart = nil
			DA_pixel_frame.texture:SetColorTexture(0.3, 0.4, 0.9)
			Swiftmend_CenarionWard = nil
			Swiftmend_CenarionWard_Sequence2 = nil
			
			Restoration_DeBugEnemyCount:Hide()
			Restoration_DeBugSpellIcon:Hide()
			
			StopAttack()
			
			for i=1, NUM_RAID_GROUPS do
				for j=1, MEMBERS_PER_RAID_GROUP do
					if IsInRaid() then
						if _G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"] then
							_G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"]:Hide()
						end
					elseif IsInGroup() then
						if _G["CompactPartyFrameMember"..j.."SpellIcon"] then
							_G["CompactPartyFrameMember"..j.."SpellIcon"]:Hide()
						end
					end
				end
			end
			for i=1, GetNumGroupMembers() do
				if _G["CompactRaidFrame"..i.."SpellIcon"] then
					_G["CompactRaidFrame"..i.."SpellIcon"]:Hide()
				end
			end
			
			if RestorationSaves.RestorationOption_Other_ShowCastlInfo then
				RestorationSwitchStatusText:SetTextColor(1, 0, 0)
				C_Timer.After(0.15, function()
					RestorationSwitchStatusText:Hide()
					StopAttack()
				end)
				C_Timer.After(0.3, function()
					RestorationSwitchStatusText:Show()
					StopAttack()
				end)
				C_Timer.After(0.45, function()
					RestorationSwitchStatusText:Hide()
					StopAttack()
				end)
				C_Timer.After(0.55, function()
					RestorationSwitchStatusText:Show()
					StopAttack()
				end)
				C_Timer.After(0.65, function()
					RestorationSwitchStatusText:Hide()
					StopAttack()
				end)
			elseif RestorationSwitchStatusText then
				RestorationSwitchStatusText:Hide()
			end
			
			StaticPopupDialogs["ADDON_ACTION_FORBIDDEN"] = {
				text = ADDON_ACTION_FORBIDDEN, 
				button1 = DISABLE, 
				button2 = IGNORE_DIALOG, 
				OnAccept = function(self, data)
					DisableAddOn(data);
					ReloadUI();
				end, 
				timeout = 0, 
				exclusive = 1, 
				whileDead = 1, 
				hideOnEscape = 1
			}
		end
	end
end

--切换启动/停止
function WoWAssistant_BeToggle()
	if DA_GetSpecialization() == 102 then
	--平衡专精
		if BalanceCycleStart then
			WoWAssistant_BeStop()
		else
			WoWAssistant_BeStart()
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		if FeralCycleStart then
			WoWAssistant_BeStop()
		else
			WoWAssistant_BeStart()
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		if RestorationCycleStart then
			WoWAssistant_BeStop()
		else
			WoWAssistant_BeStart()
		end
	end
end

--切换模式
function WoWAssistant_BeReplace()
	if DA_GetSpecialization() == 102 then
	--平衡专精
		if not BalanceCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		BalanceCycleStartFlash = 1
		BalanceOption_TargetFilterWill = BalanceOption_TargetFilterWill or BalanceSaves.BalanceOption_TargetFilter
		if BalanceOption_TargetFilterWill == 3 then
			BalanceOption_TargetFilterWill = 2
			BalanceSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
			BalanceOptionConversionTime = GetTime()
			Balance_ReplaceFrame2 = Balance_ReplaceFrame2 or CreateFrame("frame")
			Balance_ReplaceFrame2:SetScript("OnUpdate",function()
				if GetTime() - BalanceOptionConversionTime > 1 then
					BalanceCycleStartFlash = nil
					Balance_ReplaceFrame2:SetScript("OnUpdate", nil)
					Balance_ReplaceFrame2 = nil
				else
					BalanceCycleStartFlash = 1
				end
			end)
		elseif BalanceOption_TargetFilterWill == 1 then
			BalanceOption_TargetFilterWill = 3
			BalanceSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
			BalanceOptionConversionTime = GetTime()
			Balance_ReplaceFrame3 = Balance_ReplaceFrame3 or CreateFrame("frame")
			Balance_ReplaceFrame3:SetScript("OnUpdate",function()
				if GetTime() - BalanceOptionConversionTime > 1 then
					BalanceCycleStartFlash = nil
					Balance_ReplaceFrame3:SetScript("OnUpdate", nil)
					Balance_ReplaceFrame3 = nil
				else
					BalanceCycleStartFlash = 1
				end
			end)
		elseif BalanceOption_TargetFilterWill == 2 then
			BalanceOption_TargetFilterWill = 1
			BalanceSwitchStatusText:SetTextColor(1, 0.55, 0.3)
			BalanceOptionConversionTime = GetTime()
			Balance_ReplaceFrame1 = Balance_ReplaceFrame1 or CreateFrame("frame")
			Balance_ReplaceFrame1:SetScript("OnUpdate",function()
				if GetTime() - BalanceOptionConversionTime > 1 then
					BalanceCycleStartFlash = nil
					Balance_ReplaceFrame1:SetScript("OnUpdate", nil)
					Balance_ReplaceFrame1 = nil
				else
					BalanceCycleStartFlash = 1
				end
			end)
		end
		if BalanceOption_TargetFilterWill == 2 then
			BalanceSaves.BalanceOption_TargetFilter = BalanceOption_TargetFilterWill
			if BalanceOptionBalanceOptionTargetFilter then
				UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, BalanceSaves.BalanceOption_TargetFilter)
				BalanceOptionBalanceOptionTargetFilterText:SetText(BalanceOptionBalanceOptionTargetFilterItems[BalanceSaves.BalanceOption_TargetFilter])
			end
		else
			Balance_ReplaceFrame = Balance_ReplaceFrame or CreateFrame("frame")
			Balance_ReplaceFrame:SetScript("OnUpdate", function()
				if not BalanceCycleStartFlash then
					BalanceSaves.BalanceOption_TargetFilter = BalanceOption_TargetFilterWill
					BalanceOption_TargetFilterWill = nil
					if BalanceOptionBalanceOptionTargetFilter then
						UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, BalanceSaves.BalanceOption_TargetFilter)
						BalanceOptionBalanceOptionTargetFilterText:SetText(BalanceOptionBalanceOptionTargetFilterItems[BalanceSaves.BalanceOption_TargetFilter])
					end
					Balance_ReplaceFrame:SetScript("OnUpdate", nil)
					Balance_ReplaceFrame = nil
				end
			end)
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		if not FeralCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		FeralCycleStartFlash = 1
		FeralOption_TargetFilterWill = FeralOption_TargetFilterWill or FeralSaves.FeralOption_TargetFilter
		if FeralOption_TargetFilterWill == 3 then
			FeralOption_TargetFilterWill = 2
			FeralSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
			FeralOptionConversionTime = GetTime()
			Feral_ReplaceFrame2 = Feral_ReplaceFrame2 or CreateFrame("frame")
			Feral_ReplaceFrame2:SetScript("OnUpdate",function()
				if GetTime() - FeralOptionConversionTime > 1 then
					FeralCycleStartFlash = nil
					Feral_ReplaceFrame2:SetScript("OnUpdate", nil)
					Feral_ReplaceFrame2 = nil
				else
					FeralCycleStartFlash = 1
				end
			end)
		elseif FeralOption_TargetFilterWill == 1 then
			FeralOption_TargetFilterWill = 3
			FeralSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
			FeralOptionConversionTime = GetTime()
			Feral_ReplaceFrame3 = Feral_ReplaceFrame3 or CreateFrame("frame")
			Feral_ReplaceFrame3:SetScript("OnUpdate",function()
				if GetTime() - FeralOptionConversionTime > 1 then
					FeralCycleStartFlash = nil
					Feral_ReplaceFrame3:SetScript("OnUpdate", nil)
					Feral_ReplaceFrame3 = nil
				else
					FeralCycleStartFlash = 1
				end
			end)
		elseif FeralOption_TargetFilterWill == 2 then
			FeralOption_TargetFilterWill = 1
			FeralSwitchStatusText:SetTextColor(0, 1, 1)
			FeralOptionConversionTime = GetTime()
			Feral_ReplaceFrame1 = Feral_ReplaceFrame1 or CreateFrame("frame")
			Feral_ReplaceFrame1:SetScript("OnUpdate",function()
				if GetTime() - FeralOptionConversionTime > 1 then
					FeralCycleStartFlash = nil
					Feral_ReplaceFrame1:SetScript("OnUpdate", nil)
					Feral_ReplaceFrame1 = nil
				else
					FeralCycleStartFlash = 1
				end
			end)
		end
		if FeralOption_TargetFilterWill == 2 then
			FeralSaves.FeralOption_TargetFilter = FeralOption_TargetFilterWill
			if FeralOptionFeralOptionTargetFilter then
				UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, FeralSaves.FeralOption_TargetFilter)
				FeralOptionFeralOptionTargetFilterText:SetText(FeralOptionFeralOptionTargetFilterItems[FeralSaves.FeralOption_TargetFilter])
			end
		else
			Feral_ReplaceFrame = Feral_ReplaceFrame or CreateFrame("frame")
			Feral_ReplaceFrame:SetScript("OnUpdate", function()
				if not FeralCycleStartFlash then
					FeralSaves.FeralOption_TargetFilter = FeralOption_TargetFilterWill
					FeralOption_TargetFilterWill = nil
					if FeralOptionFeralOptionTargetFilter then
						UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, FeralSaves.FeralOption_TargetFilter)
						FeralOptionFeralOptionTargetFilterText:SetText(FeralOptionFeralOptionTargetFilterItems[FeralSaves.FeralOption_TargetFilter])
					end
					Feral_ReplaceFrame:SetScript("OnUpdate", nil)
					Feral_ReplaceFrame = nil
				end
			end)
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		if not RestorationCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		if RestorationSaves.RestorationOption_Effect == 3 then
			RestorationSaves.RestorationOption_Effect = 2
			RestorationSwitchStatusText:SetTextColor(1, 0.49, 0.04)
			RestorationOptionConversionTime = GetTime()
			local F = F or CreateFrame("frame")
			F:SetScript("OnUpdate",function()
				if GetTime() - RestorationOptionConversionTime > 1 then
					RestorationCycleStartFlash = nil
				else
					RestorationCycleStartFlash = 1
				end
			end)
		elseif RestorationSaves.RestorationOption_Effect == 1 then
			RestorationSaves.RestorationOption_Effect = 3
			RestorationSwitchStatusText:SetTextColor(0, 1, 0)
			RestorationOptionConversionTime = GetTime()
			local F = F or CreateFrame("frame")
			F:SetScript("OnUpdate",function()
				if GetTime() - RestorationOptionConversionTime > 1 then
					RestorationCycleStartFlash = nil
				else
					RestorationCycleStartFlash = 1
				end
			end)
		elseif RestorationSaves.RestorationOption_Effect == 2 then
			RestorationSaves.RestorationOption_Effect = 1
			RestorationSwitchStatusText:SetTextColor(0.53, 0.81, 0.98)
			RestorationOptionConversionTime = GetTime()
			local F = F or CreateFrame("frame")
			F:SetScript("OnUpdate",function()
				if GetTime() - RestorationOptionConversionTime > 1 then
					RestorationCycleStartFlash = nil
				else
					RestorationCycleStartFlash = 1
				end
			end)
		end
		if RestorationOptionRestorationOptionEffect then
			UIDropDownMenu_SetSelectedID(RestorationOptionRestorationOptionEffect, RestorationSaves.RestorationOption_Effect)
			RestorationOptionRestorationOptionEffectText:SetText(RestorationOptionRestorationOptionEffectItems[RestorationSaves.RestorationOption_Effect])
		end
	end
end

--切换到模式1
function WoWAssistant_BeReplace1()
	if DA_GetSpecialization() == 102 then
	--平衡专精
		if not BalanceCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		BalanceSaves.BalanceOption_TargetFilter = 1
		BalanceOption_TargetFilterWill = 1
		BalanceSwitchStatusText:SetTextColor(1, 0.55, 0.3)
		BalanceOptionConversionTime = GetTime()
		Balance_ReplaceAutoFrame = Balance_ReplaceAutoFrame or CreateFrame("frame")
		Balance_ReplaceAutoFrame:SetScript("OnUpdate",function()
			if GetTime() - BalanceOptionConversionTime > 1 then
				BalanceCycleStartFlash = nil
				Balance_ReplaceAutoFrame:SetScript("OnUpdate", nil)
				Balance_ReplaceAutoFrame = nil
			else
				BalanceCycleStartFlash = 1
			end
		end)
		if BalanceOptionBalanceOptionTargetFilter then
			UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, BalanceSaves.BalanceOption_TargetFilter)
			BalanceOptionBalanceOptionTargetFilterText:SetText(BalanceOptionBalanceOptionTargetFilterItems[BalanceSaves.BalanceOption_TargetFilter])
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		if not FeralCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		FeralSaves.FeralOption_TargetFilter = 1
		FeralOption_TargetFilterWill = 1
		FeralSwitchStatusText:SetTextColor(0, 1, 1)
		FeralOptionConversionTime = GetTime()
		Feral_ReplaceAutoFrame = Feral_ReplaceAutoFrame or CreateFrame("frame")
		Feral_ReplaceAutoFrame:SetScript("OnUpdate",function()
			if GetTime() - FeralOptionConversionTime > 1 then
				FeralCycleStartFlash = nil
				Feral_ReplaceAutoFrame:SetScript("OnUpdate", nil)
				Feral_ReplaceAutoFrame = nil
			else
				FeralCycleStartFlash = 1
			end
		end)
		if FeralOptionFeralOptionTargetFilter then
			UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, FeralSaves.FeralOption_TargetFilter)
			FeralOptionFeralOptionTargetFilterText:SetText(FeralOptionFeralOptionTargetFilterItems[FeralSaves.FeralOption_TargetFilter])
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		if not RestorationCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		RestorationSaves.RestorationOption_Effect = 1
		RestorationSwitchStatusText:SetTextColor(1, 0.49, 0.04)
		RestorationOptionConversionTime = GetTime()
		local F = F or CreateFrame("frame")
		F:SetScript("OnUpdate",function()
			if GetTime() - RestorationOptionConversionTime > 1 then
				RestorationCycleStartFlash = nil
			else
				RestorationCycleStartFlash = 1
			end
		end)
		if RestorationOptionRestorationOptionEffect then
			UIDropDownMenu_SetSelectedID(RestorationOptionRestorationOptionEffect, RestorationSaves.RestorationOption_Effect)
			RestorationOptionRestorationOptionEffectText:SetText(RestorationOptionRestorationOptionEffectItems[RestorationSaves.RestorationOption_Effect])
		end
	end
end

--切换到模式2
function WoWAssistant_BeReplace2()
	if DA_GetSpecialization() == 102 then
	--平衡专精
		if not BalanceCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		BalanceSaves.BalanceOption_TargetFilter = 2
		BalanceOption_TargetFilterWill = 2
		BalanceSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
		BalanceOptionConversionTime = GetTime()
		Balance_ReplaceManualFrame = Balance_ReplaceManualFrame or CreateFrame("frame")
		Balance_ReplaceManualFrame:SetScript("OnUpdate",function()
			if GetTime() - BalanceOptionConversionTime > 1 then
				BalanceCycleStartFlash = nil
				Balance_ReplaceManualFrame:SetScript("OnUpdate", nil)
				Balance_ReplaceManualFrame = nil
			else
				BalanceCycleStartFlash = 1
			end
		end)
		if BalanceOptionBalanceOptionTargetFilter then
			UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, BalanceSaves.BalanceOption_TargetFilter)
			BalanceOptionBalanceOptionTargetFilterText:SetText(BalanceOptionBalanceOptionTargetFilterItems[BalanceSaves.BalanceOption_TargetFilter])
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		if not FeralCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		FeralSaves.FeralOption_TargetFilter = 2
		FeralOption_TargetFilterWill = 2
		FeralSwitchStatusText:SetTextColor(0.7, 0.4, 0.85)
		FeralOptionConversionTime = GetTime()
		Feral_ReplaceManualFrame = Feral_ReplaceManualFrame or CreateFrame("frame")
		Feral_ReplaceManualFrame:SetScript("OnUpdate",function()
			if GetTime() - FeralOptionConversionTime > 1 then
				FeralCycleStartFlash = nil
				Feral_ReplaceManualFrame:SetScript("OnUpdate", nil)
				Feral_ReplaceManualFrame = nil
			else
				FeralCycleStartFlash = 1
			end
		end)
		if FeralOptionFeralOptionTargetFilter then
			UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, FeralSaves.FeralOption_TargetFilter)
			FeralOptionFeralOptionTargetFilterText:SetText(FeralOptionFeralOptionTargetFilterItems[FeralSaves.FeralOption_TargetFilter])
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		if not RestorationCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		RestorationSaves.RestorationOption_Effect = 2
		RestorationSwitchStatusText:SetTextColor(0, 1, 0)
		RestorationOptionConversionTime = GetTime()
		local F = F or CreateFrame("frame")
		F:SetScript("OnUpdate",function()
			if GetTime() - RestorationOptionConversionTime > 1 then
				RestorationCycleStartFlash = nil
			else
				RestorationCycleStartFlash = 1
			end
		end)
		if RestorationOptionRestorationOptionEffect then
			UIDropDownMenu_SetSelectedID(RestorationOptionRestorationOptionEffect, RestorationSaves.RestorationOption_Effect)
			RestorationOptionRestorationOptionEffectText:SetText(RestorationOptionRestorationOptionEffectItems[RestorationSaves.RestorationOption_Effect])
		end
	end
end

--切换到模式3
function WoWAssistant_BeReplace3()
	if DA_GetSpecialization() == 102 then
	--平衡专精
		if not BalanceCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		BalanceSaves.BalanceOption_TargetFilter = 3
		BalanceOption_TargetFilterWill = 3
		BalanceSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
		BalanceOptionConversionTime = GetTime()
		Balance_ReplaceAllFrame = Balance_ReplaceAllFrame or CreateFrame("frame")
		Balance_ReplaceAllFrame:SetScript("OnUpdate",function()
			if GetTime() - BalanceOptionConversionTime > 1 then
				BalanceCycleStartFlash = nil
				Balance_ReplaceAllFrame:SetScript("OnUpdate", nil)
				Balance_ReplaceAllFrame = nil
			else
				BalanceCycleStartFlash = 1
			end
		end)
		if BalanceOptionBalanceOptionTargetFilter then
			UIDropDownMenu_SetSelectedID(BalanceOptionBalanceOptionTargetFilter, BalanceSaves.BalanceOption_TargetFilter)
			BalanceOptionBalanceOptionTargetFilterText:SetText(BalanceOptionBalanceOptionTargetFilterItems[BalanceSaves.BalanceOption_TargetFilter])
		end
	end
	
	if DA_GetSpecialization() == 103 then
	--野性专精
		if not FeralCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		FeralSaves.FeralOption_TargetFilter = 3
		FeralOption_TargetFilterWill = 3
		FeralSwitchStatusText:SetTextColor(0.25, 0.45, 0.9)
		FeralOptionConversionTime = GetTime()
		Feral_ReplaceAllFrame = Feral_ReplaceAllFrame or CreateFrame("frame")
		Feral_ReplaceAllFrame:SetScript("OnUpdate",function()
			if GetTime() - FeralOptionConversionTime > 1 then
				FeralCycleStartFlash = nil
				Feral_ReplaceAllFrame:SetScript("OnUpdate", nil)
				Feral_ReplaceAllFrame = nil
			else
				FeralCycleStartFlash = 1
			end
		end)
		if FeralOptionFeralOptionTargetFilter then
			UIDropDownMenu_SetSelectedID(FeralOptionFeralOptionTargetFilter, FeralSaves.FeralOption_TargetFilter)
			FeralOptionFeralOptionTargetFilterText:SetText(FeralOptionFeralOptionTargetFilterItems[FeralSaves.FeralOption_TargetFilter])
		end
	end
	
	if DA_GetSpecialization() == 105 then
	--恢复专精
		if not RestorationCycleStart then return end
		PlaySound(SOUNDKIT.GS_TITLE_OPTION_EXIT)
		RestorationSaves.RestorationOption_Effect = 3
		RestorationSwitchStatusText:SetTextColor(0.53, 0.81, 0.98)
		RestorationOptionConversionTime = GetTime()
		local F = F or CreateFrame("frame")
		F:SetScript("OnUpdate",function()
			if GetTime() - RestorationOptionConversionTime > 1 then
				RestorationCycleStartFlash = nil
			else
				RestorationCycleStartFlash = 1
			end
		end)
		if RestorationOptionRestorationOptionEffect then
			UIDropDownMenu_SetSelectedID(RestorationOptionRestorationOptionEffect, RestorationSaves.RestorationOption_Effect)
			RestorationOptionRestorationOptionEffectText:SetText(RestorationOptionRestorationOptionEffectItems[RestorationSaves.RestorationOption_Effect])
		end
	end
end