local Noelle, super = Class(LightEncounter)

function Noelle:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Here comes Noelle!"

    -- Battle music ("battleut" is undertale)
    self.music = "battleut"

    -- Add the dummy enemy to the encounter
    self:addEnemy("noelle")

end

return Noelle