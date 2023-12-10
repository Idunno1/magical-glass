local DTAttackBox, super = Class(Object)

function DTAttackBox:init(x, y)
    super.init(self, x, y)

    self.arena = Game.battle.arena

    self.target_sprite = Sprite("ui/lightbattle/dumbtarget_multi")
    self.target_sprite:setOrigin(0.5, 0.5)
    self.target_sprite:setPosition(self.arena:getRelativePos((self.arena.width / 2) - 10, self.arena.height / 2))
    self.target_sprite.layer = BATTLE_LAYERS["above_ui"]
    Game.battle:addChild(self.target_sprite)

    -- called "fatal" for some reason in ut
    self.bolt_target = 136

    self.attackers = Game.battle.normal_attackers
    self.lanes = {}

    self.timer = 0

    self.done = nil

    self.fading = false
end

function DTAttackBox:createBolts()
    for i,battler in ipairs(self.attackers) do
        local lane = {}
        lane.battler = battler
        --lane.mini = battler.mini
        lane.bolts = {}
        lane.weapon = battler.chara:getWeapon()
        lane.speed = lane.weapon.getBoltSpeed and lane.weapon:getBoltSpeed() or 8
        lane.attacked = false
        lane.score = 0
        lane.stretch = nil

        if (lane.weapon.getBoltCount and lane.weapon:getBoltCount() or 1) > 1 then
            lane.attack_type = "shoe"
        else
            lane.attack_type = "slice"
        end

        local fuck = {0, 40, 80, 120}
        if self.attackers == 1 then
            table.remove(fuck, 3)
            table.remove(fuck, 4)
        end
        local start_x = self.bolt_target + (370 + Utils.pick(fuck))

        for j = 1, lane.weapon.getBoltCount and lane.weapon:getBoltCount() or 1 do
            local bolt
            local scale_y = (1 / #Game.battle.party)
            if j == 1 then
                bolt = DTAttackBar(start_x + (lane.weapon.getBoltStart and lane.weapon:getBoltStart() or -16), 310, battler, scale_y)
            else
                bolt = DTAttackBar(start_x + (lane.weapon.getMultiboltVariance and lane.weapon:getMultiboltVariance(j - 1) or (50 * j)), 310, battler, scale_y)
            end
            bolt.y = math.ceil(bolt.y + (bolt.sprite.height * scale_y * (Game.battle:getPartyIndex(lane.battler.chara.id) - 1)))
            bolt.layer = BATTLE_LAYERS["above_ui"]
            table.insert(lane.bolts, bolt)
            Game.battle:addChild(bolt)
        end
        table.insert(self.lanes, lane)
    end
end

function DTAttackBox:getClose(battler)
    return Utils.round(battler.bolts[1].x - self.bolt_target)
end

function DTAttackBox:checkAttackEnd(battler, score, bolts, close)
    if #bolts == 0 then
        if battler.attack_type == "shoe" then
            self.fading = true
        end
        battler.attacked = true
        return battler.score
    end
end

function DTAttackBox:hit(battler)
    local bolt = battler.bolts[1]
    if battler.weapon.onBoltHit then
        battler.weapon:onBoltHit(battler)
    end
    if battler.attack_type == "shoe" then
        local close = math.abs(self:getClose(battler))

        local eval = self:evaluateHit(battler, close)
        
        if battler.weapon.scoreHit then
            battler.score = battler.weapon:scoreHit(battler, battler.score, eval, close)
        else
            battler.score = battler.score + eval

            if battler.score > 430 then
                battler.score = battler.score * 1.8
            end
            if battler.score >= 400 then
                battler.score = battler.score * 1.25
            end
        end

        bolt:burst()

        if close < 1 then
            bolt.x = self.bolt_target
            Assets.stopAndPlaySound("victor")
            bolt.perfect = true
        elseif close < 5 then
            Assets.stopAndPlaySound("hit")
            bolt.sprite:setColor(128/255, 1, 1)
        elseif close < 28 then
            bolt.sprite:setColor(192/255, 0, 0)
        else
            bolt.sprite:setColor(192/255, 0, 0)
        end

        table.remove(battler.bolts, 1)
        if #battler.bolts > 0 then
            battler.bolts[1].sprite:setSprite(bolt.active_sprite)
        end

        return self:checkAttackEnd(battler, battler.score, battler.bolts, close)
    elseif battler.attack_type == "slice" then
        local score = self:getClose(battler)

        if score < 10 and score > -10 then
            battler.bolts[1].x = self.bolt_target + 5
        end

        battler.score = self:evaluateHit(battler, score)

        bolt:burst()
        battler.attacked = true

        table.remove(battler.bolts, 1)
    
        return battler.score
    end
end

function DTAttackBox:evaluateHit(battler, close)
    print(close)
    if close < -10 then
        return close/4
    elseif close < 10 then
        print("perfect")
        return 20
    else
        return close/4
    end
end

function DTAttackBox:update()

    self.timer = self.timer + DTMULT

    if self.timer > 6 and #self.lanes == 0 then
        self:createBolts()
    end
    
    if #self.lanes ~= 0 then

        self.done = true

        for _,battler in ipairs(self.lanes) do
            if not battler.attacked then
                self.done = false
            end
        end

        if not self.done then
            for _,lane in ipairs(self.lanes) do
                for _,bolt in ipairs(lane.bolts) do
                    bolt:move(-lane.speed * DTMULT, 0)
                end
            end
        end

        if Game.battle.cancel_attack or self.fading then
            self.target_sprite.scale_x = self.target_sprite.scale_x - 0.06 * DTMULT
            self.target_sprite.alpha = self.target_sprite.alpha - 0.08 * DTMULT
            if self.target_sprite.scale_x < 0.08 or self.target_sprite.alpha < 0.08 then
                Game.battle.timer:after(1, function()
                    self:remove()
                end)
            end
        end
    end

    super.update(self)
end

function DTAttackBox:checkMiss(battler)
    if battler.attack_type == "shoe" then
        return self:getClose(battler) < -(battler.weapon.getAttackMissZone and battler.weapon:getAttackMissZone() or 2)
    elseif battler.attack_type == "slice" then
        return self:getClose(battler) <= -105
    end
end

function DTAttackBox:miss(battler)
    if battler.attack_type == "shoe" then
        battler.bolts[1]:fade(battler.speed, battler.direction)

        if #battler.bolts > 1 then
            battler.bolts[2].sprite:setSprite(battler.bolts[2].active_sprite)
        end
    else
        battler.bolts[1]:remove()
    end
    table.remove(battler.bolts, 1)
    return self:checkAttackEnd(battler, battler.score, battler.bolts)
end

function DTAttackBox:draw()
    super.draw(self)

    if DEBUG_RENDER then
        Draw.setColor(1, 0, 0, 1)
        love.graphics.setLineWidth(3)
        love.graphics.rectangle("line", self.bolt_target, 270, 10, 60)
    end

end

return DTAttackBox