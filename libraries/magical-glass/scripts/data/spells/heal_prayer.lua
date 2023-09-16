local spell, super = Class(Spell, "heal_prayer")

function spell:init()
    super.init(self)

    -- Display name
    self.name = "Heal Prayer"
    -- Name displayed when cast (optional)
    self.cast_name = nil

    -- Battle description
    self.effect = "Heal\nAlly"
    -- Menu description
    self.description = "Heavenly light restores a little HP to\none party member. Depends on Magic."

    -- TP cost
    self.cost = 32

    -- Target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"

    -- Tags that apply to this spell
    self.tags = {"heal"}
end

function spell:onLightCast(user, target)
    self.amount = math.ceil((user.chara:getStat("magic") * 2))
    target:heal(self.amount, false, true)
end

function spell:getLightCastMessage(user, target)
    local message = "* "..user.chara:getName().." cast "..self:getName().."."
    local heal_text = self:getLightBattleHealingText(user, target)
    return message .. "\n" .. heal_text
end

function spell:getLightBattleHealingText(user, target)
    local message = ""
    if self.target == "ally" then
        local maxed = target.chara.lw_health >= target.chara:getStat("health")
        if target.id == Game.battle.party[1].chara.id and maxed then
            message = "* Your HP was maxed out."
        elseif target.id == Game.battle.party[1].chara.id and not maxed then
            message = "* You recovered " .. self.amount .. " HP."
        elseif maxed then
            message = target.chara.name .. "'s HP was maxed out."
        else
            message = target.chara.name .. " recovered " .. self.amount .. " HP."
        end
    elseif self.target == "party" then
        if #Game.battle.party > 1 then
            message = "* Everyone recovered " .. self.amount .. " HP."
        else
            message = "* You recovered " .. self.amount .. " HP."
        end
    end
    return message
end

return spell