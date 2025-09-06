print("[ATLAS_SANITY_CHECK] Loading atlas_book.lua file - Version with FINAL FIX")

local assets =
{
    Asset("ANIM", "anim/book_fossil.zip"),
    Asset("ANIM", "anim/swap_book_fossil.zip"),
    Asset("ATLAS", "images/inventoryimages/book_fossil.xml"),
    Asset("IMAGE", "images/inventoryimages/book_fossil.tex"),
}

local prefabs = {}

-- ====================================================================
-- 1. 服务器端逻辑：当书被阅读时，只推送一个简单的"信号"事件
-- ====================================================================
local function onread_server(inst, reader)
    print("[ATLAS_DEBUG] SERVER: Pushing 'open_atlas_book_ui' signal event.")
    -- 我们不再发送任何数据，因为客户端自己可以判断
    inst:PushEvent("open_atlas_book_ui")
    return true
end

-- ====================================================================
-- ▼▼▼ 将客户端监听函数变为全局函数 ▼▼▼
-- ====================================================================
_G.OnAtlasBookOpenUI = function(inst)
    print("[ATLAS_DEBUG] CLIENT: Received 'open_atlas_book_ui' signal.")
    if ThePlayer and ThePlayer.replica.inventory and ThePlayer.replica.inventory:IsGrandOwner(inst) then
        print("[ATLAS_DEBUG] CLIENT: Book is owned by ThePlayer. Opening UI.")
        if ThePlayer.HUD and ThePlayer.HUD.OpenAtlasBook then
            ThePlayer.HUD:OpenAtlasBook()
        else
            print("[ATLAS_DEBUG] CRITICAL ERROR: ThePlayer.HUD or OpenAtlasBook is nil on client!")
        end
    else
        print("[ATLAS_DEBUG] CLIENT: Book is not owned by ThePlayer. Ignoring event.")
    end
end

-- ====================================================================
-- ▼▼▼ 主要修改在这里 ▼▼▼
-- ====================================================================
local function onreplicated(inst)
    print("[ATLAS_DEBUG] CLIENT: atlas_book entity replicated. Setting up event listener.")
    -- 使用全局函数来设置监听
    inst:ListenForEvent("open_atlas_book_ui", _G.OnAtlasBookOpenUI)
end

local function fn()
    print("[ATLAS_SANITY_CHECK] Client is running fn() for an atlas_book instance.") -- ▼▼▼ ADD THIS LINE HERE ▼▼▼
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("book_fossil")
    inst.AnimState:SetBuild("book_fossil")
    inst.AnimState:PlayAnimation("book_fossil")

    MakeInventoryFloatable(inst, "med", nil, 0.75)
    
    inst:AddTag("atlas_book")
    inst.entity:SetPristine()

    -- ▼▼▼ 将客户端逻辑移出 if/else 结构 ▼▼▼
    -- 这个函数赋值必须在 if/else 之外，以便在客户端实体创建时被识别
    inst.OnEntityReplicated = onreplicated

    if TheWorld.ismastersim then
        -- 服务器端代码
        inst:AddComponent("inspectable")
        local description = STRINGS.RECIPE_DESC and STRINGS.RECIPE_DESC.ATLAS_BOOK or "包含丰富知识的指南书"
        inst.components.inspectable:SetDescription(description)
        
        inst:AddComponent("book")
        inst.components.book.onread = onread_server -- 使用服务器版本的 onread

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "book_fossil"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/book_fossil.xml"

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL
        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)
        MakeHauntableLaunch(inst)
    end
    -- 我们不再需要 else 分支了，因为客户端逻辑已经由 OnEntityReplicated 处理

    return inst
end

return Prefab("atlas_book", fn, assets, prefabs) 