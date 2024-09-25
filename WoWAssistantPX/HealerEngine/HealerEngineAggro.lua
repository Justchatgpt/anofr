--仇恨监测

function HealerEngine_GetAggro(unitid)
	local status = UnitThreatSituation(unitid)

	if status and status >= 2 then
		for k, v in ipairs(HealerEngineHeals_AggroTarget) do --遍历表格, 看目标是否已存在表格内
			if UnitGUID(unitid) == UnitGUID(v) then --目标存在表格内
				HealerEngineHeals_AggroTarget_UnitIsInTable = 1
				break
			end
		end
		if not HealerEngineHeals_AggroTarget_UnitIsInTable then
			table.insert(HealerEngineHeals_AggroTarget, unitid) --写入表格内
		end
		HealerEngineHeals_AggroTarget_UnitIsInTable = nil
	end
end