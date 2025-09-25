-- JB's Big Wood Menu Stuff

JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.menuStuff = JB_Big_Wood.menuStuff or {}
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

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
            context:insertOptionAfter(getText("ContextMenu_Chop_Tree"), getText("ContextMenu_SawDownTree"), worldObjects,
                JB_Big_Wood.onSawTree, playerObj, sq:getTree())
        else
            context:insertOptionAfter(getText("ContextMenu_SitGround"), getText("ContextMenu_SawDownTree"), worldObjects,
                JB_Big_Wood.onSawTree, playerObj, sq:getTree())
        end
    end
end

function JB_Big_Wood.menuStuff.canDigStump(playerIndex, context, worldObjects, test)
    if test then
        return ISWorldObjectContextMenu.Test or ISWorldObjectContextMenu.setTest()
    end

    local playerObj = getSpecificPlayer(playerIndex)
    local digTool = playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    if not digTool or not worldObjects or not worldObjects[1]:getSquare() then return end

    local treeStump
    for _, obj in ipairs(worldObjects) do
        local props = obj:getSprite():getProperties()
        if props:Is("CustomName") and props:Val("CustomName") == "Small Stump" then
            treeStump = obj
            break
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
        context:insertOptionAfter(getText(anchor), getText("ContextMenu_Remove_Stump"), worldObjects, digStump, playerObj)
    else
        context:addOption(getText("ContextMenu_Remove_Stump"), worldObjects, digStump, playerObj)
    end
end

Events.OnFillWorldObjectContextMenu.Add(JB_Big_Wood.menuStuff.canSawDownTrees)
Events.OnFillWorldObjectContextMenu.Add(JB_Big_Wood.menuStuff.canDigStump)

local modOptions = PZAPI.ModOptions:getOptions("JB_BigWood_ModOptions")
print(modOptions:getOption("Enable_Crafting_Submenu"):getValue(1))

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

return JB_Big_Wood

-- testing shit
-- https://steamcommunity.com/sharedfiles/filedetails/?id=3565427354&searchtext=
--[[ 
require "ISUI/ISInventoryPage"

local function needsFireFeatures(self)
    local inv = self.inventoryPane and self.inventoryPane.inventory
    if self.onCharacter or not inv then return false end
    local tile = inv:getParent()
    if not tile then return false end
    local campfire = CCampfireSystem.instance:getLuaObjectOnSquare(tile:getSquare())
    return campfire or (tile:isFireInteractionObject() and not tile:isPropaneBBQ())
end

local og = {
    syncPutOut    = ISInventoryPage.syncPutOut,
    syncLightFire = ISInventoryPage.syncLightFire,
    syncAddFuel   = ISInventoryPage.syncAddFuel,
}

function ISInventoryPage:syncPutOut()
    if needsFireFeatures(self) then
        self.putOut:setVisible(false); return
    end
    return og.syncPutOut(self)
end

function ISInventoryPage:syncLightFire()
    if needsFireFeatures(self) then
        self.putOut:setVisible(false); return
    end
    return og.syncLightFire(self)
end

function ISInventoryPage:syncAddFuel()
    if needsFireFeatures(self) then return end
    return og.syncAddFuel(self)
end ]]