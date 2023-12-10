local character, super = Class("noelle", true)

function character:init()
    super.init(self)

    self.light_color = {1, 1, 1}
    self.light_dmg_color = { 1, 0, 0 }
    self.light_miss_color = { 192 / 255, 192 / 255, 192 / 255 }
    self.light_attack_color = { 1, 210 / 255, 96 / 255 }
    self.light_multibolt_attack_color = { 1, 1, 0 }
    self.light_attack_bar_color = { 1, 1, 0 }
    self.light_xact_color = { 1, 1, 1 }

end

return character