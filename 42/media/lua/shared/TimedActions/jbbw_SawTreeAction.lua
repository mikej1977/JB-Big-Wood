require "TimedActions/ISBaseTimedAction"
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

JBSawTreeAction = ISChopTreeAction:derive("JBSawTreeAction")

function JBSawTreeAction:start()
    self.axe = self.character:getPrimaryHandItem()
    self.axe:setJobType(getText("ContextMenu_SawDownTree"))
    self.axe:setJobDelta(0.0)

    if self.character:isTimedActionInstant() then
        self.tree:setHealth(1)
    end

    self:setActionAnim("JBSawTree")

    self:setOverrideHandModels(self.axe, nil)
end

function JBSawTreeAction:waitToStart()
    self.character:faceThisObject(self.tree)
    return self.character:shouldBeTurning()
end

function JBSawTreeAction:animEvent(event, parameter)
    --print(event)
    if not isClient() then
        --if event == 'ChopTree' and self.axe then
        if event == 'SawTree' and self.axe then
            self.tree:WeaponHit(self.character, self.axe)
            local modifier = 1
            if ("lumberjack" == self.character:getDescriptor():getProfession()) then modifier = 0.5 end
            self.character:addCombatMuscleStrain(self.axe, 1, modifier)

            self:useEndurance()

            if self.tree:getObjectIndex() == -1 then
                if isServer() then
                    self.netAction:forceComplete()
                else
                    self:forceComplete()
                end
            end
        end
    else
         if event == 'SawTree' then
            self.character:getEmitter():playSound("JB_Saw")
        end
    end
end

function JBSawTreeAction:useEndurance()
    -- nope
end

function JBSawTreeAction:update()
    self.axe:setJobDelta(self:getJobDelta())

    self.character:faceThisObject(self.tree)

    if instanceof(self.character, "IsoPlayer") then
        self.character:setMetabolicTarget(Metabolics.MediumWork)
    end
end

function JBSawTreeAction:isValid()
    return self.tree ~= nil and self.tree:getObjectIndex() >= 0 and
        self.character:isEnduranceSufficientForAction() and
        self.character:getPrimaryHandItem() ~= nil and
        self.character:getPrimaryHandItem():hasTag("TreeSaw")
end

function JBSawTreeAction:new(character, tree)
    local o = ISBaseTimedAction.new(self, character)
    o.character = getSpecificPlayer(character)
    o.tree = tree
    o.maxTime = o:getDuration()
    o.spriteFrame = 0
    o.caloriesModifier = 8
    o.forceProgressBar = false
    return o
end