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

    self.check = "Wake up and taste the [color:red]pain"

    self.text = {}

    self.low_health_text = nil
    self.spareable_text = nil

    self.tired_percentage = 0.5

    -- Speech bubble style - defaults to "round" or "cyber", depending on chapter
    -- This is set to nil in `battler.lua` as well, but it's here for completion's sake.
    self.dialogue_bubble = "round"

    -- The offset for the speech bubble, also set in `battler.lua`
    self.dialogue_offset = {0, 0}

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
end

function LightEnemyBattler:getExitDirection()
    return self.exit_direction or Utils.random(-2, 2, 1)
end

function LightEnemyBattler:setTired(bool)
    self.tired = bool
--[[     if self.tired then
        self.comment = "(Tired)"
    else
        self.comment = ""
    end ]]
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
    if self.exit_on_defeat then
        self.alpha = 0.5
        Game.battle.spare_sound:stop()
        Game.battle.spare_sound:play()

        -- this still seems to break for bigger enemies, but it works so eh
        for i = 0, 15 do
            local x = ((Utils.random((self.width / 2)) + (self.width / 4)) + self.x) - 32
            local y = ((Utils.random((self.height / 2)) + (self.height / 4)) + self.y) - 64

            local dust = SpareDust(x, y)
            self.parent:addChild(dust)

            dust.rightside = ((32 + dust.x) - self.x) / (self.width / 2)
            dust.topside = ((64 + dust.y) - self.y) / (self.height / 2)

            dust:spread()

            dust.layer = BATTLE_LAYERS["above_ui"] + 3
        end
    end

    self.sprite:setAnimation("spared")
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
    self:setAnimation("spared")
end

function LightEnemyBattler:onSpareable()
    self:setAnimation("spared")
end

function LightEnemyBattler:addMercy(amount)
    if self.mercy >= 100 then
        -- We're already at full mercy; do nothing.
        return
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

    if Game:getConfig("mercyMessages") then
        if amount > 0 then
            local pitch = 0.8
            if amount < 99 then pitch = 1 end
            if amount <= 50 then pitch = 1.2 end
            if amount <= 25 then pitch = 1.4 end

            local src = Assets.playSound("mercyadd", 0.8)
            src:setPitch(pitch)

            self:lightStatusMessage("mercy", amount)
        else
            --self:statusMessage("msg", "miss")
        end
    end
end

function LightEnemyBattler:onMercy(battler)
    if self:canSpare() then
        self:spare()
        return true
    else
        self:addMercy(self.spare_points)
        return false
    end
end

function LightEnemyBattler:getNameColors()
    local result = {}
    if self:canSpare() then -- pink name shit goes here
        table.insert(result, Game:getFlag("name_color"))
    end
    if self.tired then
        table.insert(result, {0, 0.7, 1})
    end
    return result
end

function LightEnemyBattler:getEncounterText()
    if self.low_health_text and self.health <= (self.max_health * self.tired_percentage) then
        return self.low_health_text
    end
    if self.spareable_text and self:canSpare() then
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

function LightEnemyBattler:selectWave()
    local waves = self:getNextWaves()
    if waves and #waves > 0 then
        local wave = Utils.pick(waves)
        self.selected_wave = wave
        return wave
    end
end

function LightEnemyBattler:onCheck(battler) end

function LightEnemyBattler:onActStart(battler, name)
    --battler:setAnimation("battle/act")
    local action = Game.battle:getCurrentAction()
--[[     if action.party then
        for _,party_id in ipairs(action.party) do
            Game.battle:getPartyBattler(party_id):setAnimation("battle/act")
        end
    end ]]
end

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

function LightEnemyBattler:hurt(amount, battler, on_defeat, color)
    self.health = self.health - amount
    self:lightStatusMessage("damage", amount, color or (battler and {battler.chara:getLightDamageColor()}))

    self.hurt_timer = 1
    self:onHurt(amount, battler)

    self:checkHealth(on_defeat, amount, battler)
end

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

        total_damage = total_damage * ((points / 160) * (4 / lane.weapon:getAttackBolts())) -- might not be the bolt count
        total_damage = Utils.round(total_damage) + Utils.random(0, 2, 1)

        if points > (400 * (lane.weapon:getAttackBolts() / 4)) then
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

function LightEnemyBattler:onHurt(damage, battler)
    self:toggleOverlay(true)
    if not self:getActiveSprite():setAnimation("hurt") then
        self:toggleOverlay(false)
    end
    self:getActiveSprite():shake(9) -- not sure if this should be different

--[[     if self.health <= (self.max_health * self.tired_percentage) then
        self:setTired(true)
    end ]]
end

function LightEnemyBattler:onHurtEnd()
    self:getActiveSprite():stopShake()
    self:toggleOverlay(false)
end

function LightEnemyBattler:onDefeat(damage, battler)
    if self.exit_on_defeat then
        --self:onDefeatRun(damage, battler)
        Game.battle.timer:after(self.hurt_timer, function()
            self:onDefeatVaporized(damage, battler)        
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
        self:getActiveSprite().run_away = true

        Game.battle.timer:after(15/30, function()
            self:remove()
        end)
    end)

    self:defeat("VIOLENCED", true)
end

function LightEnemyBattler:onDefeatVaporized(damage, battler)
    self.hurt_timer = -1

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

function LightEnemyBattler:heal(amount)
    Assets.stopAndPlaySound("power")
    self.health = self.health + amount

    if self.health >= self.max_health then
        self.health = self.max_health
    end
    self:lightStatusMessage("heal", "+" .. amount, {0, 1, 0})

end

function LightEnemyBattler:freeze()
    if not self.can_freeze then
        self:onDefeatRun()
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

--[[ function LightEnemyBattler:recruitMessage(...)
    return super.recruitMessage(self, self.width/2, self.height/2, ...)
end ]]

function LightEnemyBattler:defeat(reason, violent)
    self.done_state = reason or "DEFEATED"
    Game.battle.money = Game.battle.money + self.money

    if violent then
        Game.battle.used_violence = true
        Game.battle.xp = Game.battle.xp + self.experience
    end

    Game.battle:removeEnemy(self, true)
end

function LightEnemyBattler:setActor(actor, use_overlay)
    super.setActor(self, actor, use_overlay)

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
    Game:setFlag("enemy#"..self.id..":"..flag, value)
end

function LightEnemyBattler:getFlag(flag, default)
    return Game:getFlag("enemy#"..self.id..":"..flag, default)
end

function LightEnemyBattler:addFlag(flag, amount)
    return Game:addFlag("enemy#"..self.id..":"..flag, amount)
end

return LightEnemyBattler