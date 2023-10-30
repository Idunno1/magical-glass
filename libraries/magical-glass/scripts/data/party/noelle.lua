local character, super = Class("noelle", true)

function character:init()
    super.init(self)

    self.lw_portrait = "face/noelle/silly"

    self:addSpell("snowgrave")

    -- Light world base stats (saved to the save file)
    self.lw_stats = {
        health = 20,
        attack = 10,
        defense = 10,
        magic = 3
    }

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "weapons/ring"
    self.lw_armor_default = "light/wristwatch"

end

return character