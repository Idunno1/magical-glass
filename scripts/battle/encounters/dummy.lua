local Dummy, super = Class(Encounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The tutorial begins...?"

    -- Battle music ("battleut" is undertale)
    self.music = "battle"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")
end

return Dummy