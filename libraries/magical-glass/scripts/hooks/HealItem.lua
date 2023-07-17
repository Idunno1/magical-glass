local HealItem, super = Class("HealItem", true)

function HealItem:init()

    super.init(self)
    -- Short name for the light battle item menu
    self.short_name = nil
    -- Serious name for the light battle item menu
    self.serious_name = nil
    -- Should the item display how much HP was healed after its message?
    self.display_healing = true

end

function HealItem:getShortName() return self.short_name end
function HealItem:getSeriousName() return self.serious_name end

function HealItem:onWorldUse(target)

    self:useSound(target)
    local text = self:onWorldUseText(target)
    --local text = self:onWorldUseText(target)
    if self.target == "ally" then
        local amount = self:getWorldHealAmount(target.id)
        Game.world:heal(target, amount, text, self, self.display_healing)
        return true
    elseif self.target == "party" then
        -- Heal all party members
        for _,party_member in ipairs(target) do
            local amount = self:getWorldHealAmount(party_member.id)
            Game.world:heal(party_member, amount, text, self, self.display_healing)
        end
        return true
    else
        -- No target or enemy target (?), do nothing
        return false
    end

end

function HealItem:onWorldUseText(target)

    if self.target == "ally" and target.id == Game.party[1].id then
        return self:useOnPlayerText(target)
    elseif self.target == "ally" then
        return self:useOnAllyText(target)
    elseif self.target == "party" then
        return self:useOnEveryoneText(target)
    end

end

function HealItem:useOnPlayerText(target)
    return "* You ate the " .. self:getName() .. "."
end

function HealItem:useOnAllyText(target)
    return "* " .. target.name .. " ate the " .. self:getName() .. "."
end

function HealItem:useOnEveryoneText(target)
    return "* Everyone ate the " .. self:getName() .. "."
end

function HealItem:useSound(target)
    Game.world.timer:script(function(wait)
        Assets.stopAndPlaySound("swallow")
        wait(0.4)
        Assets.stopAndPlaySound("power")
    end)
end

return HealItem