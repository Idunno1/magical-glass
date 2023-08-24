local item, super = Class(LightEquipItem, "light/temy_armor")

function item:init()
    super.init(self)

    -- Display name
    self.name = "temy armor"
    self.short_name = "Temmie AR"
    self.serious_name = "Tem.Armor"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = {
        "Armor DF 20\n* The things you can do with\na college education!",
        "* Raises ATTACK when worn.\nRecovers HP every other turn.\nINV up slightly."
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.inv_bonus = 15/30

    self.regen_health = 1
    self.regen_turns = 2

    self.bonuses = {
        defense = 20,
        attack = 10
    }

end

return item