local LightEnemySprite, super = Class(ActorSprite)

function LightEnemySprite:init(actor)
    super.init(self, actor)
    self.actor = actor

    self.parts = {}
    self.part_offsets = {}
    
    for i, part in ipairs(self.actor.parts) do
        local part = Sprite(self.actor.path .. "/" .. self.actor.parts[i][1])
        table.insert(self.parts, part)
        self:addChild(part)
    end

end

function LightEnemySprite:update()

end

function LightEnemySprite:draw()

end

return LightEnemySprite