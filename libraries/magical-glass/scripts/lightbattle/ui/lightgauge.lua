local LightGauge, super = Class(Object)

function LightGauge:init(type, amount, x, y, enemy, color)
    super.init(self, x, y)

    self.layer = BATTLE_LAYERS["damage_numbers"]
    print("balls")

    self.type = type
    self:setOrigin(0.5, 0)

    if not color then
        if self.type == "damage" then
            self.color = COLORS["lime"]
        elseif self.type == "mercy" then
            self.color = COLORS["yellow"]
        end
    else
        self.color = color
    end

    self.enemy = enemy
    self.width, self.height = Utils.unpack(self.enemy:getGaugeSize())

    self.amount = amount

    self.health = self.enemy.health
    self.real_health = self.enemy.health
    self.max_health = self.enemy.max_health
    self.extra_width = (self.width / self.max_health)

end

function LightGauge:update()
    super.update(self)

    if self.health > (self.real_health - self.amount) then
        self.health = self.health - (self.amount / 15) * DTMULT
    else
        self.health = (self.real_health - self.amount)
    end

    if self.health < 0 then
        self.health = 0
    end
end

function LightGauge:draw()
    super.draw(self)

    Draw.setColor(COLORS["black"])
    love.graphics.rectangle("fill", -1, 7, Utils.round(self.max_health * self.extra_width + 1), self.height + 1)
    Draw.setColor(0.5, 0.5, 0.5) -- temp
    love.graphics.rectangle("fill", 0, 8, Utils.round(self.max_health * self.extra_width), self.height)
    if self.health > 0 then
        Draw.setColor(COLORS["lime"])
        love.graphics.rectangle("fill", 0, 8, Utils.round(self.health * self.extra_width), self.height)
    end
end

return LightGauge