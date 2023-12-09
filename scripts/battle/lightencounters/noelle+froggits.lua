local Noelle, super = Class(LightEncounter)

function Noelle:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Here they come!\n* (Auto Placement test :3)"

    -- Battle music ("battleut" is undertale)
    self.music = "battleut"

    -- Add the dummy enemy to the encounter
    self:addEnemy("noelle")
    self:addEnemy("froggit")
    self:addEnemy("froggit")
    self:addEnemy("froggit")
    --self:addEnemy("froggit")

end

return Noelle