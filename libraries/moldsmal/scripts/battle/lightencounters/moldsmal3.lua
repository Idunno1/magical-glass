local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    self.text = "* You tripped into a line of Moldsmals."

    self.music = "battleut"

    self:addEnemy("moldsmal", SCREEN_WIDTH/2 - 175, 226)
    self:addEnemy("moldsmal", SCREEN_WIDTH/2, 226)
    self:addEnemy("moldsmal", SCREEN_WIDTH/2 + 175, 226)
end

return encounter