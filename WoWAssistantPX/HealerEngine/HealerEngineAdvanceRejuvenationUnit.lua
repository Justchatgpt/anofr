--获取是否存在需要预铺回春的敌对目标

local AdvanceRejuvenationUnitCache = {
	--{Name = "团队副本训练假人", GUID = 31146, Type = "", Instance = "暴风城-测试"},
	{Name = "傲慢具象", GUID = 173729, Type = "", Instance = "大秘境"},
	-- {Name = "哈尔吉亚斯的碎片", GUID = 164557, Type = "", Instance = "赎罪大厅"},
	-- {Name = "激怒之灵", GUID = 168934, Type = "", Instance = "彼界"},
	-- {Name = "炎缚火焰风暴", GUID = 189886, Type = "", Instance = "[红玉新生法池]"},
	-- {Name = "风暴引导者", GUID = 198047, Type = "", Instance = "[红玉新生法池]"},
	-- {Name = "大引导者莱瓦迪", GUID = 197535, Type = "", Instance = "[红玉新生法池]"},
}

function HealerEngine_GetAdvanceRejuvenationUnit()
	local AdvanceRejuvenationUnitExists = nil
	if not Restoration_EnemyCache then return end
	for k, v in ipairs(Restoration_EnemyCache) do
		for k2, v2 in ipairs(AdvanceRejuvenationUnitCache) do
			if DA_ObjectId(v.Unit) == v2.GUID then
				AdvanceRejuvenationUnitExists = 1
				break
			end
		end
	end
	if AdvanceRejuvenationUnitExists then
		HealerEngineHeals_AdvanceRejuvenation = 1
		return true
	else
		HealerEngineHeals_AdvanceRejuvenation = nil
		return false
	end
end