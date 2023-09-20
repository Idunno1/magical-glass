local spell, super = Class(Spell, "heal_prayer")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "Heal Prayer"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = "Heal\nAlly"
    -- Menu description
    self.description = "Heavenly light restores a little HP to\none party member. Depends on Magic."

    -- TP cost
    self.cost = 32

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onLightCast(user, target)
    self.amount = math.ceil((user.chara:getStat("magic") * 1.5))
    target:heal(self.amount, false, true)
end

function spell:getLightCastMessage(user, target)
    local message = "* "..user.chara:getNameOrYou().." cast "..self:getName().."."
    local heal_text = self:getHealMessage(user, target)
    return message .. "\n" .. heal_text
end

return spell