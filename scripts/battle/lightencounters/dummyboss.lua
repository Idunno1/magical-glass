local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The boss battle begins...?"

    -- Battle music ("battleut" is undertale)
    self.music = "battle_dt"

    -- Background image (Defaults are "battle", "battle2", and "none")
    self.backgroundimage = "ui/lightbattle/backgrounds/battle2"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")
end

function Dummy:getVictoryXP()
    return 10
end

return Dummy