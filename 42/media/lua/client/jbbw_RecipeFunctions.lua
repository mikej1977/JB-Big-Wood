-- f your SawLogs recipeData

JB_Big_Wood = JB_Big_Wood  or {}
JB_Big_Wood.Recipes = JB_Big_Wood.Recipes or {}
JB_Big_Wood.Recipes.MakeLogs = JB_Big_Wood.Recipes.MakeLogs or {}
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

function JB_Big_Wood.Recipes.MakeLogs.OnCreate(craftRecipe)
    local modData = craftRecipe:getAllConsumedItems():get(0):getModData()
    if not modData then return end
    local craftedItems = craftRecipe:getAllCreatedItems()
    for i = 0, craftedItems:size() - 1 do
        if JB_Big_Wood.data.logTypes[craftedItems:get(i):getWorldStaticModel()] then
            local wsm = craftedItems:get(i):getWorldStaticModel() .. "_" .. modData.treeKey
            craftedItems:get(i):setWorldStaticModel(wsm)
            craftedItems:get(i):getModData().treeKey = modData.treeKey
        end
    end
end

--------------------------------------------------------------------------------
-- craftRecipe input/output overrides

local function changeRecipes()
    local recipeList = {
        ["Advanced_Forge"] = {
            inputs = [[
                item 1 tags[MasonsTrowel] mode:keep flags[Prop1;MayDegradeLight],
                item 30 [Base.StoneBlock],
                item 1 tags[Concrete] flags[DontRecordInput],
                item 1 [Base.BlacksmithAnvil],
                item 1 [Base.BucketLargeWood],
                item 1 [JB_Big_Wood.LargeLog],
                item 1 [Base.LargeBellows],
            ]]
        },

        ["LeanTo_Shelter"] = {
            inputs = [[
                item 20 [Base.TreeBranch2;Base.WoodenStick2],
                item 4 [Base.Stone2],
                item 2 [JB_Big_Wood.LargeLog],
                item 5 [Base.LongStick;Base.Sapling],
                item 2 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["Forge"] = {
            inputs = [[
                item 1 tags[MasonsTrowel] mode:keep flags[Prop1;MayDegradeLight],
                item 30 [Base.StoneBlock],
                item 1 tags[Concrete] flags[DontRecordInput],
                item 1 [Base.BlacksmithAnvil],
                item 1 [Base.BucketLargeWood],
                item 2 [Base.Log],
            ]]
        },

        ["Tarp_Shelter"] = {
            inputs = [[
                item 2 [Base.TreeBranch2;Base.WoodenStick2],
                item 1 [Base.Tarp],
                item 4 [Base.Stone2],
                item 4 [Base.Log],
                item 2 [JB_Big_Wood.LargeLog],
                item 1 [Base.LongStick;Base.Sapling],
                item 2 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["LogGate"] = {
            inputs = [[
                item 3 [JB_Big_Wood.LargeLog],
                item 5 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["Log_Stairs"] = {
            inputs = [[
                item 1 tags[Hammer] mode:keep flags[MayDegradeVeryLight],
                item 8 [Base.Log],
                item 2 [JB_Big_Wood.VeryLargeLog],
                item 1 tags[ChopTree;Saw;CrudeSaw] mode:keep flags[Prop1;MayDegradeLight;IsNotDull],
                item 12 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["SimpleLoom"] = {
            inputs = [[
                item 1 tags[Hammer] mode:keep flags[Prop1;MayDegradeVeryLight],
                item 1 tags[CrudeSaw;Saw] mode:keep flags[MayDegradeLight],
                item 2 [JB_Big_Wood.LargeLog],
                item 5 [Base.LongStick],
                item 4 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["WoodLampPillar"] = {
            inputs = [[
                item 1 tags[Hammer] mode:keep flags[Prop1;MayDegradeVeryLight],
                item 1 [JB_Big_Wood.LargeLog],
                item 2 [Base.Plank],
                item 4 [Base.Nails],
                item 1 [Base.Rope],
                item 1 tags[FlashlightPillar] mode:destroy,
            ]]
        },

        ["DrillPlank"] = {
            [[
                item 1 [Base.Plank;Base.Firewood;Base.LargeBranch] flags[Prop2],

                item 1 tags[Screwdriver;DullKnife;SharpKnife;DrillWood;DrillWoodPoor] mode:keep flags[Prop1;MayDegradeLight],
            ]]
        },

        ["SawLogs"] = {
            inputs = [[
                item 1 [Base.Log] flags[Prop2],
                item 1 [JB_Big_Wood.RipSaw] mode:keep flags[MayDegradeLight;Prop1],
            ]],
            outputs = [[
                item 2 Base.Firewood,
                item 1 Base.UnusableWood,
            ]]
        },

        ["SawLargeBranch"] = {
            inputs = [[
                item 1 [Base.LargeBranch] flags[Prop2;InheritCondition],
                item 1 tags[Saw;CrudeSaw] mode:keep flags[MayDegradeLight;Prop1],
            ]],
            outputs = [[
                item 1 JB_Big_Wood.SmallLog,
            ]]
        },

        ["Log_Table"] = {
            inputs = [[
                item 4 [Base.TreeBranch2],
                item 2 [Base.Log],
                item 1 [JB_Big_Wood.LargeLog],
                item 1 tags[ChopTree;Saw;CrudeSaw] mode:keep flags[MayDegradeLight;IsNotDull;Prop1],
                item 8 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["LogWall"] = {
            inputs = [[
                item 2 [JB_Big_Wood.LargeLog],
                item 4 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["LogWindowFrameLvl1"] = {
            inputs = [[
                item 2 [JB_Big_Wood.LargeLog],
                item 4 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["LogDoorFrameLvl1"] = {
            inputs = [[
                item 2 [Base.Log],
                item 1 [JB_Big_Wood.LargeLog],
                item 3 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["LogFence"] = {
            inputs = [[
                item 2 [JB_Big_Wood.LargeLog],
                item 2 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["Log_Stool"] = {
            inputs = [[
                item 1 [Base.Log],
                item 1 [JB_Big_Wood.LargeLog],
                item 3 [Base.TreeBranch2],
                item 1 tags[ChopTree;Saw;CrudeSaw] mode:keep flags[MayDegradeLight;IsNotDull;Prop1],
                item 4 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["Other_Log_Stool"] = {
            inputs = [[
                item 2 [Base.Log],
                item 3 [Base.TreeBranch2],
                item 1 tags[ChopTree;Saw;CrudeSaw] mode:keep flags[MayDegradeLight;IsNotDull;Prop1],
                item 4 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["Leather_Shelter"] = {
            inputs = [[
                item 2 [Base.TreeBranch2;Base.WoodenStick2],
                item 1 tags[LeatherCrudeTannedLarge;LeatherFurTannedLarge],
                item 4 [Base.Stone2],
                item 4 [Base.Log],
                item 4 [Base.LongStick;Base.Sapling],
                item 2 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

        ["Log_Bench"] = {
            inputs = [[
                item 1 [JB_Big_Wood.VeryLargeLog],
                item 2 [Base.Log],
                item 2 [Base.TreeBranch2],
                item 1 tags[ChopTree;Saw;CrudeSaw] mode:keep flags[MayDegradeLight;IsNotDull;Prop1],
                item 4 [Base.RippedSheets;Base.RippedSheetsDirty;Base.Twine;Base.Rope;Base.SheetRope] flags[DontReplace],
            ]]
        },

    }

    for recipeName, recipeDef in pairs(recipeList) do

        local recipe = getScriptManager():getCraftRecipe(recipeName)
        if recipe then
            local wrappedScript = "{"
            if recipeDef.inputs then
                recipe:getInputs():clear()
                wrappedScript = wrappedScript .. " inputs { " .. recipeDef.inputs .. " }"
            end
            if recipeDef.outputs then
                recipe:getOutputs():clear()
                wrappedScript = wrappedScript .. " outputs { " .. recipeDef.outputs .. " }"
            end
            wrappedScript = wrappedScript .. " }"
            recipe:Load(recipeName, wrappedScript)
        end
    end
end

Events.OnInitWorld.Add(changeRecipes)

return JB_Big_Wood