local item, super = Class(HealItem, "items/croquet_roll")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Croquet Roll"
    self.short_name = "CroqtRoll"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 15

    -- Default shop price (sell price is halved)
    self.price = 10
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Heals 15 HP\n* Fried dough traditionally\nserved with a mallet."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
    
end

function item:getLightBattleText(user, target)
    if Game:getFlag("#serious_mode") then
        return super.getLightBattleText(self, user, target)
    else
        if user.chara.id == Game.party[1].id and target.chara.id == Game.party[1].id then
            return "* " .. user.chara:getNameOrYou() .. " hit the Croquet Roll into \nyour mouth."
        else
            return "* " .. user.chara:getNameOrYou() .. " hit the Croquet Roll into \n"..target.chara:getName().."'s mouth."
        end
    end
end

return item