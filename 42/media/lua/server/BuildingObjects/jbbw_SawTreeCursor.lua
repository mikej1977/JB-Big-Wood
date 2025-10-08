require "jb_saw_down_trees"
require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"
JBSawTreeCursor = ISChopTreeCursor:derive("JBSawTreeCursor")

local FONT_HGT_SMALL = getTextManager():getFontHeight(UIFont.Small)

local function drawDebugInfo(sx, sy, lines, color)
    for _, line in ipairs(lines) do
        getTextManager():DrawString(sx, sy, line, color:getR(), color:getG(), color:getB(), 1.0)
        sy = sy + FONT_HGT_SMALL
    end
end

local OG_ISChopTreeCursor_isValid = ISChopTreeCursor.isValid
function ISChopTreeCursor:isValid(square)
    return OG_ISChopTreeCursor_isValid(self, square) and square:getTree()
end

function JBSawTreeCursor:create(x, y, z, north, sprite)
    local square = getWorld():getCell():getGridSquare(x, y, z)
    JB_Big_Wood.sawDownTree(self.character, square:getTree())
end

function JBSawTreeCursor:getAPrompt()
    if self.canBeBuild then
        return getText("ContextMenu_SawDownTree")
    end
    return nil
end

local OG_ISChopTreeCursor_render = ISChopTreeCursor.render

if isDebugEnabled() then -- or modoption is true
    function ISChopTreeCursor:render(x, y, z, square)
        
        if self:isValid(square) then
            local hc = getCore():getGoodHighlitedColor()
            local sx, sy = ISCoordConversion.ToScreen(x, y, z)
            local yield = square:getTree():getLogYield()
            local tree = JB_Big_Wood.treeDrops[yield]

            if tree then
                if isDebugEnabled() then
                    drawDebugInfo(sx + 32, sy - 35, { tree.size, "Possible Drops:" }, hc)
                    drawDebugInfo(sx + 32, sy - 35 + 2 * FONT_HGT_SMALL,
                        (function()
                            local lines = {}
                            if tree.drops then
                                if tree.drops.exclusive then
                                    table.insert(lines, "-- Exclusive --")
                                    for _, drop in ipairs(tree.drops.exclusive) do
                                        table.insert(lines, drop.item .. " (" .. math.floor(drop.chance * 100) .. "%)")
                                    end
                                end
                                if tree.drops.normal then
                                    table.insert(lines, "-- Normal --")
                                    for _, drop in ipairs(tree.drops.normal) do
                                        table.insert(lines, drop.item .. " (" .. math.floor(drop.chance * 100) .. "%)")
                                    end
                                end
                            end
                            return lines
                        end)(),
                        hc
                    )
                else
                    drawDebugInfo(sx + 32, sy - 35, { tree.size }, hc)
                end
            end
        end

        OG_ISChopTreeCursor_render(self, x, y, z, square)
    end
end

function JBSawTreeCursor:new(sprite, northSprite, character)
    local o = ISChopTreeCursor.new(self, sprite, northSprite, character)
    setmetatable(o, self)
    self.__index = self
    o.noNeedHammer = true
    o.skipBuildAction = true
    return o
end
