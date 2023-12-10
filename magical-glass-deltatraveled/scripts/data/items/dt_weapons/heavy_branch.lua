local item, super = Class(LightEquipItem, "dt_weapons/heavy_branch")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Heavy Branch"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = {
        "Weapon AT 8\n* Susie can't unequip this,\nso there's no way to see\nthe message.",
        "* This weapon is a SLASH\ntype weapon.\n* One bar, standard damage."
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        attack = 8
    }

    self.bolt_speed = 9
    self.bolt_speed_variance = 0

end

return item