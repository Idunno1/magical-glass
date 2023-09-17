local item, super = Class(HealItem, "items/spider_donut")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Spider Donut"
    self.short_name = "SpidrDont"
    self.serious_name = "SpidrDonut"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 12

    -- Default shop price (sell price is halved)
    self.price = 7
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Heals 12 HP\n* A donut made with Spider\n  Cider in the batter."

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
    Game.world:showText("* The Spider Donut was\n  thrown away.")
    return false
end

return item