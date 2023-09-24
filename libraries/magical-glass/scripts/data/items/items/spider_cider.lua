local item, super = Class(HealItem, "items/spider_cider")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Spider Cider"
    self.short_name = "SpidrCidr"
    self.serious_name = "SpidrCider"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 24

    -- Default shop price (sell price is halved)
    self.price = 18
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Heals 24 HP\n* Made with whole spiders[wait:2],\nnot just the juice."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
end

function item:onToss()
    Game.world:showText("* The Spider Donut was\nthrown away.")
    return true
end

return item