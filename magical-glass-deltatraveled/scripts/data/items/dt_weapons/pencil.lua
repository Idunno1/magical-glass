local item, super = Class(LightEquipItem, "dt_weapons/pencil")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Pencil"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = {
        "Weapon AT 1\n* Mightier than a sword?\n* Maybe equal at best.",
        "* This weapon is a SLASH\ntype weapon.\n* One bar, standard damage."
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        attack = 1,
    }

    -- Default dark item conversion for this item
    self.dark_item = "wood_blade"

    self.bolt_speed = 9
    self.bolt_speed_variance = 0

end

return item