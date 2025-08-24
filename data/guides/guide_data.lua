-- 万象全书攻略数据文件
-- 这个文件包含了所有攻略内容，以支持数据驱动的架构

print("[万象全书] 正在加载外部攻略数据文件...")

local GUIDE_DATA = {
    -- 第一大节：新手指南
    beginner = {
        title = "新手指南",
        is_section = true,
        children = {
            beginner_day1to3 = {
                title = "开局前三天",
                text = "第一天：收集树枝、草、燧石，制作基本工具。\n第二天：建立营地，制作科学机器。\n第三天：准备食物和火把，迎接第一个夜晚。",
            },
            beginner_base = {
                title = "基地建设",
                text = "选择基地位置时要考虑资源、生物群落和季节因素。\n基础设施：营火、科学机器、烹饪锅、冰箱、晾肉架。\n围墙与陷阱可以提供安全保障。",
            },
            beginner_resources = {
                title = "资源管理",
                text = "合理分配时间：采集、建造、探索、战斗。\n优先级：食物 > 安全 > 科技 > 探索。\n保持库存整洁，避免物品堆积过多。",
            },
        },
    },

    -- 第二大节：生存技巧
    survival = {
        title = "生存技巧",
        is_section = true,
        children = {
            survival_seasons = {
                title = "四季生存指南",
                text = "春季：雨水较多，注意防潮。\n夏季：高温引发自燃，准备降温装备。\n秋季：收获的季节，多收集资源。\n冬季：低温致命，准备保暖装备和充足食物。",
            },
            survival_food = {
                title = "食物与烹饪",
                text = "烹饪锅可以制作更有营养的食物。\n肉类食物：怪物肉、兔肉、鸟肉等。\n蔬菜：胡萝卜、浆果、蘑菇等。\n最佳食谱：肉丸、火鸡大餐、培根煎蛋。",
            },
            survival_health = {
                title = "健康管理",
                text = "保持饱食度：定期进食，避免过度饥饿。\n注意精神状态：保持在安全区域，远离怪物。\n治疗方法：使用蜂蜜、蓝蘑菇、蜘蛛腺体等。",
            },
            survival_weather = {
                title = "天气应对",
                text = "雨天：寻找庇护所或制作雨伞。\n雷暴：远离高处和金属物品。\n雾天：注意能见度，使用火把照明。\n雪天：准备保暖装备和热源。",
            },
        },
    },

    -- 第三大节：战斗指南
    combat = {
        title = "战斗指南",
        is_section = true,
        children = {
            combat_basics = {
                title = "战斗技巧",
                text = "学会走位和攻击节奏。\n制作武器：长矛、暗夜剑、触手棒等。\n制作护甲：草甲、木甲、大理石甲等。\n学会风筝怪物，避免被围攻。",
            },
            combat_bosses = {
                title = "常见BOSS攻略",
                text = "树精守卫：用火攻击最有效。\n克劳斯：冬季出现，掉落红宝石。\n蜂后：引出巢穴后集中攻击。\n远古守护者：地下世界的最终BOSS。",
            },
            combat_monsters = {
                title = "怪物弱点",
                text = "蜘蛛：用火或范围攻击。\n树精：用斧头或火。\n触手：用锤子或远程攻击。\n牛：用陷阱或远程攻击。",
            },
            combat_strategy = {
                title = "战术要点",
                text = "观察怪物行为模式。\n利用地形优势。\n合理使用道具和陷阱。\n团队配合：分工明确，互相支援。",
            },
        },
    },

    -- 第四大节：科技与建造
    technology = {
        title = "科技与建造",
        is_section = true,
        children = {
            technology_science = {
                title = "科学机器",
                text = "解锁基本科技：工具、武器、食物。\n高级科技：魔法、战斗、生存。\n实用发明：冰箱、晾肉架、雨伞等。",
            },
            technology_magic = {
                title = "魔法科技",
                text = "暗影魔法：暗影触手、暗影剑等。\n远古魔法：远古守护者相关科技。\n实用魔法：传送法杖、懒人法杖等。",
            },
            technology_building = {
                title = "建筑技巧",
                text = "合理规划基地布局。\n使用地形：高地防御、山洞庇护。\n装饰：提升精神状态，获得增益效果。",
            },
            technology_farming = {
                title = "农业技术",
                text = "种植作物：胡萝卜、玉米、土豆等。\n养殖动物：兔子、牛、猪等。\n园艺：花卉种植，获得特殊效果。",
            },
        },
    },

    -- 第五大节：探索与冒险
    exploration = {
        title = "探索与冒险",
        is_section = true,
        children = {
            exploration_biomes = {
                title = "生态群落",
                text = "森林：基础资源丰富。\n沙漠：高温，仙人掌资源。\n沼泽：危险但资源独特。\n洞穴：黑暗，需要光源。",
            },
            exploration_dangers = {
                title = "探索风险",
                text = "准备充足：食物、武器、医疗品。\n注意时间：夜晚更危险。\n识别危险：颜色鲜艳的生物通常有毒。\n团队探索：互相照应，共同进退。",
            },
            exploration_resources = {
                title = "稀有资源",
                text = "黄金：制作高级装备。\n宝石：魔法道具材料。\n远古：特殊科技材料。\n月亮：月亮科技材料。",
            },
            exploration_maps = {
                title = "地图探索",
                text = "标记重要地点：基地、资源点。\n绘制地图：记录地形和生物分布。\n寻找特殊地点：废墟、遗迹、洞穴入口。",
            },
        },
    },
}

print("[万象全书] 外部攻略数据文件加载完成，共 " .. (function()
    local count = 0
    for _ in pairs(GUIDE_DATA) do count = count + 1 end
    return count
end)() .. " 个大节")

return GUIDE_DATA