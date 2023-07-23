local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The tutorial begins...?"

    -- Battle music ("battleut" is undertale)
    self.music = "battle_dt"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")
end

return Dummy