---@class LightDamageNumber : Object
---@overload fun(...) : LightDamageNumber
local LightDamageNumber, super = Class(Object)

-- Types: "mercy", "damage", "msg"
-- Arg:
--    "mercy"/"damage": amount
--    "msg": message sprite name ("down", "frozen", "lost", "max", "mercy", "miss", "recruit", and "up")

function LightDamageNumber:init(type, arg, x, y, color, bounce)
    super.init(self, x, y)

    self:setOrigin(1, 0)

    self.color = color or {1, 0, 0}

    self.bounce = bounce or true

    -- Halfway between UI and the layer above it
    self.layer = BATTLE_LAYERS["damage_numbers"]

    self.type = type or "msg"
    if self.type == "msg" then
        self.message = arg or "miss"
    else
        self.font = Assets.getFont("lwdmg")
        self.amount = arg or 0
        if self.type == "mercy" then
            if self.amount == 100 then
                self.color = {0, 1, 0}
            else
                self.color = COLORS["yellow"]
            end
            self.text = "+"..self.amount.."%"
        elseif self.type == "miss" then
            --self.color = {1, 1, 1}
        else
            self.text = tostring(self.amount)
        end
    end

    if self.message then
        self.texture = Assets.getTexture("ui/lightbattle/msg/"..self.message)
        self.width = self.texture:getWidth()
        self.height = self.texture:getHeight()
    elseif self.text then
        self.width = self.font:getWidth(self.text)
        self.height = self.font:getHeight()
    end

    self.timer = 0
    self.delay = 2

    self.start_x = nil
    self.start_y = nil

    if self.bounce then
        self.physics.speed_y = -4
        self.physics.gravity = 0.5
        self.physics.gravity_direction = math.rad(90)
    end

    self.kill_timer = 0

    self.do_once = false

    self.kill_others = false
end

function LightDamageNumber:onAdd(parent)
    for _,v in ipairs(parent.children) do
        if isClass(v) and v:includes(LightDamageNumber) then
            if self.kill_others then
                if (v.timer >= 1) then
                    v.killing = true
                end
            else
                v.kill_timer = 0
            end
        end
    end
    self.killing = false
end

function LightDamageNumber:update()
    if not self.start_x then
        self.start_x = self.x
        self.start_y = self.y
    end

    super.update(self)

    self.timer = self.timer + DTMULT

    if (self.timer >= self.delay) and (not self.do_once) then
        self.do_once = true
        self.physics.speed_y = (-5 - (love.math.random() * 2))
        self.start_speed_y = self.physics.speed_y
    end

    if self.timer >= self.delay then
        self.physics.speed_x = Utils.approach(self.physics.speed_x, 0, DTMULT)

        if self.y > self.start_y then
            self.y = self.start_y

            self.physics.speed_y = self.start_speed_y / 2
        end

        if self.y == self.start_y then
            self.physics.speed_y = 0
            self.y = self.start_y
        end

        self.kill_timer = self.kill_timer + DTMULT
        if self.kill_timer > 35 then
            self:remove()
            return
        end

    end

    if Game.state == "BATTLE" then
        if self.x >= 600 then
            self.x = 600
        end
    end
end

function LightDamageNumber:draw()
    if self.timer >= self.delay then
        local r, g, b, a = self:getDrawColor()
        Draw.setColor(r, g, b, a)

        if self.texture then
            Draw.draw(self.texture, 30, 0)
        elseif self.text then
            love.graphics.setFont(self.font)
            love.graphics.print(self.text, 30, 0)
        end
    end

    -- need to pass in gauge max
--[[     if true and arg > 0 then -- if the enemy shows their health bar
        Draw.setColor(COLORS["black"])
        love.graphics.rectangle("fill", self.x - 1, self.y + 7, self.x + Utils.round())
    end ]]

    super.draw(self)
end

return LightDamageNumber