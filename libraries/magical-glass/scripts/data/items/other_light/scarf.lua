local item, super = Class(LightEquipItem, "light/scarf")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Scarf"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Weapon 2 MG\n* A magical pink scarf.\n* Very fluffy."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        magic = 2
    }

    -- Default dark item conversion for this item
    self.dark_item = "red_scarf"
end

return item