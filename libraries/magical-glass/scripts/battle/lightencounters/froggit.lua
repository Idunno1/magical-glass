local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Froggit hopped close!"

    -- Battle music ("battleut" is undertale)
    self.music = "battleut"

    -- Add the dummy enemy to the encounter
    self:addEnemy("froggit", SCREEN_WIDTH/2 - 49, 246)
end

return encounter