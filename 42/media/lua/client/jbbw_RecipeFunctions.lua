-- f your SawLogs recipeData

JB_Big_Wood = JB_Big_Wood  or {}
JB_Big_Wood.Recipes = JB_Big_Wood.Recipes or {}
JB_Big_Wood.Recipes.MakeLogs = JB_Big_Wood.Recipes.MakeLogs or {}
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

local scriptManager = getScriptManager()

function JB_Big_Wood.Recipes.MakeLogs.OnCreate(craftRecipe)
    local modData = craftRecipe:getAllConsumedItems():get(0):getModData()
    if not modData then return end
    local craftedItems = craftRecipe:getAllCreatedItems()
    for i = 0, craftedItems:size() - 1 do
        if JB_Big_Wood.data.logTypes[craftedItems:get(i):getWorldStaticModel()] then
            local useWSM = craftedItems:get(i):getWorldStaticModel() .. "_" .. modData.treeKey
            craftedItems:get(i):setWorldStaticModel(useWSM)
            craftedItems:get(i):getModData().treeKey = modData.treeKey
        end
    end
end

function JB_Big_Wood.Recipes.HideRecipe()
    return false
end

--------------------------------------------------------------------------------
-- craftRecipe input/output overrides

local function overrideSawLogsOutputs()
    local originalRecipe = scriptManager:getCraftRecipe("Base.SawLogs")
    local overrideRecipe = scriptManager:getCraftRecipe("JB_Big_Wood.JBSawLogs")

    if not originalRecipe or not overrideRecipe then return end

    local originalOutputs = originalRecipe:getOutputs()
    local overrideOutputs = overrideRecipe:getOutputs()

    if not originalOutputs or not overrideOutputs then return end
    
    originalOutputs:clear()

    for i = 0, overrideOutputs:size() - 1 do
        originalOutputs:add(i, overrideOutputs:get(i))
    end
end

local function overrideDrillPlankInputs()
    local originalRecipe = scriptManager:getCraftRecipe("Base.DrillPlank")
    local overrideRecipe = scriptManager:getCraftRecipe("JB_Big_Wood.JBDrillPlank")

    if not originalRecipe or not overrideRecipe then return end

    local originalInputs = originalRecipe:getInputs()
    local overrideInputs = overrideRecipe:getInputs()

    if not originalInputs or not overrideInputs then return end

    originalInputs:clear()

    for i = 0, overrideInputs:size() - 1 do
        originalInputs:add(overrideInputs:get(i))
    end
end

local function overrideSawLogsInputs()
    local originalRecipe = scriptManager:getCraftRecipe("Base.SawLogs")
    local overrideRecipe = scriptManager:getCraftRecipe("JB_Big_Wood.JBSawLogs")
    if not originalRecipe or not overrideRecipe then return end
    local originalInputs = originalRecipe:getInputs()
    local overrideInputs = overrideRecipe:getInputs()
    if not originalInputs or not overrideInputs then return end
    originalInputs:clear()
    for i = 0, overrideInputs:size() - 1 do
        originalInputs:add(overrideInputs:get(i))
    end
end

local function overrideSawLargeBranchOutputs()
    local originalRecipe = scriptManager:getCraftRecipe("Base.SawLargeBranch")
    local overrideRecipe = scriptManager:getCraftRecipe("JB_Big_Wood.JBSawLargeBranch")
    if not originalRecipe or not overrideRecipe then return end
    local originalOutputs = originalRecipe:getOutputs()
    local overrideOutputs = overrideRecipe:getOutputs()
    if not originalOutputs or not overrideOutputs then return end
    originalOutputs:clear()
    for i = 0, overrideOutputs:size() - 1 do
        originalOutputs:add(i, overrideOutputs:get(i))
    end
end

Events.OnGameStart.Add(function()
    overrideSawLogsOutputs()
    overrideDrillPlankInputs()
    overrideSawLargeBranchOutputs()
    overrideSawLogsInputs()
end)

return JB_Big_Wood