local LightArenaSprite, super = Class(Object)

function LightArenaSprite:init(arena, x, y)
    super.init(self, x, y)

    self.arena = arena

    self.width = arena.width
    self.height = arena.height

    self:setScaleOrigin(0.5, 0.5)
    self:setRotationOrigin(0.5, 0.5)

    self:setLayer(BATTLE_LAYERS["below_ui"] - 5)

    self.border = LightArenaBorder(arena, x, y)
    self:addChild(self.border)

    self.background = true

    self.debug_select = false
end

function LightArenaSprite:update()
    self.width = self.arena.width
    self.height = self.arena.height

    super.update(self)
end

function LightArenaSprite:draw()
    if self.background then
        Draw.setColor(self.arena:getBackgroundColor())
        self:drawBackground()
    end

    super.draw(self)
end

function LightArenaSprite:drawBackground()
    for _,triangle in ipairs(self.arena.triangles) do
        love.graphics.polygon("fill", unpack(triangle))
    end
end

function LightArenaSprite:canDeepCopyKey(key)
    return super.canDeepCopyKey(self, key) and key ~= "arena"
end

return LightArenaSprite