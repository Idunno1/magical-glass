local DTActionBoxDisplay, super = Class(Object)

function DTActionBoxDisplay:init(actbox, x, y)
    super.init(self, x, y)

    if Kristal.getLibConfig("magical-glass-deltatraveled", "accurate_fonts") then
        self.font = Assets.getFont("namelv")
    else
        self.font = Assets.getFont("battlehud")
    end

    self.actbox = actbox
    self.battler = self.actbox.battler
end

function DTActionBoxDisplay:draw()
    self:drawName()
    self:drawHPGauge()
    self:drawHPText()
    super.draw(self)
end

function DTActionBoxDisplay:drawName()
    local action = self.battler.has_selected_action

    if self.battler.is_down then
        Draw.setColor(COLORS.gray)
    elseif self.battler.has_selected_action then
        Draw.setColor(COLORS.yellow)
    else
        Draw.setColor(COLORS.white)
    end
    love.graphics.setFont(self.font)
    local extra_offset = 0

    if #self.battler.chara:getName() > 5 then
        extra_offset = 4
    end

    love.graphics.printf(self.battler.chara:getName(), 4 + extra_offset, -22, 60, "center")
end

function DTActionBoxDisplay:drawHPGauge()
    local name_offset = 1
    if #self.battler.chara:getName() == 5 then
        name_offset = 7
    elseif #self.battler.chara:getName() == 6 then
        name_offset = 13
    end

    Draw.setColor(COLORS.red)
    love.graphics.rectangle("fill", 60 + name_offset, -18, 45, 10)

    local health = (self.actbox.battler.chara:getHealth() / self.actbox.battler.chara:getStat("health")) * 45
    if health > 0 then
        Draw.setColor(COLORS.yellow)
        love.graphics.rectangle("fill", 60 + name_offset, -18, health, 10)
    end
end

function DTActionBoxDisplay:drawHPText()
    if self.battler.is_down then
        Draw.setColor(COLORS.red)
    elseif (Game.battle:getActionBy(self.battler) and Game.battle:getActionBy(self.battler).action == "DEFEND") or self.battler.defending then
        Draw.setColor(COLORS.aqua)
    else
        Draw.setColor(COLORS.white)
    end
    love.graphics.setFont(self.font)

    local name_offset = 0
    if #self.battler.chara:getName() == 5 then
        name_offset = 6
    elseif #self.battler.chara:getName() == 6 then
        name_offset = 9
    end

    local current, max = self.battler.chara:getHealth(), self.battler.chara:getStat("health")

    if max < 10 and max >= 0 then
        max = "0" .. tostring(max)
    end

    if current < 10 and current >= 0 then
        current = "0" .. tostring(current)
    end

    love.graphics.printf(current.."/"..max, 110 + name_offset, -22, 60, "center")
end

return DTActionBoxDisplay