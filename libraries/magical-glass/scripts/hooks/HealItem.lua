local HealItem, super = Class("HealItem", true)

--[[ function HealItem:init()
    super.init(self)

    -- Short name for the light battle item menu
    self.short_name = nil
    -- Serious name for the light battle item menu
    self.serious_name = nil
    -- Should the item display how much HP was healed after its message?
    self.display_healing = true

end

function HealItem:getShortName() return self.short_name end
function HealItem:getSeriousName() return self.serious_name end ]]

function HealItem:onWorldUse(target)

    local text = self:getWorldUseText(target)
    if self.target == "ally" then
        self:worldUseSound(target)
        local amount = self:getWorldHealAmount(target.id)
        Game.world:heal(target, amount, text, self, self.display_healing)
        return true
    elseif self.target == "party" then
        self:worldUseSound(target)
        for _,party_member in ipairs(target) do
            local amount = self:getWorldHealAmount(party_member.id)
            Game.world:heal(party_member, amount, text, self, self.display_healing)
        end
        return true
    else
        return false
    end

end

function HealItem:onLightBattleUse(user, target)
    local text = self:getLightBattleText(user, target)

    if self.target == "ally" then
        self:battleUseSound(target)
        local amount = self:getBattleHealAmount(target.chara.id)
        target:heal(amount)
        return true
    elseif self.target == "party" then
        self:battleUseSound(target)
        for _,battler in ipairs(target) do
            local amount = self:getBattleHealAmount(battler.chara.id)
            target:heal(amount)
        end
        return true
    elseif self.target == "enemy" then
        -- Heal single enemy (why)
        local amount = self:getBattleHealAmount(target.id)
        target:heal(amount)
        return true
    elseif self.target == "enemies" then
        -- Heal all enemies (why????)
        for _,enemy in ipairs(target) do
            local amount = self:getBattleHealAmount(enemy.id)
            enemy:heal(amount)
        end
        return true
    else
        -- No target or enemy target (?), do nothing
        return false
    end
end

function HealItem:getLightBattleText(user, target)
    if self.target == "ally" and target.chara.id == Game.party[1].id then
        return self:useOnPlayerBattleText(user, target)
    elseif self.target == "ally" then
        return self:useOnAllyBattleText(user, target)
    elseif self.target == "party" then
        return self:useOnPartyBattleText(user, target)
    elseif self.target == "enemy" then
        return self:useOnEnemyBattleText(user, target)
    elseif self.target == "enemies" then
        return self:useOnEnemiesBattleText(user, target)
    end
end

function HealItem:getWorldUseText(target)
    if self.target == "ally" and target.id == Game.party[1].id then
        return self:useOnPlayerWorldText(target)
    elseif self.target == "ally" then
        return self:useOnAllyWorldText(target)
    elseif self.target == "party" then
        return self:useOnPartyWorldText(target)
    end
end

function HealItem:useOnPlayerWorldText(target)
    return "* You ate the " .. self:getName() .. "."
end

function HealItem:useOnAllyWorldText(target)
    return "* " .. target.name .. " ate the " .. self:getName() .. "."
end

function HealItem:useOnEveryoneWorldText(target)
    return "* Everyone ate the " .. self:getName() .. "."
end

function HealItem:useOnPlayerBattleText(user, target)
    return "* You ate the " .. self:getName() .. "!"
end

function HealItem:useOnAllyBattleText(user, target)
    return "* " .. target.chara.name .. " ate the " .. self:getName() .. "."
end

function HealItem:useOnPartyBattleText(user, target)
    return "* Everyone ate the " .. self:getName() .. "."
end

function HealItem:useOnEnemyBattleText(user, target)
    return "* " .. target.chara.name .. " used the " .. self:getName() .. "."
end

function HealItem:useOnEnemiesBattleText(user, target)
    return "* " .. target.chara.name .. " used the " .. self:getName() .. "."
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

function HealItem:getShortName() return self.short_name or self.serious_name or self.name end
function HealItem:getSeriousName() return self.serious_name or self.short_name or self.name end

return HealItem