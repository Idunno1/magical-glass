local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The tutorial begins...?"

    -- Battle music ("battleut" is undertale)
    self.music = "funky_town"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy", SCREEN_WIDTH/2, 240)

    self.bg_siners = {0, 15, 30, 45, 60, 75}

    self.offset = 0

    self.shader = love.graphics.newShader([[
        float edge_stretch_str = 1; // the higher the more stretched
        float edge_stretch_lim = 2; // the higher the less stretched

        vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
        {
            texture_coords.y -= (texture_coords.y - .5) * edge_stretch_str * pow(abs(texture_coords.x - .5), edge_stretch_lim);
            return Texel(tex, texture_coords) * color / 2;
        }
    ]])

end

function Dummy:update()
    super.update(self)

    if self:getFlag("deltarune") then
        self.offset = self.offset + DTMULT

        if self.offset > 100 then
            self.offset = self.offset - 100
        end
    else
        for i = 1, #self.bg_siners do
            self.bg_siners[i] = self.bg_siners[i] + DTMULT
        end
    end

end

function Dummy:drawBackground()
    if self:getFlag("deltarune") then
        local canvas = Draw.pushCanvas()
        Draw.setColor(0, 0, 0, 0)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)
    
        love.graphics.setLineStyle("rough")
        love.graphics.setLineWidth(1)
    
        for i = 2, 16 do
            Draw.setColor(1, 0, 1, 0.3)
            love.graphics.line(0, -210 + (i * 50) + math.floor(self.offset / 2), 640, -210 + (i * 50) + math.floor(self.offset / 2))
            love.graphics.line(-200 + (i * 50) + math.floor(self.offset / 2), 0, -200 + (i * 50) + math.floor(self.offset / 2), 480)
        end
    
        for i = 3, 16 do
            Draw.setColor(1, 0, 1, 0.8)
            love.graphics.line(0, -100 + (i * 50) - math.floor(self.offset), 640, -100 + (i * 50) - math.floor(self.offset))
            love.graphics.line(-100 + (i * 50) - math.floor(self.offset), 0, -100 + (i * 50) - math.floor(self.offset), 480)
        end
        Draw.popCanvas()
        love.graphics.setShader(self.shader)
        Draw.drawCanvas(canvas)
        love.graphics.setShader()
    else
--[[         Draw.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16) ]]
        local offset = 0
        for i = 1, 6 do
            local sine = (math.sin(self.bg_siners[i] / 14) * 8) + 12
            Draw.setColor(0, 107/255, 183/255)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", 18 + offset, sine, 101, 118)
            love.graphics.rectangle("line", 18 + offset, sine + 118, 101, 118)
            offset = offset + 101
        end
    end
end

return Dummy