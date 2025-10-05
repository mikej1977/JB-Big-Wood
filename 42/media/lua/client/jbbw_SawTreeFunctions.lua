JB_Big_Wood = JB_Big_Wood or {}

require "jbbw_ModOptions"
require "jbbw_Utils"
require "jbbw_DataTables"

JB_Big_Wood.onSawTree = function(_, playerObj, tree)
    local bo = JBSawTreeCursor:new("", "", playerObj)
    getCell():setDrag(bo, playerObj:getPlayerNum())
end

function JB_Big_Wood.sawDownTree(playerObj, tree)
    
    if not tree or tree:getObjectIndex() == -1 then return end
    local treeSquare = tree:getSquare()
    if not treeSquare then return end

    local walkTo = ISWalkToTimedAction:new(playerObj, treeSquare, JB_Big_Wood.utils.closeEnough, { pl = playerObj, sq = treeSquare })
    walkTo:setOnComplete(function()
        local saw = playerObj:getPrimaryHandItem()
        if not saw or not JB_Big_Wood.utils.predicateTreeSaw(saw) then
            saw = playerObj:getInventory():getFirstEvalRecurse(JB_Big_Wood.utils.predicateTreeSaw)
            if not saw then return end
            --local primary = true
            local twoHands = not playerObj:getSecondaryHandItem()
            --ISWorldObjectContextMenu.equip(playerObj, playerObj:getPrimaryHandItem(), saw, primary, twoHands)
            ISWorldObjectContextMenu.equip(playerObj, nil, saw, true, twoHands)
        end
        ISTimedActionQueue.add(JBSawTreeAction:new(playerObj:getPlayerNum(), tree))
    end)

    ISTimedActionQueue.add(walkTo)

end

return JB_Big_Wood