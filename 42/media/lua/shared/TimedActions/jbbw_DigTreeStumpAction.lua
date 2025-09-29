require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

---@class JBDigTreeStump : ISBaseTimedAction
---@field playerObj IsoPlayer
---@field stump IsoObject
---@field objectType string?
---@field diggingTool HandWeapon?
---@field spriteFrame number
---@field caloriesModifier number
---@field forceProgressBar boolean
JBDigTreeStump = ISBaseTimedAction:derive("JBDigTreeStump")

---@return boolean
function JBDigTreeStump:isValid()
    if ISBuildMenu.cheat then return true end
    local diggingTool = self.playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    if not diggingTool then return false end

    return self.stump ~= nil and self.stump:getObjectIndex() >= 0 and
        self.playerObj:isEnduranceSufficientForAction() and
        self.playerObj:getPrimaryHandItem() ~= nil
end

---@return boolean
function JBDigTreeStump:waitToStart()
    local primary = self.playerObj:getPrimaryHandItem()
    local secondary = self.playerObj:getSecondaryHandItem()
    local bothSame = primary and secondary and primary == secondary
    local isValidDiggingTool = bothSame and JB_Big_Wood.utils.predicateDiggingTool(primary)
    if not isValidDiggingTool then
        return true
    end

    self.diggingTool = primary

    self.playerObj:faceThisObject(self.stump)

    return self.playerObj:shouldBeTurning()

end

function JBDigTreeStump:update()
    self.playerObj:faceThisObject(self.stump)
    self.spriteFrame = self.playerObj:getSpriteDef():getFrame()
    self.playerObj:setMetabolicTarget(Metabolics.HeavyWork)
end

function JBDigTreeStump:stop()
    ISBaseTimedAction.stop(self)
end

function JBDigTreeStump:perform()
    if self.stump == nil then return end

    if self.objectType then
        local trashItem ---@type string?
        if self.objectType == "Small Stump" then
            trashItem = "Base.UnusableWood"
        end
    end

    if isClient() then
        sledgeDestroy(self.stump)
    else
        self.stump:getSquare():transmitRemoveItemFromSquare(self.stump)
    end

    addSound(self.playerObj, self.playerObj:getX(), self.playerObj:getY(), self.playerObj:getZ(), 10, 10)

    if not ISBuildMenu.cheat and self.diggingTool then
        self.diggingTool:damageCheck(0, 2, false)
    end

    ISBaseTimedAction.perform(self)
end

---@param event string
---@param parameter string
function JBDigTreeStump:animEvent(event, parameter)
    if event == "PlayHitSound" and self.diggingTool then
        self.playerObj:playSound(self.diggingTool:getDoorHitSound())
    end
    if event == "PlaySwingSound" and self.diggingTool then
        self.playerObj:playSound(self.diggingTool:getSwingSound())
    end
    if event == "DigStumpShovelSound" then
        self.playerObj:playSound("DigFurrowWithShovel")
    end
end

function JBDigTreeStump:start()
    if self.stump == nil then return end

    if not self.diggingTool then
        self.diggingTool = self.playerObj:getPrimaryHandItem()
    end

    if self.diggingTool then
        if self.diggingTool:hasTag("Shovel") or JB_Big_Wood.data.shovels[self.diggingTool:getType()] then
            self:setActionAnim("JBBW_DigStumpShovel")
        else
            self:setActionAnim("JBBW_DigStumpPickAxe")
        end
    end

    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 20, 10)
end

---@param character IsoPlayer
---@param stump IsoObject
---@return JBDigTreeStump
function JBDigTreeStump:new(character, stump)
    local o = ISBaseTimedAction.new(self, character) ---@type JBDigTreeStump
    o.playerObj = character
    o.stump = stump
    local props = stump:getSprite():getProperties()
    o.objectType = props:Is("CustomName") and props:Val("CustomName") or nil
    o.maxTime = 1200 - (character:getPerkLevel(Perks.Strength) * 10)
    if character:isTimedActionInstant() then o.maxTime = 1; end
    o.spriteFrame = 0
    o.caloriesModifier = 8
    --o.forceProgressBar = true

    return o
end