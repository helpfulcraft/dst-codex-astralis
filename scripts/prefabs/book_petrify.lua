--local name = "book_"..booktype
    local assets = 
    {
        Asset("ANIM", "anim/book_fossil.zip"),
        Asset("ANIM", "anim/swap_book_fossil.zip"),
        Asset("ATLAS", "images/inventoryimages/book_fossil.xml"),
        Asset("IMAGE", "images/inventoryimages/book_fossil.tex"),
    }

local prefabs = {}

--helper function for book_gardening
local function trypetrify(inst)
    local STAGE_PETRIFY_PREFABS =
    {
    "rock_petrified_tree_short",
    "rock_petrified_tree_med",
    "rock_petrified_tree_tall",
    "rock_petrified_tree_old",
    }
    local STAGE_PETRIFY_FX =
    {
    "petrified_tree_fx_short",
    "petrified_tree_fx_normal",
    "petrified_tree_fx_tall",
    "petrified_tree_fx_old",
    }
    local function dopetrify(inst, stage, instant)
      local x, y, z = inst.Transform:GetWorldPosition()
      local r, g, b = inst.AnimState:GetMultColour()
        inst:Remove()
       --remap anim
        local rock = SpawnPrefab(STAGE_PETRIFY_PREFABS[stage])
        if rock ~= nil then
            rock.AnimState:SetMultColour(r, g, b, 1)
            rock.Transform:SetPosition(x, 0, z)
         if not instant then
            local fx = SpawnPrefab(STAGE_PETRIFY_FX[stage])
            fx.Transform:SetPosition(x, y, z)
            fx:InheritColour(r, g, b)
         end
        end
    end
    if (inst:HasTag("evergreens")) and
        not inst:HasTag("stump") then
        local stage = inst.components.growable.stage
        dopetrify(inst, stage)
    end
end

local def =   
    {
    name = "book_petrify",
    uses = 5,
    fn = function(inst, reader)
            reader.components.sanity:DoDelta(-TUNING.SANITY_HUGE)

            local x, y, z = reader.Transform:GetWorldPosition()
            local range = 30
            local ents = TheSim:FindEntities(x, y, z, range, nil, "stump")
            if #ents > 0 then
                trypetrify(table.remove(ents, math.random(#ents)))
                if #ents > 0 then
                    local timevar = 1 - 1 / (#ents + 1)
                    for i, v in ipairs(ents) do
                        v:DoTaskInTime(timevar * math.random(), trypetrify)
                    end
                end
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

        inst.entity:SetPristine()

        if not TheWorld.ismastersim then
            return inst
        end

        -----------------------------------

        inst:AddComponent("inspectable")
        inst:AddComponent("book")
        inst.components.book.onread = def.fn
        inst.components.book.onperuse = def.perusefn

        inst:AddComponent("inventoryitem")
        inst.components.inventoryitem.imagename = "book_fossil"
        inst.components.inventoryitem.atlasname = "images/inventoryimages/book_fossil.xml"

        inst:AddComponent("finiteuses")
        inst.components.finiteuses:SetMaxUses(def.uses)
        inst.components.finiteuses:SetUses(def.uses)
        inst.components.finiteuses:SetOnFinished(inst.Remove)

        inst:AddComponent("fuel")
        inst.components.fuel.fuelvalue = TUNING.MED_FUEL

        MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
        MakeSmallPropagator(inst)

        --MakeHauntableLaunchOrChangePrefab(inst, TUNING.HAUNT_CHANCE_OFTEN, TUNING.HAUNT_CHANCE_OCCASIONAL, nil, nil, morphlist)
        MakeHauntableLaunch(inst)

        return inst
    end

    --return Prefab(def.name, fn, assets, prefabs)

return Prefab("book_petrify", fn, assets, prefabs)
