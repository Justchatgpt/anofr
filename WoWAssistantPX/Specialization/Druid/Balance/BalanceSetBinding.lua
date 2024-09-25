--设置按键
BalanceSetBinding = CreateFrame("Frame")
BalanceSetBinding:RegisterEvent("PLAYER_ENTERING_WORLD")
BalanceSetBinding:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
--当选择其他职责时排队准备进入副本时,刚好玩家在战斗中,导致不能正确设置按键.因此改为OnUpdate模式

function BalanceSetBindingSaveBindings()
	local bindingSet = GetCurrentBindingSet()
	if bindingSet == 1 or bindingSet == 2 then
		--print(bindingSet)
		SaveBindings(bindingSet)
	end
end

function BalanceSetBinding_OnEvent(self, event, ...)
	BalanceSetBinding_OnEventInterval = BalanceSetBinding_OnEventInterval or GetTime()
	if GetTime() - BalanceSetBinding_OnEventInterval > 1 then
		if DA_GetSpecialization() == 102 then
			DA_GetAssignSpellIDs(DA_CastLevelColorCache_Balance)
			--获取当前最高等级技能法术ID
			--print("当前[回春术]法术ID: " .. Rejuvenation_SpellID)
		end
		
		if not UnitAffectingCombat("player") and DA_GetSpecialization() == 102 then
			if not GetBindingKey("WoWAssistant_Replace") then
				SetBinding("F9", "WoWAssistant_Replace")
				--切换
				BalanceSetBindingSaveBindings()
			end
			if not GetBindingKey("WoWAssistant_Config") then
				SetBinding("F10", "WoWAssistant_Config")
				--设置
				BalanceSetBindingSaveBindings()
			end
			
			if not GetBindingKey("WoWAssistant_Start") and not GetBindingKey("WoWAssistant_Toggle") then
				SetBinding("F11", "WoWAssistant_Start")
				--启动
				BalanceSetBindingSaveBindings()
			end
			
			if not GetBindingKey("WoWAssistant_Stop") and not GetBindingKey("WoWAssistant_Toggle") then
				SetBinding("F12", "WoWAssistant_Stop")
				--停止
				BalanceSetBindingSaveBindings()
			end
			
			if BalanceCycleStart then
				if GetCVar("nameplateShowEnemies") ~= "1" then
					SetCVar('nameplateShowEnemies', 1)
					--显示敌对目标姓名板
				end
			end
		end
		BalanceSetBinding_OnEventInterval = nil
	end
end

function BalanceSetMacroButton()
	if DA_GetSpecialization() == 102 then
		local macros = {
			{framename = "DA_TARGETRAID1", button = "CTRL-NUMPAD1", macrotext = "/target raid1"},--1
			{framename = "DA_TARGETRAID2", button = "CTRL-NUMPAD2", macrotext = "/target raid2"},--2
			{framename = "DA_TARGETRAID3", button = "CTRL-NUMPAD3", macrotext = "/target raid3"},--3
			{framename = "DA_TARGETRAID4", button = "CTRL-NUMPAD4", macrotext = "/target raid4"},--4
			{framename = "DA_TARGETRAID5", button = "CTRL-NUMPAD5", macrotext = "/target raid5"},--5
			{framename = "DA_TARGETRAID6", button = "CTRL-NUMPAD6", macrotext = "/target raid6"},--6
			{framename = "DA_TARGETRAID7", button = "CTRL-NUMPAD7", macrotext = "/target raid7"},--7
			{framename = "DA_TARGETRAID8", button = "CTRL-NUMPAD8", macrotext = "/target raid8"},--8
			{framename = "DA_TARGETRAID9", button = "CTRL-NUMPAD9", macrotext = "/target raid9"},--9
			{framename = "DA_TARGETRAID10", button = "CTRL-NUMPAD0", macrotext = "/target raid10"},--10
			{framename = "DA_TARGETRAID11", button = "ALT-NUMPAD1", macrotext = "/target raid11"},--11
			{framename = "DA_TARGETRAID12", button = "ALT-NUMPAD2", macrotext = "/target raid12"},--12
			{framename = "DA_TARGETRAID13", button = "ALT-NUMPAD3", macrotext = "/target raid13"},--13
			{framename = "DA_TARGETRAID14", button = "ALT-NUMPAD4", macrotext = "/target raid14"},--14
			{framename = "DA_TARGETRAID15", button = "ALT-NUMPAD5", macrotext = "/target raid15"},--15
			{framename = "DA_TARGETRAID16", button = "ALT-NUMPAD6", macrotext = "/target raid16"},--16
			{framename = "DA_TARGETRAID17", button = "ALT-NUMPAD7", macrotext = "/target raid17"},--17
			{framename = "DA_TARGETRAID18", button = "ALT-NUMPAD8", macrotext = "/target raid18"},--18
			{framename = "DA_TARGETRAID19", button = "ALT-NUMPAD9", macrotext = "/target raid19"},--19
			{framename = "DA_TARGETRAID20", button = "ALT-NUMPAD0", macrotext = "/target raid20"},--20
			{framename = "DA_TARGETRAID21", button = "ALT-CTRL-NUMPAD1", macrotext = "/target raid21"},--21
			{framename = "DA_TARGETRAID22", button = "ALT-CTRL-NUMPAD2", macrotext = "/target raid22"},--22
			{framename = "DA_TARGETRAID23", button = "ALT-CTRL-NUMPAD3", macrotext = "/target raid23"},--23
			{framename = "DA_TARGETRAID24", button = "ALT-CTRL-NUMPAD4", macrotext = "/target raid24"},--24
			{framename = "DA_TARGETRAID25", button = "ALT-CTRL-NUMPAD5", macrotext = "/target raid25"},--25
			{framename = "DA_TARGETRAID26", button = "ALT-CTRL-NUMPAD6", macrotext = "/target raid26"},--26
			{framename = "DA_TARGETRAID27", button = "ALT-CTRL-NUMPAD7", macrotext = "/target raid27"},--27
			{framename = "DA_TARGETRAID28", button = "ALT-CTRL-NUMPAD8", macrotext = "/target raid28"},--28
			{framename = "DA_TARGETRAID29", button = "ALT-CTRL-NUMPAD9", macrotext = "/target raid29"},--29
			{framename = "DA_TARGETRAID30", button = "ALT-CTRL-NUMPAD0", macrotext = "/target raid30"},--30
			{framename = "DA_TARGETRAID31", button = "CTRL-,", macrotext = "/target raid31"},--31
			{framename = "DA_TARGETRAID32", button = "CTRL-.", macrotext = "/target raid32"},--32
			{framename = "DA_TARGETRAID33", button = "CTRL-/", macrotext = "/target raid33"},--33
			{framename = "DA_TARGETRAID34", button = "CTRL-;", macrotext = "/target raid34"},--34
			{framename = "DA_TARGETRAID35", button = "CTRL-[", macrotext = "/target raid35"},--35
			{framename = "DA_TARGETRAID36", button = "CTRL-]", macrotext = "/target raid36"},--36
			{framename = "DA_TARGETRAID37", button = "CTRL-=", macrotext = "/target raid37"},--37
			{framename = "DA_TARGETRAID38", button = "ALT-,", macrotext = "/target raid38"},--38
			{framename = "DA_TARGETRAID39", button = "ALT-.", macrotext = "/target raid39"},--39
			{framename = "DA_TARGETRAID40", button = "ALT-/", macrotext = "/target raid40"},--40
			{framename = "DA_TARGETPARTY1", button = "ALT-;", macrotext = "/target party1"},--41
			{framename = "DA_TARGETPARTY2", button = "ALT-[", macrotext = "/target party2"},--42
			{framename = "DA_TARGETPARTY3", button = "ALT-]", macrotext = "/target party3"},--43
			{framename = "DA_TARGETPARTY4", button = "ALT-=", macrotext = "/target party4"},--44
			{framename = "DA_TARGETPLAYER", button = "SHIFT-,", macrotext = "/target player"},--45
			{framename = "DA_TARGETPARTYTARGET_HARM", button = "SHIFT-.", macrotext = "/target [@targettarget,harm]targettarget"},--46
			{framename = "DA_TARGETPARTYTARGET_HELP", button = "SHIFT-/", macrotext = "/target [@targettarget,help]targettarget"},--47
			{framename = "DA_TARGETFOCUS", button = "SHIFT-;", macrotext = "/target [@focus,exists]focus"},--48
			{framename = "DA_TARGETNEARESTFRIEND", button = "SHIFT-[", macrotext = "/targetfriend"},--49
			{framename = "DA_TARGETNEARESTENEMYPLAYER", button = "SHIFT-]", macrotext = "/targetenemyplayer"},--50
			{framename = "DA_TARGETNEARESTENEMY", button = "SHIFT-=", macrotext = "/targetenemy"},--51
			{framename = "DA_FOCUSTARGET", button = "ALT-CTRL-,", macrotext = "/focus [@target,exists]target"},--52
			{framename = "DA_TARGETBOSS1", button = "ALT-CTRL-.", macrotext = "/target [@boss1,exists]boss1"},--53
			{framename = "DA_TARGETBOSS2", button = "ALT-CTRL-/", macrotext = "/target [@boss2,exists]boss2"},--54
			{framename = "DA_TARGETBOSS3", button = "ALT-CTRL-;", macrotext = "/target [@boss3,exists]boss3"},--55
			{framename = "DA_TARGETBOSS4", button = "ALT-CTRL-[", macrotext = "/target [@boss4,exists]boss4"},--56
			{framename = "DA_TARGETBOSS5", button = "ALT-CTRL-]", macrotext = "/target [@boss5,exists]boss5"},--57
			
			{framename = "DA_TARGETARENA1", button = "ALT-SHIFT-,", macrotext = "/target [@Arena1,exists]Arena1"},--59
			{framename = "DA_TARGETARENA2", button = "ALT-SHIFT-.", macrotext = "/target [@Arena2,exists]Arena2"},--60
			{framename = "DA_TARGETARENA3", button = "ALT-SHIFT-/", macrotext = "/target [@Arena3,exists]Arena3"},--61
			{framename = "DA_TARGETARENA4", button = "ALT-SHIFT-;", macrotext = "/target [@Arena4,exists]Arena4"},--62
			{framename = "DA_TARGETARENA5", button = "ALT-SHIFT-[", macrotext = "/target [@Arena5,exists]Arena5"},--63
			
			{framename = "DA_TARGETCONTROLTARGET", button = "ALT-SHIFT-=", macrotext = "/targetexact 顺劈训练假人\n/targetexact 幻影仙狐"},--65
			{framename = "DA_STOPCASTING", button = "CTRL-NUMPADPLUS", macrotext = "/stopcasting"},--66
			{framename = "DA_USE_TRINKET13", button = "CTRL-NUMPADMINUS", macrotext = "/use 13"},--67
			{framename = "DA_USE_TRINKET14", button = "CTRL-NUMPADMULTIPLY", macrotext = "/use 14"},--68
			{framename = "DA_USE_HEALTHSTONE", button = "CTRL-NUMPADDIVIDE", macrotext = "/use 治疗石"},--69
			
			{framename = "DA_CAST_CANCELFORM", button = "SHIFT-NUMPADDIVIDE", macrotext = "/cancelform"},--77
			
			{framename = "DA_CAST_MOONFIRE", button = "CTRL-INSERT", macrotext = "/cast 月火术"},--78
			{framename = "DA_CAST_REJUVENATION", button = "CTRL-DELETE", macrotext = "/cast 回春术"},--79
			{framename = "DA_CAST_SUNFIRE", button = "CTRL-HOME", macrotext = "/cast 阳炎术"},--80
			{framename = "DA_CAST_REMOVE_CORRUPTION", button = "CTRL-END", macrotext = "/cast 清除腐蚀"},--81
			{framename = "DA_CAST_WRATH", button = "CTRL-PAGEUP", macrotext = "/cast 愤怒"},--82
			{framename = "DA_CAST_WILD_GROWTH", button = "CTRL-PAGEDOWN", macrotext = "/cast 野性成长"},--83
			{framename = "DA_CAST_STARFIRE", button = "CTRL-UP", macrotext = "/cast 星火术"},--84
			{framename = "DA_CAST_SOLAR_BEAM", button = "CTRL-LEFT", macrotext = "/cast 日光术"},--85
			{framename = "DA_CAST_SOOTHE", button = "CTRL-DOWN", macrotext = "/cast 安抚"},--86
			{framename = "DA_CAST_RENEWAL", button = "CTRL-RIGHT", macrotext = "/cast 甘霖"},--87
			{framename = "DA_CAST_INCAPACITATING_ROAR", button = "ALT-INSERT", macrotext = "/cast 夺魂咆哮"},--88
			{framename = "DA_CAST_MIGHTY_BASH", button = "ALT-DELETE", macrotext = "/cast 蛮力猛击"},--89
			{framename = "DA_CAST_REBIRTH", button = "ALT-HOME", macrotext = "/cast 复生"},--90
			{framename = "DA_CAST_HEART_OF_THE_WILD", button = "ALT-END", macrotext = "/cast 野性之心"},--91
			{framename = "DA_CAST_STARSURGE", button = "ALT-PAGEUP", macrotext = "/cast 星涌术"},--92
			{framename = "DA_CAST_NEW_MOON", button = "ALT-PAGEDOWN", macrotext = "/cast 新月"},--93
			{framename = "DA_CAST_WILD_MUSHROOM", button = "ALT-UP", macrotext = "/cast 野性蘑菇"},--94
			{framename = "DA_CAST_ELUNE_WRATH", button = "ALT-LEFT", macrotext = "/cast 艾露恩之怒"},--95
			{framename = "DA_CAST_CELESTIAL_ALIGNMENT", button = "ALT-DOWN", macrotext = "/cast [@player]超凡之盟"},--96
			{framename = "DA_CAST_STARFALL", button = "ALT-RIGHT", macrotext = "/cast 星辰坠落"},--97
			{framename = "DA_CAST_STELLAR_FLARE", button = "SHIFT-INSERT", macrotext = "/cast 星辰耀斑"},--98
			{framename = "DA_CAST_CONVOKE_THE_SPIRITS", button = "SHIFT-DELETE", macrotext = "/cast 万灵之召"},--99
			{framename = "DA_CAST_BERSERKING", button = "SHIFT-HOME", macrotext = "/cast 狂暴(种族特长)"},--100
			{framename = "DA_CAST_FORCE_OF_NATURE", button = "SHIFT-END", macrotext = "/cast [@player]自然之力"},--101
			{framename = "DA_CAST_WARRIOR_OF_ELUNE", button = "SHIFT-PAGEUP", macrotext = "/cast 艾露恩的战士"},--102
			{framename = "DA_CAST_BARKSKIN", button = "SHIFT-PAGEDOWN", macrotext = "/cast 树皮术"},--103
			
			{framename = "DA_CAST_BEAR_FORM", button = "SHIFT-LEFT", macrotext = "/cast [nostance:1]熊形态"},--105
			{framename = "DA_CAST_REGROWTH", button = "SHIFT-DOWN", macrotext = "/cast [@player]愈合"},--106
			{framename = "DA_CAST_MOONKIN_FORM", button = "SHIFT-RIGHT", macrotext = "/cast [nostance]枭兽形态"},--107
			{framename = "DA_CAST_NATURE_VIGIL", button = "ALT-CTRL-INSERT", macrotext = "/cast 自然的守护"},--108
			{framename = "DA_CAST_INNERVATE", button = "ALT-CTRL-DELETE", macrotext = "/cast 激活"},--109
			
			{framename = "DA_CAST_BEAR_FORM_RENEWAL_HEALTHSTONE", button = "ALT-SHIFT-END", macrotext = "/cast [nostance:1]熊形态\n/use [stance:1]炉铸候选者的纹章\n/cast [stance:1]甘霖\n/use [stance:1]治疗石"},--121
			{framename = "DA_CAST_BEAR_FORM_FRENZIED_REGENERATION", button = "ALT-SHIFT-PAGEUP", macrotext = "/cast [nostance:1]熊形态\n/cast [stance:1]狂暴回复"},--122
			
			{framename = "DA_CAST_ENTANGLING_ROOTS", button = "ALT-SHIFT-DOWN", macrotext = "/cast 纠缠根须"},--126
			{framename = "DA_CAST_MASS_ENTANGLEMENT", button = "ALT-SHIFT-RIGHT", macrotext = "/cast 群体缠绕"},--127
		}

		for _, macro in ipairs(macros) do
			DA_CreateMacroButton(macro.framename, macro.button, macro.macrotext)
		end
	end
end

BalanceSetBinding:SetScript("OnEvent", BalanceSetMacroButton)
BalanceSetBinding:SetScript("OnUpdate", BalanceSetBinding_OnEvent)