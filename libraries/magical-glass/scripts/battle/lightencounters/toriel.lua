local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* Toriel blocks the way!"

    -- Battle music ("battleut" is undertale)
    self.music = "boss1"
	
    self.background_image = "ui/lightbattle/backgrounds/battle2"

    -- Add the dummy enemy to the encounter
    self:addEnemy("toriel", SCREEN_WIDTH/2 - 70, 45)
end

return Dummy