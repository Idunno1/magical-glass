local item, super = Class(LightEquipItem, "dt_weapons/snow_ring")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Snow Ring"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = {
        "Wpn AT 1 MG 5\n* For some reason, it feels\n really cold in your hands.",
        "* This ICERING allows Noelle to\ncast ICE spells when equipped."
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    -- Equip bonuses (for weapons and armor)
    self.bonuses = {
        attack = 1,
        magic = 5
    }

    -- Default dark item conversion for this item
    self.dark_item = "snow_ring"

    self.bolt_speed = 9
    self.bolt_speed_variance = 0

    self.tags = {
        "icering",
        "noelle_ice_shock",
        "noelle_heal_prayer"
    }
end

return item