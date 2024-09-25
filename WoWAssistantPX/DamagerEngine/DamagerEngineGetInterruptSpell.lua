--获取打断法术

local NoInterruptSpellCache = {
	--不打断的法术
	--{Name = "寒冰箭", ID = 13322, Instance = "艾尔文森林-流浪巫师-测试"}, 
	{Name = "邪能箭", ID = 237578, Instance = "永夜大教堂-小怪"}, 
	{Name = "星辰冲击", ID = 253061, Instance = "安托鲁斯，燃烧王座-寂灭者阿古斯"}, 
	{Name = "暗影之矛", ID = 305136, Instance = "罪魂之塔-凇心间隙-强化的凇心特工"}, 
	{Name = "暗影割裂", ID = 304946, Instance = "罪魂之塔-凇心间隙-黑暗晋升者科鲁斯"}, 
}

function DamagerEngineGetInterruptSpell(Unit)
	--常规技能打断
	local NoInterruptSpell = nil
	local name1, text1, texture1, startTime1, endTime1, isTradeSkill1, castID1, notInterruptible1, spellid1 = UnitCastingInfo(Unit)
	local name2, text2, texture2, startTime2, endTime2, isTradeSkill2, notInterruptible2 = UnitChannelInfo(Unit)
	if notInterruptible1 or notInterruptible2 then
		DamagerEngine_IsNotInterruptibleSpell = 1
		return
	end
	
	if name1 then
		--读条法术
		
		local timeStart1 = GetTime() - (startTime1 / 1000)
		--读条法术已吟唱时间(秒)
		local timeFinish1 = (endTime1 / 1000) - GetTime()
		--读条法术剩余时间(秒)
		
		for k, v in ipairs(NoInterruptSpellCache) do
			if spellid1 == v.ID then
				NoInterruptSpell = 1
			end
		end
		if NoInterruptSpell then
			return
		else
			if timeStart1 > 0.25 and timeFinish1 < 0.75 and timeFinish1 > 0.1 then
			--读条法术已吟唱0.25秒,且剩余时间小于0.75秒大于0.1秒
				DamagerEngineInterruptSpell = 1
				DamagerEngineInterruptSpellTarget = Unit
				return true
			end
		end
	end
	
	if name2 then
		--引导法术
		
		local timeStart2 = GetTime() - (startTime2 / 1000)
		--引导法术已吟唱时间(秒)
		local timeFinish2 = (endTime2 / 1000) - GetTime()
		--引导法术剩余时间(秒)
		
		for k, v in ipairs(NoInterruptSpellCache) do
			if name2 == v.Name then
				NoInterruptSpell = 1
			end
		end
		if NoInterruptSpell then
			return
		else
			if timeStart2 > 0.25 and timeFinish2 > 1 then
			--引导法术已吟唱0.25秒,且剩余时间大于1秒
				DamagerEngineInterruptSpell = 1
				DamagerEngineInterruptSpellTarget = Unit
				return true
			end
		end
	end
end

function DamagerEngineGetControlInterruptSpell(Unit)
	--控制技能打断
	if DA_GetUnitIsBoss(Unit) or AuraUtil.FindAuraByName('鲜血脓液', Unit, "HELPFUL") or UnitHealth(Unit) < UnitHealthMax("player") * 0.5 then return end
	--单位免疫控制技能
	local NoInterruptSpell = nil
	local name1, text1, texture1, startTime1, endTime1, isTradeSkill1, castID1, notInterruptible1, spellid1 = UnitCastingInfo(Unit)
	local name2, text2, texture2, startTime2, endTime2, isTradeSkill2, notInterruptible2 = UnitChannelInfo(Unit)
	if notInterruptible1 or notInterruptible2 then
		DamagerEngine_IsNotInterruptibleSpell = 1
	end
	
	if name1 then
		--读条法术
		
		local timeStart1 = GetTime() - (startTime1 / 1000)
		--读条法术已吟唱时间(秒)
		local timeFinish1 = (endTime1 / 1000) - GetTime()
		--读条法术剩余时间(秒)
		
		for k, v in ipairs(NoInterruptSpellCache) do
			if spellid1 == v.ID then
				NoInterruptSpell = 1
			end
		end
		if NoInterruptSpell then
			return
		else
			if timeStart1 > 0.25 and timeFinish1 < 1 and timeFinish1 > 0.15 and not DamagerEngineGetImmuneControlUnit(Unit) then
			--读条法术已吟唱0.25秒,且剩余时间小于1秒大于0.15秒
				DamagerEngineControlInterruptSpell = 1
				DamagerEngineControlInterruptSpellTarget = Unit
				return true
			end
		end
	end
	
	if name2 then
		--引导法术
		
		local timeStart2 = GetTime() - (startTime2 / 1000)
		--引导法术已吟唱时间(秒)
		local timeFinish2 = (endTime2 / 1000) - GetTime()
		--引导法术剩余时间(秒)
		
		for k, v in ipairs(NoInterruptSpellCache) do
			if name2 == v.Name then
				NoInterruptSpell = 1
			end
		end
		if NoInterruptSpell then
			return
		else
			if timeStart2 > 0.25 and timeFinish2 > 1 and not DamagerEngineGetImmuneControlUnit(Unit) then
			--引导法术已吟唱0.25秒,且剩余时间大于1秒
				DamagerEngineControlInterruptSpell = 1
				DamagerEngineControlInterruptSpellTarget = Unit
				return true
			end
		end
	end
end