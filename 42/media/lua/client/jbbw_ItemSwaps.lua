-- f your vanilla shit

JB_Big_Wood = JB_Big_Wood or {}
JB_Big_Wood.SwapItems = {}

local randy = newrandom()

local function swapItem(item, replacements)
    if not item or #replacements == 0 then return end
    local tickCount = 0

    local function doSwap()
        local container = item:getContainer()
        if not container then
            tickCount = tickCount + 1
            if tickCount > 5 then
                --print("JB_Big_Wood - swapItem took too long...")
                Events.OnTick.Remove(doSwap)
            end
            return
        end

        container:Remove(item)
        local randyLevel = randy:random(#replacements)
        local replItem = container:AddItem(replacements[randyLevel])
        if not replItem then
            --print("JB_Big_Wood - failed to add replacement item")
        end

        Events.OnTick.Remove(doSwap)
    end

    Events.OnTick.Add(doSwap)
end

function JB_Big_Wood.SwapItems.GardenSaw(item)
    swapItem(item, {
        "JB_Big_Wood.CrossCutSaw",
        "JB_Big_Wood.RipSaw",
        "JB_Big_Wood.RipSaw", -- weighted chance
    })
end

Events.OnGameStart.Add(function()
    instanceItem("Base.GardenSaw")
        :getScriptItem()
        :setLuaCreate("JB_Big_Wood.SwapItems.GardenSaw")
end)

return JB_Big_Wood
