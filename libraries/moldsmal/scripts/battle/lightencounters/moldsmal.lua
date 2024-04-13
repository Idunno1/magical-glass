local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* Moldsmal blocked the way!"

    self.music = "battleut"

    self:addEnemy("moldsmal", SCREEN_WIDTH/2, 226)
end

return encounter