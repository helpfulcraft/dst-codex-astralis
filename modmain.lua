
local SpawnPrefab = GLOBAL.SpawnPrefab
local FUELTYPE = GLOBAL.FUELTYPE
local IsServer = GLOBAL.TheNet:GetIsServer()
local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS
local PI = GLOBAL.PI

-- 加载多语言字符串模块
local strings_module = require("strings")
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
        if book.components.book ~= nil then
            local success, reason = book.components.book.onread(book, act.doer)
            return success, reason
        end
    else
        return superRead(act)
    end
end

print("[万象全书] 动作系统覆盖完成 - 所有角色现在都可以阅读万象全书")
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

-- 多语言字符串现在通过 scripts/strings.lua 模块加载
-- 所有字符串定义已移除，改用动态加载方式

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

-- 配置临时路牌的输入界面布局 - 延迟到游戏完全初始化后执行
AddSimPostInit(function()
    -- 尝试直接加载 writeables 模块
    local success, writeables = GLOBAL.pcall(GLOBAL.require, "writeables")

    if success and writeables and writeables.AddLayout then
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