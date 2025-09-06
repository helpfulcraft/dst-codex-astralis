
-- 首先注册预制体文件，确保在存档加载前完成注册
PrefabFiles = {
    "book_petrify", 
    "spiderhole_placer", 
    "wasphive_placer", 
    "beehive_placer", 
    "slurtlehole_placer", 
    "catcoonden_placer",
    "atlas_book", -- 添加万象全书
}

local SpawnPrefab = GLOBAL.SpawnPrefab
local FUELTYPE = GLOBAL.FUELTYPE
local IsServer = GLOBAL.TheNet:GetIsServer()
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local PI = GLOBAL.PI

-- 首先定义基础字符串，确保Prefab文件加载时可用
local STRINGS = GLOBAL.STRINGS

-- 万象全书相关字符串定义
STRINGS.NAMES.ATLAS_BOOK = "万象全书"
STRINGS.RECIPE_DESC.ATLAS_BOOK = "包含丰富知识的指南书"

-- 小木牌相关字符串定义（确保Prefab加载时可用）
STRINGS.NAMES.MINISIGN = "小木牌"
STRINGS.NAMES.MINISIGN_DRAWN = "{item}木牌"

-- UI按钮字符串定义（确保writeables.AddLayout时可用）
STRINGS.CANCEL_BUTTON = "取消"
STRINGS.CLEAR_BUTTON = "清空"
STRINGS.CONFIRM_BUTTON = "确定"
STRINGS.INPUT_PROMPT = "输入任务内容:"

-- 各角色对万象全书的描述
STRINGS.CHARACTERS.GENERIC.DESCRIBE.ATLAS_BOOK = "知识就是力量！"
STRINGS.CHARACTERS.WILLOW.DESCRIBE.ATLAS_BOOK = "这本书看起来不太适合生火。"
STRINGS.CHARACTERS.WOLFGANG.DESCRIBE.ATLAS_BOOK = "小书让沃尔夫冈变聪明！"
STRINGS.CHARACTERS.WENDY.DESCRIBE.ATLAS_BOOK = "知识也无法填补我心中的空洞。"
STRINGS.CHARACTERS.WX78.DESCRIBE.ATLAS_BOOK = "人类知识数据库。低效但有用。"
STRINGS.CHARACTERS.WICKERBOTTOM.DESCRIBE.ATLAS_BOOK = "一本包含丰富知识的百科全书！"
STRINGS.CHARACTERS.WOODIE.DESCRIBE.ATLAS_BOOK = "露西不太喜欢我看书。"
STRINGS.CHARACTERS.WAXWELL.DESCRIBE.ATLAS_BOOK = "知识是我的另一种武器。"
STRINGS.CHARACTERS.WATHGRITHR.DESCRIBE.ATLAS_BOOK = "战士也需要智慧！"
STRINGS.CHARACTERS.WEBBER.DESCRIBE.ATLAS_BOOK = "我们喜欢看书！"
STRINGS.CHARACTERS.WINONA.DESCRIBE.ATLAS_BOOK = "实用的指南，我喜欢。"
STRINGS.CHARACTERS.WORTOX.DESCRIBE.ATLAS_BOOK = "知识的味道如何呢？嘻嘻！"
STRINGS.CHARACTERS.WARLY.DESCRIBE.ATLAS_BOOK = "可惜没有更多的烹饪秘方。"
STRINGS.CHARACTERS.WURT.DESCRIBE.ATLAS_BOOK = "鱼人也要学习！"
STRINGS.CHARACTERS.WORMWOOD.DESCRIBE.ATLAS_BOOK = "朋友的叶子？不，是知识。"

-- 加载多语言字符串模块（用于UI和其他功能）
local strings_module = require("strings")

-- 将strings模块暴露为全局变量，供UI模块使用
GLOBAL.ATLAS_STRINGS_MODULE = strings_module
local TheSim = GLOBAL.TheSim
local Ingredient = GLOBAL.Ingredient
local TUNING = GLOBAL.TUNING
local Recipe = GLOBAL.Recipe
local RECIPETABS = GLOBAL.RECIPETABS
local AllRecipes = GLOBAL.AllRecipes
local TECH = GLOBAL.TECH
local TheNet = GLOBAL.TheNet
local TheWorld = GLOBAL.TheWorld
local json = GLOBAL.json

-- 添加RPC命名空间和命令
local ATLAS_RPC_NAMESPACE = "atlas_book"
local ATLAS_RPC_ADD_TASK = "add_task"
local ATLAS_RPC_TOGGLE_TASK = "toggle_task"
local ATLAS_RPC_DELETE_TASK = "delete_task"
local ATLAS_RPC_SYNC_TASKS = "sync_tasks"

-- 动作系统覆盖，让所有角色都能阅读atlas_book
-- 获取COMPONENT_ACTIONS系统引用
local function GetComponentActions()
    local fn = GLOBAL.EntityScript.CollectActions
    local upvalue_name = "COMPONENT_ACTIONS"
    local set_upvalue = nil
    if fn == nil or upvalue_name == nil then
        return
    end
    local i = 1
    while true do
        local val, v = GLOBAL.debug.getupvalue(fn, i)

        if not val then
            break
        end
        if val == upvalue_name then
            if set_upvalue then
                GLOBAL.debug.setupvalue(fn, i, set_upvalue)
            end

            return v, i
        end
        i = i + 1
    end
end

-- 重写book组件动作收集函数
local COMPONENT_ACTIONS = GetComponentActions()
if COMPONENT_ACTIONS then
    local superBook = COMPONENT_ACTIONS.INVENTORY.book

    COMPONENT_ACTIONS.INVENTORY.book = function(inst, doer, actions)
        if inst and inst:HasTag('atlas_book') then
            table.insert(actions, GLOBAL.ACTIONS.READ)
        else
            if superBook then
                superBook(inst, doer, actions)
            end
        end
    end
end

-- 重写READ动作执行函数
local superRead = GLOBAL.ACTIONS.READ.fn

GLOBAL.ACTIONS.READ.fn = function(act)
    local book = act.target or act.invobject
    if book and book:HasTag('atlas_book') then
        -- ▼▼▼ 添加这行日志 ▼▼▼
        print("[ATLAS_DEBUG] READ action triggered for atlas_book by:", act.doer and act.doer.name or "nil doer")
        
        if book.components.book ~= nil then
            print("[ATLAS_DEBUG] Calling book.components.book.onread...")
            local success, reason = book.components.book.onread(book, act.doer)
            print("[ATLAS_DEBUG] onread result - success:", success, "reason:", reason)
            return success, reason
        else
            print("[ATLAS_DEBUG] ERROR: book.components.book is nil!")
        end
    else
        return superRead(act)
    end
end

print("[万象全书] 动作系统覆盖完成 - 所有角色现在都可以阅读万象全书")
-- 注册UI
print("[ATLAS_DEBUG] ========== 开始加载UI模块 ==========")
print("[ATLAS_DEBUG] 当前时间:", GLOBAL.GetTime())
print("[ATLAS_DEBUG] ThePlayer状态:", GLOBAL.ThePlayer and "存在" or "不存在")
if GLOBAL.ThePlayer then
    print("[ATLAS_DEBUG] ThePlayer名称:", GLOBAL.ThePlayer.name or "无名称")
end

local AtlasBookUI = require("widgets/atlasbook_ui")
if not AtlasBookUI then
    print("[ATLAS_DEBUG] 错误: 无法加载 widgets/atlasbook_ui.lua")
    print("[ATLAS_DEBUG] 尝试加载 scripts/widgets/atlasbook_ui.lua")
    AtlasBookUI = require("scripts/widgets/atlasbook_ui")
    if not AtlasBookUI then
        print("[ATLAS_DEBUG] 严重错误: 无法加载 scripts/widgets/atlasbook_ui.lua")
        print("[ATLAS_DEBUG] 检查文件路径和内容...")
    else
        print("[ATLAS_DEBUG] 成功加载 scripts/widgets/atlasbook_ui.lua")
        print("[ATLAS_DEBUG] AtlasBookUI类型:", type(AtlasBookUI))
        print("[ATLAS_DEBUG] AtlasBookUI构造函数:", AtlasBookUI and "存在" or "不存在")
    end
else
    print("[ATLAS_DEBUG] 成功加载 widgets/atlasbook_ui.lua")
    print("[ATLAS_DEBUG] AtlasBookUI类型:", type(AtlasBookUI))
    print("[ATLAS_DEBUG] AtlasBookUI构造函数:", AtlasBookUI and "存在" or "不存在")
end

-- 将AtlasBookUI暴露为全局变量
GLOBAL.AtlasBookUI = AtlasBookUI
print("[ATLAS_DEBUG] AtlasBookUI已设置为全局变量")
print("[ATLAS_DEBUG] GLOBAL.AtlasBookUI状态:", GLOBAL.AtlasBookUI and "存在" or "不存在")
print("[ATLAS_DEBUG] ========== UI模块加载完成 ==========")

-- 在玩家HUD中添加UI控件
print("[ATLAS_DEBUG] ========== 注册HUD类构造后处理 ==========")
AddClassPostConstruct("screens/playerhud", function(self)
    -- 这个PostConstruct函数在每个客户端的HUD创建时运行
    print("[ATLAS_DEBUG] HUD PostConstruct for owner:", self.owner and self.owner.name or "nil", "and ThePlayer:", GLOBAL.ThePlayer and GLOBAL.ThePlayer.name or "nil")

    -- 添加打开UI的方法
    function self:OpenAtlasBook()
        print("[ATLAS_DEBUG] ========== OpenAtlasBook方法被调用 ==========")
        
        -- 检查UI是否已经在屏幕上
        if GLOBAL.TheFrontEnd:GetActiveScreen() and GLOBAL.TheFrontEnd:GetActiveScreen().name == "AtlasBookUI" then
            print("[ATLAS_DEBUG] UI已在屏幕上，返回。")
            return
        end
        
        if not GLOBAL.AtlasBookUI then
            print("[ATLAS_DEBUG] 严重错误: AtlasBookUI类不存在！")
            return
        end

        -- ====================================================================
        -- THE FIX IS HERE:
        -- 无论self.owner当时是什么，当这个函数被调用时，
        -- 我们总是需要当前本地玩家的UI。GLOBAL.ThePlayer是获取它的最可靠方式。
        -- ThePlayer.HUD.owner 就是 ThePlayer 自己。
        -- ====================================================================
        print("[ATLAS_DEBUG] 准备使用 ThePlayer 创建UI实例:", GLOBAL.ThePlayer and GLOBAL.ThePlayer.name or "nil")
        local success, atlasbook = pcall(function()
            return GLOBAL.AtlasBookUI(GLOBAL.ThePlayer) -- 使用 ThePlayer 而不是 self.owner
        end)
        
        if not success then
            print("[ATLAS_DEBUG] 错误: 创建UI实例失败:", atlasbook)
            return
        end
        
        print("[ATLAS_DEBUG] UI实例创建成功，准备推送。")
        GLOBAL.TheFrontEnd:PushScreen(atlasbook)
        print("[ATLAS_DEBUG] UI推送完成。")
    end
    
    print("[ATLAS_DEBUG] OpenAtlasBook方法已添加到HUD实例。")
end)
print("[ATLAS_DEBUG] ========== HUD类构造后处理注册完成 ==========")

-- ====================================================================
-- ▼▼▼ 这是新的、正确的位置 ▼▼▼
-- 将客户端初始化逻辑放在顶层，而不是 AddSimPostInit 中
-- ====================================================================
if not TheNet:GetIsServer() then -- 使用 TheNet:GetIsServer() 更标准
    print("[万象全书] 客户端顶层初始化开始...")

    -- 这个函数用于为玩家物品栏中的书本设置监听器
    local function SetupAtlasBookListenersForPlayer(player)
        if player and player.replica.inventory then
            print("[ATLAS_DEBUG] modmain: Checking inventory for atlas_book on player ready...")
            
            for i, item in pairs(player.replica.inventory:GetItems()) do
                if item and item:HasTag("atlas_book") then
                    print("[ATLAS_DEBUG] modmain: Found atlas_book in inventory. Attaching listener as a failsafe.")
                    -- 检查全局函数是否存在，防止 Prefab 没加载
                    if _G.OnAtlasBookOpenUI then
                        item:ListenForEvent("open_atlas_book_ui", _G.OnAtlasBookOpenUI, true)
                    else
                        print("[ATLAS_DEBUG] CRITICAL ERROR: _G.OnAtlasBookOpenUI is not defined when needed!")
                    end
                end
            end
        end
    end

    -- 我们仍然需要在 SimPostInit 中添加组件和监听器，因为这需要TheWorld完全可用
    AddSimPostInit(function()
        if TheWorld then
            print("[万象全书] SimPostInit: 添加客户端组件 atlas_todolist")
            TheWorld:AddComponent("atlas_todolist")
            
            -- "ms_becameplayer" 是一个客户端事件，在玩家完全控制角色时触发
            print("[ATLAS_DEBUG] modmain: TheWorld is now available, registering ms_becameplayer listener.")
            TheWorld:ListenForEvent("ms_becameplayer", function(world, player)
                -- 事件的回调会传入 player 参数，直接使用它
                print("[ATLAS_DEBUG] modmain: Event 'ms_becameplayer' triggered.")
                SetupAtlasBookListenersForPlayer(player)
            end)
        else
            print("[ATLAS_DEBUG] CRITICAL ERROR: TheWorld is still nil in AddSimPostInit!")
        end
    end)
end
-- ====================================================================

-- 注册服务器端组件
AddComponentPostInit("worldstate", function(self)
    -- 只在主服务器上添加组件
    if GLOBAL.TheWorld.ismastersim then
        print("[万象全书] 添加服务器端组件 atlas_todolist")
        GLOBAL.TheWorld:AddComponent("atlas_todolist")
    end
end)

-- 注意：客户端初始化逻辑已经移到顶层，这里不再需要

-- 注意：移除了不可靠的AddPlayerPostInit逻辑
-- 现在完全依赖AddClassPostConstruct("screens/playerhud", ...)机制
-- 这确保了无论何时创建HUD实例，都会自动包含OpenAtlasBook方法

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

-- 客户端到服务器：请求同步任务列表
AddModRPCHandler(ATLAS_RPC_NAMESPACE, ATLAS_RPC_SYNC_TASKS, function(player)
    print("[万象全书] 收到同步任务列表请求，来自玩家:", player.name or "未知")
    if GLOBAL.TheWorld.components.atlas_todolist ~= nil then
        local tasks = GLOBAL.TheWorld.components.atlas_todolist:GetTasks()
        local tasks_json = json.encode(tasks)
        print("[万象全书] 向客户端发送任务列表，任务数量:", #tasks)
        SendModRPCToClient(ATLAS_RPC_NAMESPACE, ATLAS_RPC_SYNC_TASKS, player.userid, tasks_json)
    else
        print("[万象全书] 错误: 服务器端atlas_todolist组件不存在")
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

-- 多语言字符串现在通过 scripts/strings.lua 模块加载
-- 基础字符串已在文件开头定义，确保Prefab加载时可用

-- 延迟到游戏完全初始化后添加配方，确保 CUSTOM_RECIPETABS 可用
AddSimPostInit(function()
    if GLOBAL.CUSTOM_RECIPETABS and GLOBAL.CUSTOM_RECIPETABS.BOOKS then
        AddRecipe("book_petrify", {Ingredient("fossil_piece", GetModConfigData('fos')),Ingredient("papyrus", 2)}, GLOBAL.CUSTOM_RECIPETABS.BOOKS,
        TECH.MAGIC_THREE, nil, nil, nil, nil, "bookbuilder","images/inventoryimages.xml", "book_fossil.tex", nil, nil)
        AddRecipe("book_gardening",  {Ingredient("papyrus", 2), Ingredient("seeds", 1), Ingredient("poop", 1)}, GLOBAL.CUSTOM_RECIPETABS.BOOKS, TECH.MOON_ALTAR_TWO, nil, nil, nil, nil, "bookbuilder")
        print("[万象全书] 书籍配方添加成功")
    else
        print("[万象全书] 警告: CUSTOM_RECIPETABS.BOOKS 不可用，跳过书籍配方添加")
    end
end)
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

    -- 多语言字符串已通过 scripts/strings.lua 模块加载
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

-- 添加测试命令（仅开发模式）
if GLOBAL.CHEATS_ENABLED then
    GLOBAL.AtlasTestCommands = {
        -- 添加测试任务
        AddTestTask = function(text)
            if GLOBAL.TheWorld and GLOBAL.TheWorld.components and GLOBAL.TheWorld.components.atlas_todolist then
                local result = GLOBAL.TheWorld.components.atlas_todolist:AddTask(text or "测试任务")
                print("[万象全书] 测试命令 - 添加任务结果:", result and "成功" or "失败")
                return result
            else
                print("[万象全书] 测试命令 - 错误: atlas_todolist组件不存在")
                return nil
            end
        end,
        
        -- 查看任务列表
        ListTasks = function()
            if GLOBAL.TheWorld and GLOBAL.TheWorld.components and GLOBAL.TheWorld.components.atlas_todolist then
                local tasks = GLOBAL.TheWorld.components.atlas_todolist:GetTasks()
                print("[万象全书] 测试命令 - 当前任务列表:")
                for i, task in ipairs(tasks) do
                    print("  " .. i .. ". [" .. (task.completed and "✓" or "□") .. "] " .. task.text .. " (ID: " .. task.id .. ")")
                end
                return tasks
            else
                print("[万象全书] 测试命令 - 错误: atlas_todolist组件不存在")
                return nil
            end
        end,
        
        -- 清空任务列表
        ClearTasks = function()
            if GLOBAL.TheWorld and GLOBAL.TheWorld.components and GLOBAL.TheWorld.components.atlas_todolist then
                local tasks = GLOBAL.TheWorld.components.atlas_todolist:GetTasks()
                for i = #tasks, 1, -1 do
                    GLOBAL.TheWorld.components.atlas_todolist:DeleteTask(tasks[i].id)
                end
                print("[万象全书] 测试命令 - 已清空所有任务")
                return true
            else
                print("[万象全书] 测试命令 - 错误: atlas_todolist组件不存在")
                return false
            end
        end,
        
        -- 测试OpenAtlasBook方法
        TestOpenUI = function()
            print("[ATLAS_DEBUG] ========== 测试OpenAtlasBook方法 ==========")
            print("[ATLAS_DEBUG] ThePlayer状态:", GLOBAL.ThePlayer and "存在" or "不存在")
            if GLOBAL.ThePlayer then
                print("[ATLAS_DEBUG] ThePlayer名称:", GLOBAL.ThePlayer.name or "无名称")
                print("[ATLAS_DEBUG] ThePlayer.HUD状态:", GLOBAL.ThePlayer.HUD and "存在" or "不存在")
                if GLOBAL.ThePlayer.HUD then
                    print("[ATLAS_DEBUG] ThePlayer.HUD.OpenAtlasBook状态:", GLOBAL.ThePlayer.HUD.OpenAtlasBook and "存在" or "不存在")
                    if GLOBAL.ThePlayer.HUD.OpenAtlasBook then
                        print("[ATLAS_DEBUG] 尝试调用OpenAtlasBook方法")
                        GLOBAL.ThePlayer.HUD:OpenAtlasBook()
                    else
                        print("[ATLAS_DEBUG] 错误: ThePlayer.HUD.OpenAtlasBook方法不存在")
                    end
                else
                    print("[ATLAS_DEBUG] 错误: ThePlayer.HUD不存在")
                end
            else
                print("[ATLAS_DEBUG] 错误: ThePlayer不存在")
            end
            print("[ATLAS_DEBUG] ========== 测试完成 ==========")
        end
    }
    
    print("[万象全书] 测试命令已加载:")
    print("  AtlasTestCommands.AddTestTask('任务内容') - 添加测试任务")
    print("  AtlasTestCommands.ListTasks() - 查看任务列表")
    print("  AtlasTestCommands.ClearTasks() - 清空任务列表")
    print("  AtlasTestCommands.TestOpenUI() - 测试打开UI")
end

-- 配置临时路牌的输入界面布局 - 延迟到游戏完全初始化后执行
AddSimPostInit(function()
    -- 尝试直接加载 writeables 模块
    local success, writeables = GLOBAL.pcall(GLOBAL.require, "writeables")

    if success and writeables and writeables.AddLayout then
        -- 调试：检查字符串是否正确加载
        print("[万象全书] 调试 - STRINGS.CANCEL_BUTTON:", STRINGS.CANCEL_BUTTON)
        print("[万象全书] 调试 - STRINGS.CLEAR_BUTTON:", STRINGS.CLEAR_BUTTON)
        print("[万象全书] 调试 - STRINGS.CONFIRM_BUTTON:", STRINGS.CONFIRM_BUTTON)
        print("[万象全书] 调试 - STRINGS.INPUT_PROMPT:", STRINGS.INPUT_PROMPT)
        
        writeables.AddLayout("atlas_temp_sign", {
            prompt = STRINGS.INPUT_PROMPT,
            animbank = "ui_board_5x3",
            animbuild = "ui_board_5x3",
            menuoffset = GLOBAL.Vector3(6, -70, 0),
            maxcharacters = 100, -- 限制任务最大长度

            cancelbtn = { text = STRINGS.CANCEL_BUTTON, cb = nil, control = CONTROL_CANCEL },
            middlebtn = { text = STRINGS.CLEAR_BUTTON, cb = function(inst, doer, widget)
                widget:OverrideText("")
            end, control = CONTROL_MENU_MISC_2 },
            acceptbtn = {
                text = STRINGS.CONFIRM_BUTTON,
                cb = function(inst, doer, widget)
                    local text = widget:GetText()
                    if text and text ~= "" then
                        print("[万象全书] 输入的任务内容:", text)

                        -- 直接操作 todolist 组件，避免 RPC 问题
                        print("[万象全书] 直接添加任务到 todolist")
                        if GLOBAL.TheWorld and GLOBAL.TheWorld.components and GLOBAL.TheWorld.components.atlas_todolist then
                            local result = GLOBAL.TheWorld.components.atlas_todolist:AddTask(text)
                            if result then
                                print("[万象全书] 任务添加成功")

                                -- 组件内部已经调用了 SyncToClients()，这里额外触发UI事件
                                if GLOBAL.ThePlayer then
                                    GLOBAL.ThePlayer:DoTaskInTime(0.2, function()
                                        print("[万象全书] 触发UI更新事件")
                                        GLOBAL.ThePlayer:PushEvent("atlas_todolist_updated")
                                    end)
                                end
                            else
                                print("[万象全书] 任务添加失败")
                            end
                        else
                            print("[万象全书] 错误: atlas_todolist 组件不存在")
                        end
                    else
                        print("[万象全书] 输入内容为空")
                    end
                end,
                control = CONTROL_ACCEPT
            },
        })
        print("[万象全书] 临时路牌输入界面布局配置成功")
    else
        print("[万象全书] 警告: writeables 模块不存在或加载失败，跳过输入界面配置")
        if not success then
            print("[万象全书] 错误信息:", writeables) -- writeables 变量在失败时包含错误信息
        end
    end
end)

-- 添加模组清理函数
if GLOBAL and GLOBAL.TheWorld then
    -- 在世界清理时执行资源清理
    GLOBAL.TheWorld:ListenForEvent("worldremoving", function()
        print("[万象全书] 检测到世界清理，开始执行资源清理")
        -- 清理全局UI实例
        if _G.atlas_ui_instances then
            for i, ui_instance in ipairs(_G.atlas_ui_instances) do
                if ui_instance and ui_instance.CleanupTempSign then
                    pcall(function() ui_instance:CleanupTempSign() end)
                end
            end
            _G.atlas_ui_instances = nil
        end
    end)
end