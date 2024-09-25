--获取无仇恨类目标

local NoThreatUnit = {
-- Misc/Unknown
	[79987]  = "Training Dummy", 	          -- Location Unknown
	[92169]  = "Raider's Training Dummy",     -- Tanking (Eastern Plaguelands)
	[96442]  = "Training Dummy", 			  -- Damage (Location Unknown)
	[109595] = "Training Dummy",              -- Location Unknown
	[113963] = "Raider's Training Dummy", 	  -- Damage (Location Unknown)
	[131985] = "Dungeoneer's Training Dummy", -- Damage (Zuldazar)
	[131990] = "Raider's Training Dummy",     -- Tanking (Zuldazar)
	[132976] = "Training Dummy", 			  -- Morale Booster (Zuldazar)
-- Level 1
	[17578]  = "Hellfire Training Dummy",     -- Lvl 1 (The Shattered Halls)
	[60197]  = "Training Dummy",              -- Lvl 1 (Scarlet Monastery)
	[64446]  = "Training Dummy",              -- Lvl 1 (Scarlet Monastery)
	[144077] = "Training Dummy",              -- Lvl 1 (Dazar'alor) - Morale Booster
-- Level 3
	[44171]  = "Training Dummy",              -- Lvl 3 (New Tinkertown, Dun Morogh)
	[44389]  = "Training Dummy",              -- Lvl 3 (Coldridge Valley)
	[44848]  = "Training Dummy", 			  -- Lvl 3 (Camp Narache, Mulgore)
	[44548]  = "Training Dummy",              -- Lvl 3 (Elwynn Forest)
	[44614]  = "Training Dummy",              -- Lvl 3 (Teldrassil, Shadowglen)
	[44703]  = "Training Dummy", 			  -- Lvl 3 (Ammen Vale)
	[44794]  = "Training Dummy", 			  -- Lvl 3 (Dethknell, Tirisfal Glades)
	[44820]  = "Training Dummy",              -- Lvl 3 (Valley of Trials, Durotar)
	[44937]  = "Training Dummy",              -- Lvl 3 (Eversong Woods, Sunstrider Isle)
	[48304]  = "Training Dummy",              -- Lvl 3 (Kezan)
-- Level 55
	[32541]  = "Initiate's Training Dummy",   -- Lvl 55 (Plaguelands: The Scarlet Enclave)
	[32545]  = "Initiate's Training Dummy",   -- Lvl 55 (Eastern Plaguelands)
-- Level 60
	[32666]  = "Training Dummy",              -- Lvl 60 (Siege of Orgrimmar, Darnassus, Ironforge, ...)
-- Level 65
	[32542]  = "Disciple's Training Dummy",   -- Lvl 65 (Eastern Plaguelands)
-- Level 70
	[32667]  = "Training Dummy",              -- Lvl 70 (Orgrimmar, Darnassus, Silvermoon City, ...)
-- Level 75
	[32543]  = "Veteran's Training Dummy",    -- Lvl 75 (Eastern Plaguelands)
-- Level 80
	[31144]  = "Training Dummy",              -- Lvl 80 (Orgrimmar, Darnassus, Ironforge, ...)
	[32546]  = "Ebon Knight's Training Dummy",-- Lvl 80 (Eastern Plaguelands)
-- Level 85
	[46647]  = "Training Dummy",              -- Lvl 85 (Orgrimmar, Stormwind City)
-- Level 90
	[67127]  = "Training Dummy",              -- Lvl 90 (Vale of Eternal Blossoms)
-- Level 95
	[79414]  = "Training Dummy",              -- Lvl 95 (Broken Shore, Talador)
-- Level 100
	[87317]  = "Training Dummy",              -- Lvl 100 (Lunarfall, Frostwall) - Damage
	[87321]  = "Training Dummy",              -- Lvl 100 (Stormshield) - Healing
	[87760]  = "Training Dummy",              -- Lvl 100 (Frostwall) - Damage
	[88289]  = "Training Dummy",              -- Lvl 100 (Frostwall) - Healing
	[88316]  = "Training Dummy",              -- Lvl 100 (Lunarfall) - Healing
	[88835]  = "Training Dummy",              -- Lvl 100 (Warspear) - Healing
	[88906]  = "Combat Dummy",                -- Lvl 100 (Nagrand)
	[88967]  = "Training Dummy",              -- Lvl 100 (Lunarfall, Frostwall)
	[89078]  = "Training Dummy",              -- Lvl 100 (Frostwall, Lunarfall)
-- Levl 100 - 110
	[92164]  = "Training Dummy", 			  -- Lvl 100 - 110 (Dalaran) - Damage
	[92165]  = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (Eastern Plaguelands) - Damage
	[92167]  = "Training Dummy",              -- Lvl 100 - 110 (The Maelstrom, Eastern Plaguelands, The Wandering Isle)
	[92168]  = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (The Wandering Isles, Easter Plaguelands)
	[100440] = "Training Bag", 				  -- Lvl 100 - 110 (The Wandering Isles)
	[100441] = "Dungeoneer's Training Bag",   -- Lvl 100 - 110 (The Wandering Isles)
	[102045] = "Rebellious Wrathguard",       -- Lvl 100 - 110 (Dreadscar Rift) - Dungeoneer
	[102048] = "Rebellious Felguard",         -- Lvl 100 - 110 (Dreadscar Rift)
	[102052] = "Rebellious Imp", 			  -- Lvl 100 - 110 (Dreadscar Rift) - AoE
	[103402] = "Lesser Bulwark Construct",    -- Lvl 100 - 110 (Hall of the Guardian)
	[103404] = "Bulwark Construct",           -- Lvl 100 - 110 (Hall of the Guardian) - Dungeoneer
	[107483] = "Lesser Sparring Partner",     -- Lvl 100 - 110 (Skyhold)
	[107555] = "Bound Void Wraith",           -- Lvl 100 - 110 (Netherlight Temple)
	[107557] = "Training Dummy",              -- Lvl 100 - 110 (Netherlight Temple) - Healing
	[108420] = "Training Dummy",              -- Lvl 100 - 110 (Stormwind City, Durotar)
	[111824] = "Training Dummy", 			  -- Lvl 100 - 110 (Azsuna)
	[113674] = "Imprisoned Centurion",        -- Lvl 100 - 110 (Mardum, the Shattered Abyss) - Dungeoneer
	[113676] = "Imprisoned Weaver", 	      -- Lvl 100 - 110 (Mardum, the Shattered Abyss)
	[113687] = "Imprisoned Imp",              -- Lvl 100 - 110 (Mardum, the Shattered Abyss) - Swarm
	[113858] = "Training Dummy",              -- Lvl 100 - 110 (Trueshot Lodge) - Damage
	[113859] = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (Trueshot Lodge) - Damage
	[113862] = "Training Dummy",              -- Lvl 100 - 110 (Trueshot Lodge) - Damage
	[113863] = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 (Trueshot Lodge) - Damage
	[113871] = "Bombardier's Training Dummy", -- Lvl 100 - 110 (Trueshot Lodge) - Damage
	[113966] = "Dungeoneer's Training Dummy", -- Lvl 100 - 110 - Damage
	[113967] = "Training Dummy",              -- Lvl 100 - 110 (The Dreamgrove) - Healing
	[114832] = "PvP Training Dummy",          -- Lvl 100 - 110 (Stormwind City)
	[114840] = "PvP Training Dummy",          -- Lvl 100 - 110 (Orgrimmar)
-- Level 102
	[87318]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Lunarfall) - Damage
	[87322]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Stormshield) - Tank
	[87761]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Frostwall) - Damage
	[88288]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Frostwall) - Tank
	[88314]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Lunarfall) - Tank
	[88836]  = "Dungeoneer's Training Dummy", -- Lvl 102 (Warspear) - Tank
	[93828]  = "Training Dummy",              -- Lvl 102 (Hellfire Citadel)
	[97668]  = "Boxer's Trianing Dummy",      -- Lvl 102 (Highmountain)
	[98581]  = "Prepfoot Training Dummy",     -- Lvl 102 (Highmountain)
-- Level 110 - 120
	[126781] = "Training Dummy", 			  -- Lvl 110 - 120 (Boralus) - Damage
	[131989] = "Training Dummy", 			  -- Lvl 110 - 120 (Boralus) - Damage
	[131994] = "Training Dummy", 			  -- Lvl 110 - 120 (Boralus) - Healing
	[144082] = "Training Dummy",              -- Lvl 110 - 120 (Dazar'alor) - PVP Damage
	[144085] = "Training Dummy", 			  -- Lvl 110 - 120 (Dazar'alor) - Damage
	[144081] = "Training Dummy",              -- Lvl 110 - 120 (Dazar'alor) - Damage
	[153285] = "Training Dummy", 			  -- Lvl 110 - 120 (Ogrimmar) - Damage
	[153292] = "Training Dummy", 			  -- Lvl 110 - 120 (Stormwind) - Damage
-- Level 111 - 120
	[131997] = "Training Dummy", 			  -- Lvl 111 - 120 (Boralus, Zuldazar) - PVP Damage
	[131998] = "Training Dummy",              -- Lvl 111 - 120 (Boralus, Zuldazar) - PVP Healing
-- Level 112 - 120
	[144074] = "Training Dummy", 			  -- Lvl 112 - 120 (Dazar'alor) - PVP Healing
-- Level 112 - 122
	[131992] = "Dungeoneer's Training Dummy",  -- Lvl 112 - 122 (Boralus) - Tanking
-- Level 113 - 120 
	[132036] = "Training Dummy", 			  -- Lvl 113 - 120 (Boralus) - Healing
-- Level 113 - 122
	[144078] = "Dungeoneer's Training Dummy", -- Lvl 113 - 122 (Dazar'alor) - Tanking
-- Level 114 - 120
	[144075] = "Training Dummy", 			  -- Lvl 114 - 120 (Dazar'alor) - Healing
-- Level 60 
	[174569] = "Training Dummy",			  -- Lvl 60 (Ardenweald)
	[174570] = "Swarm Training Dummy",		  -- Lvl 60 (Ardenweald)
	[174571] = "Cleave Training Dummy",		  -- Lvl 60 (Ardenweald)
	[174487] = "Competent Veteran", 		  -- Lvl 60 (Location Unknown)
	[173942] = "Training Dummy",			  -- Lvl 60 (Revendreth)
	[175456] = "Swarm Training Dummy",		  -- Lvl 60 (Revendreth)
	[175455] = "Cleave Training Dummy",		  -- Lvl 60 (Revendreth)
-- Level 62
	[174484] = "Immovable Champion", 		  -- Lvl 62 (Location Unknown)
	[175449] = "Dungeoneer's Training Dummy", -- Lvl 62 (Revendreth)
	[173957] = "Necrolord's Resolve",		  -- Lvl 62 (Oribos)
	[173955] = "Pride's Resolve",		 	  -- Lvl 62 (Oribos)
	[173954] = "Nature's Resolve",		 	  -- Lvl 62 (Oribos)
	[173919] = "Valiant's Resolve",		 	  -- Lvl 62 (Oribos)
-- Level ??
	[24792]  = "Advanced Training Dummy",     -- Lvl ?? Boss (Location Unknown)
	[30527]  = "Training Dummy", 		      -- Lvl ?? Boss (Location Unknown)
	[31146]  = "Raider's Training Dummy",     -- Lvl ?? (Orgrimmar, Stormwind City, Ironforge, ...)
	[87320]  = "Raider's Training Dummy",     -- Lvl ?? (Lunarfall, Stormshield) - Damage
	[87329]  = "Raider's Training Dummy",     -- Lvl ?? (Stormshield) - Tank
	[87762]  = "Raider's Training Dummy",     -- Lvl ?? (Frostwall, Warspear) - Damage
	[88837]  = "Raider's Training Dummy",     -- Lvl ?? (Warspear) - Tank
	[92166]  = "Raider's Training Dummy",     -- Lvl ?? (The Maelstrom, Dalaran, Eastern Plaguelands, ...) - Damage
	[101956] = "Rebellious Fel Lord",         -- lvl ?? (Dreadscar Rift) - Raider
	[103397] = "Greater Bulwark Construct",   -- Lvl ?? (Hall of the Guardian) - Raider
	[107202] = "Reanimated Monstrosity", 	  -- Lvl ?? (Broken Shore) - Raider
	[107484] = "Greater Sparring Partner",    -- Lvl ?? (Skyhold)
	[107556] = "Bound Void Walker",           -- Lvl ?? (Netherlight Temple) - Raider
	[113636] = "Imprisoned Forgefiend",       -- Lvl ?? (Mardum, the Shattered Abyss) - Raider
	[113860] = "Raider's Training Dummy",     -- Lvl ?? (Trueshot Lodge) - Damage
	[113864] = "Raider's Training Dummy",     -- Lvl ?? (Trueshot Lodge) - Damage
	[70245]  = "Training Dummy",              -- Lvl ?? (Throne of Thunder)
	[113964] = "Raider's Training Dummy",     -- Lvl ?? (The Dreamgrove) - Tanking
	[131983] = "Raider's Training Dummy",     -- Lvl ?? (Boralus) - Damage
	[144086] = "Raider's Training Dummy",     -- Lvl ?? (Dazal'alor) - Damage
	[174565] = "Raider's Training Dummy",	  -- Lvl ?? (Ardenweald) 
	[174566] = "Dungeoneer's Tanking Dummy",  -- Lvl ?? (Ardenweald) 
	[174567] = "Raider's Training Dummy",	  -- Lvl ?? (Ardenweald) 
	[174568] = "Dungeoneer's Tanking Dummy",  -- Lvl ?? (Ardenweald) 
	[174491] = "Iron Tester", 				  -- Lvl ?? (Location Unknown)
	[174488] = "Unbreakable Defender", 		  -- Lvl ?? (Location Unknown)
	-- [174489] = "Necromantic Guide", 		  -- Lvl ?? (Location Unknown)
	[174489] = "Raider's Training Dummy",	  -- Lvl ?? (Revendreth)
	[175452] = "Raider's Training Dummy",	  -- Lvl ?? (Location Unknown)
	[175451] = "Dungeoneer's Tanking Dummy",  -- Lvl ?? (Revendreth)
	[154580] = "Reinforced Guardian", 		  -- Elysian Hold
	[154583] = "Stalward Guardian", 		  -- Elysian Hold
	[154585] = "Valiant's Resolve",			  -- Elysian Hold
	[154586] = "Stalward Phalanx", 			  -- Elysian Hold
	[154567] = "纯洁的净化", 			  -- 极乐堡
	[160325] = "谦逊的遵从", 			  -- 极乐堡
-- 其他
	[120651]  = "爆炸物",     -- 大秘境-词缀
	[109908]  = "梦魇畸兽",     -- 黑心林地-烂皮灰熊
	[102962]  = "梦魇畸兽",     -- 黑心林地-大德鲁伊格兰达里斯
	[100991]  = "纠缠之根",     -- 黑心林地-橡树之心
	[92387]  = "战争之鼓",     -- 奈萨里奥的巢穴-小怪
	[98081]  = "嚎叫雕像",     -- 奈萨里奥的巢穴-乌拉罗格·塑山-召唤
	[100818]  = "嚎叫雕像",     -- 奈萨里奥的巢穴-乌拉罗格·塑山-分化
	[101075]  = "虫语虔信者",     -- 奈萨里奥的巢穴-小怪
	[113552]  = "过载的透镜",     -- 守望者地窟-格雷泽
	[99664]  = "永不安息的灵魂",     -- 黑鸦堡垒-融合之魂
	[101008]  = "针刺虫群",     -- 黑鸦堡垒-库塔洛斯·拉文凯斯
	[115395]  = "王后",     -- 卡拉赞-象棋大厅
	[115402]  = "主教",     -- 卡拉赞-象棋大厅
	[115406]  = "骑士",     -- 卡拉赞-象棋大厅
	[115407]  = "城堡",     -- 卡拉赞-象棋大厅
	[119169]  = "狂暴的鞭笞者",     -- 永夜大教堂-阿格洛诺克斯
	[120646]  = "奥术畸体之书",     -- 永夜大教堂-小怪
	[118718]  = "永冬之书",     -- 永夜大教堂-小怪
	[120727]  = "永默之书",     -- 永夜大教堂-小怪
	[118834]  = "邪能传送门守卫",     -- 永夜大教堂-多玛塔克斯
	[117590]  = "孟菲斯托斯之影",     -- 永夜大教堂-孟菲斯托斯
	[104326]  = "幽灵血牙",     -- 暗夜要塞-提克迪奥斯
	[109804]  = "离子球",     -- 暗夜要塞-高级植物学家特尔安
	[105630]  = "古尔丹之眼",     -- 暗夜要塞-古尔丹
	[106545]  = "强化古尔丹之眼",     -- 暗夜要塞-古尔丹
	[121155]  = "苍白的蝌蚪",     -- 萨格拉斯之墓-哈亚坦
	[123451]  = "恶魔卫士",     -- 安托鲁斯，燃烧王座-生命的缚誓者艾欧娜尔
	[123452]  = "邪能领主",     -- 安托鲁斯，燃烧王座-生命的缚誓者艾欧娜尔
	[123191]  = "恶魔犬",     -- 安托鲁斯，燃烧王座-生命的缚誓者艾欧娜尔
	[124227]  = "飞翔的科拉佩特隆",     -- 安托鲁斯，燃烧王座-生命的缚誓者艾欧娜尔
	[124207]  = "邪能干扰器",     -- 安托鲁斯，燃烧王座-生命的缚誓者艾欧娜尔
	[122897]  = "邪丝蛛网",     -- 安托鲁斯，燃烧王座-传送门守护者哈萨贝尔
	[125837]  = "阿曼苏尔的痛苦",     -- 安托鲁斯，燃烧王座-破坏魔女巫会
	[124164]  = "高戈奈斯的痛苦",     -- 安托鲁斯，燃烧王座-破坏魔女巫会
	[124166]  = "卡兹格罗斯的痛苦",     -- 安托鲁斯，燃烧王座-破坏魔女巫会
	[123503]  = "诺甘农的痛苦",     -- 安托鲁斯，燃烧王座-破坏魔女巫会
	[122532]  = "泰沙拉克的余烬",     -- 安托鲁斯，燃烧王座-阿格拉玛
	[127809]  = "起源重组模块",     -- 安托鲁斯，燃烧王座-寂灭者阿古斯
	[125327]  = "醉步白鼬",     -- 提拉加德海峡
	[136330]  = "灵魂荆棘",     -- 维克雷斯庄园-魂缚巨像
	[133361]  = "大手大脚的仆从",     -- 维克雷斯庄园-贪食的拉尔
	[127315]  = "复生图腾",     -- 阿塔达萨-小怪
	[131009]  = "黄金之灵",     -- 阿塔达萨-女祭司阿伦扎
	[125828]  = "碎魂",     -- 阿塔达萨-亚兹玛
	[134388]  = "缠绕的蛇群",     -- 塞塔里斯神庙-米利克萨
	[134389]  = "喷毒盘蛇",     -- 塞塔里斯神庙-米利克萨
	[134390]  = "沙鳞突击者",     -- 塞塔里斯神庙-米利克萨
	[134612]  = "抓地机械手",     -- 风暴神殿-阿库希尔
	[130896]  = "眩晕酒桶",     -- 自由镇-海盗议会
	[170234]  = "压制战旗",     -- 伤逝剧场-无堕者哈夫
	[169498]  = "魔法炸弹",     -- 凋魂之殇-伊库斯博士
	[170927]  = "爆发污泥",     -- 凋魂之殇-伊库斯博士
	[168394]  = "零星软泥",     -- 凋魂之殇-小怪
	[169912]  = "狂怒面具",     -- 彼界-小怪
	[168326]  = "破碎残影",     -- 彼界-穆厄扎拉
	[164698]  = "灰烬护命匣",     -- 罪魂之塔
	[165523]  = "灰烬护命匣",     -- 罪魂之塔
	[165533]  = "灰烬护命匣",     -- 罪魂之塔
	[167986]  = "灰烬护命匣",     -- 罪魂之塔
	[170452]  = "精华宝珠",     -- 罪魂之塔-上层区域-吞噬者苟克苏尔
	[219250]  = "PVP训练假人",     -- 训练假人
	[225982]  = "顺劈训练假人",     -- 训练假人
	[225983]  = "地下城训练假人",     -- 训练假人
	[225984]  = "训练假人",     -- 训练假人
	[225985]  = "藻拳",     -- 训练假人
	[214443]  = "水晶碎片",     -- 矶石宝库-斯卡莫拉克
	[214287]  = "爆地图腾",     -- 矶石宝库-小怪
	[219301]  = "酒滴",     -- 燧酿酒庄-艾帕
	[220368]  = "失败批次",     -- 燧酿酒庄-艾帕
	[222700]  = "晦幽纺纱",     -- 千丝之城
	[215826]  = "血工",     -- 艾拉-卡拉，回响之城
	[213684]  = "虚空碎块",     -- 驭雷栖巢
}

function DamagerEngineGetNoThreatUnit(Unit)
	--无仇恨类目标检测
	if Unit == nil then
		Unit = "target"
	end
	if UnitExists(Unit) and UnitGUID(Unit) then
		if (NoThreatUnit[tonumber(string.match(UnitGUID(Unit),"-(%d+)-%x+$"))] or (UnitIsPlayer(Unit) and IsInInstance())) and UnitCanAttack("player", Unit) and UnitAffectingCombat("player") then
			return true
		end
	end
end