local LightArenaBorder, super = Class(Object)

-- yes, this IS stupid.

function LightArenaBorder:init(arena, x, y)
    super:init(self, x, y)

    self.arena = arena

    self.layer = BATTLE_LAYERS["ui"] + 5

end

function LightArenaBorder:update()
    self.width = self.arena.width
    self.height = self.arena.height

    super.update(self)
end

function LightArenaBorder:draw()

    super.draw(self)

    local r,g,b,a = self:getDrawColor()
    local arena_r,arena_g,arena_b,arena_a = self.arena:getDrawColor()

    Draw.setColor(r * arena_r, g * arena_g, b * arena_b, a * arena_a)
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(self.arena.line_width)
    love.graphics.line(unpack(self.arena.border_line))

end

return LightArenaBorder