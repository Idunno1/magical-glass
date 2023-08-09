local LightAttackBox, super = Class(Object)

function LightAttackBox:init(x, y)
    super.init(self, x, y)

    self.target_sprite = Sprite("ui/lightbattle/dumbtarget")
    self.target_sprite:setOrigin(0.5, 0.5)
    self:addChild(self.target_sprite)

    -- called "fatal" for some reason in ut
    self.bolt_target = self.target_sprite.x

    self.attackers = Game.battle.normal_attackers -- deep copying crashes
    self.lanes = {}

    for i,battler in ipairs(self.attackers) do
        local lane = {}
        lane.battler = battler
        lane.bolts = {}
        lane.weapon = battler.chara:getWeapon()
        lane.speed = lane.weapon:getAttackSpeed()
        lane.attacked = false
        lane.score = 0
        lane.stretch = nil
        lane.direction = lane.weapon:getAttackDirection()

        if lane.weapon:getAttackBolts() > 1 then
            lane.attack_type = "shoe"
        else
            lane.attack_type = "slice"
        end

        local start_x
        if lane.direction == "left" then
            start_x = (self.target_sprite.x + self.target_sprite.width / 2) - lane.weapon:getAttackStart()
        elseif lane.direction == "right" then
            start_x = (self.target_sprite.x - self.target_sprite.width / 2) + lane.weapon:getAttackStart()
        else
            error("Invalid attack direction")
        end

        for i = 1, lane.weapon:getAttackBolts() do
            local bolt
            if i == 1 then
                bolt = LightAttackBar(start_x, 0, battler)
            else
                if lane.direction == "left" then
                    bolt = LightAttackBar(start_x + lane.weapon:getMultiboltVariance(i - 1), 0, battler)
                else
                    bolt = LightAttackBar(start_x - lane.weapon:getMultiboltVariance(i - 1), 0, battler)
                end
            end
            bolt.layer = 1
            table.insert(lane.bolts, bolt)
            self:addChild(bolt)
        end
        table.insert(self.lanes, lane)
    end
    self.done = nil
end

function LightAttackBox:getClose(battler)
    if battler.attack_type == "shoe" then
        return math.abs(math.floor(battler.bolts[1].x / battler.speed) - math.floor(self.bolt_target / battler.speed))
    elseif battler.attack_type == "slice" then
        return Utils.round(battler.bolts[1].x - self.bolt_target)
    end
end

function LightAttackBox:evaluateHit(battler, close)
    if close < 1 then
        return 110
    elseif close < 2 then
        return 90
    elseif close < 3 then
        return 80
    elseif close < 4 then
        return 70
    elseif close < 5 then
        return 50
    elseif close < 10 then
        return 40
    elseif close < 16 then
        return 20
    elseif close < 22 then
        return 15
    elseif close < 28 then -- moves the bolt onto the target
        return 10
    end
end

function LightAttackBox:evaluateScore(battler, score, bolts, close)
    local new_score = score
    if score > 430 then
        new_score = new_score * 1.8
    elseif score >= 400 then
        new_score = new_score * 1.25
    end
    return new_score
end

function LightAttackBox:checkAttackEnd(battler, score, bolts, close)
    if #bolts == 0 then
        battler.attacked = true
        return self:evaluateScore(battler, score, bolts, close)
    end
end

function LightAttackBox:hit(battler)
    local bolt = battler.bolts[1]
    if battler.attack_type == "shoe" then
        local close = self:getClose(battler)

        battler.score = battler.score + self:evaluateHit(battler, close)
        bolt:burst()

        if close < 1 then
            Assets.stopAndPlaySound("victor")
        elseif close < 5 then
            Assets.stopAndPlaySound("hit")
            bolt.sprite:setColor(128/255, 1, 1)
        elseif close < 28 then
            bolt.sprite:setColor(192/255, 0, 0)
        end

        table.remove(battler.bolts, 1)

        return self:checkAttackEnd(battler, battler.score, battler.bolts, close), 2
    elseif battler.attack_type == "slice" then
        battler.score = math.abs(self:getClose(battler))
        if battler.score == 0 then
            battler.score = 1
        end

        battler.stretch = (self.target_sprite.width - battler.score) / self.target_sprite.width

        bolt:flash()
        battler.attacked = true
        bolt.layer = 1
        bolt:setPosition(bolt:getRelativePos(0, 0, self.parent))
        bolt:setParent(self.parent)
    
        return battler.score, battler.stretch
    end
end

function LightAttackBox:checkMiss(battler)
    if battler.attack_type == "shoe" then
        return (battler.direction == "left" and self:getClose(battler) <= -29) or (battler.direction == "right" and self:getClose(battler) >= 29)
    elseif battler.attack_type == "slice" then
        return (battler.direction == "left" and self:getClose(battler) <= -296 + 14) or (battler.direction == "right" and self:getClose(battler) >= 296)
    end
end

function LightAttackBox:miss(battler)
    battler.bolts[1]:remove()
    table.remove(battler.bolts, 1)

    return self:checkAttackEnd(battler, battler.score, battler.bolts)
end

function LightAttackBox:update()

    self.done = true

    for _,battler in ipairs(self.lanes) do
        if not battler.attacked then
            self.done = false
        end
    end

    if not self.done then
        for _,lane in ipairs(self.lanes) do
            if lane.direction == "right" then
                for _,bolt in ipairs(lane.bolts) do
                    bolt:move(lane.speed * DTMULT, 0)
                end
            elseif lane.direction == "left" then
                for _,bolt in ipairs(lane.bolts) do
                    bolt:move(-lane.speed * DTMULT, 0)
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

        local offset = 0
        for _,battler in ipairs(self.lanes) do
            Draw.setColor(1, 1, 1, 1)
            if not battler.attacked then
                Game.battle:debugPrintOutline("close: "    .. self:getClose(battler),         0, -200)
            end
            if battler.score then
                Game.battle:debugPrintOutline("score: "    .. battler.score,           0, -200 + 16)
            end
            if battler.stretch then
                Game.battle:debugPrintOutline("stretch: "  .. battler.stretch,         0, -200 + 32)
            end
            Game.battle:debugPrintOutline("attacked: "     .. tostring(battler.attacked), 0, -200 + 48)
        end

        love.graphics.rectangle("line", self.bolt_target, -100, 1, 65)
    end

    super.draw(self)
end

return LightAttackBox