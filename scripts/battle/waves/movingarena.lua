local MovingArena, super = Class(Wave)

function MovingArena:init()
    super:init(self)

    -- Initialize timer
    self.siner = 0

    if Game.battle.light then
        self.darken = true
        self:setArenaSize(142, Game.battle.arena.height)
        self:setArenaPosition(SCREEN_WIDTH/2, 300)
    end
end

function MovingArena:onStart()
    -- Get the arena object
    local arena = Game.battle.arena

    if Game.battle.light then
        -- arena sprite bullshit, hopefully we won't have to do this in the future
        Game.battle.soul.layer = Game.battle.arena.sprite.layer + 5

        -- Spawn spikes on top of arena
        self:spawnBulletTo(Game.battle.arena.sprite, "arenahazard", arena.width/2, 0, math.rad(0))

        -- Spawn spikes on bottom of arena (rotated 180 degrees)
        self:spawnBulletTo(Game.battle.arena.sprite, "arenahazard", arena.width/2, arena.height, math.rad(180))

    else
        -- Spawn spikes on top of arena
        self:spawnBulletTo(Game.battle.arena, "arenahazard", arena.width/2, 0, math.rad(0))

        -- Spawn spikes on bottom of arena (rotated 180 degrees)
        self:spawnBulletTo(Game.battle.arena, "arenahazard", arena.width/2, arena.height, math.rad(180))
    end
    
    -- Store starting arena position
    self.arena_start_x = arena.x
    self.arena_start_y = arena.y
end

function MovingArena:onEnd()
    Game.battle.soul.layer = BATTLE_LAYERS["soul"]
end

function MovingArena:update()
    -- Increment timer for arena movement
    self.siner = self.siner + DT

    -- Calculate the arena Y offset
    local offset = math.sin(self.siner * 1.5) * 60

    -- Move the arena
    Game.battle.arena:setPosition(self.arena_start_x, self.arena_start_y + offset)

    super:update(self)
end

return MovingArena