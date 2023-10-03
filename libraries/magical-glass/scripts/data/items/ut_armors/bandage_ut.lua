local item, super = Class(LightEquipItem, "ut_armors/bandage")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Bandage"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop sell price
    self.sell_price = 150
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Heals 10 HP\n* It has already been used\nseveral times."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.heal_amount = 10
end

function item:getFleeBonus() return 100 end

function item:onWorldUse(target)
    -- gross
    local bonus = 0
    for _,party in ipairs(Game.party) do
        for _,equip in ipairs(party:getEquipment()) do
            bonus = bonus + (equip.getHealBonus and equip:getHealBonus() or 0)
        end
    end

    Assets.playSound("power")
    if target.id == Game.party[1].id then
        if not Game:getFlag("#serious_mode") then
            Game.world:heal(target, self.heal_amount + bonus, "* You re-applied the bandage.\n* Still kind of gooey.", self)
        else
            Game.world:heal(target, self.heal_amount + bonus, "* You re-applied the bandage.", self)
        end
    else
        Game.world:heal(target, self.heal_amount + bonus, "* " .. target:getName() .. " applied the bandage.", self)
    end

    Game.inventory:removeItem(self)
end

function item:onBattleSelect(user, target)
    return true
end

function item:getLightBattleText(user, target)
    if target.chara.id == Game.battle.party[1].chara.id then
        if not Game:getFlag("#serious_mode") then
            return "* You re-applied the bandage.\n* Still kind of gooey."
        else
            return "* You re-applied the bandage."
        end
    else
        return "* "..target.chara:getName().." applied the bandage."
    end
end

function item:onLightBattleUse(user, target)
    Assets.stopAndPlaySound("power")
    target:heal(self.heal_amount)
    Game.battle:battleText(self:getLightBattleText(user, target).."\n"..self:getLightBattleHealingText(self.heal_amount, user, target))
end

function item:getLightBattleHealingText(user, target, amount, maxed)
    if target then
        if self.target == "ally" then
            maxed = target.chara:getHealth() >= target.chara:getStat("health")
        elseif self.target == "enemy" then
            maxed = target.health >= target.max_health
        end
    end

    local message
    if self.target == "ally" then
        if target.chara.id == Game.battle.party[1].chara.id and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
        else
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
        end
    end
    return message
end

function item:getLightWorldHealingText(target, amount, maxed)
    if target then
        if self.target == "ally" then
            maxed = target:getHealth() >= target:getStat("health")
        end
    end

    local message
    if self.target == "ally" then
        if target.id == Game.party[1].id and maxed then
            message = "* Your HP was maxed out."
        elseif maxed then
            message = "* " .. target:getName() .. "'s HP was maxed out."
        else
            message = "* " .. target:getNameOrYou() .. " recovered " .. amount .. " HP."
        end
    end
    return message
end

return item