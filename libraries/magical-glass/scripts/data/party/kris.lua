local character, super = Class("kris", true)

function character:init()
    super.init(self)
    
    self.weapon_default = "wood_blade"
    if Game.chapter >= 2 then
        self.armor_default[1] = "amber_card"
        self.armor_default[2] = "amber_card"
    end
end

return character