-- JB's Big Wood Utilities

JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.utils = JB_Big_Wood.utils or {}
require "jbbw_DataTables"
local randy = newrandom()

JB_Big_Wood.utils = {

    ["predicateDiggingTool"] = function(item)
        if item:isBroken() then return false end
        local itemType = item:getType()
        return item:hasTag("Shovel")
            or JB_Big_Wood.data.shovels[itemType]
            or JB_Big_Wood.data.diggingTools[itemType]
    end,

    ["predicateTreeSaw"] = function(item)
        return not item:isBroken() and item:hasTag("TreeSaw")
    end,

    ["closeEnough"] = function(t)
        local offsetX = math.abs(t.sq:getX() + 0.5 - t.pl:getX())
        local offsetY = math.abs(t.sq:getY() + 0.5 - t.pl:getY())
        if offsetX <= 0.7 and offsetY <= 0.7 and t.pl:getSquare():canReachTo(t.sq) then
            return true
        end
    end,

    ["isTreeType"] = function(name, tree, spriteNames)
        name = string.lower(name)
        for _, keyword in ipairs(tree) do
            if string.contains(name, keyword) then return true end
        end
        for _, exact in ipairs(spriteNames) do
            if name == exact then return true end
        end
        return false
    end,

    ["rollDrops"] = function(dropTable)
            local results = {}

    -- Roll only one exclusive thing
    if dropTable.exclusive and #dropTable.exclusive > 0 then
        local totalChance = 0
        for _, drop in ipairs(dropTable.exclusive) do
            totalChance = totalChance + drop.chance
        end
        local roll = randy:random(0, 10000) / 10000 * totalChance
        local accum = 0
        for _, drop in ipairs(dropTable.exclusive) do
            accum = accum + drop.chance
            if roll <= accum then
                table.insert(results, drop.item)
                break
            end
        end
    end

    -- Roll for normal shit
    if dropTable.normal then
        for _, drop in ipairs(dropTable.normal) do
            if drop.chance >= 1.0 or randy:random(0, 10000) / 10000 < drop.chance then
                table.insert(results, drop.item)
            end
        end
    end

    return results
    end,

    ["stripSpriteName"] = function(spriteName)
        -- returns shit like "americanholly"
        local name = spriteName:match("^e_(.+)")
        if not name then return spriteName end
        name = name:gsub("_%d+_%d+$", "")
        name = name:gsub("JUMBO$", "")
        return name
    end,

    ["addTreeStumps"] = function(sq, tree)
        local cell = getWorld():getCell()
        local treeSize = tree:getSize()
        local shortTreeName = JB_Big_Wood.utils.stripSpriteName(tree:getSprite():getName())
        local stumpSprite = JB_Big_Wood.treeTable[shortTreeName].treeStump[treeSize]
        stumpSprite = stumpSprite or "d_generic_1_9"
        local stump = IsoObject.new(cell, sq, stumpSprite)
        sq:transmitAddObjectToSquare(stump, -1)
    end,
}

return JB_Big_Wood