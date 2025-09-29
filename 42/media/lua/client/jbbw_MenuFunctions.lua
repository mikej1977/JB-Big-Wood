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

--[[ local OG_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer

function ISInventoryPane:refreshContainer()

    local playerObj = getSpecificPlayer(self.player)
    local items = self.inventory:getItems()
    
    if modOptions:getOption("showTreeSpecies"):getValue(1) then
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if JB_Big_Wood.data.logTypes[item:getFullType()] then
                if item:getModData().treeKey then
                    local og_Name = instanceItem(item:getFullType()):getName(playerObj)
                    local displayName = og_Name .. " - " .. JB_Big_Wood.treeTable[item:getModData().treeKey].displayName
                    if og_Name ~= displayName then
                        item:setName(displayName)
                    end
                end
            end
        end
    else
        for i = 0, items:size() - 1 do
            local item = items:get(i)
            if JB_Big_Wood.data.logTypes[item:getFullType()] then
                local og_Name = instanceItem(item:getFullType()):getDisplayName()
                local displayName = item:getDisplayName()
                if og_Name ~= displayName then
                    item:setName(og_Name)
                end
            end
        end
    end
    
    return OG_ISInventoryPane_refreshContainer(self)

end ]]

--[[ local OG_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
local displayNameCache = {}
local cacheKeys = {}
local cacheMax = 100
local cacheIndex = 1

local function cacheSet(id, name)
    if not displayNameCache[id] then
        cacheKeys[cacheIndex] = id
        cacheIndex = cacheIndex + 1
        if cacheIndex > cacheMax then
            cacheIndex = 1
        end

        local evict = cacheKeys[cacheIndex]
        if evict then
            print("Setting cache index to ", cacheIndex)
            displayNameCache[evict] = nil
        end
    end
    displayNameCache[id] = name
end

function ISInventoryPane:refreshContainer()
    local items = self.inventory:getItems()
    local count = items:size()

    local showSpecies = modOptions:getOption("showTreeSpecies"):getValue(1)
    local logTypes = JB_Big_Wood.data.logTypes
    local treeTable = JB_Big_Wood.treeTable

    for i = 0, count - 1 do
        local item = items:get(i)
        local fullType = item:getFullType()

        if logTypes[fullType] then
            local id = item:getID()
            local cachedName = displayNameCache[id]
            
            local newName
            if showSpecies then
                local treeKey = item:getModData().treeKey
                if treeKey then
                    local baseName = instanceItem(fullType):getName()
                    newName = baseName .. " - " .. treeTable[treeKey].displayName
                end
            else
                newName = instanceItem(fullType):getDisplayName()
            end

            if newName and newName ~= cachedName then
                item:setName(newName)
                cacheSet(id, newName)
            end
        end
    end

    return OG_ISInventoryPane_refreshContainer(self)
end ]]

local OG_ISInventoryPane_refreshContainer = ISInventoryPane.refreshContainer
local originalNameCache = {}

function ISInventoryPane:refreshContainer()
    local items = self.inventory:getItems()
    local count = items:size()

    local showSpecies = modOptions:getOption("showTreeSpecies"):getValue(1)
    local logTypes = JB_Big_Wood.data.logTypes
    local treeTable = JB_Big_Wood.treeTable

    for i = 0, count - 1 do
        local item = items:get(i)
        local fullType = item:getFullType()

        if logTypes[fullType] then
            local og_Name = originalNameCache[fullType]
            if not og_Name then
                local inst = instanceItem(fullType)
                og_Name = showSpecies and inst:getName() or inst:getDisplayName()
                originalNameCache[fullType] = og_Name
            end

            if showSpecies then
                local treeKey = item:getModData().treeKey
                if treeKey then
                    local displayName = og_Name .. " - " .. treeTable[treeKey].displayName
                    if item:getDisplayName() ~= displayName then
                        item:setName(displayName)
                    end
                end
            else
                local displayName = item:getDisplayName()
                if displayName ~= og_Name then
                    item:setName(og_Name)
                end
            end
        end
    end

    return OG_ISInventoryPane_refreshContainer(self)
end

return JB_Big_Wood