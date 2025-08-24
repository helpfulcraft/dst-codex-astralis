local Layouts = GLOBAL.require("map/layouts").Layouts
local StaticLayout = GLOBAL.require("map/static_layout")

	Layouts[1] = StaticLayout.Get("map/static_layouts/mactusk_city")
	Layouts[2] = StaticLayout.Get("map/static_layouts/tallbird_rocks")
	Layouts[3] = StaticLayout.Get("map/static_layouts/tenticle_reeds")
	Layouts[4] = StaticLayout.Get("map/static_layouts/insane_wormhole")
	Layouts[5] = StaticLayout.Get("map/static_layouts/mactusk_village") 
	Layouts[6] = StaticLayout.Get("map/static_layouts/hound_rocks")
	Layouts[7] = StaticLayout.Get("map/static_layouts/insane_eyebone")
	Layouts[8] = StaticLayout.Get("map/static_layouts/beefalo_farm")
	Layouts[9] = StaticLayout.Get("map/static_layouts/chess_blocker_b")
	Layouts[10] = StaticLayout.Get("map/static_layouts/chess_blocker_c")
	Layouts[11] = StaticLayout.Get("map/static_layouts/chess_blocker")
	Layouts[12] = StaticLayout.Get("map/static_layouts/chess_spot")
	Layouts[13] = StaticLayout.Get("map/static_layouts/leif_forest")
	Layouts[14] = StaticLayout.Get("map/static_layouts/tentacles_blocker_small")
	Layouts[15] = StaticLayout.Get("map/static_layouts/tentacles_blocker")
	Layouts[16] = StaticLayout.Get("map/static_layouts/pigguard_berries")
	Layouts[17] = StaticLayout.Get("map/static_layouts/pigtown")
	Layouts[18] = StaticLayout.Get("map/static_layouts/insane_flint")
	Layouts[19] = StaticLayout.Get("map/static_layouts/simple_base")
	Layouts[20] = StaticLayout.Get("map/static_layouts/insane_pig")
	Layouts[21] = StaticLayout.Get("map/static_layouts/trap_firestaff")
	Layouts[22] = StaticLayout.Get("map/static_layouts/trap_forceinsane")
	Layouts[23] = StaticLayout.Get("map/static_layouts/trap_icestaff")
	Layouts[24] = StaticLayout.Get("map/static_layouts/wasphive_grass_easy")
	Layouts[25] = StaticLayout.Get("map/static_layouts/maxwell_merm_shrine")
	Layouts[26] = StaticLayout.Get("map/static_layouts/maxwell_pig_shrine")
	Layouts[27] = StaticLayout.Get("map/static_layouts/spider_blocker")
	Layouts[28] = StaticLayout.Get("map/static_layouts/warzone_1")
	Layouts[29] = StaticLayout.Get("map/static_layouts/trap_winter")
	Layouts[30] = StaticLayout.Get("map/static_layouts/dev_graveyard")

local task_forest_any = {"Make a pick", "Dig that rock", "Great Plains", "Squeltch", "Beeeees!", "Speak to the king", "Forest hunters", "Befriend the pigs", "For a nice walk", "Kill the spiders", "Killer bees!", "Make a Beehat", "The hunters", "Magic meadow", "Frogs and bugs", "Badlands"}
local task_forest_swamp = {"Squeltch","Lots-o-Spiders","Lots-o-Tentacles","Merms ahoy"}
local task_forest_desert = {"Badlands","Oasis",}
local task_forest_grasslands = {"Waspy Beeeees!","For a nice walk","Frogs and bugs","Magic meadow","Make a Beehat","Killer bees!","Wasps and Frogs and bugs","Killer bees!",}
local task_forest_deciduous = {"Speak to the king","Mole Colony Deciduous",}
local task_forest_rocky = {"Mole Colony Rocks","Dig that rock","The hunters",}
local task_forest_savannah = {"Great Plains","Greater Plains"}
local task_forest_forest = {"The Deep Forest","Befriend the pigs","Kill the spiders","Forest hunters",}

AddSetPiecePreInitAny = function(name, count, tasks)
    AddLevelPreInitAny(function(level)

        if level.location ~= "forest" then
            return
        end

        if not level.set_pieces then
            level.set_pieces = {}
        end
        level.set_pieces[name] = { count = count, tasks = tasks }
    end)
end

	AddSetPiecePreInitAny(1, 3, task_forest_grasslands)
	AddSetPiecePreInitAny(2, 1, task_forest_rocky)
	AddSetPiecePreInitAny(3, 3, task_forest_swamp)
	AddSetPiecePreInitAny(13, 3, task_forest_forest)
	AddSetPiecePreInitAny(25, 3, task_forest_swamp)
	AddSetPiecePreInitAny(30, 1, task_forest_forest)