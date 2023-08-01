local SpareDust, super = Class(Sprite, "SpareDust")

function SpareDust:init(x, y)
    super.init(self, "effects/spare/dustcloud", x, y)

    self:play(5/30, false, function(s) s:remove() end)

    self.physics.friction = 0.8

    self.scale_variance = Utils.random(0, 1, 1) + 0.7
    self:setScale(self.scale_variance, self.scale_variance)

end

function SpareDust:spread()
    local direction = self.physics.direction
    direction = math.rad(Utils.random(360)) -- why

    if self.rightside < 0.75 then
        direction = math.rad(0)
    end
    if self.rightside > 1.25 then
        direction = math.rad(180)
    end
    if self.topside > 1.25 and self.rightside > 1.25 then
        direction = math.rad(225)
    end
    if self.topside > 1.25 and self.rightside > 0.75 and self.rightside < 1.25 then
        direction = math.rad(270)
    end
    if self.topside > 1.25 and self.rightside < 0.75 then
        direction = math.rad(315)
    end
    if self.topside < 0.75 and self.rightside > 1.25 then
        direction = math.rad(135)
    end
    if self.topside < 0.75 and self.rightside > 0.75 and self.rightside < 1.25 then
        direction = math.rad(90)
    end
    if self.topside < 0.75 and self.rightside < 0.75 then
        direction = math.rad(125)
    end
    
    self.physics.direction = (-direction)
    self.physics.speed = 8
end

function SpareDust:update()
    self.alpha = self.alpha - 0.03 * DTMULT
    super.update(self)
end

return SpareDust