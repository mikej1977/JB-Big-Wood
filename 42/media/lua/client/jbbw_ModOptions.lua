local function JB_Big_Wood_ModOptions()

    local config = {
        checkBox = nil,
    }

    local options = PZAPI.ModOptions:create("JB_BigWood_ModOptions", "")

    local title = getText("IGUI_ModOptions_JBBigWoodTitle")

    local desc = string.format("<H1><LEFT><ORANGE> %s", title)
    local desc2 = string.format("<SIZE:SMALL><LEFT> %s", getText("IGUI_ModOptions_JBBigWood_Desc2"))
    local desc3 = string.format("<H2><LEFT> %s", getText("IGUI_ModOptions_JBBigWood_Desc3"))

    options:addDescription(desc)
    options:addDescription(desc2)
    options:addDescription(desc3)
    options:addSeparator()

    config.checkBox = options:addTickBox("spawnStumps", getText("IGUI_ModOptions_JBBigWood_spawnStumps"), true)
    config.checkBox = options:addTickBox("showTreeSpecies", getText("IGUI_ModOptions_JBBigWood_showTreeSpecies"), false)
    options:addSeparator()
    config.checkBox = options:addTickBox("Enable_Crafting_Submenu", getText("IGUI_ModOptions_JBBigWood_Enable_Crafting_Submenu"), true)
    config.checkBox = options:addTickBox("Fuck_isUnstableScriptNameSpam", getText("IGUI_ModOptions_JBBigWood_Fuck_isUnstableScriptNameSpam"), true)

    function options.apply(self)
        triggerEvent("OnContainerUpdate")
    end

end

return JB_Big_Wood_ModOptions()
