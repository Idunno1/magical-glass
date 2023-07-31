local SpareDust, super = Class(Sprite, "SpareDust")

function SpareDust:init(x, y)
    super.init(self, "effects/spare/dustcloud", x, y)

    self.x = x
    self.y = y

    self:play(4/30, false, function(s) s:remove() end)

    --self.alpha = 0.5
    self.physics.friction = 0.8

    self.scale_variance = Utils.random(0, 1, 1) + 0.7
    self:setScale(self.scale_variance, self.scale_variance)

end

function SpareDust:spread()
    local direction = self.physics.direction
    direction = math.rad(Utils.random(360))
    print(self.rightside, self.topside)

    if self.rightside < 0.75 then
        print("1")
        direction = math.rad(180)
    elseif self.rightside > 1.25 then
        print("2")
        direction = math.rad(0)
    elseif self.topside > 1.25 and self.rightside > 1.25 then
        print("3")
        direction = math.rad(45)
    elseif self.topside > 1.25 and self.rightside > 0.75 and self.rightside < 1.25 then
        print("4")
        direction = math.rad(90)
    elseif self.topside > 1.25 and self.rightside < 0.75 then
        print("5")
        direction = math.rad(135)
    elseif self.topside < 0.75 and self.rightside > 1.25 then
        print("6")
        direction = math.rad(315)
    elseif self.topside < 0.75 and self.rightside > 0.75 and self.rightside < 1.25 then
        print("7")
        direction = math.rad(270)
    elseif self.topside < 0.75 and self.rightside < 0.75 then
        print("8")
        direction = math.rad(235)
    end
    
    direction = (-direction)
    self.physics.speed = 8
end

function SpareDust:update()
    --self.alpha = self.alpha - 0.03 * DTMULT
    self.alpha = self.alpha - 0.05 * DTMULT
    super.update(self)
end

return SpareDust