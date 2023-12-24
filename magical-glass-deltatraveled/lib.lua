MagicalGlassDeltatraveled = {}
local lib = MagicalGlassDeltatraveled

DeltatravelerBattle         = libRequire("magical-glass-deltatraveled", "scripts/deltatravelerbattle")
DTBattleUI                  = libRequire("magical-glass-deltatraveled", "scripts/deltatravelerbattle/ui/dtbattleui")
DTActionBox                 = libRequire("magical-glass-deltatraveled", "scripts/deltatravelerbattle/ui/dtactionbox")
DTActionBoxDisplay          = libRequire("magical-glass-deltatraveled", "scripts/deltatravelerbattle/ui/dtactionboxdisplay")
DTAttackBox                 = libRequire("magical-glass-deltatraveled", "scripts/deltatravelerbattle/ui/dtattackbox")
DTAttackBar                 = libRequire("magical-glass-deltatraveled", "scripts/deltatravelerbattle/ui/dtattackbar")

function lib:save(data)
    data.magical_glass_deltatraveled = {}
    data.magical_glass_deltatraveled["dt_light_battles"] = lib.dt_light_battles
    print(data.magical_glass_deltatraveled["dt_light_battles"])
end

function lib:load(data, is_new_file)
    if is_new_file then
        lib.dt_light_battles = true
    else
        lib.dt_light_battles = data.magical_glass_deltatraveled["dt_light_battles"]
    end
end

function lib:init()
    print(self.info.id .. " version " .. self.info.version .. ": Getting ready...")

    PALETTE["dt_desc"] = {192/255, 192/255, 192/255, 1}
    PALETTE["dt_tension_preview"] = {127/255, 80/255, 32/255, 1}
    PALETTE["dt_max_tension_preview"] = {127/255, 127/255, 0, 1}

    Utils.hook(Game, "encounterLight", function(orig, self, encounter, transition, enemy, context)
        if transition == nil then transition = true end

        if self.battle then
            error("Attempt to enter light battle while already in battle")
        end
        
        if enemy and not isClass(enemy) then
            self.encounter_enemies = enemy
        else
            self.encounter_enemies = {enemy}
        end

        self.state = "BATTLE"

        if MagicalGlassDeltatraveled.dt_light_battles then
            self.battle = DeltatravelerBattle()
        else
            self.battle = LightBattle()
        end

        if context then
            self.battle.encounter_context = context
        end

        if type(transition) == "string" then
            self.battle:postInit(transition, encounter)
        else
            self.battle:postInit("TRANSITION", encounter)
        end

        self.stage:addChild(self.battle)
    end)

    Utils.hook(LightArena, "init", function(orig, self, x, y, shape)
        LightArena.__super:init(self, x, y)

        self.x = math.floor(self.x)
        self.y = math.floor(self.y)
    
        self.home_x = self.x
        self.home_y = self.y
        self.init_width = 565
        self.init_height = 130
    
        self.collider = ColliderGroup(self)
    
        self.line_width = 5 -- must call setShape again if u change this
        self:setShape(shape or {{0, 0}, {self.init_width, 0}, {self.init_width, self.init_height}, {0, self.init_height}})
    
        self.color = {1, 1, 1}
        self.bg_color = {0, 0, 0}
    
        self.sprite = LightArenaSprite(self)
        self.sprite:setOrigin(0.5, 1)
        self.sprite:setPosition(self:getRelativePos())
        self.sprite.layer = BATTLE_LAYERS["ui"] - 5
        Game.battle:addChild(self.sprite)

        self.background = LightArenaBackground(self)
        self.background:setOrigin(0.5, 1)
        self.background:setPosition(self:getRelativePos())
        self.background.layer = BATTLE_LAYERS["ui"] - 5
        Game.battle:addChild(self.background)
    
        self.mask = ArenaMask(1, 0, 0, self)
        self.mask.layer = BATTLE_LAYERS["arena"] - 1
        self:addChild(self.mask)
    
        self:setOrigin(0.5, 1)
    
        self.target_shape = {}
        self.target_position = {}
    
        self.target_shape_callback = nil
        self.target_position_callback = nil
    end)

    Utils.hook(PartyMember, "init", function(orig, self)
        orig(self)
        self.light_hurt_color = {1, 1, 1}
    end)

    Utils.hook(PartyMember, "getLightHurtColor", function(orig, self)
        if self.light_hurt_color and type(self.light_hurt_color) == "table" then
            return self.light_hurt_color
        else
            return self.light_color
        end
    end)

    Utils.hook(LightTensionBar, "init", function(orig, self, x, y, dont_animate)
        orig(self, x, y, dont_animate)

        self.moving = false
        self.interrupted = false
    end)

    Utils.hook(LightTensionBar, "processTension", function(orig, self)
        if Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltatraveler" then
            self.apparent = self:getTension250()

            -- queues up way too many tweens but it works, look into this later
            if (self.current ~= self.apparent) then
                TweenManager.tween(self, {current = self.apparent}, 10, "outExpo")
            end
        elseif Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltarune" then
            orig(self)
        end
    end)

    Utils.hook(LightTensionBar, "drawText", function(orig, self)
        if Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltatraveler" then
            local x = self.x - 49
            love.graphics.setFont(self.tp_font)
            love.graphics.setColor(0, 0, 0, 1)
            love.graphics.print("T", x + 1, 1)
            love.graphics.print("P", x + 1, 22)
        
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.print("T", x, 0)
            love.graphics.print("P", x, 21)
        
            local tamt = math.floor(self:getPercentageFor250(self.apparent) * 100)
            self.maxed = false
            love.graphics.setFont(self.font)
            if (tamt < 100) then
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.printf(tostring(math.floor(self:getPercentageFor250(self.apparent) * 100)) .. "%", self.x - 38, self.height - 4, 50, "center")
                love.graphics.setColor(1, 1, 1, 1)
                love.graphics.printf(tostring(math.floor(self:getPercentageFor250(self.apparent) * 100)) .. "%", self.x - 39, self.height - 5, 50, "center")
                --love.graphics.print("%", x, self.height - 4)
            end
            if (tamt >= 100) then
                self.maxed = true
        
                love.graphics.setColor(0, 0, 0, 1)
                love.graphics.print("MAX", self.x - 36, self.height - 4)
                Draw.setColor(PALETTE["tension_maxtext"])
                love.graphics.print("MAX", self.x - 37, self.height - 5)
            end
        elseif Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltarune" then
            orig(self)
        end
    end)

    Utils.hook(LightTensionBar, "drawBack", function(orig, self)
        if Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltatraveler" then
            Draw.setColor(PALETTE["tension_back"])
            Draw.draw(self.tp_bar_fill, 0, 0)
        elseif Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltarune" then
            orig(self)
        end
    end)

    Utils.hook(LightTensionBar, "drawFill", function(orig, self)
        if Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltatraveler" then
            if self.maxed then
                Draw.setColor(COLORS.yellow)
            else
                Draw.setColor(PALETTE["tension_fill"])
            end
            Draw.pushScissor()
            Draw.scissorPoints(0, 156 - (self:getPercentageFor250(self.current) * 156) + 1, 25, 156)
            Draw.draw(self.tp_bar_fill, 0, 0)
            Draw.popScissor()
            
            if (self.tension_preview > 0) then
                local theight = 156 - (self:getPercentageFor250(self.current) * 156)
                local theight2 = theight + (self:getPercentageFor(self.tension_preview) * 156)
                Draw.pushScissor()
                Draw.scissorPoints(0, theight2 + 1, 25, theight + 1)
                if self.maxed then
                    Draw.setColor(PALETTE["dt_max_tension_preview"])
                else
                    Draw.setColor(PALETTE["dt_tension_preview"])
                end
                Draw.draw(self.tp_bar_fill, 0, 0)
                Draw.popScissor()
        
                Draw.setColor(1, 1, 1, 1)
            end
    
        elseif Kristal.getLibConfig("magical-glass-deltatraveled", "tp_bar_animation") == "deltarune" then
            orig(self)
        end
    end)

    Utils.hook(LightEncounter, "init", function(orig, self)
        orig(self)
        if MagicalGlassDeltatraveled.dt_light_battles then
            self.can_defend = true
            self.can_flee = false
        end
    end)

    Utils.hook(HelpWindow, "init", function(orig, self, x, y)
        if MagicalGlassDeltatraveled.dt_light_battles then
            HelpWindow.__super.init(self, x, y)

            self.showing = false
        
            self.box_fill = Rectangle(0, 0, 560, 45)
            self.box_fill:setOrigin(0.5)
            self.box_fill.color = COLORS.black
            self:addChild(self.box_fill)
        
            self.box_line = Rectangle(0, 0, 560, 45)
            self.box_line.line = true
            self.box_line.line_width = 5
            self.box_fill:addChild(self.box_line)
        
            self.description_text = Text("", 14, 8, 400, 32, {color = PALETTE["dt_desc"], font = "main_mono"})
            self.box_fill:addChild(self.description_text)
        
            self.cost_text = Text("", 10, 8, 539, 32, {color = PALETTE["tension_desc"], align = "right", font = "main_mono"})
            self.box_fill:addChild(self.cost_text)
        else
            orig(self, x, y)
        end
    end)

    Utils.hook(HelpWindow, "update", function(orig, self)
        if MagicalGlassDeltatraveled.dt_light_battles then
            local battle = Game.battle

            if (battle.state == "MENUSELECT" and #battle.menu_items > 0) or battle.state == "PARTYSELECT" then
                local item = battle.state == "MENUSELECT" and Game.battle.menu_items[Game.battle:getItemIndex()]
                if battle.state == "PARTYSELECT" or (#item.description > 0 or (item.tp and item.tp > 0)) then
                    if not self.showing then
                        self.showing = true
                        TweenManager.tween(self, {y = 437.5}, 11, "outExpo")
                    end
                else
                    if self.showing then
                        self.showing = false
                        TweenManager.tween(self, {y = 397.5}, 6, "outExpo")
                    end
                end
            else
                if self.showing then
                    self.showing = false
                    TweenManager.tween(self, {y = 397.5}, 6, "outExpo")
                end
            end
            
            HelpWindow.__super.update(self)
        else
            orig(self)
        end
    end)

    Utils.hook(LightPartyBattler, "init", function(orig, self, chara, x, y)
        self.chara = chara
        self.actor = chara:getActor()
    
        LightPartyBattler.__super.init(self, x, y, self.actor:getSize())
    
        if self.actor then
            self:setActor(self.actor, true)
        end

        -- default to the idle animation, handle the battle intro elsewhere
        if self.actor:getAnimation("lightbattle/idle") then
            self:setAnimation("lightbattle/idle")
        else
            self:setAnimation("walk/down")
        end
    
        self.action = nil
        self.has_selected_action = false
    
        self.defending = false
        self.hurting = false
    
        self.is_down = false
        self.sleeping = false
    
        self.targeted = false

        -- "down" or "up"
        self.force_action_box = nil
    end)

    Utils.hook(LightPartyBattler, "calculateDamage", function(orig, self, amount)
        -- this is most certainly different in dt
        local def = self.chara:getStat("defense")
        local max_hp = self.chara:getStat("health")
    
        local threshold_a = (max_hp / 5)
        local threshold_b = (max_hp / 8)
        for i = 1, def do
            if amount > threshold_a then
                amount = amount - 3
            elseif amount > threshold_b then
                amount = amount - 2
            else
                amount = amount - 1
            end
        end
    
        return math.max(amount, 1)
    end)

    Utils.hook(LightPartyBattler, "statusMessage", function(orig, self, ...)
        local message = LightPartyBattler.__super.statusMessage(self, 0, 0, ...)

        local actbox
        for _,box in ipairs(Game.battle.battle_ui.action_boxes) do
            if box.battler == self then
                actbox = box
            end
        end

        if not actbox.down then
            message.x = message.x - 5
            message.y = message.y - 90
        else
            message.x = message.x - 5
            message.y = message.y + 35
        end

        return message
    end)

    Utils.hook(LightPartyBattler, "hurt", function(orig, self, amount, exact, color, options)
        if MagicalGlassDeltatraveled.dt_light_battles then
            options = options or {}

            if not options["all"] then
                Assets.playSound("hurt")
                if not exact then
                    amount = self:calculateDamage(amount)
                    if self.defending then
                        amount = math.ceil((2 * amount) / 3)
                    end
                    local element = 0
                    amount = math.ceil((amount * self:getElementReduction(element)))
                end
        
                self:removeHealth(amount)
            else
                if not exact then
                    amount = self:calculateDamage(amount)
                    local element = 0
                    amount = math.ceil((amount * self:getElementReduction(element)))
        
                    if self.defending then
                        amount = math.ceil((3 * amount) / 4)
                    end
        
                    self:removeHealthBroken(amount)
                end
            end

            if (self.chara:getHealth() <= 0) then
                self:statusMessage("msg", "down", color, true)
            else
                self:statusMessage("damage", amount, color, true)
            end
        
            Game.battle:shakeCamera(4)
        else
            orig(self, amount, exact, color, options)
        end
    end)

    Utils.hook(LightPartyBattler, "heal", function(orig, self, amount, show_up, sound)
        if sound then
            Assets.stopAndPlaySound("power")
        end
    
        amount = math.floor(amount)
    
        if self.chara:getHealth() < self.chara:getStat("health") then
            self.chara:setHealth(math.min(self.chara:getStat("health"), self.chara:getHealth() + amount))
            
            if show_up then
                if was_down ~= self.is_down then
                    self:statusMessage("msg", "up")
                end
            else
                self:statusMessage("heal", amount, {0, 1, 0})
            end
        else
            self:statusMessage("msg", "max")
        end
    
        local was_down = self.is_down
        self:checkHealth()
    end)

    Utils.hook(LightPartyBattler, "draw", function(orig, self)
        if MagicalGlassDeltatraveled.dt_light_battles then
            LightPartyBattler.__super.draw(self)
            if self.actor then
                self.actor:onBattleDraw(self)
            end
        else
            orig(self)
        end
    end)

    Utils.hook(LightPartyBattler, "resetSprite", function(orig, self)
        self:setAnimation("lightbattle/idle")
    end)

    Utils.hook(Actor, "init", function(orig, self)
        orig(self)
        self.lw_battle_offset_up = {0, 0}
        self.lw_battle_offset_down = {0, 0}
    end)

    Utils.hook(Actor, "getLightBattleOffsetUp", function(orig, self)
        return Utils.unpack(self.lw_battle_offset_up)
    end)

    Utils.hook(Actor, "getLightBattleOffsetDown", function(orig, self)
        return Utils.unpack(self.lw_battle_offset_down)
    end)

    Utils.hook(LightActionButton, "draw", function(orig, self)
        if (Game.battle.current_selecting == Game.battle:getPartyIndex(self.battler.chara.id)) and self.selectable and self.hovered then
            love.graphics.draw(self.hover_tex or self.tex)
        else
            love.graphics.draw(self.tex)
            if self.selectable and self.special_tex and self:hasSpecial() then
                local r, g, b, a = self:getDrawColor()
                love.graphics.setColor(r, g, b, a * (0.4 + math.sin((Kristal.getTime() * 30) / 6) * 0.4))
                love.graphics.draw(self.special_tex)
            end
        end
    
        LightActionButton.__super.draw(self)
    end)

    Utils.hook(LightEnemyBattler, "getAttackDamage", function(orig, self, damage, lane, points, stretch)
        if MagicalGlassDeltatraveled.dt_light_battles then
            local battler = lane.battler.chara
            local total_damage
            local crit = false

            if points >= 20 then
                crit = true
            end

            local icering_debuff = false
            for _,tag in ipairs(lane.weapon.tags) do
                if tag == "icering" then
                    icering_debuff = true
                end
            end

            if icering_debuff and battler:getLightLV() < 9 then
                if battler:getLightLV() >= 6 then
                    damage = damage * 0.9
                elseif battler:getLightLV() >= 3 then
                    damage = damage * 0.85
                else
                    damage = damage * 0.8
                end
            end

            local at = (battler:getLightLV() - 1) * 2

            -- unhardcode this
            if battler.id == "susie" then
                at = at + (2 + math.floor(battler:getLightLV() / 4))
            end

            if battler.id == "noelle" then
                at = at + (Utils.round(at * 2 / 3))
            end

            total_damage = ((8 + (at + battler:getEquipmentBonus("attack"))) * damage / 8) - self.defense

            return math.floor(total_damage * points), crit
        else
            return orig(self, damage, lane, points, stretch)
        end
    end)

    Utils.hook(Item, "onDTAttack", function(orig, self, battler, enemy, damage, crit)
        local src = Assets.playSound(self:getLightAttackSound())
        src:setPitch(self:getLightAttackPitch() or 1)
    
        if crit then
            Assets.playSound("criticalswing")
        end

        local sprite = Sprite(self:getLightAttackSprite())
        sprite:setScale(2)
        sprite:setOrigin(0.5, 0.5)
        sprite:setPosition(enemy:getRelativePos(((enemy.width / 2) - 5) + (#Game.battle.party - 1 * 10), (enemy.height / 2)))
        sprite.layer = BATTLE_LAYERS["above_ui"] + 5
        sprite.color = battler.chara:getLightAttackColor()
        enemy.parent:addChild(sprite)
        sprite:play(2/30, false, function(this) -- timing may still be incorrect
            
            local sound = enemy:getDamageSound() or "damage"
            if sound and type(sound) == "string" then
                Assets.stopAndPlaySound(sound)
            end
            enemy:hurt(damage, battler)
    
            battler.chara:onAttackHit(enemy, damage)

            Game.battle.timer:after(1, function()
                Game.battle:finishActionBy(battler)
            end)

            this:remove()
        end)
    end)

    Utils.hook(Item, "onDTMiss", function(orig, self, battler, enemy, damage, crit)
        enemy:hurt(0, battler, on_defeat, {battler.chara:getLightMissColor()})
        Game.battle.timer:after(1, function()
            Game.battle:finishActionBy(battler)
        end) 
    end)
end

return lib