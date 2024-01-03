local spell, super = Class("ice_shock", true)

function spell:onLightCast(user, target)
    self:onCast(user, target)
end

function spell:getDamage(user, target)
    if Game.battle.light then
        local min_magic = Utils.clamp(user.chara:getStat("magic") - 3, 1, 999)
        return math.ceil((min_magic * 8) + 45 + Utils.random(10))
    else
        local min_magic = Utils.clamp(user.chara:getStat("magic") - 10, 1, 999)
        return math.ceil((min_magic * 30) + 90 + Utils.random(10))
    end
end

return spell