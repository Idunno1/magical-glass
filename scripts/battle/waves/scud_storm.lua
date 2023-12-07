local ScudStorm, super = Class(Wave)

function ScudStorm:init()
    super.init(self)
end

function ScudStorm:onStart()
    self.timer:every(1/6, function()
        local x = Game.battle.arena.x - 100
        local y = Utils.random(Game.battle.arena.left - 50, Game.battle.arena.right + 50) - 100

        local bullet = self:spawnBullet("scud", x, y, math.rad(45), 12)

        bullet.remove_offscreen = true
    end)
end

function ScudStorm:update()
    -- Code here gets called every frame

    super:update(self)
end

return ScudStorm