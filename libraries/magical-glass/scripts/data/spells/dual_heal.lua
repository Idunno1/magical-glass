local spell, super = Class(Spell, "dual_heal")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "Dual Heal"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = "Heal All\n30 HP"
    -- Menu description
    self.description = "Heavenly light restores a little HP to\nall party members. Depends on Magic."

    -- TP cost
    self.cost = 50

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "party"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onLightCast(user, target)
    for _,battler in ipairs(Game.battle.party) do
        self.amount = math.ceil((user.chara:getStat("magic") * 2.5))
        battler:heal(self.amount)
    end
end

function spell:getLightCastMessage(user, target)
    local message = "* "..user.chara:getName().." cast "..self:getName().."."
    local heal_text = self:getHealMessage(user, target)
    return message .. "\n" .. heal_text
end

return spell