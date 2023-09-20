local spell, super = Class(Spell, "ultimate_heal")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "UltimatHeal"
    -- Name displayed when cast (optional)
    self.cast_name = "ULTIMATEHEAL"

    -- Battle description
    self.effect = "Best\nhealing"
    -- Menu description
    self.description = "Heals 1 party member to the\nbest of Susie's ability."

    -- TP cost
    self.cost = 100

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onLightCast(user, target)
    self.amount = math.ceil((user.chara:getStat("magic") + 1))
    target:heal(self.amount, false, true)
end

function spell:getLightCastMessage(user, target)
    local message = "* "..user.chara:getNameOrYou().." cast "..self:getName().."."
    local heal_text = self:getHealMessage(user, target)
    return message .. "\n" .. heal_text
end

return spell
