-- type F's in chat for IsoTree

JB_Big_Wood = JB_Big_Wood or {}
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

local modOptions = PZAPI.ModOptions:getOptions("JB_BigWood_ModOptions")
local randy = newrandom()

local function handleLogItem(item, chr, sq, treeKey, treeDisplayName)
    local itemTreeSpecies = item .. "_" .. treeKey
    local realTree = instanceItem(item)
    realTree:setWorldStaticModel(itemTreeSpecies)

    if modOptions:getOption("showTreeSpecies"):getValue(1) then
        realTree:setName(realTree:getName() .. " - " .. treeDisplayName)
    end
    
    local modData = realTree:getModData()
    modData.treeKey = treeKey
    sq:AddWorldInventoryItem(realTree, 0, 0, 0)
    local spinny = chr:getDirectionAngle() + 90 + randy:random(-15, 15)
    realTree:setWorldZRotation(spinny)
end

local function getWood(chr, sq, tree)
    local treeName = tree:getSprite():getName()
    local yield = tree:getLogYield()
    local treeData = JB_Big_Wood.treeDrops[yield]
    if not treeData then return end

    local rolledDrops = JB_Big_Wood.utils.rollDrops(treeData.drops)
    local treeKey = JB_Big_Wood.utils.stripSpriteName(treeName)
    local treeEntry = JB_Big_Wood.treeTable[treeKey]
    --local treeDisplayName = treeEntry and treeEntry.displayName or "Unknown Tree"
    local treeDisplayName = treeEntry and getText("IGUI_JBBW_" .. treeKey) or "Unknown Tree"

    for _, item in ipairs(rolledDrops) do
        if item:match("Log") then
            handleLogItem(item, chr, sq, treeKey, treeDisplayName)
        else
            sq:AddWorldInventoryItem(item, 0, 0, 0)
        end
    end

    local season = getClimateManager():getSeasonName()
    local isWinter, isAutumn, isSpring = season == "Winter", season == "Autumn", season == "Spring"

    if (isAutumn or isWinter) and JB_Big_Wood.utils.isTreeType(treeName, { "holly" }, {
            "e_americanholly_1_2", "e_americanholly_1_3", "e_americanholly_1_4",
            "e_americanholly_1_5", "e_americanholly_1_6", "e_americanholly_1_7" }) then
        for i = 1, randy:random(0, 3) do
            sq:AddWorldInventoryItem("Base.HollyBerry", 0, 0, 0, false)
        end
    end

    local seedItem
    if JB_Big_Wood.utils.isTreeType(treeName, { "oak" }, {
            "vegetation_trees_01_13", "vegetation_trees_01_14", "vegetation_trees_01_15" }) then
        seedItem = "Base.Acorn"
    elseif JB_Big_Wood.utils.isTreeType(treeName, { "pine" }, {
            "vegetation_trees_01_08", "vegetation_trees_01_09",
            "vegetation_trees_01_010", "vegetation_trees_01_011" }) then
        seedItem = "Base.Pinecone"
    end

    if seedItem and not (isWinter or isSpring) then
        for i = 1, yield - 1 do
            if randy:random(100) < 25 then
                sq:AddWorldInventoryItem(seedItem, 0, 0, 0, false)
            end
        end
    end

    triggerEvent("OnContainerUpdate")
end

--------------------------------------------------------------------------------

local IsoTree_WeaponHit = {}

function IsoTree_WeaponHit.GetClass()
    local class, methodName = IsoTree.class, "WeaponHit"
    local metatable = __classmetatables[class]
    local metatable__index = metatable.__index
    local original_function = metatable__index[methodName]
    metatable__index[methodName] = IsoTree_WeaponHit.PatchClass(original_function)
end

local sawSound = 0

local treeSound = {
    [3] = "JBFallingTreeSmall",
    [4] = "JBFallingTreeMedium",
    [5] = "JBFallingTreeMedium",
    [6] = "JBFallingTreeLarge"
}

function IsoTree_WeaponHit.PatchClass(original_function)
    return function(self, chr, weapon)
        if not chr or not weapon then return end

        local sq = self:getSquare()
        if not sq then return end

        local emitter = chr:getEmitter()
        local scriptItem = weapon:getScriptItem()
        if not scriptItem then return end
        local treeHealth = self:getHealth()
        
        --local isAxe = instanceof(weapon, "HandWeapon") and scriptItem:getCategories():contains("Axe")
        local isAxe = instanceof(weapon, "HandWeapon") and scriptItem:containsWeaponCategory("Axe")
        local isSaw = scriptItem:hasTag("TreeSaw")

        -- axes are for chumps, but you do you
        if isAxe then
            weapon:damageCheck(chr:getWeaponLevel(weapon), 1.0, true, true, chr)

            if not isServer() then
                self:WeaponHitEffects(chr, weapon)
            end

            local damage = weapon:getTreeDamage()
            if chr:HasTrait("Axeman") then
                damage = damage * 1.5
            end

            self:setHealth(treeHealth - damage)
            treeHealth = self:getHealth()

            if treeHealth <= damage and treeHealth > 0 then
                if emitter then emitter:playSound("JBTreeCracking") end
            end

            if treeHealth > 0 then return end

            sq:transmitRemoveItemFromSquare(self)

            if emitter then emitter:playSound(treeSound[self:getSize()]) end

            sq:RecalcAllWithNeighbours(true)
            getWood(chr, sq, self)
            if modOptions:getOption("spawnStumps"):getValue(1) and self:getSize() > 2 then
                JB_Big_Wood.utils.addTreeStumps(sq, self)
            end
            self:reset()
            return
        end

        -- saws are the new axes, welcome to the madness
        if not isSaw then return end

        local damage = 10 + (chr:getPerkLevel(Perks.Woodwork) * 2)
        if chr:HasTrait("Axeman") then
            damage = damage * 1.5
        end

        if emitter and (sawSound == 0 or not emitter:isPlaying(sawSound)) then
            sawSound = emitter:playSound("JB_Saw")
        end

        self:setHealth(treeHealth - damage)
        treeHealth = self:getHealth()

        if treeHealth <= damage and treeHealth > 0 then
            if emitter then emitter:playSound("JBTreeCracking") end
        end

        if treeHealth > 0 then return end

        sq:transmitRemoveItemFromSquare(self)

        if emitter then
            if emitter:isPlaying(sawSound) then emitter:stopSound(sawSound) end
            if emitter then emitter:playSound(treeSound[self:getSize()]) end
        end

        sq:RecalcAllWithNeighbours(true)
        sawSound = 0

        getWood(chr, sq, self)
        if modOptions:getOption("spawnStumps"):getValue(1) and self:getSize() > 2 then
            JB_Big_Wood.utils.addTreeStumps(sq, self)
        end
        self:reset()
    end
end

Events.OnGameStart.Add(IsoTree_WeaponHit.GetClass)

return JB_Big_Wood
