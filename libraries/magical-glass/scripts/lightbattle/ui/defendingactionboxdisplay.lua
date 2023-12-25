---@class ActionBoxDisplay : Object
---@overload fun(...) : ActionBoxDisplay
local ActionBoxDisplay, super = Class(Object)

function ActionBoxDisplay:init(actbox, x, y)
    super.init(self, x, y)

    self.font = Assets.getFont("namelv")

    self.actbox = actbox
end

function ActionBoxDisplay:draw()
    Draw.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(5)
    love.graphics.line(0, 1+40, 213+40, 1+40)

    Draw.setColor(PALETTE["action_fill"])
    love.graphics.rectangle("fill", 0, 2, 218, 36)
    
    Draw.setColor(1, 1, 1, 1)
    love.graphics.setLineWidth(3)
    love.graphics.line(2, 0, 2, 40)
    love.graphics.line(213, 0, 213, 40)

    local health_offset = 0
    health_offset = (#tostring(self.actbox.battler.chara:getHealth()) - 1) * 8

    local maxhealth = self.actbox.battler.chara:getStat("health")
    local health = (self.actbox.battler.chara:getHealth() / maxhealth) * 56
    local overhundred = 0
    if maxhealth >= 100 and maxhealth < 1000 then
        overhundred = 7
    elseif maxhealth >= 1000 then
        overhundred = 7*2
    end

    love.graphics.setColor(COLORS["red"])
    love.graphics.rectangle("fill", 152 - health_offset +overhundred, 22 - self.actbox.data_offset, 59, 10)

    if health > 0 then
        love.graphics.setColor(COLORS["yellow"])
        love.graphics.rectangle("fill", 152 - health_offset +overhundred, 22 - self.actbox.data_offset, math.ceil(((self.actbox.battler.chara:getHealth() / maxhealth)) * 20) * 3, 10)
    end


    local color = PALETTE["action_health_text"]
    if health <= 0 then
        color = PALETTE["action_health_text_down"]
    elseif (self.actbox.battler.chara:getHealth() <= (self.actbox.battler.chara:getStat("health") / 4)) then
        color = PALETTE["action_health_text_low"]
    else
        color = PALETTE["action_health_text"]
    end

    Draw.setColor(color)
    love.graphics.setFont(self.font)
    love.graphics.print(self.actbox.battler.chara:getHealth(), (152-overhundred) - health_offset, 7 - self.actbox.data_offset)
    Draw.setColor(PALETTE["action_health_text"])
    love.graphics.print(" /", 161-overhundred, 7 - self.actbox.data_offset)
    local string_width = self.font:getWidth(tostring(self.actbox.battler.chara:getStat("health")))
    Draw.setColor(color)
    love.graphics.print(self.actbox.battler.chara:getStat("health"), 205 - string_width, 7 - self.actbox.data_offset)

    super.draw(self)
end

return ActionBoxDisplay