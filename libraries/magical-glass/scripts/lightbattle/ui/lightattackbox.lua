local LightAttackBox, super = Class(Object)

LightAttackBox.BOLTSPEED = 11

function LightAttackBox:init(x, y)
    super.init(self, x, y)

    self.target_sprite = Sprite("ui/lightbattle/dumbtarget")
    self.target_sprite:setOrigin(0.5, 0.5)
    self:addChild(self.target_sprite)

    -- called "fatal" for some reason in ut
    self.bolt_target = self.target_sprite.x

    self.attackers = Game.battle.attackers


    for _,battler in ipairs(self.attackers) do
        battler.bolts = {}
        battler.weapon = battler.chara:getWeapon()
        battler.speed = battler.weapon:getAttackSpeed()
        battler.attacked = false
        battler.score = 0
        battler.direction = battler.weapon:getAttackDirection()

        local start_x
        if battler.direction == "left" then
            start_x = (self.target_sprite.x + self.target_sprite.width / 2) - battler.weapon:getAttackStart()
        elseif battler.direction == "right" then
            start_x = (self.target_sprite.x - self.target_sprite.width / 2) + battler.weapon:getAttackStart()
        else
            error("Invalid attack direction")
        end

        for i = 1, battler.weapon:getAttackBolts() do
            local bolt
            if i == 1 then
                bolt = LightAttackBar(start_x, 0, battler)
            else
                if battler.direction == "left" then
                    bolt = LightAttackBar(start_x + battler.weapon:getMultiboltVariance(i - 1), 0, battler)
                else
                    bolt = LightAttackBar(start_x - battler.weapon:getMultiboltVariance(i - 1), 0, battler)
                end
            end
            bolt.layer = 1
            table.insert(battler.bolts, bolt)
            self:addChild(bolt)
        end
    end

--[[     self.bolt = LightAttackBar(self.bolt_start_x, -65, self.battler)
    self:addChild(self.bolt) ]]

    self.bonus = nil
    self.stretch = nil

    self.attacked = false

    self.done = false
end 

function LightAttackBox:getClose()
    return Utils.round(self.attackers[1].bolts[1].x - self.bolt_target)
end

function LightAttackBox:checkMiss()
    return (self.direction == "left" and self:getClose() <= -296 + 14) or (self.direction == "right" and self:getClose() >= 296)
end

function LightAttackBox:hit()
    for _,battler in ipairs(self.attackers) do
        local bolt = battler.bolts[1]
        if battler.chara:getWeapon():getAttackBolts() > 1 then
            bolt:burst()
            table.remove(battler.bolts, 1)

            return self.bonus, self.stretch
        else
            self.bonus = math.abs(self:getClose())
            if self.bonus == 0 then
                self.bonus = 1
            end

            self.stretch = (self.target_sprite.width - self.bonus) / self.target_sprite.width

            bolt:flash()
            battler.attacked = true
            bolt.layer = 1
            bolt:setPosition(bolt:getRelativePos(0, 0, self.parent))
            bolt:setParent(self.parent)
        
            return battler.points, self.stretch
        end
    end
end

function LightAttackBox:miss()
    self.attackers[1].bolts[1]:remove()
    self.attacked = true
end

function LightAttackBox:update()

    self.done = true

    for _,battler in ipairs(self.attackers) do
        if not battler.attacked then
            self.done = false
        end
    end

    if not self.done then
        for _,battler in ipairs(self.attackers) do
            if battler.direction == "right" then
                for _,bolt in ipairs(battler.bolts) do
                    bolt:move(battler.speed * DTMULT, 0)
                end
            elseif battler.direction == "left" then
                for _,bolt in ipairs(battler.bolts) do
                    bolt:move(-battler.speed * DTMULT, 0)
                end
            end
        end
    end

    if self.fading or Game.battle.cancel_attack then
        self.target_sprite.x = self.target_sprite.x - 15.8 * DTMULT -- yes, this is off-center
        self.target_sprite.scale_x = self.target_sprite.scale_x - 0.06 * DTMULT
        self.target_sprite.alpha = self.target_sprite.alpha - 0.08 * DTMULT
        if self.target_sprite.scale_x < 0.08 then
            self:remove()
        end
    end

    super.update(self)
end

function LightAttackBox:draw()

    if DEBUG_RENDER then
        local font = Assets.getFont("main", 16)
        love.graphics.setFont(font)

        Draw.setColor(1, 1, 1, 1)
        Game.battle:debugPrintOutline("close: "    .. self:getClose(),                  0, -200)
        if self.bonus and self.stretch then
            Game.battle:debugPrintOutline("bonus: "    .. self.bonus,                  0, -200 + 16)
            Game.battle:debugPrintOutline("stretch: "    .. self.stretch,                       0, -200 + 32)
        end
        Game.battle:debugPrintOutline("attacked: " .. tostring(self.attacked),          0, -200 + 48)

        love.graphics.rectangle("line", self.bolt_target, -100, 1, 65)
    end

    super.draw(self)
end

return LightAttackBox