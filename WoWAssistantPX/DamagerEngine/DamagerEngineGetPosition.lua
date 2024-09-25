--职责监测
function DamagerEngine_GetPosition(unitid)
	local status = DA_UnitGroupRolesAssigned(unitid)
	--if WoWAssistantUnlocked and DA_GetNovaDistance("player", unitid) <= 40 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup()) and not UnitIsDeadOrGhost(unitid) then
	if DA_IsSpellInRange(Regrowth_SpellID, unitid) == 1 and not UnitIsCharmed(unitid) and UnitReaction("player", unitid) > 4 and UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and UnitIsVisible(unitid) and UnitPhaseReason(unitid)~=0 and UnitPhaseReason(unitid)~=1 and (UnitInRange(unitid) or not IsInGroup()) and not UnitIsDeadOrGhost(unitid) then
		table.insert(DamagerEngine_GroupMember, {
			Unit = unitid, 
			UnitAssigned = status, 
			UnitName = UnitName(unitid), 
			UnitGUID = UnitGUID(unitid), 
			UnitHealth = UnitHealth(unitid),
			UnitHealthMax = UnitHealthMax(unitid),
			UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
			UnitPower = UnitPower(unitid, 0),
			UnitPowerMax = UnitPowerMax(unitid, 0),
			UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
		}) --队友写入表格
		
		if status == "TANK" then
			table.insert(DamagerEngine_TankAssigned, {
				Unit = unitid, 
				UnitName = UnitName(unitid), 
				UnitGUID = UnitGUID(unitid), 
				UnitHealth = UnitHealth(unitid),
				UnitHealthMax = UnitHealthMax(unitid),
				UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
				UnitPower = UnitPower(unitid, 0),
				UnitPowerMax = UnitPowerMax(unitid, 0),
				UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
			}) --坦克写入表格
		end
		if status == "HEALER" then
			table.insert(DamagerEngine_HealerAssigned, {
				Unit = unitid, 
				UnitName = UnitName(unitid), 
				UnitGUID = UnitGUID(unitid), 
				UnitHealth = UnitHealth(unitid),
				UnitHealthMax = UnitHealthMax(unitid),
				UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
				UnitPower = UnitPower(unitid, 0),
				UnitPowerMax = UnitPowerMax(unitid, 0),
				UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
			}) --治疗写入表格
		end
		if status == "DAMAGER" or (unitid == "player" and DA_GetSpecialization() ~= 105) then
		--if status == "DAMAGER" then
			table.insert(DamagerEngine_DamagerAssigned, {
				Unit = unitid, 
				UnitName = UnitName(unitid), 
				UnitGUID = UnitGUID(unitid), 
				UnitHealth = UnitHealth(unitid),
				UnitHealthMax = UnitHealthMax(unitid),
				UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
				UnitPower = UnitPower(unitid, 0),
				UnitPowerMax = UnitPowerMax(unitid, 0),
				UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
			}) --伤害输出写入表格
		end
	end
	if UnitIsConnected(unitid) and UnitCanAssist("player", unitid) and (UnitInRange(unitid) or not IsInGroup()) and UnitIsDeadOrGhost(unitid) and not UnitHasIncomingResurrection(unitid) and not AuraUtil.FindAuraByName('正在复活', unitid, "HARMFUL") then
		if status == "TANK" then
			table.insert(DamagerEngine_TankAssignedDead, {
				Unit = unitid, 
				UnitName = UnitName(unitid), 
				UnitGUID = UnitGUID(unitid), 
				UnitHealth = UnitHealth(unitid),
				UnitHealthMax = UnitHealthMax(unitid),
				UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
				UnitPower = UnitPower(unitid, 0),
				UnitPowerMax = UnitPowerMax(unitid, 0),
				UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
			}) --阵亡的坦克写入表格
		end
		
		if status == "HEALER" then
			table.insert(DamagerEngine_HealerAssignedDead, {
				Unit = unitid, 
				UnitName = UnitName(unitid), 
				UnitGUID = UnitGUID(unitid), 
				UnitHealth = UnitHealth(unitid),
				UnitHealthMax = UnitHealthMax(unitid),
				UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
				UnitPower = UnitPower(unitid, 0),
				UnitPowerMax = UnitPowerMax(unitid, 0),
				UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
			}) --阵亡的治疗写入表格
		end
		
		if status == "DAMAGER" then
			table.insert(DamagerEngine_DamagerAssignedDead, {
				Unit = unitid, 
				UnitName = UnitName(unitid), 
				UnitGUID = UnitGUID(unitid), 
				UnitHealth = UnitHealth(unitid),
				UnitHealthMax = UnitHealthMax(unitid),
				UnitHealthScale = UnitHealth(unitid)/UnitHealthMax(unitid),
				UnitPower = UnitPower(unitid, 0),
				UnitPowerMax = UnitPowerMax(unitid, 0),
				UnitPowerScale = UnitPower(unitid, 0)/UnitPowerMax(unitid, 0),
			}) --阵亡的伤害输出写入表格
		end
	end
end
