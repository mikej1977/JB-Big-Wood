
require "Foraging/forageDefinitions"
require "Foraging/forageSystem"

JB_Big_Wood = JB_Big_Wood  or {}

--------------------------------------------------------------------------------

local function generateFirewoodDefs()
    local firewood = {
        SmallLog = {
            type = "JB_Big_Wood.SmallLog",
            skill = 0,
            xp = 5,
            categories = { "Firewood" },
            zones = {
                DeepForest    = 3,
                OrganicForest = 5,
                BirchForest   = 4,
                PRForest      = 3,
                PHForest      = 3,
                Forest        = 2,
                Vegitation    = 1,
            },
            bonusMonths = { 9, 10, 11 },
            itemSizeModifier = 5,
            isItemOverrideSize = true,
        },        
    }
    for itemName, itemDef in pairs(firewood) do
        forageSystem.addForageDef(itemName, itemDef)
    end
end

generateFirewoodDefs()

return JB_Big_Wood