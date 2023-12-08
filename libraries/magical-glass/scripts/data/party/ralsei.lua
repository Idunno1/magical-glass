local character, super = Class("ralsei", true)

function character:init()
    super.init(self)
    
    self.weapon = "red_scarf"
    if Game.chapter >= 2 then
        self.armor[1] = "amber_card"
        self.armor[2] = "white_ribbon"
    end
end

return character