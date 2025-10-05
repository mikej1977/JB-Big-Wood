-- JB's Big Wood Menu Stuff

JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.menuStuff = JB_Big_Wood.menuStuff or {}
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

local modOptions = PZAPI.ModOptions:getOptions("JB_BigWood_ModOptions")

function JB_Big_Wood.menuStuff.canSawDownTrees(playerIndex, context, worldObjects, test)
    if test then
        if ISWorldObjectContextMenu.Test then return true end
        return ISWorldObjectContextMenu.setTest()
    end

    local playerObj = getSpecificPlayer(playerIndex)
    local playerInv = playerObj:getInventory()

    if playerObj:getVehicle() then return end
    local treeSaw = playerInv:getFirstEvalRecurse(JB_Big_Wood.utils.predicateTreeSaw)

    local sq = worldObjects[1]:getSquare()
    if treeSaw and sq:HasTree() and sq:getTree() then
        if context:getOptionFromName(getText("ContextMenu_Chop_Tree")) then
            context:insertOptionAfter(getText("ContextMenu_Chop_Tree"), getText("ContextMenu_JBBW_SawDownTree"), worldObjects,
                JB_Big_Wood.onSawTree, playerObj, sq:getTree())
        else
            context:insertOptionAfter(getText("ContextMenu_SitGround"), getText("ContextMenu_JBBW_SawDownTree"), worldObjects,
                JB_Big_Wood.onSawTree, playerObj, sq:getTree())
        end
    end
end

function JB_Big_Wood.menuStuff.canDigStump(playerIndex, context, worldObjects, test)
    if test then
        return ISWorldObjectContextMenu.Test or ISWorldObjectContextMenu.setTest()
    end

    -- remove OG Remove Stump Jank
    local jankShit = getText("ContextMenu_Remove_Stump")
    if context:getOptionFromName(jankShit) then
        --print("removing the jank shit")
        context:removeOptionByName(jankShit)
    end

    local playerObj = getSpecificPlayer(playerIndex)
    local digTool = playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    if not digTool or not worldObjects or not worldObjects[1]:getSquare() then return end

    local treeStump
    for _, obj in ipairs(worldObjects) do
        local sprite = obj:getSprite()
        if sprite then
            local props = sprite:getProperties()
            if props and props:Is("CustomName") and props:Val("CustomName") == "Small Stump" then
                treeStump = obj
                break
            end
        end
    end
    if not treeStump then return end

    local function digStump(_, playerObj)
        getCell():setDrag(JBDigStumpCursor:new("", "", playerObj), playerObj:getPlayerNum())
    end

    local function getAnchor(context)
        local shovelOpt = context:getOptionFromName(getText("ContextMenu_Shovel"))
        if shovelOpt then return "ContextMenu_Shovel" end

        local chopOpt = context:getOptionFromName(getText("ContextMenu_Chop_Tree"))
        if chopOpt then return "ContextMenu_Chop_Tree" end

        return "ContextMenu_SitGround"
    end

    local anchor = getAnchor(context)
    if anchor then
        context:insertOptionAfter(getText(anchor), getText("ContextMenu_JBBW_Remove_Stump"), worldObjects, digStump, playerObj)
    else
        context:addOption(getText("ContextMenu_JBBW_Remove_Stump"), worldObjects, digStump, playerObj)
    end
end

Events.OnFillWorldObjectContextMenu.Add(JB_Big_Wood.menuStuff.canSawDownTrees)
Events.OnFillWorldObjectContextMenu.Add(JB_Big_Wood.menuStuff.canDigStump)

local OG_addNewCraftingDynamicalContextMenu = ISInventoryPaneContextMenu.addNewCraftingDynamicalContextMenu
function ISInventoryPaneContextMenu.addNewCraftingDynamicalContextMenu(selectedItem, context, recipeList, player, containerList)
    if modOptions:getOption("Enable_Crafting_Submenu"):getValue(1) then
        -- if there's only 1 thing, don't bundle it like Frank RIP
        if recipeList:size() > 1 then
            local subMenu = context:getNew(context)
            context:addSubMenu(context:addOption(getText("IGUI_CraftUI_Title")), subMenu)
            context = subMenu
        end
    end

    OG_addNewCraftingDynamicalContextMenu(selectedItem, context, recipeList, player, containerList)

    -- fuck isUnstableScriptNameSpam
    if modOptions:getOption("Fuck_isUnstableScriptNameSpam"):getValue(1) then
        for i = 1, #context.options do
            context.options[i].name = context.options[i].name:match("^(.-) %- Recipe Reports:") or
                context.options[i].name
        end
    end
end

local OG_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
local function getLogDisplayName(item, showSpecies, logTypes, treeTable)
    local fullType = item:getFullType()
    if not logTypes[fullType] then return nil end

    local inst = instanceItem(fullType)
    local ogName = showSpecies and inst:getName()
    if not ogName then
        ogName = showSpecies and inst:getName()
    end

    if showSpecies then
        local treeKey = item:getModData().treeKey
        local treeDef = treeKey and treeTable[treeKey]
        if treeDef then
            local textString = getText("IGUI_JBBW_" .. treeKey)
            return ogName .. " - " .. textString
        end
    end

    return ogName
end

function ISInventoryPane:refreshContainer()
    local items = self.inventory:getItems()
    local count = items:size()
    local showSpecies = modOptions:getOption("showTreeSpecies"):getValue(1)
    local logTypes = JB_Big_Wood.data.logTypes
    local treeTable = JB_Big_Wood.treeTable

    for i = 0, count - 1 do
        local item = items:get(i)
        local displayName = getLogDisplayName(item, showSpecies, logTypes, treeTable)
        if displayName and item:getName() ~= displayName then
            item:setName(displayName)
        end
    end

    return OG_ISInventoryPane_refreshContainer(self)
end

return JB_Big_Wood