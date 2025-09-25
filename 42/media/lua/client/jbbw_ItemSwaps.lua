-- f your vanilla shit

JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.SwapItems = {}

local randy = newrandom()

local function swapItemOnTick(item, replacements)
    
    local function OnTick()

        if not item:getContainer() then
            return
        end
        
        local container = item:getContainer()
        container:Remove(item)
        --print("Removed " .. item:getType())
        
        local rand = randy:random(#replacements)
        local newItem = replacements[rand]
        --print("Adding " .. newItem)
        
        container:AddItem(newItem)

        Events.OnTick.Remove(OnTick)

    end

    Events.OnTick.Add(OnTick)
end

function JB_Big_Wood.SwapItems.GardenSaw(item)
    swapItemOnTick(item, {
        "JB_Big_Wood.CrossCutSaw",
        "JB_Big_Wood.RipSaw",
        "JB_Big_Wood.RipSaw"
    })
end

Events.OnGameStart.Add(function()
    instanceItem("Base.GardenSaw"):getScriptItem():setLuaCreate("JB_Big_Wood.SwapItems.GardenSaw")
end)

return JB_Big_Wood