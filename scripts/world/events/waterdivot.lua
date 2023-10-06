local event, super = Class(Event)

function event:init(x, y, properties)
    super.init(self, x, y)
    properties = properties or {}

    self:setSprite("world/events/waterdivot/waterdivot", (2/15 + Utils.random(3/15)))
    self.siner = Utils.random(20)

    self.physics.speed_x = properties["speed_x"] or 3
    if self.physics.speed_x > 0 then -- right
        self.delete_x = properties["delete_x"] or Game.world.width
        self.respawn_x = properties["respawn_x"] or -30
    elseif self.physics.speed_x <= 0 then -- left
        self.delete_x = properties["delete_x"] or Game.world.map.x
        self.respawn_x = properties["respawn_x"] or Game.world.width + 10
    end
end

function event:update()
    super.update(self)

    self.x = self.x + (math.sin((self.siner / 6)) * 0.02)

    self.siner = self.siner + DTMULT

    if (self.physics.speed_x > 0 and self.x > self.delete_x) or (self.physics.speed_x < 0 and self.x < self.delete_x) then
        self.x = self.respawn_x
    end
end

return event