-- JB's Big Wood Menu Stuff
JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.menuStuff = JB_Big_Wood.menuStuff or {}

require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

local modOptions = PZAPI.ModOptions:getOptions("JB_BigWood_ModOptions")
JB_Big_Wood.defaultTreeKey = "virginiapine"

local function getRandomTreeKey(treeTable)
    local keys = {}
    for key, _ in pairs(treeTable) do
        keys[#keys + 1] = key
    end
    return #keys > 0 and keys[ZombRand(#keys) + 1] or nil
end

local itemNameCache = {}
local function getLogDisplayName(item, showSpecies, logTypes, treeTable)
    local fullType = item:getFullType()
    if not logTypes[fullType] then return nil end

    local inst = itemNameCache[fullType]
    if not inst then
        inst = instanceItem(fullType)
        itemNameCache[fullType] = inst
    end

    local baseName = inst:getName()
    if not showSpecies then return baseName end

    local modData = item:getModData()
    modData.jbbw = modData.jbbw or {}

    if not modData.jbbw.treeKey then
        modData.jbbw.treeKey = getRandomTreeKey(treeTable) or JB_Big_Wood.defaultTreeKey
    end

    local treeKey = modData.jbbw.treeKey
    local treeDef = treeTable[treeKey]
    return treeDef and (baseName .. " - " .. getText("IGUI_JBBW_" .. treeKey)) or baseName
end

function JB_Big_Wood.menuStuff.canSawDownTrees(playerIndex, context, worldObjects, test)
    if test then return ISWorldObjectContextMenu.Test or ISWorldObjectContextMenu.setTest() end

    local playerObj = getSpecificPlayer(playerIndex)
    if playerObj:getVehicle() then return end

    local treeSaw = playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateTreeSaw)
    if not treeSaw or not worldObjects or not worldObjects[1] then return end

    local sq = worldObjects[1]:getSquare()
    if not sq or not sq:HasTree() or not sq:getTree() then return end

    local anchor = context:getOptionFromName(getText("ContextMenu_Chop_Tree")) and "ContextMenu_Chop_Tree" or
    "ContextMenu_SitGround"

    context:insertOptionAfter(getText(anchor), getText("ContextMenu_JBBW_SawDownTree"), worldObjects,
        JB_Big_Wood.onSawTree, playerObj, sq:getTree())
end

function JB_Big_Wood.menuStuff.canDigStump(playerIndex, context, worldObjects, test)
    if test then return ISWorldObjectContextMenu.Test or ISWorldObjectContextMenu.setTest() end

    local vanillaStump = getText("ContextMenu_Remove_Stump")
    if context:getOptionFromName(vanillaStump) then
        context:removeOptionByName(vanillaStump)
    end

    local playerObj = getSpecificPlayer(playerIndex)
    local digTool = playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    if not digTool or not worldObjects or not worldObjects[1]:getSquare() then return end

    local treeStump
    for _, obj in ipairs(worldObjects) do
        local sprite = obj:getSprite()
        local props = sprite and sprite:getProperties()
        if props and props:Is("CustomName") and props:Val("CustomName") == "Small Stump" then
            treeStump = obj
            break
        end
    end
    if not treeStump then return end

    local function digStump(_, playerObj)
        getCell():setDrag(JBDigStumpCursor:new("", "", playerObj), playerObj:getPlayerNum())
    end

    local function getAnchor(context)
        if context:getOptionFromName(getText("ContextMenu_Shovel")) then return "ContextMenu_Shovel" end
        if context:getOptionFromName(getText("ContextMenu_Chop_Tree")) then return "ContextMenu_Chop_Tree" end
        return "ContextMenu_SitGround"
    end

    local anchor = getAnchor(context)
    context:insertOptionAfter(getText(anchor), getText("ContextMenu_JBBW_Remove_Stump"),
        worldObjects, digStump, playerObj)
end

local OG_addNewCraftingDynamicalContextMenu = ISInventoryPaneContextMenu.addNewCraftingDynamicalContextMenu
function ISInventoryPaneContextMenu.addNewCraftingDynamicalContextMenu(selectedItem, context, recipeList, player,
                                                                       containerList)
    if modOptions:getOption("Enable_Crafting_Submenu"):getValue(1) and recipeList:size() > 1 then
        local subMenu = context:getNew(context)
        context:addSubMenu(context:addOption(getText("IGUI_CraftUI_Title")), subMenu)
        context = subMenu
    end

    OG_addNewCraftingDynamicalContextMenu(selectedItem, context, recipeList, player, containerList)

    if modOptions:getOption("Fuck_isUnstableScriptNameSpam"):getValue(1) then
        for i = 1, #context.options do
            context.options[i].name = context.options[i].name:match("^(.-) %- Recipe Reports:") or
            context.options[i].name
        end
    end
end

local OG_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
function ISInventoryPane:refreshContainer()
    local items = self.inventory:getItems()
    local showSpecies = modOptions:getOption("showTreeSpecies"):getValue(1)
    local logTypes = JB_Big_Wood.data.logTypes
    local treeTable = JB_Big_Wood.treeTable

    for i = 0, items:size() - 1 do
        local item = items:get(i)
        local displayName = getLogDisplayName(item, showSpecies, logTypes, treeTable)
        if displayName and item:getName() ~= displayName then
            item:setName(displayName)
            local modData = item:getModData()
            modData.jbbw = modData.jbbw or {}
            local WSM = item:getWorldStaticModel()
            item:setWorldStaticModel(WSM)
        end
    end

    return OG_ISInventoryPane_refreshContainer(self)
end

-- Event Hooks
Events.OnFillWorldObjectContextMenu.Add(JB_Big_Wood.menuStuff.canSawDownTrees)
Events.OnFillWorldObjectContextMenu.Add(JB_Big_Wood.menuStuff.canDigStump)

return JB_Big_Wood