local character, super = Class("susie", true)

function character:init()
    super.init(self)
    
    self.lw_portrait = "face/susie/shock"

    -- Light world base stats (saved to the save file)
    self.lw_stats = {
        health = 30,
        attack = 12,
        defense = 10,
        magic = 1
    }

    -- Default light world equipment item IDs (saves current equipment)
    self.lw_weapon_default = "weapons/toothbrush"
    self.lw_armor_default = "light/bandage"

end

return character