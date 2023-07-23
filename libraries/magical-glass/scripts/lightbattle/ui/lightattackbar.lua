local LightAttackBar, super = Class(Object)

function LightAttackBar:init(x, y, battler)
    super.init(self, x, y)

    self.battler = battler

    self.sprite = Sprite("ui/lightbattle/targetchoice")
    self.sprite:setOrigin(0.5, 0)
    self.sprite.color = self.battler.chara.color or {1, 1, 1, 1}
    self:addChild(self.sprite)

    self.flashing = false
    self.bursting = false
    self.fading = false

    self.flash_speed = 1/15
    self.burst_speed = 0.1
    self.fade_speed = 1/15

end

function LightAttackBar:flash(flash_speed)
    self.flashing = true
    self.sprite:play(self.flash_speed, true)
end

return LightAttackBar