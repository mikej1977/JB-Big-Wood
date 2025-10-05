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
            local name = props and props:Is("CustomName") and props:Val("CustomName")
            if name and name:match("Stump") then
                return obj
            end
        end
    end
end

local function hasStump(square)
    return getStump(square) ~= nil
end

local function ensureDiggingToolEquipped(cursor, diggingTool)
    local primary = cursor.character:getPrimaryHandItem()
    local secondary = cursor.character:getSecondaryHandItem()
    local bothSame = primary and secondary and primary == secondary

    local isPrimary = primary and JB_Big_Wood.utils.predicateDiggingTool(primary)
    local isSecondary = secondary and JB_Big_Wood.utils.predicateDiggingTool(secondary)

    if not isPrimary and not isSecondary then
        if diggingTool then
            ISWorldObjectContextMenu.transferIfNeeded(cursor.character, diggingTool)
            ISTimedActionQueue.add(ISEquipWeaponAction:new(cursor.character, diggingTool, 50, true, true))
        end
    elseif not bothSame then
        local tool = isPrimary and primary or (isSecondary and secondary)
        if tool then
            ISTimedActionQueue.add(ISEquipWeaponAction:new(cursor.character, tool, 50, true, true))
        end
    end
end

local function clearHighlights(cursor)
    for _, stump in ipairs(cursor.highlightedStumps) do
        stump:setOutlineHighlight(cursor.player, false)
    end
    cursor.highlightedStumps = {}
    if cursor.lastStump then
        cursor.lastStump:setOutlineHighlight(cursor.player, false)
        cursor.lastStump = nil
    end
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

function JBDigStumpCursor:create(x, y, z)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    if not square then return end

    local diggingTool = self.character:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    ensureDiggingToolEquipped(self, diggingTool)

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
    clearHighlights(self)
    if isGamePaused() or self.character:getVehicle() then
        getCell():setDrag(nil, self.player)
        return
    end

    local zoom = getCore():getZoom(self.player)
    local mouseX, mouseY = getMouseXScaled(), getMouseYScaled()
    local iconX = mouseX + (32 * zoom)
    local iconY = mouseY - 15 - (32 * zoom)
    local iconW = self.iconWidth + (32 * zoom)
    local iconH = self.iconHeight + (32 * zoom)
    UIManager.DrawTexture(self.icon, iconX, iconY, iconW, iconH, 1)

    -- highlight main stump
    local stump = getStump(square)
    if stump then
        self.lastStump = stump
        stump:setOutlineHighlight(self.player, true)
        stump:setOutlineHighlightCol(1, 1, 1, 1)
        stump:setHighlighted(true, true)
    end

    -- highlight nearby stumps
    local hx, hy = ISCoordConversion.ToWorld(mouseX, mouseY, 0)
    hx, hy = math.floor(hx), math.floor(hy)
    for dx = -4, 4 do
        for dy = -4, 4 do
            local sq = getSquare(hx + dx, hy + dy, 0)
            local nearStump = sq and getStump(sq)
            if nearStump and nearStump ~= stump then
                local dist2 = dx * dx + dy * dy
                if dist2 <= 16 then
                    local alpha = 1 - (math.sqrt(dist2) / 4.0)
                    nearStump:setOutlineHighlight(self.player, true)
                    nearStump:setOutlineHighlightCol(0.8, 0.8, 0, alpha)
                    table.insert(self.highlightedStumps, nearStump)
                end
            end
        end
    end
end

function JBDigStumpCursor:deactivate()
    clearHighlights(self)
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

return JB_Big_Wood
