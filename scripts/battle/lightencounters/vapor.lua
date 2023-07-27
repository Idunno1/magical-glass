local Dummy, super = Class(LightEncounter)

function Dummy:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "* The tutorial begins...?"

    -- Battle music ("battleut" is undertale)
    self.music = "battleut"

    -- Add the dummy enemy to the encounter
    self:addEnemy("dummy")

    local wave_shader = love.graphics.newShader([[
        extern number wave_sine;
        extern number wave_mag;
        extern number wave_height;
        extern vec2 texsize;
        vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords )
        {
            number i = texture_coords.y * texsize.y;
            vec2 coords = vec2(max(0.0, min(1.0, texture_coords.x + (sin((i / wave_height) + (wave_sine / 30.0)) * wave_mag) / texsize.x)), max(0.0, min(1.0, texture_coords.y + 0.0)));
            return Texel(texture, coords) * color;
        }
    ]])
    self.wave_fx = ShaderFX(wave_shader, {
        ["wave_sine"] = function() return Kristal.getTime() * 100 end,
        ["wave_mag"] = function() return self.battle_temp - 1 end,
        ["wave_height"] = function() return self.battle_temp - 1 end,
        ["texsize"] = {SCREEN_WIDTH, SCREEN_HEIGHT}
    }, true, 10)

    --Game.battle:addFX(self.wave_fx, "wave_fx")
end

function Dummy:update()
    Game.battle.music:setPitch(1 + (math.sin(Kristal.getTime() * 4) / 4))
end

return Dummy