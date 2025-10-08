-- f your SawLogs recipeData

JB_Big_Wood = JB_Big_Wood  or {}
JB_Big_Wood.Recipes = JB_Big_Wood.Recipes or {}
JB_Big_Wood.Recipes.MakeLogs = JB_Big_Wood.Recipes.MakeLogs or {}
JB_Big_Wood.Recipes.MakeLogStack = JB_Big_Wood.Recipes.MakeLogStack or {}
JB_Big_Wood.Recipes.UnstackLogs = JB_Big_Wood.Recipes.UnstackLogs or {}
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

function JB_Big_Wood.Recipes.MakeLogs.OnCreate(craftRecipe)
    local logItem = craftRecipe:getAllConsumedItems():get(0)
    if not logItem then return end

    local logModData = logItem:getModData()
    local treeKey = logModData.jbbw and logModData.jbbw.treeKey
    if not treeKey then return end

    local craftedItems = craftRecipe:getAllCreatedItems()
    for i = 0, craftedItems:size() - 1 do
        local logBoltItem = craftedItems:get(i)
        local baseWSM = logBoltItem:getWorldStaticModel()

        if JB_Big_Wood.data.logTypes[baseWSM] then
            local wsm = baseWSM .. "_" .. treeKey
            logBoltItem:setWorldStaticModel(wsm)

            local stackModData = logBoltItem:getModData()
            stackModData.jbbw = stackModData.jbbw or {}
            stackModData.jbbw.treeKey = treeKey
        end
    end
end

local OG_RecipeCodeOnCreate_createLogStack = RecipeCodeOnCreate.createLogStack

function RecipeCodeOnCreate.createLogStack(craftRecipeData, player)
    
    local logs = craftRecipeData:getAllConsumedItems()
    local treeKeys = {}
    local firstTreeKey

    for i = 0, logs:size() - 1 do
        local logItem = logs:get(i)
        local modData = logItem:getModData()

        if modData and modData.jbbw and modData.jbbw.treeKey then
            treeKeys[#treeKeys + 1] = modData.jbbw.treeKey
        end

        if not firstTreeKey then
            firstTreeKey = treeKeys[1]
        end
    end

    if firstTreeKey and #treeKeys > 0 then
        local craftedItems = craftRecipeData:getAllCreatedItems()
        for i = 0, craftedItems:size() - 1 do
            local logStackItem = craftedItems:get(i)
            local WSM = logStackItem:getWorldStaticModel() .. "_" .. firstTreeKey
            print(WSM)
            logStackItem:setWorldStaticModel(WSM)

            local stackModData = logStackItem:getModData()
            stackModData.jbbw = stackModData.jbbw or {}
            stackModData.jbbw.treeKeys = treeKeys
        end
    end

    return OG_RecipeCodeOnCreate_createLogStack(craftRecipeData, player)
end

local OG_RecipeCodeOnCreate_splitLogStack = RecipeCodeOnCreate.splitLogStack

function RecipeCodeOnCreate.splitLogStack(craftRecipeData, player)
    print("Overriding RecipeCodeOnCreate.splitLogStack")

    local logStackItem = craftRecipeData:getAllConsumedItems():get(0)
    if not logStackItem then return end

    local stackModData = logStackItem:getModData()
    local treeKeys = stackModData.jbbw and stackModData.jbbw.treeKeys
    if not treeKeys then return end

    local logs = craftRecipeData:getAllCreatedItems()
    for i = 0, logs:size() - 1 do
        local logItem = logs:get(i)
        local treeKey = treeKeys[i + 1]

        if treeKey then
            local baseWSM = logItem:getWorldStaticModel()
            local wsm = baseWSM .. "_" .. treeKey
            logItem:setWorldStaticModel(wsm)

            local logModData = logItem:getModData()
            logModData.jbbw = logModData.jbbw or {}
            logModData.jbbw.treeKey = treeKey
        end
    end

    return OG_RecipeCodeOnCreate_splitLogStack(craftRecipeData, player)
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

    local sm = getScriptManager()
    for recipeName, recipeDef in pairs(recipeList) do

        local recipe = sm:getCraftRecipe(recipeName)
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