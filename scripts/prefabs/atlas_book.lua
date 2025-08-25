local assets = 
{
    Asset("ANIM", "anim/book_fossil.zip"),
    Asset("ANIM", "anim/swap_book_fossil.zip"),
    Asset("ATLAS", "images/inventoryimages/book_fossil.xml"),
    Asset("IMAGE", "images/inventoryimages/book_fossil.tex"),
}

local prefabs = {}

-- 定义书本的属性
local def = {
    name = "atlas_book",
    uses = -1, -- 无限使用次数
    fn = function(inst, reader)
        -- 打开书本UI
        if reader.HUD then
            reader.HUD:OpenAtlasBook()
        end
        return true
    end,
}

local function fn()
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
    
    -- 添加标签以便识别
    inst:AddTag("atlas_book")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    -----------------------------------

    inst:AddComponent("inspectable")
    inst.components.inspectable:SetDescription(STRINGS.RECIPE_DESC.ATLAS_BOOK)
    
    inst:AddComponent("book")
    inst.components.book.onread = def.fn

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "book_fossil"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/book_fossil.xml"

    -- 这本书不会用坏
    if def.uses > 0 then
        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)
    end

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    MakeSmallPropagator(inst)

    MakeHauntableLaunch(inst)

    return inst
end

return Prefab("atlas_book", fn, assets, prefabs) 