local HealItem, super = Class("HealItem", true)

function HealItem:onWorldUse(target)

    local bonus = 0
    for _,party in ipairs(Game.party) do
        for _,equip in ipairs(party:getEquipment()) do
            bonus = bonus + (equip.getHealBonus and equip:getHealBonus() or 0)
        end
    end

    local text = self:getWorldUseText(target)
    if self.target == "ally" then
        self:worldUseSound(target)
        local amount = self:getWorldHealAmount(target.id) + bonus
        Game.world:heal(target, amount, text, self)
        return true
    elseif self.target == "party" then
        self:worldUseSound(target)
        for _,party_member in ipairs(target) do
            local amount = self:getWorldHealAmount(party_member.id) + bonus
            Game.world:heal(party_member, amount, text, self)
        end
        return true
    else
        return false
    end

end

function HealItem:onLightBattleUse(user, target)
    local text = self:getLightBattleText(user, target)

    local bonus = 0
    for _,equip in ipairs(user.chara:getEquipment()) do
        bonus = bonus + (equip.getHealBonus and equip:getHealBonus() or 0)
    end

    if self.target == "ally" then
        self:battleUseSound(target)
        local amount = self:getBattleHealAmount(target.chara.id)
        target:heal(amount + bonus)
        return true
    elseif self.target == "party" then
        self:battleUseSound(target)
        for _,battler in ipairs(target) do
            local amount = self:getBattleHealAmount(battler.chara.id)
            battler:heal(amount + bonus)
        end
        return true
    elseif self.target == "enemy" then
        -- Heal single enemy (why)
        local amount = self:getBattleHealAmount(target.id)
        target:heal(amount + bonus)
        return true
    elseif self.target == "enemies" then
        -- Heal all enemies (why????)
        for _,enemy in ipairs(target) do
            local amount = self:getBattleHealAmount(enemy.id)
            enemy:heal(amount + bonus)
        end
        return true
    else
        -- No target or enemy target (?), do nothing
        return false
    end
end

function HealItem:getLightBattleText(user, target)
    if self.target == "ally" then
        return "* " .. target.chara:getNameOrYou() .. " ate the " .. self:getName() .. "."
    elseif self.target == "party" then
        if #Game.party > 1 then
            return "* Everyone ate the " .. self:getName() .. "."
        else
            return "* You ate the " .. self:getName() .. "."
        end
    elseif self.target == "enemy" then
        return "* " .. target:getName() .. " used the " .. self:getName() .. "."
    elseif self.target == "enemies" then
        return "* " .. target:getName() .. " used the " .. self:getName() .. "."
    end
end

function HealItem:getWorldUseText(target)
    if self.target == "ally" then
        return "* " .. target:getNameOrYou() .. " ate the " .. self:getName() .. "."
    elseif self.target == "party" then
        if #Game.party > 1 then
            return "* Everyone ate the " .. self:getName() .. "."
        else
            return "* You ate the " .. self:getName() .. "."
        end
    end
end

function HealItem:getLightWorldHealingText(target, amount, maxed)
    local message = ""
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

function HealItem:getLightBattleHealingText(user, target, amount, maxed)
    local message = ""
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
        if #Game.battle.party > 1 then
            message = "* Everyone recovered " .. amount .. " HP."
        else
            message = "* You recovered " .. amount .. " HP."
        end
    end
    return message
end

function HealItem:battleUseSound(target)
    Game.battle.timer:script(function(wait)
        Assets.stopAndPlaySound("swallow")
        wait(0.4)
        Assets.stopAndPlaySound("power")
    end)
end

function HealItem:worldUseSound(target)
    Game.world.timer:script(function(wait)
        Assets.stopAndPlaySound("swallow")
        wait(0.4)
        Assets.stopAndPlaySound("power")
    end)
end

return HealItem