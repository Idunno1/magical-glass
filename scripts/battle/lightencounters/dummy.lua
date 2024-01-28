local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* You encountered the Dummy...?"

    -- Battle music ("battleut" is undertale)
    self.music = "funky_town"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")

    self.bg_siners = {0, 15, 30, 45, 60, 75}

    self.offset = 0

end

function Dummy:onBattleInit()
    if self:getFlag("deltarune") then
        local fuck = Game.battle.enemies[1]:getAct("deltarune")
        Game.battle.tension = true
        fuck.name = "undertale"
    end
end

function Dummy:update()
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

        love.graphics.setLineStyle("rough")
        love.graphics.setLineWidth(1)

        for i = 2, 16 do
            Draw.setColor(0, 61 / 255, 17 / 255, 1 / 2)
            love.graphics.line(0, -210 + (i * 50) + math.floor(self.offset / 2), 640, -210 + (i * 50) + math.floor(self.offset / 2))
            love.graphics.line(-200 + (i * 50) + math.floor(self.offset / 2), 0, -200 + (i * 50) + math.floor(self.offset / 2), 480)
        end

        for i = 3, 16 do
            Draw.setColor(0, 61 / 255, 17 / 255, 1)
            love.graphics.line(0, -100 + (i * 50) - math.floor(self.offset), 640, -100 + (i * 50) - math.floor(self.offset))
            love.graphics.line(-100 + (i * 50) - math.floor(self.offset), 0, -100 + (i * 50) - math.floor(self.offset), 480)
        end
    else
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

    Draw.setColor(1/2, 1/2, 1/2)
    love.graphics.rectangle("fill", 0, 0, 999, 999)
end

return Dummy