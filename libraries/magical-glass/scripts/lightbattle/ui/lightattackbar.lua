local LightAttackBar, super = Class(Object)

function LightAttackBar:init(x, y, battler)
    super.init(self, x, y)

    self.battler = battler

    self.sprite = Sprite("ui/lightbattle/targetchoice")
    self.fade_sprite = "ui/lightbattle/targetchoice_fade"
    self.sprite:setOrigin(0.5, 0.5)
    self.sprite.color = self.battler.chara.color or {1, 1, 1, 1}
    self:addChild(self.sprite)

    self.perfect = false
    self.bursting = false

    self.flash_speed = 1/15
    self.burst_speed = 0.1
    
end

function LightAttackBar:flash(flash_speed)
    self.sprite:play(self.flash_speed, true)
end
--self.sprite:setColor(1, 1, 64/255)
--self.sprite:setColor(192/255, 0, 0)
--self.sprite:setColor(128/255, 1, 1)

function LightAttackBar:burst()
    self.sprite:setSprite(self.fade_sprite)
    self.bursting = true
end

function LightAttackBar:update()
    if self.bursting then

        self.sprite.alpha = self.sprite.alpha - self.burst_speed * DTMULT
        if self.sprite.alpha < (0 + self.burst_speed) then
            self:remove()
        end
        self.scale_x = self.scale_x + self.burst_speed * DTMULT
        self.scale_y = self.scale_y + self.burst_speed * DTMULT

    end

    super.update(self)
end

return LightAttackBar