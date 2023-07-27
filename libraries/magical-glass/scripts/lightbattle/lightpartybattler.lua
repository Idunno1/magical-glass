local LightPartyBattler, super = Class(Battler)

function LightPartyBattler:init(chara, x, y)
    self.chara = chara
    self.actor = chara:getActor()

    super.init(self, x, y, self.actor:getSize())
    
    -- not exactly sure how this is gonna work yet
--[[     if self.actor then
        self:setActor(self.actor, true)
    end

    self:setAnimation("battle/idle") ]]

    self.action = nil

    self.defending = false
    self.hurting = false

    self.is_down = false
    self.sleeping = false

    self.targeted = false
end

function LightPartyBattler:canTarget()
    return (not self.is_down)
end

function LightPartyBattler:calculateDamage(amount, min, cap)
    local def = self.chara:getStat("defense")
    local max_hp = self.chara:getStat("health")

    -- good shit toby
    if max_hp > 20 then
        amount = amount + 1
    elseif max_hp >= 30 then
        amount = amount + 1
    elseif max_hp >= 40 then
        amount = amount + 1
    elseif max_hp >= 50 then
        amount = amount + 1
    elseif max_hp >= 60 then
        amount = amount + 1
    elseif max_hp >= 70 then
        amount = amount + 1
    elseif max_hp >= 80 then
        amount = amount + 1
    elseif max_hp >= 90 then
        amount = amount + 1
    end

    amount = Utils.round((amount - def) / 5)

    if min and amount < min then
        amount = min
    end

    if cap and amount > cap then
        amount = cap
    end

    return math.max(amount, 1)
end

function LightPartyBattler:calculateDamageSimple(amount)
    return math.ceil(amount - (self.chara:getStat("defense")))
end

function LightPartyBattler:getElementReduction(element)
    -- TODO: this

    if (element == 0) then return 1 end

    -- dummy values since we don't have elements
    local armor_elements = {
        {element = 0, element_reduce_amount = 0},
        {element = 0, element_reduce_amount = 0}
    }

    local reduction = 1
    for i = 1, 2 do
        local item = armor_elements[i]
        if (item.element ~= 0) then
            if (item.element == element)                              then reduction = reduction - item.element_reduce_amount end
            if (item.element == 9 and (element == 2 or element == 8)) then reduction = reduction - item.element_reduce_amount end
            if (item.element == 10)                                   then reduction = reduction - item.element_reduce_amount end
        end
    end
    return math.max(0.25, reduction)
end

function LightPartyBattler:hurt(amount, exact, color, options)
    options = options or {}

    if not options["all"] then
        Assets.playSound("hurt")
        if not exact then
            amount = self:calculateDamage(amount)
            if self.defending then
                amount = math.ceil((2 * amount) / 3)
            end
            -- we don't have elements right now
            local element = 0
            amount = math.ceil((amount * self:getElementReduction(element)))
        end

        self:removeHealth(amount)
    else
        -- We're targeting everyone.
        if not exact then
            amount = self:calculateDamage(amount)
            -- we don't have elements right now
            local element = 0
            amount = math.ceil((amount * self:getElementReduction(element)))

            if self.defending then
                amount = math.ceil((3 * amount) / 4) -- Slightly different than the above
            end

            self:removeHealthBroken(amount) -- Use a separate function for cleanliness
        end
    end

    -- delt of traveler
--[[     if (self.chara:getHealth() <= 0) then
        self:statusMessage("msg", "down", color, true)
    else
        self:statusMessage("damage", amount, color, true)
    end ]]

    Game.battle:shakeCamera(2)

    if (not self.defending) and (not self.is_down) then
        self.sleeping = false
        self.hurting = true
        Game.battle.timer:after(1, function()
            self.hurting = false
        end)
    end
end

function LightPartyBattler:removeHealth(amount)
    if (self.chara:getHealth() <= 0) then
        amount = Utils.round(amount / 4)
        self.chara:setHealth(self.chara:getHealth() - amount)
    else
        self.chara:setHealth(self.chara:getHealth() - amount)
        if (self.chara:getHealth() <= 0) then
            amount = math.abs((self.chara:getHealth() - (self.chara:getStat("health") / 2)))
            self.chara:setHealth(Utils.round(((-self.chara:getStat("health")) / 2)))
        end
    end
    self:checkHealth()
end

function LightPartyBattler:removeHealthBroken(amount)
    self.chara:setHealth(self.chara:getHealth() - amount)
    if (self.chara:getHealth() <= 0) then
        -- BUG: Use Kris' max health...
        self.chara:setHealth(Utils.round(((-Game.party[1]:getStat("health")) / 2)))
    end
    self:checkHealth()
end

function LightPartyBattler:down()
    self.is_down = true
    self.sleeping = false
    --self:toggleOverlay(true)
    --self.overlay_sprite:setAnimation("battle/defeat")
    if self.action then
        Game.battle:removeAction(Game.battle:getPartyIndex(self.chara.id))
    end
    Game.battle:checkGameOver()
end

function LightPartyBattler:setSleeping(sleeping)
    if self.sleeping == (sleeping or false) then return end

    if sleeping then
        if self.is_down then return end
        self.sleeping = true
        self:toggleOverlay(true)
        if not self.overlay_sprite:setAnimation("battle/sleep") then
            self.overlay_sprite:setAnimation("battle/defeat")
        end
        if self.action then
            Game.battle:removeAction(Game.battle:getPartyIndex(self.chara.id))
        end
    else
        self.sleeping = false
        self:toggleOverlay(false)
    end
end

function LightPartyBattler:revive()
    self.is_down = false
    self:toggleOverlay(false)
end

--[[ function LightPartyBattler:flash(sprite, offset_x, offset_y, layer)
    super.flash(self, sprite or self.overlay_sprite.visible and self.overlay_sprite or self.sprite, offset_x, offset_y, layer)
end ]]

function LightPartyBattler:heal(amount, show_up, sound)
    if sound then
        Assets.stopAndPlaySound("power")
    end

    amount = math.floor(amount)

    self.chara:setHealth(self.chara:getHealth() + amount)

    local was_down = self.is_down
    self:checkHealth()

    if self.chara:getHealth() >= self.chara:getStat("health") then
        self.chara:setHealth(self.chara:getStat("health"))
        --self:statusMessage("msg", "max")
--[[     else
        if show_up then
            if was_down ~= self.is_down then
                self:statusMessage("msg", "up")
            end
        else
            self:statusMessage("heal", amount, {0, 1, 0})
        end ]]
    end

    --self:sparkle(unpack(sparkle_color or {}))
end

function LightPartyBattler:checkHealth()
    if (not self.is_down) and self.chara:getHealth() <= 0 then
        self:down()
    elseif (self.is_down) and self.chara:getHealth() > 0 then
        self:revive()
    end
end

function LightPartyBattler:statusMessage(...)
    local message = super.statusMessage(self, 0, self.height/2, ...)
    message.y = message.y - 4
    return message
end

function LightPartyBattler:recruitMessage(...)
    return super.recruitMessage(self, ...)
end

function LightPartyBattler:isActive()
    return not self.is_down and not self.sleeping
end

function LightPartyBattler:isTargeted()
    return self.targeted
end

function LightPartyBattler:getHeadIcon()
    if self.sleeping then
        return "sleep"
    elseif self.defending then
        return "defend"
    elseif self.action and self.action.icon then
        return self.action.icon
    elseif self.hurting then
        return "head_hurt"
    else
        return "head"
    end
end

function LightPartyBattler:resetSprite()
    self:setAnimation("battle/idle")
end

--[[ function LightPartyBattler:setActSprite(sprite, ox, oy, speed, loop, after)

    self:setCustomSprite(sprite, ox, oy, speed, loop, after)

    local x = self.x - (self.actor:getWidth()/2 - ox) * 2
    local y = self.y - (self.actor:getHeight() - oy) * 2
    local flash = FlashFade(sprite, x, y)
    flash:setOrigin(0, 0)
    flash:setScale(self:getScale())
    self.parent:addChild(flash)

    local afterimage1 = AfterImage(self, 0.5)
    local afterimage2 = AfterImage(self, 0.6)
    afterimage1.physics.speed_x = 2.5
    afterimage2.physics.speed_x = 5

    afterimage2.layer = afterimage1.layer - 1

    self:addChild(afterimage1)
    self:addChild(afterimage2)
end ]]

--[[ function LightPartyBattler:setSprite(sprite, speed, loop, after)
    self.sprite:setSprite(sprite)
    if not self.sprite.directional and speed then
        self.sprite:play(speed, loop, after)
    end
end ]]

function LightPartyBattler:update()
    if self.actor then
        self.actor:onBattleUpdate(self)
    end

    if self.chara:getWeapon() then
        self.chara:getWeapon():onBattleUpdate(self)
    end
    for i = 1, 2 do
        if self.chara:getArmor(i) then
            self.chara:getArmor(i):onBattleUpdate(self)
        end
    end

--[[     self.target_sprite.visible = false
    if self:isTargeted() then
        if (Game:getConfig("targetSystem")) and (Game.battle.state == "ENEMYDIALOGUE") then
            self.target_sprite.visible = true
        end
    elseif self.should_darken then
        if (self.darken_timer < 15) then
            self.darken_timer = self.darken_timer + DTMULT
        end
    else
        if not self.should_darken then
            if self.darken_timer > 0 then
                self.darken_timer = self.darken_timer - (3 * DTMULT)
            end
        end
    end ]]

    super.update(self)
end

function LightPartyBattler:draw()
    super.draw(self)
--[[     if self.actor then
        self.actor:onBattleDraw(self)
    end ]]
end

return LightPartyBattler