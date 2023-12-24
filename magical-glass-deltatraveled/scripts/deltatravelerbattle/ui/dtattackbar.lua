local DTAttackBar, super = Class(Object)

function DTAttackBar:init(x, y, battler, scale_y)
    super.init(self, x, y)

    self.battler = battler

    self.scale_y = scale_y or 1

    self.sprite = Sprite("ui/lightbattle/targetchoice")
    self.sprite:setOrigin(0.5, 0.5)
    if #Game.battle:getActiveParty() > 1 then
        self.sprite.color = self.battler.chara:getLightAttackBarColor() or {1, 1, 1, 1}
    end
    self:addChild(self.sprite)

    self.bursting = false
    self.burst_speed = 0.1
end

function DTAttackBar:burst()
    self.bursting = true
end

function DTAttackBar:update()
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

return DTAttackBar