JB_Big_Wood = JB_Big_Wood or {}

require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

local function getStump(square)
    if not square then return nil end
    for i = 0, square:getObjects():size() - 1 do
        local obj = square:getObjects():get(i)
        local sprite = obj:getSprite()
        if sprite then
            local props = sprite:getProperties()
            if props and props:Is("CustomName") and props:Val("CustomName") == "Small Stump" then
                return obj
            end
        end
    end
    return nil
end

local function hasStump(square)
    return getStump(square) ~= nil
end

JBDigStumpCursor = ISBuildingObject:derive("JBDigStumpCursor")

function JBDigStumpCursor:new(sprite, northSprite, playerObj)
    local o = setmetatable({}, self)
    self.__index = self
    o:setSprite(sprite)
    o:setNorthSprite(northSprite)
    o.character = playerObj
    o.player = playerObj:getPlayerNum()
    o.noNeedHammer = true
    o.skipBuildAction = true
    o.highlightedStumps = {}
    o.lastStump = nil
    o.icon = instanceItem("Base.PickAxe"):getIcon()
    o.iconWidth = o.icon:getWidth() / 3
    o.iconHeight = o.icon:getHeight() / 3
    return o
end

function JBDigStumpCursor:isValid(square)
    return hasStump(square)
end

function JBDigStumpCursor:create(x, y, z, north, sprite)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    local diggingTool = self.character:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)

    local primary = self.character:getPrimaryHandItem()
    local secondary = self.character:getSecondaryHandItem()
    local bothSame = primary and secondary and primary == secondary

    local isPrimaryValidDiggingTool = primary and JB_Big_Wood.utils.predicateDiggingTool(primary)
    local isSecondaryValidDiggingTool = secondary and JB_Big_Wood.utils.predicateDiggingTool(secondary)


    if self.lastStump then
        self.lastStump:setOutlineHighlight(false)
    end

    if not isPrimaryValidDiggingTool and not isSecondaryValidDiggingTool then
        ISWorldObjectContextMenu.transferIfNeeded(self.character, diggingTool)
        ISTimedActionQueue.add(ISEquipWeaponAction:new(self.character, diggingTool, 50, true, true))
    elseif not bothSame then
        if primary and isPrimaryValidDiggingTool then
            ISTimedActionQueue.add(ISEquipWeaponAction:new(self.character, primary, 50, true, true))
        elseif secondary and isSecondaryValidDiggingTool then
            ISTimedActionQueue.add(ISEquipWeaponAction:new(self.character, secondary, 50, true, true))
        end
    end

    local walkTo = ISWalkToTimedAction:new(self.character, square, JB_Big_Wood.utils.closeEnough, { pl = self.character, sq = square })
    walkTo:setOnComplete(function()
        local stump = getStump(square)
        if stump then
            ISTimedActionQueue.add(JBDigTreeStump:new(self.character, stump))
        end
    end)
    ISTimedActionQueue.add(walkTo)
end

function JBDigStumpCursor:render(x, y, z, square)

    for _, s in ipairs(self.highlightedStumps) do
        s:setOutlineHighlight(self.player, false)
    end
    self.highlightedStumps = {}

    if isGamePaused() then return end

    if self.character:getVehicle() then
        getCell():setDrag(nil, self.player)
        return
    end

    local zoom   = getCore():getZoom(self.player)
    local mouseX = getMouseXScaled()
    local mouseY = getMouseYScaled()
    local hx, hy = ISCoordConversion.ToWorld(mouseX, mouseY, 0)
    
    hx, hy = math.floor(hx), math.floor(hy)

    local iconX  = mouseX + (32 * zoom)
    local iconY  = mouseY - 15 - (32 * zoom)
    local iconW  = self.iconWidth + (32 * zoom)
    local iconH  = self.iconHeight + (32 * zoom)

    UIManager.DrawTexture(self.icon, iconX, iconY, iconW, iconH, 1)

    local stump = getStump(square)
    if stump then
        if self.lastStump and self.lastStump ~= stump then
            self.lastStump:setOutlineHighlight(self.player, false)
        end
        self.lastStump = stump
        stump:setOutlineHighlight(self.player, true)
        stump:setOutlineHighlightCol(1, 1, 1, 1)
        stump:setHighlighted(true, true)
    elseif self.lastStump then
        self.lastStump:setOutlineHighlight(self.player, false)
        self.lastStump = nil
    end

    for dx = -4, 4 do
        for dy = -4, 4 do
            local sq = getSquare(hx + dx, hy + dy, 0)
            local nearStump = sq and getStump(sq)
            if nearStump and nearStump ~= stump then
                local dist = math.sqrt((dx * dx) + (dy * dy))
                if dist <= 4 then
                    local alpha = 1 - (dist / 4.0)
                    nearStump:setOutlineHighlight(self.player, true)
                    nearStump:setOutlineHighlightCol(0.8, 0.8, 0, alpha)
                    table.insert(self.highlightedStumps, nearStump)
                end
            end
        end
    end
end

function JBDigStumpCursor:deactivate()
    for _, stump in ipairs(self.highlightedStumps) do
        stump:setOutlineHighlight(self.player, false)
    end
    self.highlightedStumps = {}
    if self.lastStump then
        self.lastStump:setOutlineHighlight(false)
    end
end

--[[ function JBDigStumpCursor:getAPrompt()
    return self.canBeBuild and getText("ContextMenu_Remove_Stump") or nil
end ]]

return JB_Big_Wood
