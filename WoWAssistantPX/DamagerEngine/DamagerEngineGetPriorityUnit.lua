--获取优先击杀目标

local PrioritySingleTatgetCache = {
	--{Name = "团队副本训练假人", GUID = 113964, Type = "", Instance = "梦境林地-测试"},
	{Name = "熔火焦皮", GUID = 101476, Type = "", Instance = "奈萨里奥的巢穴-地底之王达古尔"},
	{Name = "雷铸毁灭者", GUID = 102019, Type = "", Instance = "英灵殿-奥丁"},
	{Name = "复仇的化身", GUID = 100351, Type = "", Instance = "守望者地窟-科达娜·邪歌"},
	{Name = "针刺虫群", GUID = 101008, Type = "", Instance = "黑鸦堡垒-库塔洛斯·拉文凯斯"},
	{Name = "国王", GUID = 115388, Type = "", Instance = "卡拉赞-象棋大厅"},
	{Name = "奥术畸体之书", GUID = 120646, Type = "", Instance = "永夜大教堂-小怪"},
	{Name = "邪能传送门守卫", GUID = 118834, Type = "", Instance = "永夜大教堂-多玛塔克斯"},
	{Name = "勇气侍女", GUID = 117264, Type = "", Instance = "萨格拉斯之墓-堕落的化身"},
	{Name = "灵魂荆棘", GUID = 136330, Type = "", Instance = "维克雷斯庄园-魂缚巨像"},
	{Name = "蛛形地雷", GUID = 133482, Type = "", Instance = "暴富矿区！！-小怪"},
	{Name = "幻影克隆体", GUID = 165108, Type = "", Instance = "塞兹仙林的迷雾-唤雾者"},
}--(单体输出,不AOE)


local PriorityTatgetCache = {
	--{Name = "团队副本训练假人", GUID = 113964, Type = "", Instance = "梦境林地-测试"},
	{Name = "梦魇畸兽", GUID = 102962, Type = "", Instance = "黑心林地-大德鲁伊格兰达里斯"},
	{Name = "永冬之书", GUID = 118718, Type = "", Instance = "永夜大教堂-小怪"},
	{Name = "永默之书", GUID = 120727, Type = "", Instance = "永夜大教堂-小怪"},
	{Name = "狂暴的鞭笞者", GUID = 119169, Type = "", Instance = "永夜大教堂-阿格洛诺克斯"},
	{Name = "多汁的鞭笞者", GUID = 119144, Type = "", Instance = "永夜大教堂-阿格洛诺克斯"},
	{Name = "活体讽刺书籍", GUID = 121364, Type = "", Instance = "永夜大教堂-轻蔑的萨什比特"},
	{Name = "活体小说书籍", GUID = 121384, Type = "", Instance = "永夜大教堂-轻蔑的萨什比特"},
	{Name = "活体传记书籍", GUID = 121392, Type = "", Instance = "永夜大教堂-轻蔑的萨什比特"},
	{Name = "小鬼", GUID = 118801, Type = "", Instance = "永夜大教堂-多玛塔克斯"},
	{Name = "鬼焰魔女", GUID = 118802, Type = "", Instance = "永夜大教堂-多玛塔克斯"},
	{Name = "炽燃小鬼", GUID = 122783, Type = "", Instance = "安托鲁斯，燃烧王座-传送门守护者哈萨贝尔"},
	{Name = "阿曼苏尔的痛苦", GUID = 125837, Type = "", Instance = "安托鲁斯，燃烧王座-破坏魔女巫会"},
	{Name = "高戈奈斯的痛苦", GUID = 124164, Type = "", Instance = "安托鲁斯，燃烧王座-破坏魔女巫会"},
	{Name = "卡兹格罗斯的痛苦", GUID = 124166, Type = "", Instance = "安托鲁斯，燃烧王座-破坏魔女巫会"},
	{Name = "诺甘农的痛苦", GUID = 123503, Type = "", Instance = "安托鲁斯，燃烧王座-破坏魔女巫会"},
	{Name = "起源重组模块", GUID = 127809, Type = "", Instance = "安托鲁斯，燃烧王座-寂灭者阿古斯"},
	{Name = "复生图腾", GUID = 125977, Type = "", Instance = "阿塔达萨-沃卡尔"},
	{Name = "碎魂", GUID = 125828, Type = "", Instance = "阿塔达萨-亚兹玛"},
	{Name = "酒滴", GUID = 219301, Type = "", Instance = "燧酿酒庄-艾帕"},
	{Name = "失败批次", GUID = 220368, Type = "", Instance = "燧酿酒庄-艾帕"},
	{Name = "晦幽纺纱", GUID = 222700, Type = "", Instance = "千丝之城"},
	{Name = "血工", GUID = 215826, Type = "", Instance = "艾拉-卡拉，回响之城"},
	{Name = "黑血", GUID = 215968, Type = "", Instance = "艾拉-卡拉，回响之城"},
	{Name = "虚空碎块", GUID = 213684, Type = "", Instance = "驭雷栖巢"},
	{Name = "醒觉的虚空石", GUID = 213741, Type = "", Instance = "驭雷栖巢"},
	{Name = "水晶碎片", GUID = 214443, Type = "", Instance = "矶石宝库-斯卡莫拉克"},
	{Name = "爆地图腾", GUID = 214287, Type = "", Instance = "矶石宝库-小怪"},
}--先打血高的特殊目标(非单体输出,可AOE)


local PriorityTatgetReverseHealthCache = {
	--{Name = "团队副本训练假人", GUID = 113964, Type = "", Instance = "梦境林地-测试"},
	{Name = "无头骑士的脑袋", GUID = 23775, Type = "", Instance = "万圣节-无头骑士"},
	{Name = "烂皮灰熊", GUID = 95779, Type = "", Instance = "黑心林地-小怪"},
	{Name = "腐心守护者", GUID = 99359, Type = "", Instance = "黑心林地-小怪"},
	{Name = "枯碎蜘蛛", GUID = 97720, Type = "", Instance = "奈萨里奥的巢穴-洛克莫拉"},
	{Name = "嚎叫雕像", GUID = 100818, Type = "", Instance = "奈萨里奥的巢穴-乌拉罗格·塑山-分化"},
	{Name = "永不安息的灵魂", GUID = 99664, Type = "", Instance = "黑鸦堡垒-融合之魂"},
	{Name = "奥术仆从", GUID = 101549, Type = "", Instance = "黑鸦堡垒-小怪"},
	{Name = "复活的小伙伴", GUID = 101839, Type = "", Instance = "黑鸦堡垒-小怪"},
	{Name = "守夜水手", GUID = 97182, Type = "", Instance = "噬魂之喉-小怪"},
	{Name = "被禁锢的仆从", GUID = 98693, Type = "", Instance = "噬魂之喉-哈布隆"},
	{Name = "粉碎", GUID = 98761, Type = "", Instance = "噬魂之喉-哈布隆"},
	{Name = "毁灭触须", GUID = 99801, Type = "", Instance = "噬魂之喉-海拉"},
	{Name = "贪食触须", GUID = 100360, Type = "", Instance = "噬魂之喉-海拉"},
	{Name = "杜萝希·米尔斯迪普女伯爵", GUID = 114316, Type = "", Instance = "卡拉赞-莫罗斯"},
	{Name = "卡翠欧娜·沃宁迪女伯爵", GUID = 114317, Type = "", Instance = "卡拉赞-莫罗斯"},
	{Name = "拉弗·德鲁格尔男爵", GUID = 114318, Type = "", Instance = "卡拉赞-莫罗斯"},
	{Name = "吉拉·拜瑞巴克女伯爵", GUID = 114319, Type = "", Instance = "卡拉赞-莫罗斯"},
	{Name = "罗宾·达尼斯伯爵", GUID = 114320, Type = "", Instance = "卡拉赞-莫罗斯"},
	{Name = "克里斯宾·费伦斯伯爵", GUID = 114321, Type = "", Instance = "卡拉赞-莫罗斯"},
	{Name = "易爆能量", GUID = 114249, Type = "", Instance = "卡拉赞-馆长"},
	{Name = "守护者的影像", GUID = 114675, Type = "", Instance = "卡拉赞-麦迪文"},
	{Name = "王后", GUID = 115395, Type = "", Instance = "卡拉赞-象棋大厅"},
	{Name = "主教", GUID = 115402, Type = "", Instance = "卡拉赞-象棋大厅"},
	{Name = "骑士", GUID = 115406, Type = "", Instance = "卡拉赞-象棋大厅"},
	{Name = "城堡", GUID = 115407, Type = "", Instance = "卡拉赞-象棋大厅"},
	{Name = "暮色卫队哨兵", GUID = 104251, Type = "", Instance = "群星庭院-小怪"},
	{Name = "魔刃豹", GUID = 105699, Type = "", Instance = "群星庭院-小怪"},
	{Name = "邪脉植物学家", GUID = 118703, Type = "", Instance = "永夜大教堂"},
	{Name = "狂暴的鞭笞者", GUID = 119978, Type = "", Instance = "永夜大教堂-小怪"},
	{Name = "纳尔莎", GUID = 118705, Type = "", Instance = "永夜大教堂-小怪"},
	{Name = "孟菲斯托斯之影", GUID = 117590, Type = "", Instance = "永夜大教堂-多玛塔克斯"},
	{Name = "衰减时间粒子", GUID = 104676, Type = "", Instance = "暗夜要塞-时空畸体"},
	{Name = "寒冰魔灵", GUID = 107237, Type = "", Instance = "暗夜要塞-魔剑士奥鲁瑞尔"},
	{Name = "烈焰魔灵", GUID = 107285, Type = "", Instance = "暗夜要塞-魔剑士奥鲁瑞尔"},
	{Name = "奥术魔灵", GUID = 107287, Type = "", Instance = "暗夜要塞-魔剑士奥鲁瑞尔"},
	{Name = "燃烧的余烬", GUID = 104262, Type = "", Instance = "暗夜要塞-克洛苏斯"},
	{Name = "不应存在之物", GUID = 104880, Type = "", Instance = "暗夜要塞-占星师艾塔乌斯"},
	{Name = "离子球", GUID = 109804, Type = "", Instance = "暗夜要塞-高级植物学家特尔安"},
	{Name = "寄生鞭笞者", GUID = 109075, Type = "", Instance = "暗夜要塞-高级植物学家特尔安"},
	{Name = "午夜虹吸者", GUID = 111151, Type = "", Instance = "暗夜要塞-大魔导师艾利桑德"},
	{Name = "星界先知", GUID = 111170, Type = "", Instance = "暗夜要塞-大魔导师艾利桑德"},
	{Name = "暮光星舞者", GUID = 111164, Type = "", Instance = "暗夜要塞-大魔导师艾利桑德"},
	{Name = "递归元素", GUID = 105299, Type = "", Instance = "暗夜要塞-大魔导师艾利桑德"},
	{Name = "加速元素", GUID = 105301, Type = "", Instance = "暗夜要塞-大魔导师艾利桑德"},
	{Name = "审判官维斯瑞兹", GUID = 104536, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "库拉兹玛尔", GUID = 104537, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "诱捕者德佐克斯", GUID = 104534, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "阿扎格力姆", GUID = 105295, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "贝瑟瑞斯", GUID = 107232, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "古尔丹之眼", GUID = 105630, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "强化古尔丹之眼", GUID = 106545, Type = "", Instance = "暗夜要塞-古尔丹"},
	{Name = "哀嚎的映像", GUID = 119107, Type = "", Instance = "萨格拉斯之墓-堕落的化身"},
	{Name = "屠戮者", GUID = 122773, Type = "", Instance = "安托鲁斯，燃烧王座-加洛西灭世者"},
	{Name = "歼灭者", GUID = 122778, Type = "", Instance = "安托鲁斯，燃烧王座-加洛西灭世者"},
	{Name = "邪能干扰器", GUID = 124207, Type = "", Instance = "安托鲁斯，燃烧王座-生命的缚誓者艾欧娜尔"},
	{Name = "邪丝蛛网", GUID = 122897, Type = "", Instance = "安托鲁斯，燃烧王座-传送门守护者哈萨贝尔"},
	{Name = "鲜血雕像", GUID = 134701, Type = "", Instance = "地渊孢林-长者莉娅克萨"},
	{Name = "灵魂汲取图腾", GUID = 135169, Type = "", Instance = "地渊孢林-小怪"},
	{Name = "血面兽", GUID = 137103, Type = "", Instance = "地渊孢林-不羁畸变怪"},
	{Name = "怪诞恐魔", GUID = 138187, Type = "", Instance = "地渊孢林-小怪"},
	{Name = "阿德里斯", GUID = 133379, Type = "", Instance = "塞塔里斯神庙-阿德里斯和阿斯匹克斯"},
	{Name = "缠绕的蛇群", GUID = 134388, Type = "", Instance = "塞塔里斯神庙-米利克萨"},
	{Name = "灾厄妖术师", GUID = 137204, Type = "", Instance = "塞塔里斯神庙-塞塔里斯的化身"},
	{Name = "神殿骑士", GUID = 134139, Type = "", Instance = "风暴神殿-小怪"},
	{Name = "小型水元素", GUID = 134828, Type = "", Instance = "风暴神殿-阿库希尔"},
	{Name = "抓地机械手", GUID = 134612, Type = "", Instance = "风暴神殿-阿库希尔"},
	{Name = "刻符者食客", GUID = 134150, Type = "", Instance = "风暴神殿-小怪"},
	{Name = "深海祭师", GUID = 134417, Type = "", Instance = "风暴神殿-小怪"},
	{Name = "被遗忘的居民", GUID = 136297, Type = "", Instance = "风暴神殿-小怪"},
	{Name = "被遗忘的居民", GUID = 136083, Type = "", Instance = "风暴神殿-低语者沃尔兹斯"},
	{Name = "亡触奴隶主", GUID = 135552, Type = "", Instance = "维克雷斯庄园-高莱克·图尔"},
	{Name = "大手大脚的仆从", GUID = 133361, Type = "", Instance = "维克雷斯庄园-贪食的拉尔"},
	{Name = "杰斯·豪里斯", GUID = 127484, Type = "", Instance = "托尔达戈-杰斯·豪里斯"},
	{Name = "铁潮打击者", GUID = 130400, Type = "", Instance = "自由镇-小怪"},
	{Name = "眩晕酒桶", GUID = 130896, Type = "", Instance = "自由镇-海盗议会"},
	{Name = "铁潮掷弹兵", GUID = 129758, Type = "", Instance = "自由镇-哈兰·斯威提"},
	{Name = "复生图腾", GUID = 127315, Type = "", Instance = "阿塔达萨-小怪"},
	{Name = "鎏金女祭司", GUID = 132126, Type = "", Instance = "阿塔达萨-女祭司阿伦扎"},
	{Name = "黄金之灵", GUID = 131009, Type = "", Instance = "阿塔达萨-女祭司阿伦扎"},
	{Name = "地怒者", GUID = 129802, Type = "", Instance = "暴富矿区！！-艾泽洛克"},
	{Name = "束缚恐魔", GUID = 137627, Type = "", Instance = "围攻伯拉勒斯-维克戈斯"},
	{Name = "攫握恐魔", GUID = 137405, Type = "", Instance = "围攻伯拉勒斯-维克戈斯"},
	{Name = "攻城恐魔", GUID = 137614, Type = "", Instance = "围攻伯拉勒斯-维克戈斯"},
	{Name = "攻城恐魔", GUID = 137625, Type = "", Instance = "围攻伯拉勒斯-维克戈斯"},
	{Name = "攻城恐魔", GUID = 137626, Type = "", Instance = "围攻伯拉勒斯-维克戈斯"},
	{Name = "压制战旗", GUID = 170234, Type = "", Instance = "伤逝剧场-无堕者哈夫"},
	{Name = "凋零淤泥喷射者", GUID = 174210, Type = "", Instance = "伤逝剧场-小怪"},
	{Name = "魔法炸弹", GUID = 169498, Type = "", Instance = "凋魂之殇-伊库斯博士"},
	{Name = "失灵的牙钻", GUID = 167962, Type = "", Instance = "彼界-小怪"},
	{Name = "破碎残影", GUID = 168326, Type = "", Instance = "彼界-穆厄扎拉"},
	{Name = "精华宝珠", GUID = 170452, Type = "", Instance = "罪魂之塔-上层区域-吞噬者苟克苏尔"},
	{Name = "渊誓护火者", GUID = 157571, Type = "", Instance = "罪魂之塔-灵魂熔炉"},
	{Name = "渊誓召火者", GUID = 157572, Type = "", Instance = "罪魂之塔-灵魂熔炉"},
	{Name = "弃誓小队长", GUID = 163520, Type = "", Instance = "晋升高塔-小怪"},
	{Name = "傲慢具象", GUID = 173729, Type = "", Instance = "大秘境"},
	{Name = "堕落的驯犬者", GUID = 164562, Type = "", Instance = "赎罪高塔-小怪"},
	{Name = "德鲁斯特碎枝者", GUID = 164926, Type = "", Instance = "塞兹仙林的迷雾-小怪"},
	{Name = "蔓生藤条", GUID = 168988, Type = "", Instance = "塞兹仙林的迷雾-小怪"},
	{Name = "纱雾照看者", GUID = 166299, Type = "", Instance = "塞兹仙林的迷雾-小怪"},
	{Name = "外科医生缝肉", GUID = 162689, Type = "", Instance = "通灵战潮-外科医生缝肉"},
	{Name = "缝合助理", GUID = 173044, Type = "", Instance = "通灵战潮-小怪"},
	{Name = "骷髅劫掠者", GUID = 165919, Type = "", Instance = "通灵战潮-小怪"},
	{Name = "佐尔拉姆斯通灵师", GUID = 163618, Type = "", Instance = "通灵战潮-小怪"},
	{Name = "凝结软泥", GUID = 165010, Type = "", Instance = "凋魂之殇-小怪"},
	{Name = "被召唤的暗影烈焰之灵", GUID = 40357, Type = "", Instance = "格瑞姆巴托-达加·燃影者"},
}--先打血低的特殊目标(非单体输出,可AOE)

function DamagerEngineGetSinglePriorityUnit(Unit)
	--(单体输出,不AOE)
	for k, v in ipairs(PrioritySingleTatgetCache) do
		if DA_ObjectId(Unit) == v.GUID then
			local name1, text1, texture1, startTime1, endTime1, isTradeSkill1, castID1, notInterruptible1, spellid1 = UnitCastingInfo(Unit)
			local name2, text2, texture2, startTime2, endTime2, isTradeSkill2, notInterruptible2 = UnitChannelInfo(Unit)
			
			if v.GUID == 101476 then
				--[熔火焦皮]
				local name1, icon1, count1, dispelType1, duration1, expires1, caster1, isStealable1, nameplateShowPersonal1, spellID1 = AuraUtil.FindAuraByName('水晶迸裂', Unit, "HELPFUL")
				local name2, icon2, count2, dispelType2, duration2, expires2, caster2, isStealable2, nameplateShowPersonal2, spellID2 = AuraUtil.FindAuraByName('炼狱升腾', Unit, "HELPFUL")
				count2 = count2 or 0
				if not name1 and count2 < 10 then
					--没撞山且[炼狱升腾]叠加不超过10层,不优先击杀
					return
				end
			end
			if v.GUID == 117264 and name1 ~= "净化协议" then
				--[勇气侍女]没读条净化协议,不优先击杀
				return
			end
			if v.GUID == 115388 and AuraUtil.FindAuraByName('王权', Unit, "HELPFUL") then
				--[国王]存在减伤BUFF,不优先击杀
				return
			end
			if v.GUID == 165108 and UnitHealthMax(Unit) - UnitHealth(Unit) < UnitHealthMax("player") * 0.3 then
				--[幻影克隆体]损失血量小于玩家血量的30%,不优先击杀
				return
			end
			
			DamagerEngine_AutoDPS_DPSTarget = Unit
			DamagerEngine_AutoDPS_SinglePriorityTatgetExists = 1
			break
		end
	end
end

function DamagerEngineGetPriorityUnit(Unit)
	--先打血高的特殊目标(非单体输出,可AOE)
	local PriorityTatgetExists = nil
	for k, v in ipairs(PriorityTatgetCache) do
		if DA_ObjectId(Unit) == v.GUID then
			local name1, text1, texture1, startTime1, endTime1, isTradeSkill1, castID1, notInterruptible1, spellid1 = UnitCastingInfo(Unit)
			local name2, text2, texture2, startTime2, endTime2, isTradeSkill2, notInterruptible2 = UnitChannelInfo(Unit)
			
			if (v.GUID == 105299 or v.GUID == 105301 or v.GUID == 119144) and UnitHealth(Unit) > UnitHealth("boss1") / 1.25 then
				--[递归元素]或[加速元素]或[多汁的鞭笞者]血量大于(BOSS血量/1.25),不优先攻击
				return
			end
	
			PriorityTatgetExists = 1
			break
		end
	end
	if PriorityTatgetExists then
		return true
	else
		return false
	end
end

function DamagerEngineGetPriorityUnitReverseHealth(Unit)
	--先打血低的特殊目标(非单体输出,可AOE)
	local PriorityTatgetReverseHealthExists = nil
	for k, v in ipairs(PriorityTatgetReverseHealthCache) do
		if DA_ObjectId(Unit) == v.GUID then
			local name1, text1, texture1, startTime1, endTime1, isTradeSkill1, castID1, notInterruptible1, spellid1 = UnitCastingInfo(Unit)
			local name2, text2, texture2, startTime2, endTime2, isTradeSkill2, notInterruptible2 = UnitChannelInfo(Unit)
			
			if (v.GUID == 105299 or v.GUID == 105301 or v.GUID == 119144) and UnitHealth(Unit) > UnitHealth("boss1") / 1.25 then
				--[递归元素]或[加速元素]或[多汁的鞭笞者]血量大于(BOSS血量/1.25),不优先攻击
				return
			end
			if v.GUID == 127315 and UnitHealth(Unit) / UnitHealthMax(Unit) == 1 then
				--[复生图腾]血量满,不攻击
				return
			end
	
			PriorityTatgetReverseHealthExists = 1
			break
		end
	end
	if PriorityTatgetReverseHealthExists then
		return true
	else
		return false
	end
end