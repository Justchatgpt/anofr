--获取不用爆发技能的情况

function DamagerEngineGetNoUsePowerfulSpell(Table)
	local DamagerEngine_IsNoUsePowerfulSpell = nil
	if not Table or (Table and #Table == 0) then return end
	for k, v in ipairs(Table) do
		if DA_ObjectId(v.Unit) == 174570 then
			--[群攻训练假人],不使用爆发技能(测试)
			--DamagerEngine_IsNoUsePowerfulSpell = 1
		end
		if DA_ObjectId(v.Unit) == 162309 and not AuraUtil.FindAuraByName('魂魄归体', "player", "HARMFUL") and DA_UnitGroupRolesAssigned("player") ~= "HEALER" then
			--伤逝剧场[库尔萨洛克],当玩家身上没有[魂魄归体]DEBUFF时,不使用爆发技能,治疗专精除外(不会点名治疗)
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 164567 and not AuraUtil.FindAuraByName('宗主之怒', v.Unit, "HARMFUL") then
			--塞兹仙林的迷雾[英格拉·马洛克],当[英格拉·马洛克]身上没有[宗主之怒]DEBUFF时,不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 166608 and UnitHealth(v.Unit) / UnitHealthMax(v.Unit) > 0.5 then
			--彼界[穆厄扎拉],不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 162060 and not AuraUtil.FindAuraByName('枯竭', v.Unit, "HARMFUL") then
			--晋升高塔[奥莱芙莉安],当[奥莱芙莉安]身上没有[枯竭]DEBUFF时,不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 163618 then
			--通灵战潮[佐尔拉姆斯通灵师],不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 163620 then
			--通灵战潮[烂吐],不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 164578 and AuraUtil.FindAuraByName('毒雾', "boss1", "HELPFUL") then
			--通灵战潮[缝肉的造物],当[外科医生缝肉]身上有[毒雾]BUFF时,不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 162693 and not AuraUtil.FindAuraByName('勇士之赐', "player", "HARMFUL") and DA_UnitGroupRolesAssigned("player") ~= "HEALER" then
			--通灵战潮[缚霜者纳尔佐],当玩家身上没有[勇士之赐]DEBUFF时,不使用爆发技能,治疗专精除外(不会点名治疗)
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
		if DA_ObjectId(v.Unit) == 164815 then
			--通灵战潮[缚霜者纳尔佐]-[佐尔拉姆斯虹吸者],不使用爆发技能
			DamagerEngine_IsNoUsePowerfulSpell = 1
			break
		end
	end
	if DamagerEngine_IsNoUsePowerfulSpell then
		return true
	else
		return false
	end
end