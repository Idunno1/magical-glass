local LightAttackBar, super = Class(Object)

function LightAttackBar:init(x, y, type)
    super.init(self, x, y)

    self.type = type

    self:setOrigin(0.5, 0.5)

    self.sprite = Sprite("ui/lightbattle/targetchoice")
    self:addChild(self.sprite)

    self.hit = false
    self.hit_speed = 0.3
end

function LightAttackBar:hit()
    self.hit = true
    self.sprite:setAnimation({"ui/lightbattle/targetchoice", self.hit_speed, 2})
end

return LightAttackBar