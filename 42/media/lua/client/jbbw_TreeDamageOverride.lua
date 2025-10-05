-- no chop chop
JB_Big_Wood = JB_Big_Wood  or {}

Events.OnWeaponSwing.Add(function(player, weapon)
    if not weapon or not instanceof(weapon, "HandWeapon") then return end
    if not player:hasTimedActions() then
        weapon:setTreeDamage(0)
    end
end)

Events.OnPlayerAttackFinished.Add(function(player, weapon)
    if not weapon or not instanceof(weapon, "HandWeapon") then return end
    local damage = instanceItem(weapon:getType()):getTreeDamage()
    weapon:setTreeDamage(damage)
end)

return JB_Big_Wood