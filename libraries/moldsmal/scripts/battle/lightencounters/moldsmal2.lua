local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* Moldsmal and Moldsmal block\nthe way."

    self.music = "battleut"

    self:addEnemy("moldsmal", SCREEN_WIDTH/2 - 125, 226)
    self:addEnemy("moldsmal", SCREEN_WIDTH/2 + 125, 226)
end

return encounter