local wave, super = Class(Wave)

function wave:onStart()
    self.time = 3.3

    local x = Utils.random(Game.battle.arena.left, Game.battle.arena.right)

    local bullet = self:spawnBullet("fly", x, Game.battle.arena.top)

    self.timer:every(20/30, function()
        local x = Utils.random(Game.battle.arena.left, Game.battle.arena.right)

        local bullet = self:spawnBullet("fly", x, Game.battle.arena.top)
    end)
end

return wave