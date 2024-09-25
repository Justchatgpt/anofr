--获取特殊治疗目标

local SpecialHealsUnitCache = {
	--{Name = "训练假人", GUID = 113967, Type = "", Instance = "梦境林地"},
	{Name = "受难之魂", GUID = 204773, Type = "", Instance = "大秘境"},
	-- {Name = "塞塔里斯的化身", GUID = 133392, Type = "", Instance = "塞塔里斯神庙"},
	-- {Name = "剥离之魂", GUID = 171577, Type = "", Instance = "纳斯利亚堡-猎手阿尔迪莫"},
	-- {Name = "精华之泉", GUID = 165778, Type = "", Instance = "纳斯利亚堡-太阳之王的救赎"},
	-- {Name = "凯尔萨斯·逐日者", GUID = 165759, Type = "", Instance = "纳斯利亚堡-太阳之王的救赎"},
	-- {Name = "卡多雷精魂", GUID = 207800, Type = "", Instance = "阿梅达希尔，梦境之愿-火光之龙菲莱克"},
}

function HealerEngine_GetSpecialHealsUnit(Unit)
	local SpecialHealsUnitExists = nil
	for k, v in ipairs(SpecialHealsUnitCache) do
		if DA_ObjectId(Unit) == v.GUID then
			if v.GUID == 133392 and not UnitExists("boss1") then
				--[塞塔里斯的化身]不在BOSS战中,不治疗
				return
			end
			if v.GUID == 165759 and DA_ObjectId("boss2") == 165805 then
				--[凯尔萨斯·逐日者]凯尔萨斯之影存在时,不治疗
				return
			end
			SpecialHealsUnitExists = 1
			break
		end
	end
	if SpecialHealsUnitExists then
		return true
	else
		return false
	end
end