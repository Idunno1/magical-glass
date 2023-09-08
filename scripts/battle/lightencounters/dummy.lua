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

--[[     self.shader = love.graphics.newShader([[
        vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords)
        {
           vec4 pixel = Texel(texture, texture_coords);
           texture.x *= width;
           return pixel;
        }
    ]] --]])

end

function Dummy:update()
--[[     self.shader:send("width", SCREEN_WIDTH)
    self.shader:send("height", SCREEN_HEIGHT) ]]
    super.update(self)

    if self:getFlag("deltarune") then
        self.offset = self.offset + 1 * DTMULT

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
        Draw.setColor(0, 0, 0, 0)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)
    
        love.graphics.setLineStyle("rough")
        love.graphics.setLineWidth(1)
    
        for i = 2, 16 do
            Draw.setColor(66 / 255, 0, 66 / 255, 0.5)
            love.graphics.line(0, -210 + (i * 50) + math.floor(self.offset / 2), 640, -210 + (i * 50) + math.floor(self.offset / 2))
            love.graphics.line(-200 + (i * 50) + math.floor(self.offset / 2), 0, -200 + (i * 50) + math.floor(self.offset / 2), 480)
        end
    
        for i = 3, 16 do
            Draw.setColor(66 / 255, 0, 66 / 255, 1)
            love.graphics.line(0, -100 + (i * 50) - math.floor(self.offset), 640, -100 + (i * 50) - math.floor(self.offset))
            love.graphics.line(-100 + (i * 50) - math.floor(self.offset), 0, -100 + (i * 50) - math.floor(self.offset), 480)
        end
    else
        --love.graphics.setShader(self.shader)
        Draw.setColor(0.5, 0.5, 0.5)
        love.graphics.rectangle("fill", -8, -8, SCREEN_WIDTH+16, SCREEN_HEIGHT+16)
        local offset = 0
        for i = 1, 6 do
            local sine = (math.sin(self.bg_siners[i] / 14) * 8) + 12
            Draw.setColor(0, 107/255, 183/255)
            love.graphics.setLineWidth(1)
            love.graphics.rectangle("line", 18 + offset, sine, 101, 118)
            love.graphics.rectangle("line", 18 + offset, sine + 118, 101, 118)
            offset = offset + 101
        end
        --love.graphics.setShader()
    end
end

return Dummy