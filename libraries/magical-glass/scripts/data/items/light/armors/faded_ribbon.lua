local item, super = Class(LightEquipItem, "light/armors/faded_ribbon")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Faded Ribbon"
    self.short_name = "Ribbon"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Armor DF 3\n* If you're cuter, monsters\nwon't hit you as hard."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        defense = 3
    }

    -- Default dark item conversion for this item
    self.dark_item = "white_ribbon"
end

function item:showEquipText()
    Game.world:showText("* You equipped the ribbon.")
end

return item