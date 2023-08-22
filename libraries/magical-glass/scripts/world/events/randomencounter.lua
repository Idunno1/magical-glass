---@class RandomEnc : Event
---@overload fun(...) : RandomEnc
local RandomEnc, super = Class(Event, "random_encounter")

function RandomEnc:init(x, y, w, h, properties)
    super.init(self, x, y, w, h)

    properties = properties or {}

    self.randome = properties["random"]
end

function RandomEnc:update()
    super.update(self)

    if chara == Game.world.player and Game.random_encounter_value < 0 then
        if not Game.world.cutscene and not Game.battle then
            Game.world:startCutscene(function(cutscene)
                Assets.stopAndPlaySound("alert")
                local sprite = Sprite("effects/alert", Game.world.player.width/2)
                sprite:setScale(1,1)
                sprite:setOrigin(0.5, 1)
                Game.world.player:addChild(sprite)
                sprite.layer = WORLD_LAYERS["above_events"]
                cutscene:wait(0.75)
                sprite:remove()
                RandomEncounter()
            end)
            Game.random_encounter_value = love.math.random(20, 100)
        end
    end

end

return RandomEnc