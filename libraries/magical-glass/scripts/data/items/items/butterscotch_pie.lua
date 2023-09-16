local item, super = Class(HealItem, "items/butterscotch_pie")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Butterscotch Pie"
    self.short_name = "ButtsPie"
    self.serious_name = "Pie"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = math.huge

    -- Default shop price (sell price is halved)
    self.price = 0
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "All HP\n* Butterscotch-cinnamon\n  pie[wait:2], one slice."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "party"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
    
    -- Default dark item conversion for this item
    self.dark_item = "dark_candy"
end

function item:onToss()
    Game.world:showText("* The Butterscotch Pie was\n  thrown away.")
    return false
end

return item