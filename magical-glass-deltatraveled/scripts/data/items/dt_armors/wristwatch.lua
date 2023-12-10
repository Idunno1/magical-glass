local item, super = Class(LightEquipItem, "dt_armors/wristwatch")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Wristwatch"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Armor 5 DF\n* Maybe an expensive antique.\n* Stuck before half past noon."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        defense = 5
    }

    -- Default dark item conversion for this item
    self.dark_item = "silver_watch"
end

return item