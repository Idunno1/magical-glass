local LightAttackBar, super = Class(Object)

function LightAttackBar:init(x, y, battler)
    super.init(self, x, y)

    self.battler = battler

    self.sprite = Sprite("ui/lightbattle/targetchoice")
    self.sprite:setOrigin(0.5, 0.5)
    self.sprite.color = self.battler.chara.color or {1, 1, 1, 1}
    self:addChild(self.sprite)

    self.bursting = false

    self.flash_speed = 1/15
    self.burst_speed = 0.05
    
end

function LightAttackBar:flash(flash_speed)
    self.sprite:play(self.flash_speed, true)
end

function LightAttackBar:burst()
    self.bursting = true
    self:fadeOutSpeedAndRemove(0.1)
end

function LightAttackBar:update()
    if self.bursting then
        self.scale_x = self.scale_x + self.burst_speed * DTMULT
        self.scale_y = self.scale_y + self.burst_speed * DTMULT
    end

    super.update(self)
end

return LightAttackBar