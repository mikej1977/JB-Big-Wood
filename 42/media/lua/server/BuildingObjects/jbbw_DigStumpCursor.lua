JB_Big_Wood = JB_Big_Wood or {}

require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

---@param square IsoGridSquare | nil
---@return IsoObject | nil
local function getStump(square)
    if not square then return nil end
    for i = 0, square:getObjects():size() - 1 do
        local obj = square:getObjects():get(i)
        local props = obj:getSprite():getProperties()
        if props:Is("CustomName") and props:Val("CustomName") == "Small Stump" then
            return obj
        end
    end
    return nil
end

---@param square IsoGridSquare | nil
---@return boolean
local function hasStump(square)
    return getStump(square) ~= nil
end

---@class JBDigStumpCursor : ISBuildingObject
---@field character IsoPlayer
---@field player number
---@field noNeedHammer boolean
---@field skipBuildAction boolean
---@field lastStump IsoObject | nil
JBDigStumpCursor = ISBuildingObject:derive("JBDigStumpCursor")

---@param sprite string
---@param northSprite string
---@param playerObj IsoPlayer
---@return JBDigStumpCursor
function JBDigStumpCursor:new(sprite, northSprite, playerObj)
    local o = setmetatable({}, self)
    self.__index = self
    o:setSprite(sprite)
    o:setNorthSprite(northSprite)
    o.character = playerObj
    o.player = playerObj:getPlayerNum()
    o.noNeedHammer = true
    o.skipBuildAction = true
    o.lastStump = nil
    return o
end

---@param square IsoGridSquare
---@return boolean
function JBDigStumpCursor:isValid(square)
    return hasStump(square)
end

---@param x number
---@param y number
---@param z number
---@param north boolean
---@param sprite string
function JBDigStumpCursor:create(x, y, z, north, sprite)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    local diggingTool = self.character:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    local primary = self.character:getPrimaryHandItem()
    local secondary = self.character:getSecondaryHandItem()
    local bothSame = primary and secondary and primary == secondary
    local isValidDiggingTool = bothSame and JB_Big_Wood.utils.predicateDiggingTool(primary)

    if self.lastStump then
        self.lastStump:setOutlineHighlight(false)
    end

    if not isValidDiggingTool then
        ISWorldObjectContextMenu.transferIfNeeded(self.character, diggingTool)
        ISTimedActionQueue.add(ISEquipWeaponAction:new(self.character, diggingTool, 50, true, true))
    end

    local walkTo = ISWalkToTimedAction:new(self.character, square, JB_Big_Wood.utils.closeEnough, { pl = self.character, sq = square })
    walkTo:setOnComplete(function()
        local stump = getStump(square)
        if stump then
            ISTimedActionQueue.add(JBDigTreeStumpAction:new(self.character, stump))
        end
    end)
    ISTimedActionQueue.add(walkTo)
end

---@param x number
---@param y number
---@param z number
---@param square IsoGridSquare
function JBDigStumpCursor:render(x, y, z, square)
    if self.character:getVehicle() then
        getCell():setDrag(nil, self.player)
        return
    end

    local stump = getStump(square)

    if stump then
        if self.lastStump and self.lastStump ~= stump then
            self.lastStump:setOutlineHighlight(false)
        end
        self.lastStump = stump
        stump:setOutlineHighlight(true)
        stump:setHighlighted(true, true)
    elseif self.lastStump then
        self.lastStump:setOutlineHighlight(false)
    end
end

function JBDigStumpCursor:deactivate()
    if self.lastStump then
        self.lastStump:setOutlineHighlight(false)
    end
end

---@return string | nil
function JBDigStumpCursor:getAPrompt()
    return self.canBeBuild and getText("ContextMenu_Remove_Stump") or nil
end

return JB_Big_Wood
