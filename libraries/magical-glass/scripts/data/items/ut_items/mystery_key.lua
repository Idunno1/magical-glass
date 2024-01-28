local item, super = Class(Item, "ut_items/mystery_key")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Mystery Key"
    self.short_name = "MystryKey"
    self.serious_name = "Key"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop price (sell price is halved)
    self.price = 600
    -- Whether the item can be sold
    self.can_sell = false

    -- Item description text (unused by light items outside of debug menu)
    self.description = "It has DON'T DROP IT written on it."

    -- Light world check text
    self.check = "* \"Mystery Key\" Unique\n* It is too bent to fit on\nyour keychain."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "none"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
    
end

function item:onWorldUse()
    if Game.world.cutscene then Game.world.cutscene:endCutscene() end
    Game.world:startCutscene(function(cutscene)
        cutscene:text("* You used the Mystery Key.[wait:10]\n* But nothing happened.")
        return false
    end)
end

function Item:onCheck()
    Game.world:showText(self:getCheck())
end

function item:onToss()
    Game.world:showText("* The Mystery Key was\nthrown away.")
    return true
end

return item