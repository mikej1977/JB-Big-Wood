require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

JBDigTreeStump = ISBaseTimedAction:derive("JBDigTreeStump")

function JBDigTreeStump:isValid()
    if ISBuildMenu.cheat then return true end

    local diggingTool = self.playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateDiggingTool)
    if not diggingTool then return false end

    return self.stump
        and self.stump:getObjectIndex() >= 0
        and self.playerObj:isEnduranceSufficientForAction()
        and self.playerObj:getPrimaryHandItem() ~= nil
end

function JBDigTreeStump:waitToStart()
    local primary = self.playerObj:getPrimaryHandItem()
    local secondary = self.playerObj:getSecondaryHandItem()

    if not (primary and primary == secondary and JB_Big_Wood.utils.predicateDiggingTool(primary)) then
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
    if not self.stump then return end

    local square = self.stump:getSquare()
    local trashItem = "Base.UnusableWood"

    if isClient() then
        sledgeDestroy(self.stump)
    else
        square:transmitRemoveItemFromSquare(self.stump)
    end

    addSound(self.playerObj, self.playerObj:getX(), self.playerObj:getY(), self.playerObj:getZ(), 10, 10)

    if not ISBuildMenu.cheat and self.diggingTool then
        self.diggingTool:damageCheck(0, 2, false)
    end

    square:AddWorldInventoryItem(trashItem, 0, 0, 0, false)

    ISBaseTimedAction.perform(self)
end

function JBDigTreeStump:animEvent(event, parameter)
    if not self.diggingTool then
        if event == "DigStumpShovelSound" then
            self.playerObj:playSound("DigFurrowWithShovel")
        end
        return
    end

    if event == "PlayHitSound" then
        self.playerObj:playSound(self.diggingTool:getDoorHitSound())
    elseif event == "PlaySwingSound" then
        self.playerObj:playSound(self.diggingTool:getSwingSound())
    elseif event == "DigStumpShovelSound" then
        self.playerObj:playSound("DigFurrowWithShovel")
    end
end

function JBDigTreeStump:start()
    if not self.stump then return end

    self.diggingTool = self.diggingTool or self.playerObj:getPrimaryHandItem()

    if self.diggingTool then
        local toolType = self.diggingTool:getType()
        if self.diggingTool:hasTag("Shovel") or JB_Big_Wood.data.shovels[toolType] then
            self:setActionAnim("JBBW_DigStumpShovel")
        else
            self:setActionAnim("JBBW_DigStumpPickAxe")
        end
    end

    addSound(self.character, self.character:getX(), self.character:getY(), self.character:getZ(), 20, 10)
end

function JBDigTreeStump:new(character, stump)
    local o = ISBaseTimedAction.new(self, character)
    o.playerObj = character
    o.stump = stump

    local props = stump:getSprite():getProperties()
    o.objectType = props:Is("CustomName") and props:Val("CustomName") or nil

    o.maxTime = 1200 - (character:getPerkLevel(Perks.Strength) * 10)
    if character:isTimedActionInstant() then
        o.maxTime = 1
    end

    o.spriteFrame = 0
    o.caloriesModifier = 8

    return o
end