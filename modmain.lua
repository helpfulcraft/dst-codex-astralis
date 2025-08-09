
local SpawnPrefab = GLOBAL.SpawnPrefab
local FUELTYPE = GLOBAL.FUELTYPE
local IsServer = GLOBAL.TheNet:GetIsServer()
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local PI = GLOBAL.PI
local TheSim = GLOBAL.TheSim
local Ingredient = GLOBAL.Ingredient
local TUNING = GLOBAL.TUNING
local Recipe = GLOBAL.Recipe
local RECIPETABS = GLOBAL.RECIPETABS
local AllRecipes = GLOBAL.AllRecipes
local TECH = GLOBAL.TECH
local TheNet = GLOBAL.TheNet
local TheWorld = GLOBAL.TheWorld

-- 添加RPC命名空间和命令
local ATLAS_RPC_NAMESPACE = "atlas_book"
local ATLAS_RPC_ADD_TASK = "add_task"
local ATLAS_RPC_TOGGLE_TASK = "toggle_task"
local ATLAS_RPC_DELETE_TASK = "delete_task"
local ATLAS_RPC_SYNC_TASKS = "sync_tasks"

-- 注册UI
local AtlasBookUI = require("widgets/atlasbook_ui")
if not AtlasBookUI then
    print("[万象全书] 错误: 无法加载 atlasbook_ui.lua")
    AtlasBookUI = require("scripts/widgets/atlasbook_ui")
    if not AtlasBookUI then
        print("[万象全书] 严重错误: 无法加载 scripts/widgets/atlasbook_ui.lua")
    else
        print("[万象全书] 成功加载 scripts/widgets/atlasbook_ui.lua")
    end
else
    print("[万象全书] 成功加载 widgets/atlasbook_ui.lua")
end

-- 在玩家HUD中添加UI控件
AddClassPostConstruct("screens/playerhud", function(self)
    -- 添加打开UI的方法
    function self:OpenAtlasBook()
        -- 检查UI是否已经在屏幕上
        if TheFrontEnd:GetActiveScreen() and TheFrontEnd:GetActiveScreen().name == "AtlasBookUI" then
            return
        end
        
        -- 创建新的UI实例并显示
        local atlasbook = AtlasBookUI(self.owner)
        TheFrontEnd:PushScreen(atlasbook)
    end
end)

-- 注册服务器端组件
AddComponentPostInit("worldstate", function(self)
    -- 只在主服务器上添加组件
    if GLOBAL.TheWorld.ismastersim then
        print("[万象全书] 添加服务器端组件 atlas_todolist")
        GLOBAL.TheWorld:AddComponent("atlas_todolist")
    end
end)

-- 注册客户端组件
-- 在游戏初始化完成后添加组件
AddSimPostInit(function()
    if not GLOBAL.TheWorld.ismastersim then
        -- 客户端初始化
        print("[万象全书] SimPostInit: 添加客户端组件 atlas_todolist")
        GLOBAL.TheWorld:AddComponent("atlas_todolist")
    end
end)

-- 添加RPC处理程序
-- 客户端到服务器：添加任务
AddModRPCHandler(ATLAS_RPC_NAMESPACE, ATLAS_RPC_ADD_TASK, function(player, task_text)
    print("[万象全书] 收到添加任务RPC:", task_text)
    if GLOBAL.TheWorld.components.atlas_todolist ~= nil then
        GLOBAL.TheWorld.components.atlas_todolist:AddTask(task_text)
    end
end)

-- 客户端到服务器：切换任务状态
AddModRPCHandler(ATLAS_RPC_NAMESPACE, ATLAS_RPC_TOGGLE_TASK, function(player, task_id, is_completed)
    print("[万象全书] 收到切换任务状态RPC:", task_id, is_completed)
    if GLOBAL.TheWorld.components.atlas_todolist ~= nil then
        GLOBAL.TheWorld.components.atlas_todolist:ToggleTask(task_id, is_completed)
    end
end)

-- 客户端到服务器：删除任务
AddModRPCHandler(ATLAS_RPC_NAMESPACE, ATLAS_RPC_DELETE_TASK, function(player, task_id)
    print("[万象全书] 收到删除任务RPC:", task_id)
    if GLOBAL.TheWorld.components.atlas_todolist ~= nil then
        GLOBAL.TheWorld.components.atlas_todolist:DeleteTask(task_id)
    end
end)

-- 服务器到客户端：同步任务列表
AddClientModRPCHandler(ATLAS_RPC_NAMESPACE, ATLAS_RPC_SYNC_TASKS, function(tasks_json)
    print("[万象全书] 收到同步任务列表RPC")
    -- 客户端接收到任务数据后，更新本地副本
    if tasks_json == nil or tasks_json == "" then
        print("[万象全书] 错误: 收到空的任务列表JSON")
        return
    end
    
    if not GLOBAL.TheWorld or not GLOBAL.TheWorld.components then
        print("[万象全书] 错误: TheWorld或其组件不存在")
        return
    end
    
    if GLOBAL.TheWorld.components.atlas_todolist then
        print("[万象全书] 将任务数据同步到客户端组件")
        GLOBAL.TheWorld.components.atlas_todolist:SyncTasks(tasks_json)
    else
        print("[万象全书] 错误: atlas_todolist组件不存在")
    end
end)

-- 玩家出生自带万象全书
AddPlayerPostInit(function(inst)
if not GLOBAL.TheWorld.ismastersim then return end
        inst:AddTag("professionalchef")
        inst:AddTag("expertchef")
        
        -- 初始化玩家的万象全书数据
        if not inst.atlas_book_data then
            inst.atlas_book_data = {
                last_page = nil
            }
        end
        
        -- 添加保存和加载函数
        local old_OnSave = inst.OnSave
        inst.OnSave = function(inst, data)
            if old_OnSave then
                old_OnSave(inst, data)
            end
            
            -- 保存万象全书数据
            if inst.atlas_book_data then
                data.atlas_book_data = inst.atlas_book_data
                print("[万象全书] 保存数据:", inst.atlas_book_data.last_page)
            end
        end
        
        local old_OnLoad = inst.OnLoad
        inst.OnLoad = function(inst, data)
            if old_OnLoad then
                old_OnLoad(inst, data)
            end
            
            -- 加载万象全书数据
            if data and data.atlas_book_data then
                inst.atlas_book_data = data.atlas_book_data
                print("[万象全书] 加载数据:", inst.atlas_book_data.last_page)
            else
                inst.atlas_book_data = {
                    last_page = nil
                }
            end
        end
        
        -- 添加出生自带万象全书的功能
        inst:DoTaskInTime(1, function()
            if inst.components and inst.components.inventory then
                -- 检查玩家是否已经有万象全书
                local has_atlas_book = false
                for k, v in pairs(inst.components.inventory.itemslots) do
                    if v.prefab == "atlas_book" then
                        has_atlas_book = true
                        break
                    end
                end
                
                -- 如果没有，则给予一本
                if not has_atlas_book then
                    local book = SpawnPrefab("atlas_book")
                    if book then
                        inst.components.inventory:GiveItem(book)
                    end
                end
            end
        end)
end)

function CookCanBeUsed(inst)
    if inst:HasTag("mastercookware") then
        inst:RemoveTag("mastercookware")
    end
end

AddPrefabPostInit("portablespicer", CookCanBeUsed)

PrefabFiles = {
    "book_petrify", 
    "spiderhole_placer", 
    "wasphive_placer", 
    "beehive_placer", 
    "slurtlehole_placer", 
    "catcoonden_placer",
    "atlas_book", -- 添加万象全书
}

Assets = 
    {
        Asset("ANIM", "anim/book_fossil.zip"),
        Asset("ANIM", "anim/swap_book_fossil.zip"),
        Asset("ATLAS", "images/inventoryimages/book_fossil.xml"),
        Asset("IMAGE", "images/inventoryimages/book_fossil.tex"),
        Asset("ATLAS", "images/inventoryimages/spiderhole.xml"),
        Asset("IMAGE", "images/inventoryimages/spiderhole.tex"),
        Asset("ATLAS", "images/inventoryimages/wasphive.xml"),
        Asset("IMAGE", "images/inventoryimages/wasphive.tex"),
        Asset("ATLAS", "images/inventoryimages/beehive.xml"),
        Asset("IMAGE", "images/inventoryimages/beehive.tex"),
        Asset("ATLAS", "images/inventoryimages/slurtlehole.xml"),
        Asset("IMAGE", "images/inventoryimages/slurtlehole.tex"),
        Asset("ATLAS", "images/inventoryimages/catcoonden.xml"),
        Asset("IMAGE", "images/inventoryimages/catcoonden.tex"),
        
    }
STRINGS.BOOK_PETRIFY = "book_petrify"
STRINGS.NAMES.BOOK_PETRIFY = "petrifying book"
STRINGS.RECIPE_DESC.BOOK_PETRIFY = "Exposure evergreens with Medusa's eyes."

-- 添加万象全书的字符串
STRINGS.NAMES.ATLAS_BOOK = "万象全书"
STRINGS.RECIPE_DESC.ATLAS_BOOK = "包含丰富知识的指南书"

-- 各角色对万象全书的描述
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATLAS_BOOK = "包含了这个世界的所有知识。"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.ATLAS_BOOK = "这本书看起来不太容易燃烧。"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ATLAS_BOOK = "大书让沃尔夫冈变聪明！"
STRINGS.CHARACTERS.WENDY.DESCRIBE.ATLAS_BOOK = "知识是对抗虚无的唯一武器。"
STRINGS.CHARACTERS.WX78.DESCRIBE.ATLAS_BOOK = "人类知识储存装置。有用。"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ATLAS_BOOK = "一本包含丰富知识的指南书。"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.ATLAS_BOOK = "这本书上没有关于伐木的内容，真遗憾。"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ATLAS_BOOK = "知识就是力量，不是吗？"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ATLAS_BOOK = "维京战士不需要书籍！...但这本可以例外。"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.ATLAS_BOOK = "我们可以从这本书里学到很多东西！"
STRINGS.CHARACTERS.WINONA.DESCRIBE.ATLAS_BOOK = "实用的指南，我喜欢。"
STRINGS.CHARACTERS.WORTOX.DESCRIBE.ATLAS_BOOK = "知识的味道如何呢？嘻嘻！"
STRINGS.CHARACTERS.WARLY.DESCRIBE.ATLAS_BOOK = "可惜没有更多的烹饪秘方。"
STRINGS.CHARACTERS.WURT.DESCRIBE.ATLAS_BOOK = "鱼人也要学习！"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.ATLAS_BOOK = "朋友的叶子？不，是知识。"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_PETRIFY            = STRINGS.CHARACTERS.GENERIC.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WILLOW.DESCRIBE.BOOK_PETRIFY             = STRINGS.CHARACTERS.WILLOW.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BOOK_PETRIFY           = STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WENDY.DESCRIBE.BOOK_PETRIFY              = STRINGS.CHARACTERS.WENDY.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WX78.DESCRIBE.BOOK_PETRIFY               = STRINGS.CHARACTERS.WX78.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BOOK_PETRIFY       = STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WOODIE.DESCRIBE.BOOK_PETRIFY             = STRINGS.CHARACTERS.WOODIE.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BOOK_PETRIFY            = STRINGS.CHARACTERS.WAXWELL.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BOOK_PETRIFY         = STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WEBBER.DESCRIBE.BOOK_PETRIFY             = STRINGS.CHARACTERS.WEBBER.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WINONA.DESCRIBE.BOOK_PETRIFY             = STRINGS.CHARACTERS.WINONA.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WORTOX.DESCRIBE.BOOK_PETRIFY             = STRINGS.CHARACTERS.WORTOX.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WARLY.DESCRIBE.BOOK_PETRIFY              = STRINGS.CHARACTERS.WARLY.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WURT.DESCRIBE.BOOK_PETRIFY               = STRINGS.CHARACTERS.WURT.DESCRIBE.BOOK_FOSSIL
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.BOOK_PETRIFY           = STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.BOOK_FOSSIL

STRINGS.RECIPE_DESC.SPIDERHOLE = "重建蜘蛛洞穴"
STRINGS.RECIPE_DESC.WASPHIVE = "我们就是喜欢养蛊"
STRINGS.RECIPE_DESC.BEEHIVE = "爱护蜜蜂 人人有责"
STRINGS.RECIPE_DESC.SLURTLEHOLE = "内有两只蜗牛"
STRINGS.RECIPE_DESC.CATCOONDEN = "浣猫喜欢居住其中"

AddRecipe("book_petrify", {Ingredient("fossil_piece", GetModConfigData('fos')),Ingredient("papyrus", 2)}, GLOBAL.CUSTOM_RECIPETABS.BOOKS, 
TECH.MAGIC_THREE, nil, nil, nil, nil, "bookbuilder","images/inventoryimages.xml", "book_fossil.tex", nil, nil)
AddRecipe("book_gardening",  {Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)}, GLOBAL.CUSTOM_RECIPETABS.BOOKS, TECH.MOON_ALTAR_TWO, nil, nil, nil, nil, "bookbuilder")
local rsh = Recipe("spiderhole", {Ingredient("fossil_piece", 1), Ingredient("silk", 20), Ingredient("spidergland",30)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "spiderhole_placer")
rsh.atlas = "images/inventoryimages/spiderhole.xml"
local rwh = Recipe("wasphive", { Ingredient("honeycomb", 1), Ingredient("stinger", 4), Ingredient("killerbee", 6)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "wasphive_placer")
rwh.atlas = "images/inventoryimages/wasphive.xml"
local rbh = Recipe("beehive", { Ingredient("honeycomb", 1), Ingredient("honey", 4), Ingredient("bee", 6)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "beehive_placer")
rbh.atlas = "images/inventoryimages/beehive.xml"
local rsl = Recipe("slurtlehole", { Ingredient("slurtleslime", 10), Ingredient("slurtle_shellpieces", 4), Ingredient("rocks", 8)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "slurtlehole_placer")
rsl.atlas = "images/inventoryimages/slurtlehole.xml"
local rcd = Recipe("catcoonden", { Ingredient("coontail", 4), Ingredient("log", 15), Ingredient("sewing_kit", 1)}, RECIPETABS.TOWN, TECH.SCIENCE_TWO, "catcoonden_placer")
rcd.atlas = "images/inventoryimages/catcoonden.xml"

    for _,v in pairs(GLOBAL.AllRecipes) do
		if IsServer then
			if v.name == "firesuppressor" then
				v.min_spacing = 1
			end
		end
	end

   function merm_init(inst)
        if IsServer then
            inst:RemoveComponent("perishable")
            inst:AddComponent("fueled")
            inst.components.fueled.fueltype = FUELTYPE.USAGE
            inst.components.fueled:InitializeFuelLevel(TUNING.TOPHAT_PERISHTIME)
            inst.components.fueled:SetDepletedFn(--[[generic_perish]]inst.Remove)
        end
    end
    function healthregen(inst) 
		if IsServer then
			if inst.components.health then 
				inst.components.health:StartRegen(4, 30)
			end
		end
    end
    function waterproofer(inst)
        inst:AddTag("waterproofer")
        if IsServer then
            inst:AddComponent("waterproofer")
            inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALLMED)
        end
    end

    function frozen(inst)
        inst:AddTag("frozen")
    end
    function petfreeze(inst)
        inst:AddTag("fridge")
    end

    function shouldnotfly(inst)
        if inst:HasTag("flying") then 
            inst:RemoveTag("flying")
        end
        if IsServer then
            GLOBAL.MakeCharacterPhysics(inst, 1, .5)
        end
    end

    function shouldstackable(inst)
        if IsServer then
            inst:AddComponent("stackable")
        end
    end

    function canliveinocean(inst)
        inst:AddTag("smalloceancreature")
    end

    local seeds = 
    {
        "seeds",
        "carrot_seeds",
        "corn_seeds",
        "pumpkin_seeds",
        "eggplant_seeds",
        "durian_seeds",
        "pomegranate_seeds",
        "dragonfruit_seeds",
        "watermelon_seeds",
        "tomato_seeds",
        "potato_seeds",
        "asparagus_seeds",
        "onion_seeds",
        "garlic_seeds",
        "pepper_seeds",
    }

    TUNING.SALTROCK_PRESERVE_PERCENT_ADD = 30
    TUNING.SALTLICK_BEEFALO_USES = 0
    TUNING.SALTLICK_KOALEFANT_USES = 0
    TUNING.SALTLICK_LIGHTNINGGOAT_USES = 0
    TUNING.SALTLICK_DEER_USES = 0

    STRINGS.RECIPE_DESC.MEATRACK_HERMIT = "剽窃老螃蟹的工艺"
    AddPrefabPostInit("petals", frozen)
    AddPrefabPostInit("mermhat", merm_init)
    AddPrefabPostInit("sisturn", petfreeze)
    AddPrefabPostInit("seedpouch", petfreeze)
    AddPrefabPostInit("bearger", healthregen)
    AddPrefabPostInit("deer", healthregen)
    AddPrefabPostInit("slurtlehole", healthregen)
	AddPrefabPostInit("friendlyfruitfly", healthregen)
	AddPrefabPostInit("glommer", healthregen)
	AddPrefabPostInit("grassgekko", healthregen)
    AddPrefabPostInit("icepack", waterproofer)
    AddPrefabPostInit("walrushat", waterproofer)
    AddPrefabPostInit("yellowamulet", waterproofer)
    AddPrefabPostInit("cane", waterproofer)
    AddPrefabPostInit("pondfish", shouldstackable)
    AddPrefabPostInit("pondeel", canliveinocean)
    AddPrefabPostInit("pondfish", canliveinocean)
    AddPrefabPostInit("pondeel", shouldstackable)
    AddPrefabPostInit("shadowheart",shouldstackable)
    AddPrefabPostInit("deer_antler", shouldstackable)
    --AddPrefabPostInit("seedpouch", equip_new)

    for i,v in pairs(seeds) do
        AddPrefabPostInit(v, frozen)
    end

    AddPrefabPostInit("eyeturret", function(inst)
        if IsServer then 
            inst:AddComponent("lootdropper")
            inst.components.lootdropper:SetLoot({"eyeturret_item"})
        end
    end)

	
	
local function canspawn(inst)
	if IsServer then 
		return true 
	end
end

AddPrefabPostInit("catcoonden", function(inst)
	if IsServer then 
		if inst.components.childspawner then
			inst.components.childspawner.canspawnfn = canspawn
		end
	end
end)

AddPrefabPostInit("foliage", function(inst)
	if IsServer then 
		if inst.components.perishable then
			inst.components.perishable.onperishreplacement = "petals"
		end
	end
end)

AddPrefabPostInit("meatrack", function(inst)
	if IsServer then 
		if inst.components.dryer then
			inst.components.dryer.protectedfromrain = true
		end
	end
end)

-- 导出RPC命名空间和命令，供其他文件使用
GLOBAL.ATLAS_RPC = {
    NAMESPACE = ATLAS_RPC_NAMESPACE,
    ADD_TASK = ATLAS_RPC_ADD_TASK,
    TOGGLE_TASK = ATLAS_RPC_TOGGLE_TASK,
    DELETE_TASK = ATLAS_RPC_DELETE_TASK,
    SYNC_TASKS = ATLAS_RPC_SYNC_TASKS
}