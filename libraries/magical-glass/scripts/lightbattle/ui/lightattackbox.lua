local LightAttackBox, super = Class(Object)

LightAttackBox.BOLTSPEED = 11

function LightAttackBox:init(x, y)
    super.init(self, x, y)

    self.battler = Game.battle.party[1]

    self.arena = Game.battle.arena

    self.attackers = Game.battle.attackers

    self.target_sprite = Sprite("ui/lightbattle/dumbtarget")
    self.target_sprite:setOrigin(0.5, 0.5)
    self:addChild(self.target_sprite)

    -- called "fatal" for some reason in ut
    self.bolt_target = self.target_sprite.x
    self.bolt_miss_threshold = 20

--[[     self.bolt_direction = Utils.pick{1, -1}
    if self.bolt_direction == 1 then
        self.bolt_start_x = -16
    else
        self.bolt_start_x = 570
    end ]]

    self.bolt_start_x = (self.target_sprite.x - self.target_sprite.width / 2) - 12

--[[     self.bolts = {}
    self.lanes = {}
    local offset = 0

    for _,battler in ipairs(self.attackers) do
        for i = 1, 1 do
            local bolt = LightAttackBar(self.bolt_start_x, -65, battler)
            bolt.layer = 1
            table.insert(self.bolts, bolt)
            self:addChild(bolt)
            offset = offset + 30
        end
    end ]]

    self.bolt = LightAttackBar(self.bolt_start_x, -65, self.battler)
    self.bolt.layer = 1
    self:addChild(self.bolt)

    self.bonus = nil
    self.stretch = nil

    self.attacked = false

    self.done = false
end 

function LightAttackBox:getClose()
    return math.abs(Utils.round(self.bolt.x - self.bolt_target))
end

function LightAttackBox:hit()
    self.bonus = self:getClose()
    if self.bonus == 0 then
        self.bonus = 1
    end

    self.stretch = (self.target_sprite.width - self.bonus) / self.target_sprite.width

    self.attacked = true

    self.bolt:flash()
    self.done = true
    self.bolt.layer = 1
    self.bolt:setPosition(self.bolt:getRelativePos(0, 0, self.parent))
    self.bolt:setParent(self.parent)

    return self.bonus, self.stretch
end

function LightAttackBox:miss()
    self.bolt:remove()
    self.attacked = true
end

function LightAttackBox:update()

    if not self.done then
        self.bolt:move(LightAttackBox.BOLTSPEED * DTMULT, 0)
    end
    
    if Game.battle.cancel_attack then
        self.bolt:remove()
        self.target_sprite.scale_x = self.target_sprite.scale_x - 0.06 * DTMULT
        self.target_sprite.alpha = self.target_sprite.alpha - 0.08 * DTMULT
        if self.target_sprite.scale_x < 0.08 then
            self:remove()
        end
    end

    if self.fading then
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