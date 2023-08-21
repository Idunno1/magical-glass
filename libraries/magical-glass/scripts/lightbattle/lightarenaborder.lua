local LightArenaBorder, super = Class(Object)

-- yes, this IS stupid.

function LightArenaBorder:init(arena, x, y)
    super:init(self, x, y)

    self.arena = arena
end

function LightArenaBorder:update()
    self.width = self.arena.sprite.width
    self.height = self.arena.sprite.height

    super.update(self)
end

function LightArenaBorder:draw()

    super.draw(self)

    local r,g,b,a = self:getDrawColor()

    Draw.setColor(r, g, b, a)
    love.graphics.setLineStyle("rough")
    love.graphics.setLineWidth(self.arena.line_width)
    love.graphics.line(unpack(self.arena.border_line))

end

return LightArenaBorder