local item, super = Class(LightEquipItem, "armors/bandage_ut")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Bandage"

    -- Item type (item, key, weapon, armor)
    self.type = "armor"
    -- Whether this item is for the light world
    self.light = true

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

    local bonus = 0
    for _,party in ipairs(Game.party) do
        for _,equip in ipairs(party:getEquipment()) do
            bonus = bonus + (equip.getHealBonus and equip:getHealBonus() or 0)
        end
    end

    Assets.playSound("power")
    if target.id == Game.party[1].id then
        Game.world:heal(target, self.heal_amount + bonus, "* You re-applied the bandage.", self)
    else
        Game.world:heal(target, self.heal_amount + bonus, "* " .. target:getName() .. " re-applied the bandage.", self)
    end

    Game.inventory:removeItem(self)
end

function item:onBattleSelect(user, target)
    return true
end

function item:getLightBattleText(battler, target)
    return "* You re-applied the bandage."
end

function item:onLightBattleUse(user, target)
    self:battleUseSound(target)
    target:heal(self.heal_amount)
end

function item:battleUseSound(target)
    Assets.stopAndPlaySound("power")
end

function item:worldUseSound(target)
    Assets.stopAndPlaySound("power")
end

function item:getLightBattleHealingText(user, target, amount, maxed)
    local message
    if self.target == "ally" then
        if target.id == Game.battle.party[1].chara.id and maxed then
            message = "* Your HP was maxed out."
        elseif target.id == Game.battle.party[1].chara.id and not maxed then
            message = "* You recovered " .. amount .. " HP."
        elseif maxed then
            message = target.name .. "'s HP was maxed out."
        else
            message = target.name .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "party" then
        if #Game.party > 1 then
            message = "* Everyone recovered " .. amount .. " HP."
        else
            message = "* You recovered " .. amount .. " HP."
        end
    end
    return message
end

function item:getLightWorldHealingText(target, amount, maxed)
    local message
    if self.target == "ally" then
        if target.id == Game.party[1].id and maxed then
            message = "* Your HP was maxed out."
        elseif target.id == Game.party[1].id and not maxed then
            message = "* You recovered " .. amount .. " HP."
        elseif maxed then
            message = target.name .. "'s HP was maxed out."
        else
            message = target.name .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "party" then
        if #Game.party > 1 then
            message = "* Everyone recovered " .. amount .. " HP."
        else
            message = "* You recovered " .. amount .. " HP."
        end
    end
    return message
end

return item