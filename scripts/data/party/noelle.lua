local character, super = Class("noelle", true)

function character:init()
    super.init(self)

    -- Whether the party member can act / use spells
    self.has_act = true
    self.has_spells = true

    self:addSpell("snowgrave")
    self:addSpell("rude_buster")
end

return character