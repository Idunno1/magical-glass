local bullet, super = Class(Bullet)

function bullet:init(x, y)
    -- Last argument = sprite path
    super:init(self, x, y, "bullets/froggit/flybullet")
    self:setSprite("bullets/froggit/flybullet", 2/30, true)

    self:setScale(1, 1)
    self:setOrigin(0.5, 0.5)

    local particle = Sprite("bullets/froggit/bulletgenmd")
    particle:setOrigin(0.5, 0.5)
    Game.battle:addChild(particle)
    local rx, ry = particle:getRelativePos(x, y)
    particle:setPosition(rx, ry + 2)
    particle:play(1/30, false, function(this) this:remove() end)

    local angle = Utils.angle(x, y, Game.battle.soul.x + 2, Game.battle.soul.y + 2)
    self.physics.direction = angle
    self.physics.speed = 2.5

    Game.battle.timer:every(1, function()
        if Game.battle.soul then
            local new_angle = Utils.angle(self.x, self.y, Game.battle.soul.x + 2, Game.battle.soul.y + 2)
            self.physics.direction = new_angle
            self.physics.speed = 0
        end
    end)

    Game.battle.timer:every(45/30 --[[lmao]], function()
        self.physics.speed = 3
    end)
end

return bullet