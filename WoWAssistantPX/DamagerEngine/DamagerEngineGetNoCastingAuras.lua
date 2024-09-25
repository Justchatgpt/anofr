--不要读条Auras监测
local DamagerEngineGetNoCastingAuras = CreateFrame("Frame")

local DebuffCache = {
	--DEBUFF
	--{Name = "昏睡", ID = 81075, Instance = "菲拉斯-加德米尔噩梦龙人-测试"}, 
	{Name = "践踏", ID = 240447, Instance = "大秘境-词缀"}, 
	{Name = "扼息暗影", ID = 422806, Instance = "暗焰裂口"}, 
}

local NoCastingSpellCache = {
	--读条技能
	--{Name = "寒冰箭", ID = 13322, Instance = "艾尔文森林-流浪巫师-测试"}, 
	{Name = "挫志嚎叫", ID = 196543, Instance = "英灵殿-芬雷尔"}, 
	{Name = "蛮横怒吼", ID = 199726, Instance = "英灵殿-小怪"}, 
	{Name = "强力践踏", ID = 227363, Instance = "卡拉赞-猎手阿图门"}, 
	{Name = "践踏", ID = 247733, Instance = "侵入点-深渊领主维尔姆斯"}, 
	{Name = "音速尖啸", ID = 266106, Instance = "地渊孢林-小怪"}, 
	{Name = "震耳咆哮", ID = 257732, Instance = "自由镇-小怪"}, 
	{Name = "打断怒吼", ID = 342135, Instance = "伤逝剧场"}, 
	{Name = "雷音贯耳", ID = 339415, Instance = "伤逝剧场-无堕者哈夫"}, 
	--{Name = "大地震颤", ID = 62325, Instance = "古达克-莫拉比"},
	--{Name = "恐怖咆哮", ID = 341887, Instance = "乌特加德城堡-掠夺者因格瓦尔"},
	--{Name = "阻断暴雨", ID = 381516, Instance = "红玉新生法池-基拉卡与厄克哈特·风脉"},
	{Name = "瓦解怒吼", ID = 427609, Instance = "圣焰隐修院-小怪"},
	--{Name = "剧烈震颤", ID = 451871, Instance = "格瑞姆巴托-小怪"},--可打断技能
	{Name = "震耳咆哮", ID = 436679, Instance = "尼鲁巴尔王宫-小怪"},
}

DamagerEngineGetNoCastingAuras:RegisterEvent("UNIT_SPELLCAST_START")

function DamagerEngine_GetNoCastingAuras()
	if not DamagerEngineDps_InterruptCastIng then
		DamagerEngine_NoCastingAuras = nil
		DamagerEngine_NoChannelAuras = nil
	end

	local index1 = 1
	while true do
		local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = DA_UnitDebuff("player", index1)
		if not spellID1 then
			break
		end
		local timeLeft = expires1 and expires1 > GetTime() and (expires1 - GetTime()) or 0
		--DEBUFF剩余时间
		for i = 1, #DebuffCache do
			if name1 == DebuffCache[i].Name then
				--print(name1.." ID: "..spellID1)
			end
			if spellID1 == DebuffCache[i].ID then
				if timeLeft < 0.25 then
					DA_SpellStopCasting()
					--读条时遇到不要读条Auras则中断施法
				end
				if timeLeft < 1.5 then
					DamagerEngine_NoCastingAuras = 1
				end
				DamagerEngine_NoChannelAuras = 1
				--引导技能提前保护
				if (UnitCastingInfo("player") or UnitChannelInfo("player")) and timeLeft < 0.25 then
					DA_SpellStopCasting()
					--读条时遇到不要读条Auras则中断施法
				end
				
				break
			end
		end
		index1 = index1 + 1
	end
	--DeBuff
end

DamagerEngineGetNoCastingAuras:SetScript("OnEvent", function(self, event, ...)
	if not BalanceCycleStart and not FeralCycleStart and not RestorationCycleStart then return end
	local unitid, _, spellID = ...
	if not unitid then return end
	local spell = DA_GetSpellInfo(spellID)
	if UnitIsFriend(unitid, "player") then return end
	for i = 1, #NoCastingSpellCache do
		if spell == NoCastingSpellCache[i].Name then
			--print(spell.." InterruptCastID: "..spellID)
		end
		if spellID == NoCastingSpellCache[i].ID then
			local name, text, texture, startTime, endTime, isTradeSkill, castID, notInterruptible = UnitCastingInfo(unitid)
			local interruptcastingTime = (endTime - startTime)/1000
			local t3 = interruptcastingTime - 0.25
			local t4 = interruptcastingTime + 0.1
			if t3 < 0 then t3 = 0 end
			if t4 < 0 then t4 = 0 end
			
			C_Timer.After(t3, function()
				DamagerEngine_NoCastingAuras = 1
				DamagerEngineDps_InterruptCastIng = 1
				DA_SpellStopCasting()
				--读条时遇到不要读条施法则中断施法
			end)
			DamagerEngine_NoChannelAuras = 1
			--引导技能提前保护
			C_Timer.After(t4, function()
				DamagerEngine_NoCastingAuras = nil
				DamagerEngine_NoChannelAuras = nil
				DamagerEngineDps_InterruptCastIng = nil
			end)
		end
	end
end)