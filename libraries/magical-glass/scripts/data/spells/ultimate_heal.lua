local spell, super = Class(Spell, "ultimate_heal")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "UltimatHeal"
    -- Name displayed when cast (optional)
    self.cast_name = "ULTIMATEHEAL"

    -- Battle description
    self.effect = "Best\nhealing"
    -- Menu description
    self.description = "Heals 1 party member to the\nbest of Susie's ability."

    -- TP cost
    self.cost = 100

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onLightCast(user, target)
    local amount = math.ceil((user.chara:getStat("magic") + 1))
    target:heal(amount, false, true)

    local result = self:onLightCast(user, target)
    Game.battle:battleText(self:getLightCastMessage(user, target).."\n"..self:getHealMessage(user, target, amount))
    if result or result == nil then
        Game.battle:finishActionBy(user)
    end
end

function spell:getHealMessage(user, target, amount)
    local char_maxed
    local enemy_maxed
    if self.target == "ally" then
        char_maxed = target.chara:getHealth() >= target.chara:getStat("health")
    elseif self.target == "enemy" then
        enemy_maxed = target.health >= target.max_health
    end
    local message = ""
    if self.target == "ally" then
        if target.chara.id == Game.battle.party[1].chara.id and char_maxed then
            message = "* Your HP was maxed out."
        elseif char_maxed then
            message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
        else
            message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "party" then
        if #Game.party > 1 then
            message = "* Everyone recovered " .. amount .. " HP."
        else
            message = "* You recovered " .. amount .. " HP."
        end
    elseif self.target == "enemy" then
        if enemy_maxed then
            message = "* " .. target.name .. "'s HP was maxed out."
        else
            message = "* " .. target.name .. " recovered " .. amount .. " HP."
        end
    elseif self.target == "enemies" then
        message = "* The enemies all recovered " .. amount .. " HP."
    end
    return message
end

return spell
