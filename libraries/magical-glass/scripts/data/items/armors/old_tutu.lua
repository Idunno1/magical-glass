local item, super = Class(LightEquipItem, "armors/old_tutu")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Old Tutu"
    self.serious_name = "Tutu"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Armor DF 10\n* Finally,[wait:2] a protective piece\nof armor."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        defense = 10
    }

end

return item