--治疗技能灯塔系统
RestorationStatusLhh = CreateFrame("Frame")

local Health5, Health10, Health15, Health20, Health25, Health30, Health35, Health40, Health45, Health50, Health55, Health60, Health65, Health70, Health75, Health80, Health85, Health90, Health95, Health99 = nil

local function DEBUG()
	if RestorationDBUG and ((RestorationDBUG_T and GetTime() - RestorationDBUG_T > 1) or not RestorationDBUG_T) and HealsUnitPriority and #HealsUnitPriority > 0 then
		print("治疗:"..UnitName(HealsUnitPriority[1].UnitID).." - 模式:"..HealsUnitPriority[1].Mode.." - 优先级:"..HealsUnitPriority[1].Priority)
		RestorationDBUG_T = GetTime()
	end
end
local DEBUGFrame = CreateFrame("frame")
DEBUGFrame:SetScript("OnUpdate", DEBUG)

function HideAllSpellIcons()
--隐藏全部技能图标
	local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
	if IsInRaid() and not IsActiveBattlefieldArena() then
		--团队中
		if raidGroupDisplayType == 0 or raidGroupDisplayType == 1 then
			--保持小队相连
			for i = 1, 8 do
				for j = 1, 5 do
					if _G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"] and _G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"]:IsShown() then
						_G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"]:Hide()
					end
				end
			end
		else
			for i = 1, 40 do
				if _G["CompactRaidFrame"..i.."SpellIcon"] and _G["CompactRaidFrame"..i.."SpellIcon"]:IsShown() then
					_G["CompactRaidFrame"..i.."SpellIcon"]:Hide()
				end
			end
		end
	end
	if (IsInGroup() and not IsInRaid()) or IsActiveBattlefieldArena() then
		--小队中
		for j = 1, 5 do
			if _G["CompactPartyFrameMember"..j.."SpellIcon"] and _G["CompactPartyFrameMember"..j.."SpellIcon"]:IsShown() then
				_G["CompactPartyFrameMember"..j.."SpellIcon"]:Hide()
			end
		end
	end
end

function Restoration_RefreshRaidCastlInfo(unitid, spellID)
	local name, rank, icon = DA_GetSpellInfo(spellID)
	if CompactRaidFrameManager.container.enabled and RestorationSaves.RestorationOption_Other_ShowCastlInfo then
		--CompactRaidFrame Shown
		local raidGroupDisplayType = EditModeManagerFrame:GetSettingValue(Enum.EditModeSystem.UnitFrame, Enum.EditModeUnitFrameSystemIndices.Raid, Enum.EditModeUnitFrameSetting.RaidGroupDisplayType)
		
		HideAllSpellIcons()
		--隐藏全部技能图标
		
		if IsInRaid() and not IsActiveBattlefieldArena() then
			--团队中
			if raidGroupDisplayType == 0 or raidGroupDisplayType == 1 then
				--保持小队相连
				for j = 1, 5 do
					i = select(3, GetRaidRosterInfo(UnitInRaid(unitid)))
					if UnitGUID(unitid) and _G["CompactRaidGroup"..i.."Member"..j] and _G["CompactRaidGroup"..i.."Member"..j].unit and UnitGUID(_G["CompactRaidGroup"..i.."Member"..j].unit) then
						if UnitGUID(unitid) == UnitGUID(_G["CompactRaidGroup"..i.."Member"..j].unit) then
							if not _G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"] then
								SpellIcon = CreateFrame("Frame", "CompactRaidGroup"..i.."Member"..j.."SpellIcon", _G["CompactRaidGroup"..i.."Member"..j])
								SpellIcon:SetPoint("CENTER", _G["CompactRaidGroup"..i.."Member"..j], "CENTER", 0, 0)
								SpellIcon:SetSize(20, 20)
								SpellIcon.Texture = SpellIcon:CreateTexture(nil, "BORDER")
								SpellIcon.Texture:SetAllPoints(true)
							end
							_G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"].Texture:SetTexture(icon)
							_G["CompactRaidGroup"..i.."Member"..j.."SpellIcon"]:Show()
						end
					end
				end
			else
				for i = 1, 40 do
					if UnitGUID(unitid) and _G["CompactRaidFrame"..i] and _G["CompactRaidFrame"..i].unit and UnitGUID(_G["CompactRaidFrame"..i].unit) then
						if UnitGUID(unitid) == UnitGUID(_G["CompactRaidFrame"..i].unit) then
							if not _G["CompactRaidFrame"..i.."SpellIcon"] then
								SpellIcon = CreateFrame("Frame", "CompactRaidFrame"..i.."SpellIcon", _G["CompactRaidFrame"..i])
								SpellIcon:SetPoint("CENTER", _G["CompactRaidFrame"..i], "CENTER", 0, 0)
								SpellIcon:SetSize(20, 20)
								SpellIcon.Texture = SpellIcon:CreateTexture(nil, "BORDER")
								SpellIcon.Texture:SetAllPoints(true)
							end
							_G["CompactRaidFrame"..i.."SpellIcon"].Texture:SetTexture(icon)
							_G["CompactRaidFrame"..i.."SpellIcon"]:Show()
						end
					end
				end
			end
		end
		if (IsInGroup() and not IsInRaid()) or IsActiveBattlefieldArena() then
			--小队中
			for j = 1, 5 do
				if UnitGUID(unitid) and _G["CompactPartyFrameMember"..j] and _G["CompactPartyFrameMember"..j].unit and UnitGUID(_G["CompactPartyFrameMember"..j].unit) then
					if UnitGUID(unitid) == UnitGUID(_G["CompactPartyFrameMember"..j].unit) then
						if not _G["CompactPartyFrameMember"..j.."SpellIcon"] then
							SpellIcon = CreateFrame("Frame", "CompactPartyFrameMember"..j.."SpellIcon", _G["CompactPartyFrameMember"..j])
							SpellIcon:SetPoint("CENTER", _G["CompactPartyFrameMember"..j], "CENTER", 0, 0)
							SpellIcon:SetSize(20, 20)
							SpellIcon.Texture = SpellIcon:CreateTexture(nil, "BORDER")
							SpellIcon.Texture:SetAllPoints(true)
						end
						_G["CompactPartyFrameMember"..j.."SpellIcon"].Texture:SetTexture(icon)
						_G["CompactPartyFrameMember"..j.."SpellIcon"]:Show()
					end
				end
			end
		end
		if Restoration_RefreshRaidCastlInfo_SpellTimers then
			Restoration_RefreshRaidCastlInfo_SpellTimers:Cancel()
		end
		Restoration_RefreshRaidCastlInfo_SpellTimers = C_Timer.NewTimer(1.25, HideAllSpellIcons)
	end
end



local function Lifebloom(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if DA_IsUsableSpell(Lifebloom_SpellID) and RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("生命绽放  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Lifebloom_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Lifebloom_SpellID)
	end
end

local function Rejuvenation(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if DA_IsUsableSpell(Rejuvenation_SpellID) and RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("回春术  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Rejuvenation_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Rejuvenation_SpellID)
	end
end

local function Regrowth(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if DA_IsUsableSpell(Regrowth_SpellID) and RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		--print("愈合  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Regrowth_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Regrowth_SpellID)
	end
end

local function Nourish_Regrowth(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if DA_IsUsableSpell(Nourish_SpellID) and RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("滋养  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Nourish_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Nourish_SpellID)
	end
end

local function Swiftmend(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("迅捷治愈  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Swiftmend_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Swiftmend_SpellID)
	end
end

local function CenarionWard(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("塞纳里奥结界  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Cenarion_Ward_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Cenarion_Ward_SpellID)
	end
end

local function Overgrowth(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("过度生长  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Overgrowth_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Overgrowth_SpellID)
	end
end

local function WildGrowth(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		--print("野性成长  "..namerealm)
		if RestorationUseItem then
			Restoration_UseAttributesEnhancedItem()
		end
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Wild_Growth_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Wild_Growth_SpellID)
	end
end

local function Barkskin(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		--print("树皮术  "..namerealm)
		DA_CastSpellByID(Barkskin_SpellID)
		Restoration_RefreshRaidCastlInfo(unitid, Barkskin_SpellID)
	end
end

local function Ironbark(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		--print("铁木树皮  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Ironbark_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Ironbark_SpellID)
	end
end

local function Invigorate(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast and not RestorationHeals_AlertSpellAOEWillWildGrowth then
		--print("鼓舞  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Invigorate_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Invigorate_SpellID)
	end
end

local function Grove_Guardians(unitid, guid)
	local class, classFilename, race, raceFilename, sex, name, realm = GetPlayerInfoByGUID(guid)
	if realm and realm ~= "" then
		namerealm = name.."-"..realm
	elseif name then
		namerealm = name
	else
		namerealm = unitid
	end
	if RestorationStatusRestorationHealsCastSpell and not Restoration_InGCD and not RestorationHeals_DoNotHeals and not RestorationSpellWillBeCast and not RestorationUnitHasAuras and not RestorationSpellWillBeChannel and not RestorationTranquilityWillBeCast then
		--print("林莽卫士  "..namerealm)
		DA_TargetUnit(unitid)
		if UnitIsUnit('target', unitid) then
			DA_CastSpellByID(Grove_Guardians_SpellID)
		end
		Restoration_RefreshRaidCastlInfo(unitid, Grove_Guardians_SpellID)
	end
end

function RestorationStatusLhh:UpdateUnit()
	local unitid
	if #HealsUnitPriority > 0 then
		table.sort(HealsUnitPriority, function(a, b) return a.Priority < b.Priority end)
		if (UnitCastingInfo("player") == '滋养' or UnitCastingInfo("player") == '愈合') and UnitHealth(HealsUnitPriority[1].UnitID)/UnitHealthMax(HealsUnitPriority[1].UnitID) > 0.25 and not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn and #HealsUnitPriority > 1 then
			unitid = HealsUnitPriority[2].UnitID
			--当有多个目标需要治疗时，第1优先目标血量大于25%且正在读条滋养或愈合,则治疗第2优先目标
			--print("2:   "..HealsUnitPriority[2].UnitID.."  - "..HealsUnitPriority[2].Mode.." - "..HealsUnitPriority[2].Priority)
		elseif (UnitCastingInfo("player") == '滋养' or UnitCastingInfo("player") == '愈合') and UnitHealth(HealsUnitPriority[1].UnitID)/UnitHealthMax(HealsUnitPriority[1].UnitID) > 0.25 and not HealerEngine_UnitHasHealAuras and not HealerEngine_UnitHasHealAurasWarn and #HealsUnitPriority == 1 then
			return
			--当只有一个目标需要治疗时，该目标血量大于25%且正在读条滋养或愈合,则忽略目标
		else
			unitid = HealsUnitPriority[1].UnitID
			--print("1:   "..HealsUnitPriority[1].UnitID.."  - "..HealsUnitPriority[1].Mode.." - "..HealsUnitPriority[1].Priority)
		end
	
		HealerEngineHeals_HealBreakoutSpellUnitID = nil
		HealerEngine_GetHealAuras(unitid) -- 判断有无需要治疗Auras
		HealerEngine_GetHealAurasLow(unitid) -- 判断有无需要轻度治疗Auras
		HealerEngine_GetHealAurasWarn(unitid) -- 判断有无急需要治疗Auras
		--施放技能时再针对使用技能的目标获取 HealerEngineHeals_HealBreakoutSpellUnitID,HealerEngineHeals_HealAurasUnitID,HealerEngineHeals_HealAurasLowHigh,HealerEngineHeals_HealAurasWarnUnitID 变量
		
		local IsSpecialHealsUnit = nil
		IsSpecialHealsUnit = HealerEngine_GetSpecialHealsUnit(unitid)
		RestorationStatusRestorationHealsCastSpell = 1
		RestorationStatusLhh:SetUnit(unitid, IsSpecialHealsUnit)
		RestorationStatusRestorationHealsCastSpell = nil
	end
end

function RestorationStatusLhh:SetUnit(unitid, IsSpecialHealsUnit)
	if not unitid then return end
	if UnitIsDeadOrGhost(unitid) then return end
	if RestorationStatusRestorationHealsRaid then
		--print("团队")
	end
	if RestorationStatusRestorationHealsParty then
		--print("小队")
	end
	
	local guid = UnitGUID(unitid)
	local UnitIsVulnerable = DA_UnitIsVulnerable(unitid)
	
	UnitHasThreat = nil
	LifebloomCanRefresh = nil
	RejuvenationCanRefresh = nil
	RejuvenationGerminationCanRefresh = nil
	RegrowthCanRefresh = nil
	UnitHasLifebloom = nil
	UnitTankHasLifebloom = nil
	UnitHasRejuvenation = nil
	UnitHasRejuvenationGermination = nil
	UnitHasWildGrowth = nil
	UnitHasRegrowth = nil
	UnitHasCenarionWard = nil
	RestorationHeals_CanSwiftmendThisUnit = nil
	RestorationHeals_CanInvigorateThisUnit = nil
	LifebloomTarget = nil
	
	local status = UnitThreatSituation(unitid)
	if status and (status > 0 or status > 1) then
		UnitHasThreat = 1
	end
	local UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid)
	
	local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1
	local timeLeft
	local timeDuration
	
	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		local flash_timeLeft = 0.15
		if IsActiveBattlefieldArena() then
			flash_timeLeft = duration1 * 0.25
		end
		
		if spellID1 == Lifebloom_SpellID and caster1 == "player" and timeLeft > flash_timeLeft then
			UnitHasLifebloom = 1
			--生命绽放
			if timeLeft < duration1 * 0.3 then
				LifebloomCanRefresh = 1
			end
		end
		if spellID1 == Lifebloom_SpellID and DA_UnitGroupRolesAssigned(unitid) == "TANK" and caster1 == "player" and timeLeft > 0.15 then
			UnitTankHasLifebloom = 1
			--坦克生命绽放
		end
	end
	
	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('回春术', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		local flash_timeLeft = 0.15
		if IsActiveBattlefieldArena() then
			flash_timeLeft = duration1 * 0.25
		end
		
		if spellID1 == Rejuvenation_SpellID and caster1 == "player" and timeLeft > flash_timeLeft then
			UnitHasRejuvenation = 1
			--回春术
			if timeLeft < duration1 * 0.3 then
				RejuvenationCanRefresh = 1
			end
		end
	end
	
	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('回春术（萌芽）', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		local flash_timeLeft = 0.15
		if IsActiveBattlefieldArena() then
			flash_timeLeft = duration1 * 0.25
		end
		
		if spellID1 == 155777 and caster1 == "player" and timeLeft > flash_timeLeft then
			UnitHasRejuvenationGermination = 1
			--回春术（萌芽）
			if timeLeft < duration1 * 0.3 then
				RejuvenationGerminationCanRefresh = 1
			end
		end
	end

	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('野性成长', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		
		if spellID1 == Wild_Growth_SpellID and caster1 == "player" and timeLeft > 0.15 then
			UnitHasWildGrowth = 1
			UnitHasWildGrowthtimeLeft = timeLeft
			--野性成长
		end
	end
	
	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('愈合', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		
		if spellID1 == Regrowth_SpellID and caster1 == "player" and timeLeft > 0.15 then
			UnitHasRegrowth = 1
			--愈合
			if timeLeft < duration1 * 0.3 then
				RegrowthCanRefresh = 1
			end
		end
	end

	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('宁静', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		
		if spellID1 == Tranquility_SpellID and caster1 == "player" and timeLeft > 0.15 and count1 >= 5 then
			UnitHasTranquility = 1
			UnitHasTranquilitytimeLeft = timeLeft
			--宁静
		end
	end
	
	name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('塞纳里奥结界', unitid, "HELPFUL")
	if spellID1 then
		timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--BUFF剩余时间
		timeDuration = duration1 and duration1 - timeLeft
		--BUFF已持续时间
		
		if spellID1 == 102352 and caster1 == "player" and timeLeft > 0.15 then
			UnitHasCenarionWard = 1
			--塞纳里奥结界
			if (timeLeft < 5.25 or not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and Swiftmend_CenarionWard and Swiftmend_CenarionWard_Sequence2 then
				Swiftmend_CenarionWard = nil
				Swiftmend_CenarionWard_Sequence2 = nil
				--迅捷治愈延长塞纳里奥结界赋值后,塞纳里奥结界治疗剩余时间小于5.25秒,则清除赋值
			end
		end
	end
	
	if (UnitHasRejuvenation or UnitHasRejuvenationGermination or UnitHasWildGrowth or UnitHasRegrowth) then
		RestorationHeals_CanSwiftmendThisUnit = 1
		--可以对该单位使用迅捷治愈
	end
	
	if (RejuvenationCanRefresh or RejuvenationGerminationCanRefresh) or (UnitHasRejuvenation and UnitHasRejuvenationGermination) or (UnitHasRejuvenation and UnitHasLifebloom) or (UnitHasRejuvenationGermination and UnitHasLifebloom) then
		RestorationHeals_CanInvigorateThisUnit = 1
		--可以对该单位使用鼓舞
	end
	
	local Count = 0
	local BeCastOvergrowth = nil
	local BeCastNourish_Regrowth = nil
	if UnitHasLifebloom then Count = Count + 1 end
	if UnitHasRejuvenation then Count = Count + 1 end
	if UnitHasRejuvenationGermination then Count = Count + 1 end
	if UnitHasWildGrowth then Count = Count + 1 end
	if UnitHasRegrowth then Count = Count + 1 end
	if Count <= 2 then
		BeCastOvergrowth = 1
	end
	if Count >= 1 then
		BeCastNourish_Regrowth = 1
	end
	
	if (#HealerEngineHeals_AggroTarget > 0 or C_PvP.IsActiveBattlefield()) and not UnitHasLifebloom and ((NotRestorationHeals_UnitHasCastLifebloom and not Overgrowth_NoCastLifebloom) or RestorationHeals_Photosynthesis) and (not LifebloomTarget_In_HealsUnitPriority or RestorationStatusRestorationHealsCastSpell) then
		if IsPlayerSpell(274902) then
		--光合作用天赋
			if RestorationHeals_Photosynthesis then
			--光合作用指示
				if not AuraUtil.FindAuraByName('生命绽放', "player", "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', "player", "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', "player", "HELPFUL")) ~= "player") then
				--玩家身上没有玩家自己施放的生命绽放
					if UnitAffectingCombat("player") then
						LifebloomTarget = "player"
						--对玩家自己施放生命绽放
					end
				end
			else
				for k, v in ipairs(HealerEngineHeals_AggroTarget) do
					if UnitAffectingCombat(v) and not AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL")) ~= "player") then
						if DA_UnitGroupRolesAssigned(v) == "TANK" and DA_IsSpellInRange(Regrowth_SpellID, v) == 1  and not DA_UnitIsInTable(UnitGUID(v), RestorationHeals_TargetNotVisible)then
						--在战斗中有仇恨的坦克
							LifebloomTarget = v
							--第1优先生命绽放目标
						end
					end
				end
				if not LifebloomTarget then
					for k, v in ipairs(DamagerEngine_TankAssigned) do
						if UnitAffectingCombat(v.Unit) and not AuraUtil.FindAuraByName('生命绽放', v.Unit, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', v.Unit, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v.Unit, "HELPFUL")) ~= "player") then
							if DA_IsSpellInRange(Regrowth_SpellID, v.Unit) == 1 and not DA_UnitIsInTable(UnitGUID(v.Unit), RestorationHeals_TargetNotVisible) then
							--在战斗中的坦克
								LifebloomTarget = v.Unit
								--第2优先生命绽放目标
							end
						end
					end
				end
				if not LifebloomTarget then
					if C_PvP.IsActiveBattlefield() then
					--战场/竞技场中
						if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and UnitAffectingCombat(unitid) and not DA_UnitIsInTable(UnitGUID(unitid), RestorationHeals_TargetNotVisible) and UnitHealthScale <= 0.95 and not AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL")) ~= "player") then
						--在战斗中生命值低于95%的单位
							LifebloomTarget = unitid
							--第3优先生命绽放目标
						end
					else
					--非战场/竞技场
						for k, v in ipairs(HealerEngineHeals_AggroTarget) do
							if UnitAffectingCombat(v) and not AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL")) ~= "player") then
								if DA_IsSpellInRange(Regrowth_SpellID, v) == 1 and UnitHealth(v)/UnitHealthMax(v) <= 0.9 and not DA_UnitIsInTable(UnitGUID(v), RestorationHeals_TargetNotVisible) then
								--在战斗中有仇恨的单位
									LifebloomTarget = v
									--第3优先生命绽放目标
								end
							end
						end
					end
				end
				if not LifebloomTarget then
					if IsPlayerSpell(392301) then
					--可以对两个目标使用[生命绽放]时
						if UnitAffectingCombat("player") and UnitHealth("player")/UnitHealthMax("player") <= 0.9 and not AuraUtil.FindAuraByName('生命绽放', "player", "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', "player", "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', "player", "HELPFUL")) ~= "player") then
						--在战斗中玩家自己生命值低于90%
							LifebloomTarget = "player"
							--第4优先生命绽放目标
						elseif DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and UnitAffectingCombat(unitid) and not DA_UnitIsInTable(UnitGUID(unitid), RestorationHeals_TargetNotVisible) and UnitHealthScale <= 0.8 and not AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL")) ~= "player") then
						--在战斗中生命值低于80%的单位
							LifebloomTarget = unitid
							--第5优先生命绽放目标
						end
					end
				end
			end
		else
		--非光合作用天赋
			for k, v in ipairs(HealerEngineHeals_AggroTarget) do
				if UnitAffectingCombat(v) and not AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL")) ~= "player") then
					if DA_UnitGroupRolesAssigned(v) == "TANK" and DA_IsSpellInRange(Regrowth_SpellID, v) == 1 and not DA_UnitIsInTable(UnitGUID(v), RestorationHeals_TargetNotVisible) then
					--在战斗中有仇恨的坦克
						LifebloomTarget = v
						--第1优先生命绽放目标
					end
				end
			end
			if not LifebloomTarget then
				for k, v in ipairs(DamagerEngine_TankAssigned) do
					if UnitAffectingCombat(v.Unit) and not AuraUtil.FindAuraByName('生命绽放', v.Unit, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', v.Unit, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v.Unit, "HELPFUL")) ~= "player") then
						if DA_IsSpellInRange(Regrowth_SpellID, v.Unit) == 1 and not DA_UnitIsInTable(UnitGUID(v.Unit), RestorationHeals_TargetNotVisible) then
						--在战斗中的坦克
							LifebloomTarget = v.Unit
							--第2优先生命绽放目标
						end
					end
				end
			end
			if not LifebloomTarget then
				if C_PvP.IsActiveBattlefield() then
				--战场/竞技场中
					if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and UnitAffectingCombat(unitid) and not DA_UnitIsInTable(UnitGUID(unitid), RestorationHeals_TargetNotVisible) and UnitHealthScale <= 0.95 and not AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL")) ~= "player") then
					--在战斗中生命值低于95%的单位
						LifebloomTarget = unitid
						--第3优先生命绽放目标
					end
				else
				--非战场/竞技场
					for k, v in ipairs(HealerEngineHeals_AggroTarget) do
						if UnitAffectingCombat(v) and not AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', v, "HELPFUL")) ~= "player") then
							if DA_IsSpellInRange(Regrowth_SpellID, v) == 1 and UnitHealth(v)/UnitHealthMax(v) <= 0.9 and not DA_UnitIsInTable(UnitGUID(v), RestorationHeals_TargetNotVisible) then
							--在战斗中有仇恨的单位
								LifebloomTarget = v
								--第3优先生命绽放目标
							end
						end
					end
				end
			end
			if not LifebloomTarget then
				if IsPlayerSpell(392301) then
				--可以对两个目标使用[生命绽放]时
					if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and UnitAffectingCombat(unitid) and not DA_UnitIsInTable(UnitGUID(unitid), RestorationHeals_TargetNotVisible) and UnitHealthScale <= 0.9 and not AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") or (AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL") and select(7, AuraUtil.FindAuraByName('生命绽放', unitid, "HELPFUL")) ~= "player") then
					--在战斗中生命值低于90%的单位
						LifebloomTarget = unitid
						--第4优先生命绽放目标
					end
				end
			end
		end
	end
	
	local PlayerPowerScale = UnitPower("player", 0) / UnitPowerMax("player", 0)
	local PlayerPowerScaleControlFactor = PlayerPowerScale * PlayerPowerScale * PlayerPowerScale * (PlayerPowerScale / 20 + PlayerPowerScale / 100)
	local PlayerPowerScaleControlFactorReverse = (1 - PlayerPowerScale) / 7.5
	if #Restoration_SpecialHealsCache <= 0 and ((PlayerPowerScale >= 0.7 and not RestorationSaves.RestorationOption_Heals_HealTank and not RestorationSaves.RestorationOption_Heals_AllRejuvenation and not RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation) or (PlayerPowerScale >= 0.7 and not UnitExists("boss1")) or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
		Health5 = 0.05 + PlayerPowerScaleControlFactor
		Health10 = 0.1 + PlayerPowerScaleControlFactor
		Health15 = 0.15 + PlayerPowerScaleControlFactor
		Health20 = 0.2 + PlayerPowerScaleControlFactor
		Health25 = 0.25 + PlayerPowerScaleControlFactor
		Health30 = 0.3 + PlayerPowerScaleControlFactor
		Health35 = 0.35 + PlayerPowerScaleControlFactor
		Health40 = 0.4 + PlayerPowerScaleControlFactor
		Health45 = 0.45 + PlayerPowerScaleControlFactor
		Health50 = 0.5 + PlayerPowerScaleControlFactor
		Health55 = 0.55 + PlayerPowerScaleControlFactor
		Health60 = 0.6 + PlayerPowerScaleControlFactor
		Health65 = 0.65 + PlayerPowerScaleControlFactor
		Health70 = 0.7 + PlayerPowerScaleControlFactor
		Health75 = 0.75 + PlayerPowerScaleControlFactor
		Health80 = 0.8 + PlayerPowerScaleControlFactor
		Health85 = 0.85 + PlayerPowerScaleControlFactor
		Health90 = 0.9 + PlayerPowerScaleControlFactor
		Health95 = 0.95 + PlayerPowerScaleControlFactor
		Health99 = 0.99 + PlayerPowerScaleControlFactor
	elseif #Restoration_SpecialHealsCache <= 0 and (RestorationSaves.RestorationOption_Heals_HealTank or RestorationSaves.RestorationOption_Heals_AllRejuvenation or RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation) and UnitExists("boss1") then
		Health5 = 0.05 - PlayerPowerScaleControlFactorReverse
		Health10 = 0.1 - PlayerPowerScaleControlFactorReverse
		Health15 = 0.15 - PlayerPowerScaleControlFactorReverse
		Health20 = 0.2 - PlayerPowerScaleControlFactorReverse
		Health25 = 0.25 - PlayerPowerScaleControlFactorReverse
		Health30 = 0.3 - PlayerPowerScaleControlFactorReverse
		Health35 = 0.35 - PlayerPowerScaleControlFactorReverse
		Health40 = 0.4 - PlayerPowerScaleControlFactorReverse
		Health45 = 0.45 - PlayerPowerScaleControlFactorReverse
		Health50 = 0.5 - PlayerPowerScaleControlFactorReverse
		Health55 = 0.55 - PlayerPowerScaleControlFactorReverse
		Health60 = 0.6 - PlayerPowerScaleControlFactorReverse
		Health65 = 0.65 - PlayerPowerScaleControlFactorReverse
		Health70 = 0.7 - PlayerPowerScaleControlFactorReverse
		Health75 = 0.75 - PlayerPowerScaleControlFactorReverse
		Health80 = 0.8 - PlayerPowerScaleControlFactorReverse
		Health85 = 0.85 - PlayerPowerScaleControlFactorReverse
		Health90 = 0.9 - PlayerPowerScaleControlFactorReverse
		Health95 = 0.95 - PlayerPowerScaleControlFactorReverse
		Health99 = 0.99 - PlayerPowerScaleControlFactorReverse
	else
		Health5 = 0.05
		Health10 = 0.1
		Health15 = 0.15
		Health20 = 0.2
		Health25 = 0.25
		Health30 = 0.3
		Health35 = 0.35
		Health40 = 0.4
		Health45 = 0.45
		Health50 = 0.5
		Health55 = 0.55
		Health60 = 0.6
		Health65 = 0.65
		Health70 = 0.7
		Health75 = 0.75
		Health80 = 0.8
		Health85 = 0.85
		Health90 = 0.9
		Health95 = 0.95
		Health99 = 0.99
	end
	
	if Health5 >= 0.99 then Health5 = 0.99 end
	if Health10 >= 0.99 then Health10 = 0.99 end
	if Health15 >= 0.99 then Health15 = 0.99 end
	if Health20 >= 0.99 then Health20 = 0.99 end
	if Health25 >= 0.99 then Health25 = 0.99 end
	if Health30 >= 0.99 then Health30 = 0.99 end
	if Health35 >= 0.99 then Health35 = 0.99 end
	if Health40 >= 0.99 then Health40 = 0.99 end
	if Health45 >= 0.99 then Health45 = 0.99 end
	if Health50 >= 0.99 then Health50 = 0.99 end
	if Health55 >= 0.99 then Health55 = 0.99 end
	if Health60 >= 0.99 then Health60 = 0.99 end
	if Health65 >= 0.99 then Health65 = 0.99 end
	if Health70 >= 0.99 then Health70 = 0.99 end
	if Health75 >= 0.99 then Health75 = 0.99 end
	if Health80 >= 0.99 then Health80 = 0.99 end
	if Health85 >= 0.99 then Health85 = 0.99 end
	if Health90 >= 0.99 then Health90 = 0.99 end
	if Health95 >= 0.99 then Health95 = 0.99 end
	if Health99 >= 0.99 then Health99 = 0.99 end
	
	if Health5 <= 0.05 then Health5 = 0.05 end
	if Health10 <= 0.05 then Health10 = 0.05 end
	if Health15 <= 0.05 then Health15 = 0.05 end
	if Health20 <= 0.05 then Health20 = 0.05 end
	if Health25 <= 0.05 then Health25 = 0.05 end
	if Health30 <= 0.05 then Health30 = 0.05 end
	if Health35 <= 0.05 then Health35 = 0.05 end
	if Health40 <= 0.05 then Health40 = 0.05 end
	if Health45 <= 0.05 then Health45 = 0.05 end
	if Health50 <= 0.05 then Health50 = 0.05 end
	if Health55 <= 0.05 then Health55 = 0.05 end
	if Health60 <= 0.05 then Health60 = 0.05 end
	if Health65 <= 0.05 then Health65 = 0.05 end
	if Health70 <= 0.05 then Health70 = 0.05 end
	if Health75 <= 0.05 then Health75 = 0.05 end
	if Health80 <= 0.05 then Health80 = 0.05 end
	if Health85 <= 0.05 then Health85 = 0.05 end
	if Health90 <= 0.05 then Health90 = 0.05 end
	if Health95 <= 0.05 then Health95 = 0.05 end
	if Health99 <= 0.05 then Health99 = 0.05 end
	
	if RestorationStatusRestorationHealsRaid then
		if Restoration_CanNotMovingCast() and not AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") and not AuraUtil.FindAuraByName('自然迅捷', "player", "HELPFUL") then
		--移动状态-团刷
			if IsPlayerSpell(Barkskin_SpellID) and UnitHealthScale <= Health50 and guid == UnitGUID("player") and UnitAffectingCombat("player") and not BarkskinCD and not AuraUtil.FindAuraByName('铁木树皮', "player", "HELPFUL") then
				Barkskin(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.001})
			elseif IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and UnitHealthScale <= Health70 and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.003})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.01})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.02})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.03})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.04})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.05})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.06})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.07})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.08})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.09})
			elseif UnitHealthScale <= Health45 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.091})
			elseif UnitHealthScale <= Health80 and not DirectSingleHealItemCD and (UnitHasThreat or UnitTankHasLifebloom) and (DirectSingleHealItemID == 147007 or DirectSingleHealItemID == 151957 or DirectSingleHealItemID == 160649) and not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL") then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.092})
			elseif UnitHealthScale <= Health30 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.093})
			elseif UnitHealthScale <= Health40 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.094})
			elseif UnitHealthScale <= Health50 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.095})
			elseif UnitHealthScale <= Health60 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.096})
			elseif IsPlayerSpell(Swiftmend_SpellID) and Swiftmend_CenarionWard and UnitHasCenarionWard and RestorationHeals_CanSwiftmendThisUnit then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.099})
			elseif IsPlayerSpell(Grove_Guardians_SpellID) and RestorationHeals_Grove_Guardians and not Grove_GuardiansCD then
				if UnitHealthScale <= Health25 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.1})
				elseif UnitHealthScale <= Health40 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.11})
				elseif UnitHealthScale <= Health55 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.12})
				elseif UnitHealthScale <= Health70 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.13})
				elseif UnitHealthScale <= Health80 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.14})
				elseif UnitHealthScale <= Health90 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.15})
				elseif UnitIsVulnerable then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.16})
				else
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.17})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and RestorationHeals_Instant_WildGrowth and (RestorationHeals_WildGrowth or RestorationHeals_WildGrowth2) and (RestorationSaves.RestorationOption_Effect == 1 or RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not WildGrowthCD then
			--强力
				if UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.2})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.3})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.4})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.5})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.6})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.7})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.71})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=0.72})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and RestorationHeals_Instant_WildGrowth and RestorationHeals_WildGrowth and (RestorationSaves.RestorationOption_Effect == 2 or RestorationSaves.RestorationOption_Effect == 3) and not WildGrowthCD then
			--正常、省蓝
				if UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.9})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.91})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.92})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.93})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.94})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.95})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.96})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=0.97})
				end
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Swiftmend_SpellID) and guid == UnitGUID("player") and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=1})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=1.01})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=1.011})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=1.02})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=1.1})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Swiftmend_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=1.5})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Swiftmend_SpellID) and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Overgrowth_SpellID) and not OvergrowthCD and BeCastOvergrowth then
				Overgrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.001})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.01})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.011})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.0111})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.01111})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.0112})
			elseif IsPlayerSpell(Lifebloom_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.012})
			elseif IsPlayerSpell(Swiftmend_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.013})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.1})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.2})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and (UnitHasThreat or UnitTankHasLifebloom) and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.5})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and not IsSpecialHealsUnit and UnitAffectingCombat(unitid) and UnitTankHasLifebloom and IsPlayerSpell(392410) and RestorationSaves.RestorationOption_Heals_HealTank and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and not RestorationHeals_SwiftmendCD then
				if IsPlayerSpell(Cenarion_Ward_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RejuvenationCanRefresh then
					CenarionWard(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=2.505})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (NotRestorationHeals_UnitHasCastLifebloom or RestorationHeals_Photosynthesis) and LifebloomTarget then
				unitid = LifebloomTarget
				guid = UnitGUID(unitid)
				Lifebloom(unitid, guid)
				LifebloomTarget_In_HealsUnitPriority = 1
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=3})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=3.5})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=4})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=4.1})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=4.11})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=4.2})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and not IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.05})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.1})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.2})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.21})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.211})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.22})
			elseif IsPlayerSpell(Lifebloom_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.3})
			elseif IsPlayerSpell(Swiftmend_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.4})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.41})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.42})
			elseif IsPlayerSpell(Nourish_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.421})
			elseif IsPlayerSpell(Regrowth_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.4211})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.422})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.43})
			elseif IsPlayerSpell(Swiftmend_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.44})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.45})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.46})
			elseif IsPlayerSpell(Nourish_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.461})
			elseif IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.4611})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.462})
			elseif IsPlayerSpell(Lifebloom_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.47})
			elseif IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.48})	
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.49})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.491})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=5.5})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.1})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.109})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.11})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.12})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.13})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.14})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.15})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=6.16})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=7})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=7.1})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=7.12})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=7.13})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=7.14})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=8})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=9})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=9.1})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=9.2})
			elseif UnitHealthScale <= Health99 and UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=9.3})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid Moveing", Priority=9.4})
			elseif RestorationSaves.RestorationOption_Effect == 1 and not RestorationHeals_DoNotHealsLowMana then
			--强力
				if UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.8})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong Moveing", Priority=10.9})
				end
			elseif RestorationSaves.RestorationOption_Effect == 2 and not RestorationHeals_DoNotHealsLowMana then
			--正常
				if UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=11})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal Moveing", Priority=12.8})
				end
			elseif RestorationSaves.RestorationOption_Effect == 3 and not RestorationHeals_DoNotHealsLowMana then
			--省蓝
				if UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize Moveing", Priority=13})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize Moveing", Priority=13.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize Moveing", Priority=13.2})
				end
			end
		else
		--非移动状态-团刷
			if IsPlayerSpell(Barkskin_SpellID) and UnitHealthScale <= Health50 and guid == UnitGUID("player") and UnitAffectingCombat("player") and not BarkskinCD and not AuraUtil.FindAuraByName('铁木树皮', "player", "HELPFUL") then
				Barkskin(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.001})
			elseif IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and UnitHealthScale <= Health70 and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.003})
			elseif RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.004})
			elseif RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and IsPlayerSpell(Regrowth_SpellID) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.005})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.01})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.02})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.03})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.04})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.05})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.06})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.07})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.08})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.09})
			elseif UnitHealthScale <= Health45 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.091})
			elseif UnitHealthScale <= Health80 and not DirectSingleHealItemCD and (UnitHasThreat or UnitTankHasLifebloom) and (DirectSingleHealItemID == 147007 or DirectSingleHealItemID == 151957 or DirectSingleHealItemID == 160649) and not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL") then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.092})
			elseif UnitHealthScale <= Health30 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.093})
			elseif UnitHealthScale <= Health40 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.094})
			elseif UnitHealthScale <= Health50 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.095})
			elseif UnitHealthScale <= Health60 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.096})
			elseif IsPlayerSpell(Swiftmend_SpellID) and Swiftmend_CenarionWard and UnitHasCenarionWard and RestorationHeals_CanSwiftmendThisUnit then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.099})
			elseif IsPlayerSpell(Grove_Guardians_SpellID) and RestorationHeals_Grove_Guardians and not Grove_GuardiansCD then
				if UnitHealthScale <= Health25 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0991})
				elseif UnitHealthScale <= Health40 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0992})
				elseif UnitHealthScale <= Health55 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0993})
				elseif UnitHealthScale <= Health70 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0994})
				elseif UnitHealthScale <= Health80 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0995})
				elseif UnitHealthScale <= Health90 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0996})
				elseif UnitIsVulnerable then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0997})
				else
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.0998})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and (RestorationHeals_WildGrowth or RestorationHeals_WildGrowth2) and (RestorationSaves.RestorationOption_Effect == 1 or RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and ((not RestorationHeals_NoCastingAuras and not Restoration_CanNotMovingCast()) or RestorationHeals_Instant_WildGrowth) and not WildGrowthCD then
			--强力
				if IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health25 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.1})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health30 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.11})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health35 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.12})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health40 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.13})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health45 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.14})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health50 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.15})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health55 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.16})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health60 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.17})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health65 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.18})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health70 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.19})
				elseif UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.2})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.3})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.4})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.5})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.6})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.7})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.71})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=0.72})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and RestorationHeals_WildGrowth and (RestorationSaves.RestorationOption_Effect == 2 or RestorationSaves.RestorationOption_Effect == 3) and ((not RestorationHeals_NoCastingAuras and not Restoration_CanNotMovingCast()) or RestorationHeals_Instant_WildGrowth) and not WildGrowthCD then
			--正常、省蓝
				if IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health25 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.8})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health30 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.81})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health35 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.82})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health40 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.83})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health45 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.84})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health50 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.85})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health55 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.86})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health60 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.87})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health65 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.88})
				elseif IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitHealthScale <= Health70 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and UnitCastingInfo("player") ~= '野性成长' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.89})
				elseif UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.9})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.91})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.92})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.93})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.94})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.95})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.96})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=0.97})
				end
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and IsSpecialHealsUnit and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1.01})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and IsSpecialHealsUnit and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1.02})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Regrowth_SpellID) and IsSpecialHealsUnit then
				if IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1.03})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1.04})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1.1})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=1.5})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Overgrowth_SpellID) and not OvergrowthCD and BeCastOvergrowth then
				Overgrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.001})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health55 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.002})
			elseif IsPlayerSpell(Lifebloom_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health55 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.01})
			elseif IsPlayerSpell(Swiftmend_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health55 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.02})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.03})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health60 and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.039})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health60 and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.04})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.05})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.06})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.07})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.1})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.2})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and (UnitHasThreat or UnitTankHasLifebloom) and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.5})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and not IsSpecialHealsUnit and UnitAffectingCombat(unitid) and UnitTankHasLifebloom and IsPlayerSpell(392410) and RestorationSaves.RestorationOption_Heals_HealTank and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and not RestorationHeals_SwiftmendCD then
				if IsPlayerSpell(Cenarion_Ward_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RejuvenationCanRefresh then
					CenarionWard(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=2.505})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and not IsPlayerSpell(158478) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=3})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Regrowth_SpellID) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=4})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=4.1})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=4.5})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and not RestorationHeals_LowMana then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and not IsPlayerSpell(158478) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.1})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (NotRestorationHeals_UnitHasCastLifebloom or RestorationHeals_Photosynthesis) and LifebloomTarget then
				unitid = LifebloomTarget
				guid = UnitGUID(unitid)
				Lifebloom(unitid, guid)
				LifebloomTarget_In_HealsUnitPriority = 1
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.5})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health80 and HealerEngineHeals_HealAurasUnitID and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.512})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.513})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.514})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health55 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.515})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health60 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.516})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health65 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.517})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health70 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.518})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and not HealerEngineHeals_HealAurasNoOver and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.519})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health55 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.52})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health60 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.521})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health65 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.522})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health70 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.523})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and not HealerEngineHeals_HealAurasNoOver and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.524})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.6})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.61})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.611})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.62})
			elseif IsPlayerSpell(Regrowth_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.63})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.64})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.65})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.651})
			elseif IsPlayerSpell(Lifebloom_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.66})
			elseif IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.67})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.671})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.672})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.673})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.674})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.675})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=5.676})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=6})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=6.1})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=6.2})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=6.3})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=6.4})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=6.5})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and not IsPlayerSpell(158478) and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.1})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.11})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.2})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.3})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.31})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.32})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.33})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.34})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.35})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.36})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.37})
			elseif UnitHealthScale <= Health45 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Abundance and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.379})
			elseif UnitHealthScale <= Health45 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.38})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.39})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Abundance and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.399})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.4})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Abundance and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.409})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.41})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Abundance and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.419})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.42})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.43})
			elseif UnitHealthScale <= Health65 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Abundance and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.439})
			elseif UnitHealthScale <= Health65 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_LowMana2 or RestorationSaves.RestorationOption_Effect == 1) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.44})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.45})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=7.46})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=8})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=9})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=10})
			elseif UnitHealthScale <= Health99 and UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=10.1})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Raid", Priority=10.2})
			elseif RestorationSaves.RestorationOption_Effect == 1 and not RestorationHeals_DoNotHealsLowMana then
			--强力
				if UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=12})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=12.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and not Restoration_AutoDPS_SunfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.8})
				elseif IsPlayerSpell(Regrowth_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidStrong", Priority=13.9})
				end
			elseif RestorationSaves.RestorationOption_Effect == 2 and not RestorationHeals_DoNotHealsLowMana then
			--正常
				if UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=14})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.8})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and not Restoration_AutoDPS_SunfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.9})
				elseif IsPlayerSpell(Regrowth_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or not IsPlayerSpell(Nourish_SpellID)) and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.91})
				elseif IsPlayerSpell(Nourish_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidNormal", Priority=15.92})
				end
			elseif RestorationSaves.RestorationOption_Effect == 3 and not RestorationHeals_DoNotHealsLowMana then
			--省蓝
				if UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize", Priority=16})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize", Priority=16.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize", Priority=16.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and not Restoration_AutoDPS_SunfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize", Priority=16.3})
				elseif IsPlayerSpell(Regrowth_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or not IsPlayerSpell(Nourish_SpellID)) and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize", Priority=16.4})
				elseif IsPlayerSpell(Nourish_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="RaidEconomize", Priority=16.5})
				end
			end
		end
	end
	
	if RestorationStatusRestorationHealsParty then
		if Restoration_CanNotMovingCast() and not AuraUtil.FindAuraByName('化身：生命之树', "player", "HELPFUL") and not AuraUtil.FindAuraByName('自然迅捷', "player", "HELPFUL") then
		--移动状态-小队
			if IsPlayerSpell(Barkskin_SpellID) and UnitHealthScale <= Health50 and guid == UnitGUID("player") and UnitAffectingCombat("player") and not BarkskinCD and not AuraUtil.FindAuraByName('铁木树皮', "player", "HELPFUL") then
				Barkskin(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.001})
			elseif IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and UnitHealthScale <= Health70 and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.003})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.01})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.02})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.03})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.04})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.05})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.06})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.07})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.08})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.09})
			elseif UnitHealthScale <= Health45 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.091})
			elseif UnitHealthScale <= Health80 and not DirectSingleHealItemCD and (UnitHasThreat or UnitTankHasLifebloom) and (DirectSingleHealItemID == 147007 or DirectSingleHealItemID == 151957 or DirectSingleHealItemID == 160649) and not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL") then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.092})
			elseif UnitHealthScale <= Health30 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.093})
			elseif UnitHealthScale <= Health40 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.094})
			elseif UnitHealthScale <= Health50 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.095})
			elseif UnitHealthScale <= Health60 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.096})
			elseif IsPlayerSpell(Swiftmend_SpellID) and Swiftmend_CenarionWard and UnitHasCenarionWard and RestorationHeals_CanSwiftmendThisUnit then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.099})
			elseif IsPlayerSpell(Grove_Guardians_SpellID) and RestorationHeals_Grove_Guardians and not Grove_GuardiansCD then
				if UnitHealthScale <= Health25 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0991})
				elseif UnitHealthScale <= Health40 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0992})
				elseif UnitHealthScale <= Health55 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0993})
				elseif UnitHealthScale <= Health70 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0994})
				elseif UnitHealthScale <= Health80 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0995})
				elseif UnitHealthScale <= Health90 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0996})
				elseif UnitIsVulnerable then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0997})
				else
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.0998})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and RestorationHeals_Instant_WildGrowth and (RestorationHeals_WildGrowth or RestorationHeals_WildGrowth2) and (RestorationSaves.RestorationOption_Effect == 1 or RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not WildGrowthCD then
			--强力
				if UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.1})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.2})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.3})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.4})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.5})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.6})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.61})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=0.62})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and RestorationHeals_Instant_WildGrowth and RestorationHeals_WildGrowth and (RestorationSaves.RestorationOption_Effect == 2 or RestorationSaves.RestorationOption_Effect == 3) and not WildGrowthCD then
			--正常、省蓝
				if UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.7})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.8})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.9})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.91})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.92})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.93})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.94})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=0.95})
				end
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Swiftmend_SpellID) and guid == UnitGUID("player") and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=1})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=1.01})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=1.011})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=1.02})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=1.1})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Swiftmend_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=2})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Overgrowth_SpellID) and not OvergrowthCD and BeCastOvergrowth then
				Overgrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=2.001})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and (UnitHasThreat or UnitTankHasLifebloom) and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=2.5})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and not IsSpecialHealsUnit and UnitAffectingCombat(unitid) and UnitTankHasLifebloom and IsPlayerSpell(392410) and RestorationSaves.RestorationOption_Heals_HealTank and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and not RestorationHeals_SwiftmendCD then
				if IsPlayerSpell(Cenarion_Ward_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RejuvenationCanRefresh then
					CenarionWard(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=2.505})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Swiftmend_SpellID) and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=3})
			elseif UnitHealthScale <= Health25 and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.01})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.011})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.0111})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.01111})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.0112})
			elseif IsPlayerSpell(Lifebloom_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.012})
			elseif IsPlayerSpell(Swiftmend_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health70 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.013})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.1})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.2})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=4.5})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Swiftmend_SpellID) and guid == UnitGUID("player") and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=5})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=5.01})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=5.011})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=5.02})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=5.1})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Swiftmend_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=6})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=7})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=8})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and guid == UnitGUID("player") and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=9})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=9.01})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=9.011})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=9.02})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=9.1})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not UnitHasRejuvenation or not RestorationHeals_SwiftmendCD) then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (NotRestorationHeals_UnitHasCastLifebloom or RestorationHeals_Photosynthesis) and LifebloomTarget then
				unitid = LifebloomTarget
				guid = UnitGUID(unitid)
				Lifebloom(unitid, guid)
				LifebloomTarget_In_HealsUnitPriority = 1
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.513})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.514})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5141})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.51411})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5142})
			elseif IsPlayerSpell(Lifebloom_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.515})
			elseif IsPlayerSpell(Swiftmend_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and UnitHealthScale <= Health70 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.516})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5161})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5162})
			elseif IsPlayerSpell(Nourish_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.51621})
			elseif IsPlayerSpell(Regrowth_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.516211})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.51622})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5163})
			elseif IsPlayerSpell(Swiftmend_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5164})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5165})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5166})
			elseif IsPlayerSpell(Nourish_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.51661})
			elseif IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.516611})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.51662})
			elseif IsPlayerSpell(Lifebloom_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5167})
			elseif IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.5168})	
			elseif IsPlayerSpell(Rejuvenation_SpellID) and DA_UnitGroupRolesAssigned(unitid) == "TANK" and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (select(3, GetInstanceInfo()) == 8 or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.521})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and DA_UnitGroupRolesAssigned(unitid) == "TANK" and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and (select(3, GetInstanceInfo()) == 8 or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=10.522})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not RestorationHeals_LowMana or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Effect ~= 3 and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=11})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=11.1})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=11.11})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=11.2})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.01})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.02})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.1})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.11})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.12})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.13})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.14})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=12.15})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=13})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=13.1})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=13.12})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=13.13})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=13.14})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and (not RestorationHeals_LowMana or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Effect ~= 3 and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=13.15})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=14})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=15})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=16})
			elseif UnitHealthScale <= Health99 and UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=16.1})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=16.2})
			elseif UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party Moveing", Priority=16.3})
			elseif RestorationSaves.RestorationOption_Effect == 1 and not RestorationHeals_DoNotHealsLowMana then
			--强力
				if IsActiveBattlefieldArena() and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=17.1})
				elseif IsActiveBattlefieldArena() and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=17.2})
				end
				if UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=18})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and guid == UnitGUID("player") and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=19})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=20})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=21})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and guid == UnitGUID("player") and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=22})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.8})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.9})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong Moveing", Priority=23.91})
				end
			elseif RestorationSaves.RestorationOption_Effect == 2 and not RestorationHeals_DoNotHealsLowMana then
			--正常
				if IsActiveBattlefieldArena() and UnitHealthScale <= Health95 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=23.92})
				elseif IsActiveBattlefieldArena() and UnitHealthScale <= Health95 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=23.93})
				end
				if UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=24})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and guid == UnitGUID("player") and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=25})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.8})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.9})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal Moveing", Priority=26.91})
				end
			elseif RestorationSaves.RestorationOption_Effect == 3 and not RestorationHeals_DoNotHealsLowMana then
			--省蓝
				if IsActiveBattlefieldArena() and UnitHealthScale <= Health90 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=26.92})
				elseif IsActiveBattlefieldArena() and UnitHealthScale <= Health90 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=26.93})
				end
				if UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=27})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=27.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=27.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=27.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=28})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize Moveing", Priority=29})
				end
			end
		else
		--非移动状态-小队
			if IsPlayerSpell(Barkskin_SpellID) and UnitHealthScale <= Health50 and guid == UnitGUID("player") and UnitAffectingCombat("player") and not BarkskinCD and not AuraUtil.FindAuraByName('铁木树皮', "player", "HELPFUL") then
				Barkskin(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.001})
			elseif IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and UnitHealthScale <= Health70 and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.003})
			elseif RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Nourish_Regrowth then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.004})
			elseif RestorationHeals_AlertSpellGUID and RestorationHeals_AlertSpellGUID == guid and IsPlayerSpell(Regrowth_SpellID) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.005})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.01})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.02})
			elseif UnitHealthScale <= Health20 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.03})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.04})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.05})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.06})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid == UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD and not AuraUtil.FindAuraByName('树皮术', "player", "HELPFUL") then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.07})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.08})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.09})
			elseif UnitHealthScale <= Health45 and IsPlayerSpell(Ironbark_SpellID) and not IsSpecialHealsUnit and guid ~= UnitGUID("player") and (UnitHasThreat or UnitTankHasLifebloom) and UnitAffectingCombat(unitid) and not IronbarkCD then
				Ironbark(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.091})
			elseif UnitHealthScale <= Health80 and not DirectSingleHealItemCD and (UnitHasThreat or UnitTankHasLifebloom) and (DirectSingleHealItemID == 147007 or DirectSingleHealItemID == 151957 or DirectSingleHealItemID == 160649) and not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL") then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.092})
			elseif UnitHealthScale <= Health30 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.093})
			elseif UnitHealthScale <= Health40 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.094})
			elseif UnitHealthScale <= Health50 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.095})
			elseif UnitHealthScale <= Health60 and not DirectSingleHealItemCD and (DirectSingleHealItemID ~= 147007 or not AuraUtil.FindAuraByName('指引之手', unitid, "HELPFUL")) then
				Restoration_UseDirectSingleHealItem(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.096})
			elseif IsPlayerSpell(Swiftmend_SpellID) and Swiftmend_CenarionWard and UnitHasCenarionWard and RestorationHeals_CanSwiftmendThisUnit then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.099})
			elseif IsPlayerSpell(Grove_Guardians_SpellID) and RestorationHeals_Grove_Guardians and not Grove_GuardiansCD then
				if UnitHealthScale <= Health25 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0991})
				elseif UnitHealthScale <= Health40 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0992})
				elseif UnitHealthScale <= Health55 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0993})
				elseif UnitHealthScale <= Health70 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0994})
				elseif UnitHealthScale <= Health80 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0995})
				elseif UnitHealthScale <= Health90 then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0996})
				elseif UnitIsVulnerable then
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0997})
				else
					Grove_Guardians(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.0998})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and (RestorationHeals_WildGrowth or RestorationHeals_WildGrowth2) and (RestorationSaves.RestorationOption_Effect == 1 or RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and ((not RestorationHeals_NoCastingAuras and not Restoration_CanNotMovingCast()) or RestorationHeals_Instant_WildGrowth) and not WildGrowthCD then
			--强力
				if UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.1})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.2})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.3})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.4})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.5})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.6})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.61})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=0.62})
				end
			elseif IsPlayerSpell(Wild_Growth_SpellID) and RestorationHeals_WildGrowth and (RestorationSaves.RestorationOption_Effect == 2 or RestorationSaves.RestorationOption_Effect == 3) and ((not RestorationHeals_NoCastingAuras and not Restoration_CanNotMovingCast()) or RestorationHeals_Instant_WildGrowth) and not WildGrowthCD then
			--正常、省蓝
				if UnitHealthScale <= Health25 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.7})
				elseif UnitHealthScale <= Health40 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.8})
				elseif UnitHealthScale <= Health55 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.9})
				elseif UnitHealthScale <= Health70 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.91})
				elseif UnitHealthScale <= Health80 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.92})
				elseif UnitHealthScale <= Health90 then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.93})
				elseif UnitIsVulnerable then
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.94})
				else
					WildGrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=0.95})
				end
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=1})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and IsSpecialHealsUnit and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=1.01})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and IsSpecialHealsUnit and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=1.02})
			elseif UnitHealthScale <= Health99 and IsPlayerSpell(Regrowth_SpellID) and IsSpecialHealsUnit then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=1.03})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=1.04})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=1.1})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2})
			elseif UnitHealthScale <= Health25 and IsPlayerSpell(Regrowth_SpellID) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.5})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Regrowth_SpellID) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.55})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Overgrowth_SpellID) and not OvergrowthCD and BeCastOvergrowth then
				Overgrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.551})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health55 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.552})
			elseif IsPlayerSpell(Lifebloom_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health55 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.61})
			elseif IsPlayerSpell(Swiftmend_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health55 and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.62})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.63})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health60 and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.639})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and UnitHealthScale <= Health60 and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.64})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.65})
			elseif IsPlayerSpell(Nourish_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and BeCastNourish_Regrowth and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.66})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAurasWarn and HealerEngineHeals_HealAurasWarnUnitID and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.67})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.68})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellRejuvenationGUID and RestorationHeals_AlertSpellRejuvenationGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.69})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.691})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.7})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.701})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.702})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.703})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.704})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.705})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Swiftmend_SpellID) and IsPlayerSpell(392356) and not RestorationHeals_SwiftmendCD and RestorationHeals_CanSwiftmendThisUnit and not Reforestation_Will_IncarnationTreeofLife then
				Swiftmend(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.706})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.71})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.72})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.73})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.74})
			elseif UnitHealthScale <= Health75 and IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=2.75})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.1})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and not IsPlayerSpell(158478) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.15})
			elseif UnitHealthScale <= Health35 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.16})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (NotRestorationHeals_UnitHasCastLifebloom or RestorationHeals_Photosynthesis) and LifebloomTarget then
				unitid = LifebloomTarget
				guid = UnitGUID(unitid)
				Lifebloom(unitid, guid)
				LifebloomTarget_In_HealsUnitPriority = 1
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health80 and HealerEngineHeals_HealAurasUnitID and RestorationHeals_Clearcasting and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.212})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.213})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngine_UnitHasHealAuras and HealerEngineHeals_HealAurasUnitID and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.214})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health55 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.215})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health60 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.216})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health65 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.217})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health70 and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.218})
			elseif IsPlayerSpell(Regrowth_SpellID) and HealerEngine_UnitHasHealAuras and not HealerEngineHeals_HealAurasNoOver and HealerEngineHeals_HealAurasUnitID and not RestorationHeals_Instant_Nourish_Regrowth and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or RestorationHeals_Abundance or not IsPlayerSpell(Nourish_SpellID)) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.219})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health55 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.22})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health60 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.221})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health65 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.222})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and UnitHealthScale <= Health70 and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.223})
			elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and HealerEngine_UnitHasHealAuras and not HealerEngineHeals_HealAurasNoOver and HealerEngineHeals_HealAurasUnitID and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or RestorationHeals_Instant_Nourish_Regrowth) then
				Nourish_Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.224})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2241})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2242})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.22421})
			elseif IsPlayerSpell(Lifebloom_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2243})
			elseif IsPlayerSpell(Regrowth_SpellID) and (RestorationHeals_HealBreakoutSpellAOE or HealerEngineHeals_HealBreakoutSpellUnitID) and UnitHealthScale <= Health85 and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2244})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2245})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2246})
			elseif IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.22461})
			elseif IsPlayerSpell(Lifebloom_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2247})
			elseif IsPlayerSpell(Regrowth_SpellID) and RestorationHeals_AlertSpellBreakoutGUID and RestorationHeals_AlertSpellBreakoutGUID == guid and UnitHealthScale <= Health85 and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
				Regrowth(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.2248})	
			elseif IsPlayerSpell(Rejuvenation_SpellID) and DA_UnitGroupRolesAssigned(unitid) == "TANK" and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (select(3, GetInstanceInfo()) == 8 or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.231})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and DA_UnitGroupRolesAssigned(unitid) == "TANK" and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and (select(3, GetInstanceInfo()) == 8 or RestorationSaves.RestorationOption_Effect == 1) and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.232})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.3})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.31})
			elseif UnitHealthScale <= Health30 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.4})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.5})
			elseif UnitHealthScale <= Health50 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.6})
			elseif UnitHealthScale <= Health60 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
				Rejuvenation(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=3.61})
			elseif UnitHealthScale <= Health90 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and (UnitHasThreat or UnitTankHasLifebloom) and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=4})
			elseif IsPlayerSpell(Rejuvenation_SpellID) and not IsSpecialHealsUnit and UnitAffectingCombat(unitid) and UnitTankHasLifebloom and IsPlayerSpell(392410) and RestorationSaves.RestorationOption_Heals_HealTank and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and not RestorationHeals_SwiftmendCD then
				if IsPlayerSpell(Cenarion_Ward_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RejuvenationCanRefresh then
					CenarionWard(unitid, guid)
				elseif IsPlayerSpell(Rejuvenation_SpellID) then
					Rejuvenation(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=4.05})
			elseif UnitHealthScale <= Health80 and IsPlayerSpell(Cenarion_Ward_SpellID) and not IsSpecialHealsUnit and not RestorationHeals_CenarionWardCD and not UnitHasCenarionWard and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
				CenarionWard(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=5})
			elseif UnitHealthScale <= Health40 and IsPlayerSpell(Regrowth_SpellID) then
				if IsPlayerSpell(Swiftmend_SpellID) and RestorationHeals_CanSwiftmendThisUnit and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=6})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=7})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=9.1})
			elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) then
				if IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) then
					Swiftmend(unitid, guid)
				elseif IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and RestorationHeals_Instant_Nourish_Regrowth then
					Nourish_Regrowth(unitid, guid)
				elseif IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
				end
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=9.5})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Invigorate_SpellID) and not RestorationHeals_InvigorateCD and RestorationHeals_SwiftmendCD and RestorationHeals_CanInvigorateThisUnit then
				Invigorate(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=9.51})
			elseif UnitHealthScale <= Health70 and IsPlayerSpell(Lifebloom_SpellID) and LifebloomCanRefresh then
				Lifebloom(unitid, guid)
				table.insert(HealsUnitPriority, {UnitID=unitid, Mode="Party", Priority=10.5})
			elseif RestorationSaves.RestorationOption_Effect == 1 then
			--强力
				if IsActiveBattlefieldArena() and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=10.91})
				elseif IsActiveBattlefieldArena() and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=10.92})
				end
				if UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=11})
				elseif UnitHealthScale <= Health55 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=11.1})
				elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=11.2})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=12})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=13})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and guid == UnitGUID("player") and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=14})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=14.5})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=15})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=15.5})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=16})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=17})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=18})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=18.1})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=18.2})
				elseif UnitHealthScale <= Health99 and UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=18.3})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=18.4})
				elseif UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=18.5})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=19})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=19.5})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and guid == UnitGUID("player") and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=20})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not UnitHasWildGrowth and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=21.8})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=22})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=22.5})
				elseif IsPlayerSpell(Regrowth_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth and not RestorationHeals_DoNotHealsLowMana then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyStrong", Priority=23})
				end
			elseif RestorationSaves.RestorationOption_Effect == 2 then
			--正常
				if IsActiveBattlefieldArena() and UnitHealthScale <= Health95 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=23.1})
				elseif IsActiveBattlefieldArena() and UnitHealthScale <= Health95 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=23.2})
				end
				if UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=24})
				elseif UnitHealthScale <= Health55 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=25})
				elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=26})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=27})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=28})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and guid == UnitGUID("player") and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=29})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=30})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=31})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=32})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=33})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=34})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=35})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=35.1})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=35.2})
				elseif UnitHealthScale <= Health99 and UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=35.3})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=35.4})
				elseif UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=35.5})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (UnitHasThreat or UnitTankHasLifebloom) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=36})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and guid == UnitGUID("player") and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=37})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=38})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasWildGrowth and RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and not UnitHasRejuvenation and not UnitHasRejuvenationGermination then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsVulnerable and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and RestorationHeals_AlertSpellAOE and UnitIsPlayer(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.4})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.5})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.6})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.7})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=39.8})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=40})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=40.5})
				elseif IsPlayerSpell(Regrowth_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or not IsPlayerSpell(Nourish_SpellID)) and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth and not RestorationHeals_DoNotHealsLowMana then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=41})
				elseif IsPlayerSpell(Nourish_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Nourish_Regrowth and not RestorationHeals_DoNotHealsLowMana then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyNormal", Priority=42})
				end
			elseif RestorationSaves.RestorationOption_Effect == 3 then
			--省蓝
				if IsActiveBattlefieldArena() and UnitHealthScale <= Health90 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=42.1})
				elseif IsActiveBattlefieldArena() and UnitHealthScale <= Health90 and DA_UnitIsArenaChosen(unitid) >= 1 and IsPlayerSpell(Rejuvenation_SpellID) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=42.2})
				end
				if UnitHealthScale <= Health55 and IsPlayerSpell(Swiftmend_SpellID) and not RestorationHeals_SwiftmendCD and not Swiftmend_CenarionWard and RestorationHeals_CanSwiftmendThisUnit and Restoration_GetUnitHealthScaleContrastToTimeline(1, unitid) == "Fall" and (not IsPlayerSpell(392410) or not RestorationSaves.RestorationOption_Heals_HealTank) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Swiftmend(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=42.5})
				elseif UnitHealthScale <= Health55 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=43})
				elseif UnitHealthScale <= Health55 and IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=44})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=45})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and guid == UnitGUID("player") and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=46})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and guid == UnitGUID("player") and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=47})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=48})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and (UnitHasThreat or UnitTankHasLifebloom) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=49})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Nourish_SpellID) and BeCastNourish_Regrowth and ((not RestorationHeals_Abundance and not RestorationHeals_Clearcasting) or RestorationHeals_Instant_Nourish_Regrowth) and ((not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras) or (RestorationHeals_Instant_Nourish_Regrowth)) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=50})
				elseif UnitHealthScale <= Health70 and IsPlayerSpell(Regrowth_SpellID) and (not RestorationHeals_NoCastingAuras or RestorationHeals_Instant_Regrowth) and UnitCastingInfo("player") ~= '滋养' and UnitCastingInfo("player") ~= '愈合' then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=51})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=52})
				elseif UnitHealthScale <= Health80 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=52.1})
				elseif UnitHealthScale <= Health90 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=52.2})
				elseif UnitHealthScale <= Health99 and UnitIsVulnerable and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=52.3})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=52.4})
				elseif UnitHealthScale <= Health75 and IsPlayerSpell(Rejuvenation_SpellID) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and (UnitHasThreat or UnitTankHasLifebloom) and not UnitHasWildGrowth and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=53})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and HealerEngineHeals_HealAurasLowUnitID and HealerEngineHeals_HealAurasLowHigh and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=53.1})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitIsVulnerable and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=53.2})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and (RestorationSaves.RestorationOption_Heals_AllRejuvenation or (RestorationHeals_DynamicHealOfBoss and RestorationStatusRestorationHealsParty) or HealerEngineHeals_AdvanceRejuvenation or Restoration_AffixesCrackUnitDying or (RestorationDBMWillAoe and RestorationSaves.RestorationOption_Heals_DBMWillRejuvenation)) and UnitIsPlayer(unitid) and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=53.3})
				elseif IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not UnitHasRejuvenation and not UnitHasRejuvenationGermination and not RestorationHeals_LowMana and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=54})
				elseif UnitHealthScale <= Health99 and IsPlayerSpell(Rejuvenation_SpellID) and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (not UnitHasRejuvenation or not UnitHasRejuvenationGermination) and IsPlayerSpell(155675) and (RestorationHeals_Innervate or RestorationHeals_DynamicHealOfBoss or HealerEngineHeals_AdvanceRejuvenation) and not RestorationHeals_DoNotHealsLowMana then
					Rejuvenation(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=55})
				elseif IsPlayerSpell(Regrowth_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and (RestorationHeals_Innervate or RestorationHeals_Clearcasting or not IsPlayerSpell(Nourish_SpellID)) and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Regrowth and not RestorationHeals_DoNotHealsLowMana then
					Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=56})
				elseif IsPlayerSpell(Nourish_SpellID) and RestorationSaves.RestorationOption_Heals_HealTank and (not IsPlayerSpell(392410) or not IsPlayerSpell(102351)) and not Restoration_AutoDPS_SunfireTarget and not Restoration_AutoDPS_MoonfireTarget and UnitTankHasLifebloom and UnitAffectingCombat(unitid) and not Restoration_CanNotMovingCast() and not RestorationHeals_NoCastingAuras and not RestorationHeals_Instant_Nourish_Regrowth and not RestorationHeals_DoNotHealsLowMana then
					Nourish_Regrowth(unitid, guid)
					table.insert(HealsUnitPriority, {UnitID=unitid, Mode="PartyEconomize", Priority=57})
				end
			end
		end
	end
end