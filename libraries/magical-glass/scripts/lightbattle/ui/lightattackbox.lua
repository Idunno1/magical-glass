local LightAttackBox, super = Class(Object)

LightAttackBox.BOLTSPEED = 8

function LightAttackBox:init(x, y)
    super.init(self, x, y)

    self.party = Game.party

    self.target_sprite = Sprite("ui/lightbattle/dumbtarget")
    self.target_sprite:setOrigin(0.5, 0.5)
    self:addChild(self.target_sprite)

    -- called "fatal" for some reason in ut
    self.bolt_target = 274
    self.bolt_miss_threshold = 20

    self.bolt_direction = Utils.pick("left", "right")
    if self.bolt_direction == "left" then
        self.bolt_start_x = -16
    else
        self.bolt_start_x = 570
    end

    self.lanes = {}

    self.bolts = {}
    self.score = 0

    local offset = 0
--[[     for i = 1, #Game.battle.attackers do
        local lane
        for i = 1, 1, do
        local bolt

        bolt = LightAttackBar(self.bolt_start_x, offset)
        bolt.sprite.height = bolt.sprite.height / #self.party
        bolt.layer = 1
        self:addChild(bolt)
        table.insert(self.bolts, bolt)
        end
        offset = offset + 30
    end ]]

    self.done = false
end 

function LightAttackBox:getClose()
    return Utils.round((self.bolt.x - self.bolt_target) / LightAttackBox.BOLTSPEED)
end

function LightAttackBox:update()
    if Game.battle.cancel_attack then
        self.scale_y = (self.scale_y - 0.08) * DTMULT
        self:fadeOutSpeedAndRemove(1) -- needs scale shit
    end

    if not self.done then
        for _,bolt in ipairs(self.bolts) do
            if self.bolt_direction == "left" then
                bolt:move(-LightActionBox.BOLTSPEED * DTMULT, 0)
            else
                bolt:move(LightActionBox.BOLTSPEED * DTMULT, 0)
            end
        end
    end

    super.update(self)
end

return LightActionBox