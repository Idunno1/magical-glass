local LightEnemyBattler, super = Class(Battler)

function LightEnemyBattler:init(actor, use_overlay)
    super.init(self)
    self.name = "Test Enemy"

    if actor then
        self:setActor(actor, use_overlay)
    end

    self.max_health = 100
    self.health = 100
    self.attack = 1
    self.defense = 0

    self.money = 0
    self.experience = 0

    self.tired = false
    self.mercy = 0

    self.spare_points = 0

    -- Whether the enemy runs/slides away when defeated/spared
    self.exit_on_defeat = true

    self.exit_direction = nil

    -- Whether this enemy is automatically spared at full mercy
    self.auto_spare = false

    -- Whether this enemy can be frozen
    self.can_freeze = false

    -- Whether this enemy can be selected or not
    self.selectable = true

    -- Whether mercy is disabled for this enemy, like snowgrave Spamton NEO.
    -- This only affects the visual mercy bar.
    self.disable_mercy = false

    self.done_state = nil

    self.waves = {}
    self.menu_waves = {}

    self.check = "Wake up and taste the [color:red]\npain"

    self.text = {}

    self.low_health_text = nil
    self.tired_text = nil
    self.spareable_text = nil

    self.tired_percentage = 0
    self.spare_percentage = 0.2
    self.low_health_percentage = 0.2

    -- Speech bubble style - defaults to "round" or "cyber", depending on chapter
    -- This is set to nil in `battler.lua` as well, but it's here for completion's sake.
    self.dialogue_bubble = "ut_large"

    -- The offset for the speech bubble, also set in `battler.lua`
    self.dialogue_offset = {0, 0}

    -- Whether the speech bubble should be flipped horizontally.
    self.dialogue_right = true

    self.dialogue = {}

    self.acts = {
        {
            ["name"] = "Check",
            ["description"] = "",
            ["party"] = {}
        }
    }

    self.hurt_timer = 0
    self.comment = ""
    self.icons = {}
    self.defeated = false

    self.current_target = "ANY"

    self.gauge_size = 100
    self.damage_offset = {5, -40}

    self.show_hp = true
    self.show_mercy = true
end

function LightEnemyBattler:getMoney()
    return self.money
end

function LightEnemyBattler:toggleOverlay(overlay, reset)
    if overlay == nil then
        overlay = self.sprite.visible
    end
    if reset then
        self.sprite:resetSprite()
        self.overlay_sprite:resetSprite()
    end
    if self.overlay_sprite then
        self.overlay_sprite.visible = overlay
        self.sprite.visible = not overlay
    end
end

function LightEnemyBattler:getGaugeSize()
    if type(self.gauge_size) == "number" then
        return {self.gauge_size, 13}
    elseif type(self.gauge_size) == "table" then
        return self.gauge_size
    end
end
function LightEnemyBattler:getDamageOffset() return self.damage_offset end

function LightEnemyBattler:getHPVisibility() return self.show_hp end
function LightEnemyBattler:getMercyVisibility() return self.show_mercy end

function LightEnemyBattler:getExitDirection()
    return self.exit_direction or Utils.random(-2, 2, 1)
end

function LightEnemyBattler:setTired(bool)
    self.tired = bool
    if self.tired then
        self.comment = "(Tired)"
    else
        self.comment = ""
    end
end

function LightEnemyBattler:removeAct(name)
    for _,act in ipairs(self.acts) do
        if act.name == name then
            act = nil
        end
    end
end

function LightEnemyBattler:registerAct(name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,chara in ipairs(Game.party) do
                table.insert(party, chara.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = nil,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = false,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
    return act
end

function LightEnemyBattler:registerShortAct(name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,battler in ipairs(Game.battle.party) do
                table.insert(party, battler.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = nil,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = true,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
    return act
end

function LightEnemyBattler:registerActFor(char, name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,chara in ipairs(Game.party) do
                table.insert(party, chara.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = char,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = false,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
end
function LightEnemyBattler:registerShortActFor(char, name, description, party, tp, highlight, icons)
    if type(party) == "string" then
        if party == "all" then
            party = {}
            for _,battler in ipairs(Game.battle.party) do
                table.insert(party, battler.id)
            end
        else
            party = {party}
        end
    end
    local act = {
        ["character"] = char,
        ["name"] = name,
        ["description"] = description,
        ["party"] = party,
        ["tp"] = tp or 0,
        ["highlight"] = highlight,
        ["short"] = true,
        ["icons"] = icons
    }
    table.insert(self.acts, act)
end

function LightEnemyBattler:spare(pacify)
    self:toggleOverlay(true)

    if self.exit_on_defeat then
        self.alpha = 0.5
        Game.battle.spare_sound:stop()
        Game.battle.spare_sound:play()

        for i = 0, 15 do
            local x = ((Utils.random((self.width / 2)) + (self.width / 4))) - 8
            local y = ((Utils.random((self.height / 2)) + (self.height / 4))) - 8

            local sx, sy = self:getRelativePos(x, y)

            local dust = SpareDust(sx, sy)
            self.parent:addChild(dust)

            dust.rightside = ((8 + x)) / (self.width / 2)
            dust.topside = ((8 + y)) / (self.height / 2)

            Game.battle.timer:after(1/30, function()
                dust:spread()
            end)

            dust.layer = BATTLE_LAYERS["above_ui"] + 3
        end
    end

    self:defeat(pacify and "PACIFIED" or "SPARED", false)
    self:onSpared()
end

function LightEnemyBattler:getSpareText(battler, success)
    if success then
        return "* " .. battler.chara:getName() .. " spared " .. self.name .. "!"
    else
        local text = "* " .. battler.chara:getName() .. " spared " .. self.name .. "!\n* But its name wasn't [color:yellow]YELLOW[color:reset]..."
        if self.tired then
            local found_spell = nil
            for _,party in ipairs(Game.battle.party) do
                for _,spell in ipairs(party.chara:getSpells()) do
                    if spell:hasTag("spare_tired") then
                        found_spell = spell
                        break
                    end
                end
                if found_spell then
                    text = {text, "* (Try using "..party.chara:getName().."'s [color:blue]"..found_spell:getCastName().."[color:reset]!)"}
                    break
                end
            end
            if not found_spell then
                text = {text, "* (Try using [color:blue]ACTs[color:reset]!)"}
            end
        end
        return text
    end
end

function LightEnemyBattler:canSpare()
    return self.mercy >= 100
end

function LightEnemyBattler:onSpared()
    if self.actor.use_light_battler_sprite then
        if self.actor:getAnimation("lightbattle_spared") then
            self.overlay_sprite:setAnimation("lightbattle_spared")
        else
            self.overlay_sprite:setAnimation("lightbattle_hurt")
        end
    else
        self.overlay_sprite:setAnimation("spared")
    end
end

function LightEnemyBattler:onSpareable() end

function LightEnemyBattler:addMercy(amount)
    
    if self.mercy >= 100 then
        -- We're already at full mercy; who cares
        return
    end
    
    if Kristal.getLibConfig("magical-glass", "mercy_messages") then
        if amount > 0 and self.mercy < 100 then
            local pitch = 0.8
            if amount < 99 then pitch = 1 end
            if amount <= 50 then pitch = 1.2 end
            if amount <= 25 then pitch = 1.4 end

            local src = Assets.playSound("mercyadd", 0.8)
            src:setPitch(pitch)

            self:lightStatusMessage("mercy", amount)
        elseif self.mercy == 0 then
            local message = self:lightStatusMessage("msg", "miss", {192/255, 192/255, 192/255})
            message:resetPhysics()
        end
    end

    self.mercy = self.mercy + amount
    if self.mercy < 0 then
        self.mercy = 0
    end

    if self.mercy >= 100 then
        self.mercy = 100
    end

    if self:canSpare() then
        self:onSpareable()
        if self.auto_spare then
            self:spare(false)
        end
    end

end

function LightEnemyBattler:onMercy(battler)
    if self:canSpare() then
        self:spare()
        return true
    else
        if self.spare_points ~= 0 then
            self:addMercy(self.spare_points)
        end
        return false
    end
end

function LightEnemyBattler:getNameColors()
    local result = {}
    if self:canSpare() and self:getMercyVisibility() then
        table.insert(result, MagicalGlassLib.name_color)
    end
    if self.tired then
        table.insert(result, {0, 0.7, 1})
    end
    return result
end

function LightEnemyBattler:getEncounterText()
    local has_spareable_text = self.spareable_text and self:canSpare()

    local priority_spareable_text = Game:getConfig("prioritySpareableText")
    if priority_spareable_text and has_spareable_text then
        return self.spareable_text
    end

    if self.low_health_text and self.health <= (self.max_health * self.low_health_percentage) then
        return self.low_health_text

    elseif self.tired_text and self.tired then
        return self.tired_text

    elseif has_spareable_text then
        return self.spareable_text
    end

    return Utils.pick(self.text)
end

function LightEnemyBattler:getTarget()
    return Game.battle:randomTarget()
end

function LightEnemyBattler:getEnemyDialogue()
    if self.dialogue_override then
        local dialogue = self.dialogue_override
        self.dialogue_override = nil
        return dialogue
    end
    return Utils.pick(self.dialogue)
end

function LightEnemyBattler:getNextWaves()
    if self.wave_override then
        local wave = self.wave_override
        self.wave_override = nil
        return {wave}
    end
    return self.waves
end

function LightEnemyBattler:getNextMenuWaves()
    if self.menu_wave_override then
        local wave = self.menu_wave_override
        return {wave}
    end
    return self.menu_waves
end

function LightEnemyBattler:selectWave()
    local waves = self:getNextWaves()
    if waves and #waves > 0 then
        local wave = Utils.pick(waves)
        self.selected_wave = wave
        return wave
    end
end

function LightEnemyBattler:selectMenuWave()
    local waves = self:getNextMenuWaves()
    if waves and #waves > 0 then
        local wave = Utils.pick(waves)
        self.selected_menu_wave = wave
        return wave
    end
end

function LightEnemyBattler:onCheck(battler) end
function LightEnemyBattler:onActStart(battler, name) end

function LightEnemyBattler:onAct(battler, name)
    if name == "Check" then
        self:onCheck(battler)
        if type(self.check) == "table" then
            local tbl = {}
            for i,check in ipairs(self.check) do
                if i == 1 then
                    table.insert(tbl, "* " .. string.upper(self.name) .. " - " .. check)
                else
                    table.insert(tbl, "* " .. check)
                end
            end
            return tbl
        else
            return "* " .. string.upper(self.name) .. " - " .. self.check
        end
    end
end

function LightEnemyBattler:onTurnStart() end
function LightEnemyBattler:onTurnEnd() end

function LightEnemyBattler:getAct(name)
    for _,act in ipairs(self.acts) do
        if act.name == name then
            return act
        end
    end
end

function LightEnemyBattler:getXAction(battler)
    return "Standard"
end

function LightEnemyBattler:isXActionShort(battler)
    return false
end

function LightEnemyBattler:hurt(amount, battler, on_defeat, color, anim)
    if amount == 0 then
        local message = self:lightStatusMessage("msg", "miss", color or (battler and {battler.chara:getLightMissColor()}))
        if message and anim == false then
            message:resetPhysics()
        else
            self.hurt_timer = 1
        end

        self:onDodge(battler)
        return
    end

    self:lightStatusMessage("damage", amount, color or (battler and {battler.chara:getLightDamageColor()}))
    self.health = self.health - amount

    if amount > 0 then
        self.hurt_timer = 1
        self:onHurt(amount, battler)
    end

    self:checkHealth(on_defeat, amount, battler)

end

function LightEnemyBattler:onDodge(battler) end

function LightEnemyBattler:checkHealth(on_defeat, amount, battler)
    -- on_defeat is optional
    if self.health <= 0 then
        self.health = 0

        if not self.defeated then
            if on_defeat then
                on_defeat(self, amount, battler)
            else
                self:forceDefeat(amount, battler)
            end
        end
    end
end

function LightEnemyBattler:forceDefeat(amount, battler)
    self:onDefeat(amount, battler)
end

function LightEnemyBattler:getAttackTension(points)
    -- In Deltarune, this is always 10*2.5, except for JEVIL where it's 15*2.5
    return points / 25
end

function LightEnemyBattler:getAttackDamage(damage, lane, points, stretch)

    local crit = false
    local total_damage
    if lane.attack_type == "shoe" then
        if damage > 0 then
            return damage
        end

        total_damage = (lane.battler.chara:getStat("attack", default, true) - self.defense)
        total_damage = total_damage * ((points / 160) * (4 / lane.weapon:getBoltCount()))
        total_damage = Utils.round(total_damage) + Utils.random(0, 2, 1)

        if points > (400 * (lane.weapon:getBoltCount() / 4)) then
            crit = true
        end
    else
        if damage > 0 then
            return damage
        end

        total_damage = (lane.battler.chara:getStat("attack", default, true) - self.defense) + Utils.random(0, 2, 1)
        if points <= 12 then
            total_damage = Utils.round(total_damage * 2.2)
        elseif points > 12 then
            total_damage = Utils.round((total_damage * stretch) * 2)
        end
    end
    
    return total_damage, crit
end

function LightEnemyBattler:getDamageSound() end
function LightEnemyBattler:getDamageVoice() end

function LightEnemyBattler:onHurt(damage, battler)
    self:toggleOverlay(true)
    if self.actor.use_light_battler_sprite then
        if not self:getActiveSprite():setAnimation("lightbattle_hurt") then
            self:toggleOverlay(false)
        end
    else
        if not self:getActiveSprite():setAnimation("hurt") then
            self:toggleOverlay(false)
        end
    end

    self:getActiveSprite():shake(9, 0, 0.5, 2/30) -- not sure if this should be different

    Game.battle.timer:after(1/3, function()
        local sound = self:getDamageVoice()
        if sound and type(sound) == "string" then
            Assets.stopAndPlaySound(sound)
        end
    end)

    if self.health <= (self.max_health * self.tired_percentage) then
        self:setTired(true)
    end

    if self.health <= (self.max_health * self.spare_percentage) then
        self.mercy = 100
    end
end

function LightEnemyBattler:onHurtEnd()
    self:getActiveSprite():stopShake()
    if self.health > 0 then
        self:toggleOverlay(false, true)
    end
end

function LightEnemyBattler:onDefeat(damage, battler)
    self:toggleOverlay(true)
    if self.exit_on_defeat and not self.can_freeze then
        Game.battle.timer:after(self.hurt_timer, function()
            self:onDefeatVaporized(damage, battler)  
            --self:onDefeatRun(damage, battler)
            --self:onDefeatFatal(damage, battler)      
        end)
    else
        self.sprite:setAnimation("defeat")
    end
end

function LightEnemyBattler:onDefeatRun(damage, battler)
    self.hurt_timer = -1
    self.defeated = true

    Assets.playSound("defeatrun")

    local sweat = Sprite("effects/defeat/sweat")
    sweat:setOrigin(0.5, 0.5)
    sweat:play(5/30, true)
    sweat.layer = 100
    self:addChild(sweat)

    Game.battle.timer:after(15/30, function()
        sweat:remove()
        self:getActiveSprite().run_away_light = true
        self:getActiveSprite().run_direction = Utils.pick({2, -2})

        Game.battle.timer:after(15/30, function()
            self:remove()
        end)
    end)

    self:defeat("VIOLENCED", true)
end

function LightEnemyBattler:onDefeatVaporized(damage, battler)
    self.hurt_timer = -1
    self.defeated = true

    Assets.playSound("vaporized", 1.2)

    local sprite = self:getActiveSprite()

    sprite.visible = false
    sprite:stopShake()

    local death_x, death_y = sprite:getRelativePos(0, 0, self)
    local death = DustEffect(sprite:getTexture(), death_x, death_y, function() self:remove() end)
    death:setColor(sprite:getDrawColor())
    death:setScale(sprite:getScale())
    self:addChild(death)

    self:defeat("KILLED", true)
end

function LightEnemyBattler:onDefeatFatal(damage, battler)
    self.hurt_timer = -1

    Assets.playSound("deathnoise")

    local sprite = self:getActiveSprite()

    sprite.visible = false
    sprite:stopShake()

    local death_x, death_y = sprite:getRelativePos(0, 0, self)
    local death = FatalEffect(sprite:getTexture(), death_x, death_y, function() self:remove() end)
    death:setColor(sprite:getDrawColor())
    death:setScale(sprite:getScale())
    self:addChild(death)

    self:defeat("KILLED", true)
end

function LightEnemyBattler:heal(amount)
    Assets.stopAndPlaySound("power")
    self:lightStatusMessage("heal", "+" .. amount, {0, 1, 0})

    self.health = self.health + amount

    if self.health >= self.max_health then
        self.health = self.max_health
    end

end

function LightEnemyBattler:freeze()
    if not self.can_freeze then
        self:onDefeat()
        return
    end

    Assets.playSound("petrify")

    self:toggleOverlay(true)

    local sprite = self:getActiveSprite()
    if not sprite:setAnimation("frozen") then
        sprite:setAnimation("hurt")
    end
    sprite:stopShake()

    self:recruitMessage("frozen")

    self.hurt_timer = -1

    sprite.frozen = true
    sprite.freeze_progress = 0

    Game.battle.timer:tween(20/30, sprite, {freeze_progress = 1})

    Game.battle.money = Game.battle.money + 24
    self:defeat("FROZEN", true)
end

function LightEnemyBattler:lightStatusMessage(...)
    return super.lightStatusMessage(self, (self.width/2), (self.height/2) - 10, ...)
end

function LightEnemyBattler:recruitMessage(...)
    return super.recruitMessage(self, self.width/2, self.height, ...)
end

function LightEnemyBattler:spawnSpeechBubble(text, options)
    options = options or {}
    options["right"] = self.dialogue_right or options["right"]

    local bubble
    if not options["style"] and self.dialogue_bubble then
        options["style"] = self.dialogue_bubble
    end
    if not options["right"] then
        local x, y = self.sprite:getRelativePos(0, self.actor:getHeight()/2, Game.battle)
        x, y = x - self.dialogue_offset[1], y + self.dialogue_offset[2]
        bubble = SpeechBubble(text, x, y, options, self)
    else
        local x, y = self.sprite:getRelativePos(self.actor:getWidth(), self.actor:getHeight()/2, Game.battle)
        x, y = x + self.dialogue_offset[1], y + self.dialogue_offset[2]
        bubble = SpeechBubble(text, x, y, options, self)
    end
    self.bubble = bubble
    self:onBubbleSpawn(bubble)
    bubble:setCallback(function()
        self:onBubbleRemove(bubble)
        bubble:remove()
        self.bubble = nil
    end)
    bubble:setLineCallback(function(index)
        Game.battle.textbox_timer = 3 * 30
    end)
    Game.battle:addChild(bubble)
    return bubble
end

function LightEnemyBattler:defeat(reason, violent)
    self.done_state = reason or "DEFEATED"

    if violent then
        Game.battle.used_violence = true
        if self.done_state == "KILLED" or self.done_state == "FROZEN" then
            MagicalGlassLib.kills = MagicalGlassLib.kills + 1
            Game.battle.xp = Game.battle.xp + self.experience
        end
    end
    
    Game.battle.money = Game.battle.money + self:getMoney()
    
    Game.battle:removeEnemy(self, true)
end

function LightEnemyBattler:setActor(actor, use_overlay)
    if type(actor) == "string" then
        self.actor = Registry.createActor(actor)
    else
        self.actor = actor
    end

    self.width = self.actor:getWidth()
    self.height = self.actor:getHeight()

    if self.sprite         then self:removeChild(self.sprite)         end
    if self.overlay_sprite then self:removeChild(self.overlay_sprite) end

    if self.actor.use_light_battler_sprite then
        self.sprite = self.actor:createLightBattleSprite()
    else
        self.sprite = self.actor:createSprite()
    end
    self:addChild(self.sprite)

    if use_overlay ~= false then
        self.overlay_sprite = self.actor:createSprite()
        self.overlay_sprite.visible = false
        self:addChild(self.overlay_sprite)
    end

    if self.sprite then
        self.sprite.facing = "left"
        self.sprite.inherit_color = true
    end
    if self.overlay_sprite then
        self.overlay_sprite.facing = "left"
        self.overlay_sprite.inherit_color = true
    end
end

function LightEnemyBattler:setSprite(sprite, speed, loop, after)
    if not self.sprite then
        self.sprite = Sprite(sprite)
        self:addChild(self.sprite)
    else
        self.sprite:setSprite(sprite)
    end
    if not self.sprite.directional and speed then
        self.sprite:play(speed, loop, after)
    end
end

function LightEnemyBattler:update()
    if self.hurt_timer > 0 then
        self.hurt_timer = Utils.approach(self.hurt_timer, 0, DT)

        if self.hurt_timer == 0 then
            self:onHurtEnd()
        end
    end

    super.update(self)
end

function LightEnemyBattler:canDeepCopy()
    return false
end

function LightEnemyBattler:setFlag(flag, value)
    Game:setFlag("lightEnemy#"..self.id..":"..flag, value)
end

function LightEnemyBattler:getFlag(flag, default)
    return Game:getFlag("lightEnemy#"..self.id..":"..flag, default)
end

function LightEnemyBattler:addFlag(flag, amount)
    return Game:addFlag("lightEnemy#"..self.id..":"..flag, amount)
end

return LightEnemyBattler