-- scripts/strings.lua 多语言字符串管理
local STRINGS = GLOBAL.STRINGS

-- 获取当前游戏语言
local language = GLOBAL.LanguageTranslator.defaultlang or "zh"
print("[万象全书] 检测到游戏语言:", language)

-- 中文字符串表
local CHINESE_STRINGS = {
    -- 物品名称
    NAMES = {
        ATLAS_BOOK = "万象全书",
        BOOK_PETRIFY = "石化之书",
    },

    -- 配方描述
    RECIPE_DESC = {
        ATLAS_BOOK = "包含丰富知识的指南书",
        BOOK_PETRIFY = "用美杜莎之眼照射常绿树。",
        SPIDERHOLE = "重建蜘蛛洞穴",
        WASPHIVE = "我们就是喜欢养蛊",
        BEEHIVE = "爱护蜜蜂 人人有责",
        SLURTLEHOLE = "内有两只蜗牛",
        CATCOONDEN = "浣猫喜欢居住其中",
        MEATRACK_HERMIT = "剽窃老螃蟹的工艺",
    },

    -- 角色描述
    CHARACTERS = {
        GENERIC = {
            DESCRIBE = {
                ATLAS_BOOK = "包含了这个世界的所有知识。",
                BOOK_PETRIFY = "我可以用这个把东西变成石头！",
            }
        },
        WILLOW = {
            DESCRIBE = {
                ATLAS_BOOK = "这本书看起来不太容易燃烧。",
                BOOK_PETRIFY = "我可以用这个把东西变成石头！",
            }
        },
        WOLFGANG = {
            DESCRIBE = {
                ATLAS_BOOK = "大书让沃尔夫冈变聪明！",
                BOOK_PETRIFY = "石头书让沃尔夫冈变强壮！",
            }
        },
        WENDY = {
            DESCRIBE = {
                ATLAS_BOOK = "知识是对抗虚无的唯一武器。",
                BOOK_PETRIFY = "永恒的凝视将生命转化为石头。",
            }
        },
        WX78 = {
            DESCRIBE = {
                ATLAS_BOOK = "人类知识储存装置。有用。",
                BOOK_PETRIFY = "有机物转化为无机物。效率：100%",
            }
        },
        WICKERBOTTOM = {
            DESCRIBE = {
                ATLAS_BOOK = "一本包含丰富知识的指南书。",
                BOOK_PETRIFY = "一本关于石化魔法的书籍。非常学术性。",
            }
        },
        WOODIE = {
            DESCRIBE = {
                ATLAS_BOOK = "这本书上没有关于伐木的内容，真遗憾。",
                BOOK_PETRIFY = "这本书能把树变成石头？太可怕了！",
            }
        },
        WAXWELL = {
            DESCRIBE = {
                ATLAS_BOOK = "知识就是力量，不是吗？",
                BOOK_PETRIFY = "石化魔法。经典但有效。",
            }
        },
        WATHGRITHR = {
            DESCRIBE = {
                ATLAS_BOOK = "维京战士不需要书籍！...但这本可以例外。",
                BOOK_PETRIFY = "石化之书！强大的魔法武器！",
            }
        },
        WEBBER = {
            DESCRIBE = {
                ATLAS_BOOK = "我们可以从这本书里学到很多东西！",
                BOOK_PETRIFY = "哇！这本书能把蜘蛛变成石头吗？",
            }
        },
        WINONA = {
            DESCRIBE = {
                ATLAS_BOOK = "实用的指南，我喜欢。",
                BOOK_PETRIFY = "这能把东西变成建筑材料吗？",
            }
        },
        WORTOX = {
            DESCRIBE = {
                ATLAS_BOOK = "知识的味道如何呢？嘻嘻！",
                BOOK_PETRIFY = "灵魂会变成石头吗？有趣的问题！",
            }
        },
        WARLY = {
            DESCRIBE = {
                ATLAS_BOOK = "可惜没有更多的烹饪秘方。",
                BOOK_PETRIFY = "石化橄榄？不，这不是食谱。",
            }
        },
        WURT = {
            DESCRIBE = {
                ATLAS_BOOK = "鱼人也要学习！",
                BOOK_PETRIFY = "石头书！鱼人鱼人鱼人！",
            }
        },
        WORMWOOD = {
            DESCRIBE = {
                ATLAS_BOOK = "朋友的叶子？不，是知识。",
                BOOK_PETRIFY = "把朋友变成石头？不好！",
            }
        },
    }

-- UI字符串表（中英文）
local UI_CHINESE_STRINGS = {
    WINDOW_TITLE = "万象全书",
    CLOSE_BUTTON = "关闭",
    GUIDE_TAB = "静态攻略",
    PLANNER_TAB = "团队计划",
    ADD_TASK_BUTTON = "添加任务",
    INPUT_PROMPT = "输入任务内容:",
    CONFIRM_BUTTON = "确定",
    CLEAR_BUTTON = "清空",
    CANCEL_BUTTON = "取消",
    DELETE_BUTTON = "删除",
    COMPLETED_TASK = "✓",
    PENDING_TASK = "□",
    PREV_PAGE = "<",
    NEXT_PAGE = ">",
}

local UI_ENGLISH_STRINGS = {
    WINDOW_TITLE = "Codex Astralis",
    CLOSE_BUTTON = "Close",
    GUIDE_TAB = "Guide",
    PLANNER_TAB = "Planner",
    ADD_TASK_BUTTON = "Add Task",
    INPUT_PROMPT = "Enter task content:",
    CONFIRM_BUTTON = "Confirm",
    CLEAR_BUTTON = "Clear",
    CANCEL_BUTTON = "Cancel",
    DELETE_BUTTON = "Delete",
    COMPLETED_TASK = "✓",
    PENDING_TASK = "□",
    PREV_PAGE = "<",
    NEXT_PAGE = ">",
}

-- 根据语言添加UI字符串到全局STRINGS
if language == "zh" or language == "zht" then
    for key, value in pairs(UI_CHINESE_STRINGS) do
        STRINGS[key] = value
    end
else
    for key, value in pairs(UI_ENGLISH_STRINGS) do
        STRINGS[key] = value
    end
end

-- 英文字符串表
local ENGLISH_STRINGS = {
    -- Item names
    NAMES = {
        ATLAS_BOOK = "Codex Astralis",
        BOOK_PETRIFY = "Petrifying Tome",
    },

    -- Recipe descriptions
    RECIPE_DESC = {
        ATLAS_BOOK = "A comprehensive guide containing vast knowledge",
        BOOK_PETRIFY = "Exposure evergreens with Medusa's eyes.",
        SPIDERHOLE = "Rebuild spider dens",
        WASPHIVE = "We just love breeding killer bees",
        BEEHIVE = "Protect the bees, save the world",
        SLURTLEHOLE = "Contains two slurtles",
        CATCOONDEN = "Raccoons love to live here",
        MEATRACK_HERMIT = "Plagiarize the old crab's craft",
    },

    -- Character descriptions
    CHARACTERS = {
        GENERIC = {
            DESCRIBE = {
                ATLAS_BOOK = "This book contains all the knowledge of this world.",
                BOOK_PETRIFY = "I can use this to turn things into stone!",
            }
        },
        WILLOW = {
            DESCRIBE = {
                ATLAS_BOOK = "This book doesn't look like it burns easily.",
                BOOK_PETRIFY = "I can use this to turn things into stone!",
            }
        },
        WOLFGANG = {
            DESCRIBE = {
                ATLAS_BOOK = "Big book make Wolfgang smart!",
                BOOK_PETRIFY = "Stone book make Wolfgang strong!",
            }
        },
        WENDY = {
            DESCRIBE = {
                ATLAS_BOOK = "Knowledge is the only weapon against nothingness.",
                BOOK_PETRIFY = "The eternal gaze turns life into stone.",
            }
        },
        WX78 = {
            DESCRIBE = {
                ATLAS_BOOK = "Human knowledge storage device. Useful.",
                BOOK_PETRIFY = "Organic matter to inorganic matter. Efficiency: 100%",
            }
        },
        WICKERBOTTOM = {
            DESCRIBE = {
                ATLAS_BOOK = "A comprehensive guide containing vast knowledge.",
                BOOK_PETRIFY = "A book about petrification magic. Very academic.",
            }
        },
        WOODIE = {
            DESCRIBE = {
                ATLAS_BOOK = "No lumberjack content in this book, what a shame.",
                BOOK_PETRIFY = "This book can turn trees into stone? Terrible!",
            }
        },
        WAXWELL = {
            DESCRIBE = {
                ATLAS_BOOK = "Knowledge is power, isn't it?",
                BOOK_PETRIFY = "Petrification magic. Classic but effective.",
            }
        },
        WATHGRITHR = {
            DESCRIBE = {
                ATLAS_BOOK = "Viking warriors don't need books! ...but this one is an exception.",
                BOOK_PETRIFY = "Book of petrification! Powerful magic weapon!",
            }
        },
        WEBBER = {
            DESCRIBE = {
                ATLAS_BOOK = "We can learn a lot from this book!",
                BOOK_PETRIFY = "Wow! Can this book turn spiders into stone?",
            }
        },
        WINONA = {
            DESCRIBE = {
                ATLAS_BOOK = "A practical guide, I like it.",
                BOOK_PETRIFY = "Can this turn things into building materials?",
            }
        },
        WORTOX = {
            DESCRIBE = {
                ATLAS_BOOK = "What does knowledge taste like? Hee hee!",
                BOOK_PETRIFY = "Do souls turn into stone? Interesting question!",
            }
        },
        WARLY = {
            DESCRIBE = {
                ATLAS_BOOK = "Too bad there aren't more cooking recipes.",
                BOOK_PETRIFY = "Petrified olives? No, this isn't a cookbook.",
            }
        },
        WURT = {
            DESCRIBE = {
                ATLAS_BOOK = "Mermfolk need to learn too!",
                BOOK_PETRIFY = "Stone book! Glurgh glurgh glurgh!",
            }
        },
        WORMWOOD = {
            DESCRIBE = {
                ATLAS_BOOK = "Friend's leaves? No, knowledge.",
                BOOK_PETRIFY = "Turn friends into stone? No good!",
            }
        },
    }
}

-- 攻略内容数据
local GUIDE_CHINESE = {
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
        },
    },
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
        },
    },
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
        },
    },
}

local GUIDE_ENGLISH = {
    beginner = {
        title = "Beginner's Guide",
        is_section = true,
        children = {
            beginner_day1to3 = {
                title = "First Three Days",
                text = "Day 1: Gather twigs, grass, and flint to craft basic tools.\nDay 2: Build a camp and craft a science machine.\nDay 3: Prepare food and torches for the first night.",
            },
            beginner_base = {
                title = "Base Building",
                text = "Consider resources, biomes, and seasons when choosing base location.\nInfrastructure: Campfire, science machine, cooking pot, icebox, drying rack.\nWalls and traps provide security.",
            },
        },
    },
    survival = {
        title = "Survival Skills",
        is_section = true,
        children = {
            survival_seasons = {
                title = "Seasonal Survival Guide",
                text = "Spring: More rain, watch for dampness.\nSummer: High heat causes spontaneous combustion, prepare cooling equipment.\nAutumn: Harvest season, gather resources.\nWinter: Deadly cold, prepare warm equipment and sufficient food.",
            },
            survival_food = {
                title = "Food and Cooking",
                text = "Cooking pots create more nutritious food.\nMeat: Monster meat, rabbit, bird meat, etc.\nVegetables: Carrots, berries, mushrooms, etc.\nBest recipes: Meatballs, turkey dinner, bacon and eggs.",
            },
        },
    },
    combat = {
        title = "Combat Guide",
        is_section = true,
        children = {
            combat_basics = {
                title = "Combat Skills",
                text = "Learn positioning and attack timing.\nCraft weapons: Spear, dark sword, tentacle spike, etc.\nCraft armor: Grass armor, wood armor, marble armor, etc.\nLearn kiting to avoid being surrounded.",
            },
            combat_bosses = {
                title = "Common Boss Strategies",
                text = "Treeguard: Fire attacks are most effective.\nKlaus: Appears in winter, drops red gem.\nBee Queen: Lure out of hive then focus attack.\nAncient Guardian: Final boss of the caves.",
            },
        },
    },
}

-- 根据语言加载字符串
local function LoadStrings()
    local strings_table

    -- 支持中文（简体和繁体）
    if language == "zh" or language == "zht" then
        strings_table = CHINESE_STRINGS
        print("[万象全书] 加载中文字符串")
    else
        strings_table = ENGLISH_STRINGS
        print("[Codex Astralis] Loading English strings")
    end

    -- 合并到全局STRINGS表
    for category, items in pairs(strings_table) do
        if not STRINGS[category] then
            STRINGS[category] = {}
        end
        for key, value in pairs(items) do
            if type(value) == "table" then
                -- 处理嵌套表（如CHARACTERS.GENERIC.DESCRIBE）
                if not STRINGS[category][key] then
                    STRINGS[category][key] = {}
                end
                for sub_key, sub_value in pairs(value) do
                    if type(sub_value) == "table" then
                        if not STRINGS[category][key][sub_key] then
                            STRINGS[category][key][sub_key] = {}
                        end
                        for final_key, final_value in pairs(sub_value) do
                            STRINGS[category][key][sub_key][final_key] = final_value
                        end
                    else
                        STRINGS[category][key][sub_key] = sub_value
                    end
                end
            else
                STRINGS[category][key] = value
            end
        end
    end
end

-- 执行字符串加载
LoadStrings()

-- 调试：检查加载结果
print("[万象全书] 字符串加载完成，检查STRINGS表:")
if STRINGS.WINDOW_TITLE then
    print("[万象全书] WINDOW_TITLE:", STRINGS.WINDOW_TITLE)
end
if STRINGS.GUIDE_TAB then
    print("[万象全书] GUIDE_TAB:", STRINGS.GUIDE_TAB)
end
if STRINGS.PLANNER_TAB then
    print("[万象全书] PLANNER_TAB:", STRINGS.PLANNER_TAB)
end

-- 根据语言选择攻略数据
local function GetGuideData()
    if language == "zh" or language == "zht" then
        return GUIDE_CHINESE
    else
        return GUIDE_ENGLISH
    end
end

-- 导出接口供其他模块使用
return {
    LoadStrings = LoadStrings,
    CurrentLanguage = language,
    CHINESE_STRINGS = CHINESE_STRINGS,
    ENGLISH_STRINGS = ENGLISH_STRINGS,
    GetGuideData = GetGuideData
}