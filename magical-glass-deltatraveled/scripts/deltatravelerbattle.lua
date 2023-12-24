local DeltatravelerBattle, super = Class(LightBattle)

function DeltatravelerBattle:init()
    super.init(self)
    self.menu_move_delay = 0
    self.last_input = nil
end

function DeltatravelerBattle:playSelectSound()
    self.ui_select:stop()
    self.ui_select:play()
end

function DeltatravelerBattle:createPartyBattlers()
    for i = 1, math.min(3, #Game.party) do
        local party_member = Game.party[i]

        local battler = LightPartyBattler(party_member)
        battler.visible = true
        battler.layer = BATTLE_LAYERS["below_ui"] - 5
        self:addChild(battler)
        table.insert(self.party, battler)

        if Game:getFlag("#remove_overheal") then
            if party_member:getHealth() > party_member:getStat("health") + 15 then
                party_member:setHealth(party_member:getStat("health") + 15)
            end
        end

        if party_member:getHealth() < 1 then
            party_member:setHealth(1)
        end
    end
end

function DeltatravelerBattle:postInit(state, encounter)
    self.state = state

    if type(encounter) == "string" then
        self.encounter = MagicalGlassLib:createLightEncounter(encounter)
    else
        self.encounter = encounter
    end

    if self.encounter.includes(Encounter) then
        error("Attempted to use Encounter in a LightBattle. Convert the encounter file to a LightEncounter.")
    end

    if Game.world.music:isPlaying() and self.encounter.music then
        self.resume_world_music = true
        Game.world.music:pause()
    end

    if self.encounter.queued_enemy_spawns then
        for _,enemy in ipairs(self.encounter.queued_enemy_spawns) do
            table.insert(self.enemies, enemy)
            self:addChild(enemy)
        end
    end

    if state == "TRANSITION" then
        self.encounter:onSoulTransition()
    else
        self.encounter:onBattleStart()
    end

    if self.encounter.story then
        self.story_wave = self.encounter:storyWave()
    end

    self.arena = LightArena(SCREEN_WIDTH/2, 419)
    self.arena.layer = BATTLE_LAYERS["above_ui"]
    self:addChild(self.arena)

    self.battle_ui = DTBattleUI()
    self:addChild(self.battle_ui)

    self.tension_bar = LightTensionBar(29, 54, true)
    if self.tension then
        self.tension_bar.visible = false
    end
    self:addChild(self.tension_bar)

    if Game.encounter_enemies then
        for _,enemy in ipairs(Game.encounter_enemies) do
            if not isClass(enemy) then
                local battler = self:parseEnemyIdentifier(enemy[1])
                enemy[2].battler = battler
                self.enemy_world_characters[battler] = enemy[2]
                if state == "TRANSITION" then
                    battler:setPosition(enemy[2]:getScreenPos())
                end
            end
        end
    end

    if self.encounter_context and self.encounter_context:includes(ChaserEnemy) then
        for _,enemy in ipairs(self.encounter_context:getGroupedEnemies(true)) do
            enemy:onEncounterStart(enemy == self.encounter_context, self.encounter)
        end
    end

    if not self.encounter:onBattleInit() then
        self:setState(state)
    end   
end

function DeltatravelerBattle:onStateChange(old, new)
    if self.encounter.beforeStateChange then
        local result = self.encounter:beforeStateChange(old,new)
        if result or self.state ~= new then
            return
        end
    end

    if new == "ACTIONSELECT" then
        self.arena.layer = BATTLE_LAYERS["ui"] - 1

        if not self.soul then
            self:spawnSoul()
        end

        self.soul.can_move = false

        if self.current_selecting < 1 or self.current_selecting > #self.party then
            self:nextTurn()
            if self.state ~= "ACTIONSELECT" then
                return
            end
        end
        
        if self.battle_ui then
            if self.current_selecting > 1 and self.state_reason ~= "CANCEL" then
                local actbox = self.battle_ui.action_boxes[self.current_selecting]
                local prev_actbox = self.battle_ui.action_boxes[self.current_selecting - 1]
                actbox.selected_button = prev_actbox.selected_button
            end
        end

        self.fader:fadeIn(function()
            self.soul.layer = BATTLE_LAYERS["below_ui"] + 1
        end, {speed=5/30})

        self.battle_ui.encounter_text.text.line_offset = 5
        self.battle_ui:clearEncounterText()
        if self.state_reason == "CANCEL" then
            self.battle_ui.encounter_text:setText("[instant]" .. self.battle_ui.current_encounter_text)
        else
            self.battle_ui.encounter_text:setText(self.battle_ui.current_encounter_text)
        end

        self.battle_ui.encounter_text.debug_rect = { -30, -12, SCREEN_WIDTH + 1, 124 }

        local had_started = self.started
        if not self.started then
            self.started = true

            if self.encounter.music then
                self.music:play(self.encounter.music)
            end
        end

        if not had_started then
            for _,party in ipairs(self.party) do
                party.chara:onTurnStart()
            end
            local party = self.party[self.current_selecting]
            party.chara:onActionSelect(party, false)
            self.encounter:onCharacterTurn(party, false)
        end

        if self.battle_ui.help_window then
            self.battle_ui.help_window:toggleVisibility(true)
        end
    elseif new == "BUTNOBODYCAME" then
        if not self.soul then
            self:spawnSoul()
        end

        self.soul.can_move = false
        
        self.fader:fadeIn(nil, {speed=5/30})

        self.battle_ui.encounter_text.text.line_offset = 5
        self.battle_ui:clearEncounterText()
        self.battle_ui.encounter_text:setText(self.battle_ui.current_encounter_text)

        self.battle_ui.encounter_text.debug_rect = { -30, -12, SCREEN_WIDTH + 1, 124 }

        local had_started = self.started
        if not self.started then
            self.started = true

            if self.encounter.music then
                self.music:play(self.encounter.music)
            end
        end

    elseif new == "ACTIONS" then
        self.battle_ui:clearEncounterText()
        if self.state_reason ~= "DONTPROCESS" then
            self:tryProcessNextAction()
        end
    elseif new == "MENUSELECT" then
        self.soul.layer = BATTLE_LAYERS["soul"]

        if self.battle_ui.help_window then
            self.battle_ui.help_window:setTension(0)
        end
        self.battle_ui:clearEncounterText()

        if self.state_reason == "ACT" then
            self.current_menu_columns = 2
            self.current_menu_rows = 3
        end

        if self.state_reason ~= "ACT" and old == "ENEMYSELECT" and self.menuselect_cursor_memory[self.state_reason] then
            self.current_menu_x = self.menuselect_cursor_memory[self.state_reason].x
            self.current_menu_y = self.menuselect_cursor_memory[self.state_reason].y
        else
            self.current_menu_x = 1
            self.current_menu_y = 1
        end

        if not self:isValidMenuLocation() then
            self.current_menu_x = 1
            self.current_menu_y = 1
        end
    elseif new == "ENEMYSELECT" then
        self.soul.layer = BATTLE_LAYERS["soul"]
        self.battle_ui:clearEncounterText()
        self.current_menu_x = 1


        if not self:isValidMenuLocation() then
            repeat
                if not self.enemies[self.current_menu_y] then
                    self.current_menu_y = 1
                    break
                end
                self.current_menu_y = self.current_menu_y + 1
            until(self:isValidMenuLocation())
        end

    elseif new == "PARTYSELECT" then
        self.current_menu_x = 1
        self.current_menu_y = 1

        self.soul.layer = BATTLE_LAYERS["soul"]
        self.battle_ui:clearEncounterText()

    elseif new == "ATTACKING" then
        self.soul.layer = BATTLE_LAYERS["soul"]
        self.battle_ui:clearEncounterText()

        local enemies_left = self:getActiveEnemies()

        if #enemies_left > 0 then
            for i,battler in ipairs(self.party) do
                local action = self.character_actions[i]
                if action and action.action == "ATTACK" then
                    self:beginAction(action)
                    table.insert(self.attackers, battler)
                    table.insert(self.normal_attackers, battler)
                elseif action and action.action == "AUTOATTACK" then
                    table.insert(self.attackers, battler)
                    table.insert(self.auto_attackers, battler)
                end
            end
        end

        self.auto_attack_timer = 0

        if #self.attackers == 0 then
            self.attack_done = true
            self:setState("ACTIONSDONE")
        else
            self.attack_done = false
        end

    elseif new == "ENEMYDIALOGUE" then
        self.arena.y = self.arena.y - 34
        self.soul.layer = BATTLE_LAYERS["soul"]
        if self.battle_ui.help_window then
            self.battle_ui.help_window:toggleVisibility(false)
        end

        self.current_selecting = 0
        self.battle_ui:clearEncounterText()
        self.textbox_timer = 3 * 30
        self.use_textbox_timer = false
        local active_enemies = self:getActiveEnemies()
        if #active_enemies == 0 then
            self:setState("VICTORY")
        else

            if self.state_reason then
                self:setWaves(self.state_reason)
                local enemy_found = false
                for i,enemy in ipairs(self.enemies) do
                    if Utils.containsValue(enemy.waves, self.state_reason[1]) then
                        enemy.selected_wave = self.state_reason[1]
                        enemy_found = true
                    end
                end
                if not enemy_found then
                    self.enemies[love.math.random(1, #self.enemies)].selected_wave = self.state_reason[1]
                end
            else
                self:setWaves(self.encounter:getNextWaves(), true)
            end

            local soul_x, soul_y, soul_offset_x, soul_offset_y
            local arena_x, arena_y, arena_w, arena_h, arena_shape
            local has_arena = false
            local has_soul = false
            for _,wave in ipairs(self.waves) do
                soul_x = wave.soul_start_x or soul_x
                soul_y = wave.soul_start_y or soul_y
                soul_offset_x = wave.soul_offset_x or soul_offset_x
                soul_offset_y = wave.soul_offset_y or soul_offset_y
                arena_x = wave.arena_x or arena_x or self.arena.home_x
                arena_y = wave.arena_y or arena_y or self.arena.home_y
                arena_w = wave.arena_width and math.max(wave.arena_width, arena_w or 0) or arena_w
                arena_h = wave.arena_height and math.max(wave.arena_height, arena_h or 0) or arena_h
                if wave.arena_shape then
                    arena_shape = wave.arena_shape
                end
                if wave.has_arena then
                    has_arena = true
                end
                if wave.has_soul then
                    has_soul = true
                end
            end
    
            local center_x, center_y
    
            if has_arena then
                
                if not arena_shape then
                    arena_w, arena_h = arena_w or 160, arena_h or 130
                    arena_x, arena_y = self.arena.home_x, self.arena.home_y
                    arena_shape = {{0, 0}, {arena_w, 0}, {arena_w, arena_h}, {0, arena_h}}
                end

                if self.encounter.story then
                    self.arena:setSize(arena_w, arena_h)
                else
                    self.arena:changeShape({arena_w, self.arena.height})
                end

                center_x, center_y = self.arena:getCenter()
            else
                center_x, center_y = SCREEN_WIDTH/2, (SCREEN_HEIGHT - 155)/2 --+ 10
            end
    
            if has_soul then
                self.timer:after(2/30, function() -- ut has a 5 frame window where the soul isn't in the arena
                    soul_x = soul_x or (soul_offset_x and center_x + soul_offset_x)
                    soul_y = soul_y or (soul_offset_y and center_y + soul_offset_y)
                    self.soul:setPosition(soul_x or center_x, soul_y or center_y)
                    self:toggleSoul(true)
                    self.soul.can_move = false
                end)
            end

            for _,enemy in ipairs(active_enemies) do
                enemy.current_target = enemy:getTarget()
            end
            local cutscene_args = {self.encounter:getDialogueCutscene()}
            if #cutscene_args > 0 then
                self:startCutscene(unpack(cutscene_args)):after(function()
                    self:setState("DIALOGUEEND")
                end)
            else
                local any_dialogue = false
                for _,enemy in ipairs(active_enemies) do
                    local dialogue = enemy:getEnemyDialogue()
                    if dialogue then
                        any_dialogue = true
                        local bubble = enemy:spawnSpeechBubble(dialogue, {no_sound_overlap = true})
                        bubble:setSkippable(false)
                        bubble:setAdvance(false)
                        table.insert(self.enemy_dialogue, bubble)
                    end
                end
                if not any_dialogue then
                    self:setState("DIALOGUEEND")
                end
            end
        end
    elseif new == "DIALOGUEEND" then
        self.battle_ui:clearEncounterText()    
        self.encounter:onDialogueEnd()
    elseif new == "DEFENDING" then
        self.arena.layer = BATTLE_LAYERS["arena"]

        self.wave_length = 0
        self.wave_timer = 0

        for _,wave in ipairs(self.waves) do
            wave.encounter = self.encounter

            self.wave_length = math.max(self.wave_length, wave.time)

            wave:onStart()

            wave.active = true
        end

        self.soul:onWaveStart()
    elseif new == "VICTORY" then
        self.music:stop()
        self.current_selecting = 0

        for _,battler in ipairs(self.party) do
            battler:setSleeping(false)
            battler.defending = false
            battler.action = nil
            battler.force_action_box = "up"

            battler.chara:resetBuffs()

            if battler.chara:getHealth() <= 0 then
                battler:revive()
                battler.chara:setHealth(battler.chara:autoHealAmount())
            end

        end

        self.money = self.encounter:getVictoryMoney(self.money) or self.money

        if self.tension_bar.visible then
            self.money = self.money + (math.floor(((Game:getTension() * 2.5) / 10)) * Game.chapter)
        end

        for _,battler in ipairs(self.party) do
            for _,equipment in ipairs(battler.chara:getEquipment()) do
                self.money = math.floor(equipment:applyMoneyBonus(self.money) or self.money)
            end
        end

        self.money = math.floor(self.money)

        self.xp = self.encounter:getVictoryXP(self.xp) or self.xp

        local win_text = "[noskip]* YOU WON!\n* You earned " .. self.xp .. " EXP and " .. self.money .. " " .. Game:getConfig("lightCurrency") .. "."

        Game.lw_money = Game.lw_money + self.money

        if (Game.lw_money < 0) then
            Game.lw_money = 0
        end

        for _,member in ipairs(self.party) do
            local lv = member.chara:getLightLV()
            member.chara:gainLightEXP(self.xp, true)

            if lv ~= member.chara:getLightLV() then
                win_text = "[noskip]* YOU WON!\n* You earned " .. self.xp .. " EXP and " .. self.money .. " " .. Game:getConfig("lightCurrency") .. ".\n* Your LOVE increased."
            end
        end

        win_text = self.encounter:getVictoryText(win_text, self.money, self.xp) or win_text

        if self.encounter.no_end_message then
            self:setState("TRANSITIONOUT")
            self.encounter:onBattleEnd()
        else
            self:battleText(win_text, function()
                self:setState("TRANSITIONOUT")
                self.encounter:onBattleEnd()
                return true
            end)
        end

    elseif new == "TRANSITIONOUT" then
        self.current_selecting = 0

        Game.fader:transition(function() self:returnToWorld() end, nil, {speed = 10/30})

    elseif new == "DEFENDINGBEGIN" then
        self.battle_ui:clearEncounterText()
    elseif new == "FLEEING" then
        self.current_selecting = 0

        for _,battler in ipairs(self.party) do
            battler:setSleeping(false)
            battler.defending = false
            battler.action = nil

            if battler.chara:getHealth() <= 0 then
                battler:revive()
                battler.chara:setHealth(battler.chara:autoHealAmount())
            end

            local box = self.battle_ui.action_boxes[self:getPartyIndex(battler.chara.id)]
        end

        self.encounter:onFlee()

    elseif new == "FLEEFAIL" then
        self:toggleSoul(false)
        self.current_selecting = 0

        local any_hurt = false
        for _,enemy in ipairs(self.enemies) do
            if enemy.hurt_timer > 0 then
                any_hurt = true
                break
            end
        end

        if not any_hurt then
            self.attackers = {}
            self.normal_attackers = {}
            self.auto_attackers = {}
            if self.battle_ui.attacking then
                self.battle_ui:endAttack()
            end

            self.encounter:onFleeFail()

            if not self.encounter:onActionsEnd() then
                self:setState("ACTIONSDONE")
            end
        end
        
    elseif new == "DEFENDINGEND" then
        self.arena.y = self.arena.y + 34
        if self.arena.height >= self.arena.init_height then
            self.arena:changePosition({self.arena.home_x, self.arena.home_y}, true,
            function()
                self.arena:changeShape({self.arena.width, self.arena.init_height},
                function()
                    self.arena:changeShape({self.arena.init_width, self.arena.height})
                end)
            end)
        else
            self.arena:changePosition({self.arena.home_x, self.arena.home_y}, true,
            function()
                self.arena:changeShape({self.arena.init_width, self.arena.height},
                function()
                    self.arena:changeShape({self.arena.width, self.arena.init_height})
                end)
            end)
        end
    end

    local should_end = true
    for _,wave in ipairs(self.waves) do
        if wave:beforeEnd() then
            should_end = false
        end
    end
    if should_end then
        for _,battler in ipairs(self.party) do
            battler.targeted = false
        end
    end

    if old == "DEFENDING" and new ~= "ENEMYDIALOGUE" and should_end then
        for _,wave in ipairs(self.waves) do
            if not wave:onEnd(false) then
                wave:clear()
                wave:remove()
            end
        end

        if self:hasCutscene() then
            self.cutscene:after(function()
                self:setState("TURNDONE", "WAVEENDED")
            end)
        else
            self.timer:after(15/30, function()
                self:setState("TURNDONE", "WAVEENDED")
            end)
        end
    end

    self.encounter:onStateChange(old,new)
end

function DeltatravelerBattle:nextTurn()
    self.turn_count = self.turn_count + 1
    if self.turn_count > 1 then
        if self.encounter:onTurnEnd() then
            return
        end
        for _,party in ipairs(self.party) do
            if party.chara:onTurnEnd() then
                return
            end
        end
        for _,enemy in ipairs(self:getActiveEnemies()) do
            if enemy:onTurnEnd() then
                return
            end
        end
    end

    for _,party in ipairs(self.party) do
        party.defending = false
    end

    for _,enemy in ipairs(self.enemies) do
        enemy.selected_wave = nil
        enemy.hit_count = 0
    end

    for _,battler in ipairs(self.party) do
        battler.hit_count = 0
        if (battler.chara:getHealth() <= 0) and battler.chara:canAutoHeal() then
            battler:heal(battler.chara:autoHealAmount(), nil, true)
        end
        battler.action = nil
    end

    self.attackers = {}
    self.normal_attackers = {}
    self.auto_attackers = {}

    if self.state ~= "BUTNOBODYCAME" then
        self.current_selecting = 1
    end

    while not (self.party[self.current_selecting]:isActive()) do
        self.current_selecting = self.current_selecting + 1
        if self.current_selecting > #self.party then
            print("WARNING: nobody up! this shouldn't happen...")
            self.current_selecting = 1
            break
        end
    end
    
    self.character_actions = {}
    self.current_actions = {}
    self.processed_action = {}

    if self.battle_ui then
        local box = self.battle_ui.action_boxes[1]
        box.selected_button = box.last_button or 1
        if not self.seen_encounter_text then
            self.seen_encounter_text = true
            self.battle_ui.current_encounter_text = self.encounter.text
        else
            self.battle_ui.current_encounter_text = self:getEncounterText()
        end
        self.battle_ui.encounter_text:setText(self.battle_ui.current_encounter_text)
    end

    self.encounter:onTurnStart()
    for _,enemy in ipairs(self:getActiveEnemies()) do
        enemy:onTurnStart()
    end

    if self.battle_ui then
        for _,party in ipairs(self.party) do
            party.chara:onTurnStart(party)
        end
    end

    if self.current_selecting ~= 0 then
        self:setState("ACTIONSELECT")
    end

    if self.encounter.getNextMenuWaves and #self.encounter:getNextMenuWaves() > 0 then
        self:setMenuWaves(self.encounter:getNextMenuWaves())

        for _,enemy in ipairs(self:getActiveEnemies()) do
            enemy.menu_wave_override = nil
        end
        self.menu_wave_length = 0
        self.menu_wave_timer = 0

        for _,wave in ipairs(self.menu_waves) do
            wave.encounter = self.encounter

            self.menu_wave_length = math.max(self.menu_wave_length, wave.time)

            wave:onStart()

            wave.active = true
        end

        self.soul:onMenuWaveStart()
    end
end

function DeltatravelerBattle:update()
    if self.menu_move_delay > 0 then
        self.menu_move_delay = Utils.approach(self.menu_move_delay, 0, DTMULT)
    end
    super.update(self)
end

function DeltatravelerBattle:startProcessing()
    for _,party in ipairs(self.party) do
        party.has_selected_action = false
    end
    super.startProcessing(self)
end

function DeltatravelerBattle:processCharacterActions()
    if self.state ~= "ACTIONS" then
        self:setState("ACTIONS", "DONTPROCESS")
    end

    self.current_action_index = 1

    local order = {{"ACT", "SPELL", "ITEM"}, "SPARE"}

    for lib_id,_ in pairs(Mod.libs) do
        order = Kristal.libCall(lib_id, "getActionOrder", order, self.encounter) or order
    end
    order = Kristal.modCall("getActionOrder", order, self.encounter) or order

    table.insert(order, "SKIP")

    for _,action_group in ipairs(order) do
        if self:processActionGroup(action_group) then
            self:tryProcessNextAction()
            return
        end
    end

    self:setSubState("NONE")
    self:setState("ATTACKING")
end

function DeltatravelerBattle:processAction(action)
    local battler = self.party[action.character_id]
    local party_member = battler.chara
    local enemy = action.target

    self.current_processing_action = action

    if enemy and enemy.done_state then
        enemy = self:retargetEnemy()
        action.target = enemy
        if not enemy then
            return true
        end
    end

    -- Call mod callbacks for onBattleAction to either add new behaviour for an action or override existing behaviour
    -- Note: non-immediate actions require explicit "return false"!
    local callback_result = Kristal.modCall("onBattleAction", action, action.action, battler, enemy)
    if callback_result ~= nil then
        return callback_result
    end
    for lib_id,_ in pairs(Mod.libs) do
        callback_result = Kristal.libCall(lib_id, "onBattleAction", action, action.action, battler, enemy)
        if callback_result ~= nil then
            return callback_result
        end
    end

    self.current_selecting = 0

    if action.action == "SPARE" then
        self:toggleSoul(false)

        -- finish spare actions of other battlers
        local worked
        for _,act_enemy in ipairs(self:getActiveEnemies()) do
            if not worked then
                worked = act_enemy:canSpare()
            end
            act_enemy:onMercy(battler)
        end

        local sparing_charas = {}
        for _,iaction in ipairs(Game.battle.current_actions) do
            if iaction.action == "SPARE" then
                for _,party in ipairs(self.party) do
                    if iaction.character_id == self:getPartyIndex(party.chara.id) then
                        table.insert(sparing_charas, party.chara)
                    end
                end
            end
        end

        local message
        local first_chara
        local second_chara
        if #sparing_charas == 1 then
            first_chara = sparing_charas[1]:getNameOrYou()
            message = "* "..first_chara.." spared the enemies!"
            if not worked then
                message = message.."\n* But the enemy's name\nwasn't [color:yellow]YELLOW[color:reset]..."
            end
        elseif #sparing_charas == 2 then
            first_chara = sparing_charas[1]:getNameOrYou()
            second_chara = sparing_charas[2]:getNameOrYou()

            message = {"* "..first_chara.." and "..second_chara.." spared the\nenemies!"}
            if not worked then
                table.insert(message, "* But the enemy's name\nwasn't [color:yellow]YELLOW[color:reset]...")
            end
        elseif #sparing_charas >= 3 then
            message = "* Everyone spared the enemies!"
            if not worked then
                message = message.."\n* But the enemy's name\nwasn't [color:yellow]YELLOW[color:reset]..."
            end
        end

        self:battleText(message or "", function()
            for i, iaction in ipairs(Game.battle.current_actions) do
                if iaction.action == "SPARE" then
                    self:finishAction(iaction)
                end
            end
        end)

        return false

    elseif action.action == "ATTACK" or action.action == "AUTOATTACK" then

        self.actions_done_timer = 1.2

        local lane
        for _,ilane in ipairs(self.battle_ui.attack_box.lanes) do
            if ilane.battler == battler then
                lane = ilane
                break
            end
        end

        if lane.attacked then

            if action.target and action.target.done_state then
                enemy = self:retargetEnemy()
                action.target = enemy
                if not enemy then
                    self.cancel_attack = true
                    self:finishAction(action)
                    return
                end
            end

            local weapon = battler.chara:getWeapon()
            local damage = 0
            local crit

            if not action.force_miss and action.points > 0 then
                damage, crit = enemy:getAttackDamage(action.damage or 0, lane, action.points or 0)
                damage = Utils.round(damage)

                if damage < 0 then
                    damage = 0
                end

                if self.tension_bar.visible then
                    Game:giveTension(Utils.round(enemy:getAttackTension(points or 100))) 
                end

                weapon:onDTAttack(battler, enemy, damage, crit)
            else
                weapon:onDTMiss(battler, enemy, damage, crit)
            end

        end

        return false

    elseif action.action == "ACT" then
        local self_short = false
        self.short_actions = {}
        for _,iaction in ipairs(self.current_actions) do
            if iaction.action == "ACT" then
                local ibattler = self.party[iaction.character_id]
                local ienemy = iaction.target

                if ienemy then
                    local act = ienemy and ienemy:getAct(iaction.name)

                    if (act and act.short) or (ienemy:getXAction(ibattler) == iaction.name and ienemy:isXActionShort(ibattler)) then
                        table.insert(self.short_actions, iaction)
                        if ibattler == battler then
                            self_short = true
                        end
                    end
                end
            end
        end

        if self_short and #self.short_actions > 1 then
            local short_text = {}
            for _,iaction in ipairs(self.short_actions) do
                local ibattler = self.party[iaction.character_id]
                local ienemy = iaction.target

                local act_text = ienemy:onShortAct(ibattler, iaction.name)
                if act_text then
                    table.insert(short_text, act_text)
                end
            end

            self:shortActText(short_text)
        else
            local text = enemy:onAct(battler, action.name)
            if text then
                self:setActText(text)
            end
        end

        return false

    elseif action.action == "SKIP" then
        return true

    elseif action.action == "SPELL" then
        self.battle_ui:clearEncounterText()

        -- The spell itself handles the animation and finishing
        action.data:onLightStart(battler, action.target)

        return false
    elseif action.action == "ITEM" then
        local item = action.data
        if item.instant then
            self:finishAction(action)
        else
            local result = item:onLightBattleUse(battler, action.target)
            if result or result == nil then
                self:finishAction(action)
            end
        end
        return false
    else
        -- we don't know how to handle this...
        Kristal.Console:warn("Unhandled battle action: " .. tostring(action.action))
        return true
    end
end

function DeltatravelerBattle:onKeyPressed(key)
    if Kristal.Config["debug"] and key == "delete" then
        for _,party in ipairs(self.party) do
            party.chara:setHealth(999)
        end
    end

    if Kristal.Config["debug"] and Input.ctrl() then
        if key == "h" then
            Assets.playSound("power")
            for _,party in ipairs(self.party) do
                party:heal(math.huge)
            end
        end
        if key == "y" then
            Input.clear(nil, true)
            self:setState("VICTORY")
        end
        if key == "m" then
            if self.music then
                if self.music:isPlaying() then
                    self.music:pause()
                else
                    self.music:resume()
                end
            end
        end
        if self.state == "DEFENDING" and key == "f" then
            self.encounter:onWavesDone()
        end
        if self.soul and key == "j" then
            self.soul:shatter(6)
            self:getPartyBattler(Game:getSoulPartyMember().id):hurt(99999)
        end
        if key == "b" then
            for _,battler in ipairs(self.party) do
                battler:hurt(99999)
            end
        end
        if key == "k" then
            Game.tension = (Game:getMaxTension() * 2)
        end
    end

    if self.state == "MENUSELECT" then
        if Input.isConfirm(key) then

            if self.battle_ui.help_window then
                self.battle_ui.help_window:setTension(0)
            end

            local menu_item = self.menu_items[self:getItemIndex()]
            local can_select = self:canSelectMenuItem(menu_item)
            if Game.battle.encounter:onMenuSelect(self.state_reason, menu_item, can_select) then return end
            if Kristal.callEvent("onBattleMenuSelect", self.state_reason, menu_item, can_select) then return end

            if not self:isPagerMenu() then
                self.menuselect_cursor_memory[self.state_reason] = {x = self.current_menu_x, y = self.current_menu_y}
            end

            if can_select then
                if menu_item.special ~= "flee" then
                    self:playSelectSound()
                end
                menu_item["callback"](menu_item)
                return
            end
        elseif Input.isCancel(key) then
            Game:setTensionPreview(0)

            if not self:isPagerMenu() then
                self.menuselect_cursor_memory[self.state_reason] = {x = self.current_menu_x, y = self.current_menu_y}
            end

            if self.state_reason == "ACT" then
                self:setState("ENEMYSELECT", "ACT")
            elseif self.state_reason == "MERCY" then
                self:setState("ACTIONSELECT", "CANCEL")
            else
                self:setState("ACTIONSELECT", "CANCEL")
            end
            return
        elseif Input.is("left", key) then
            if self:checkMoveDelay(key) then
                local old = self.current_menu_x
    
                self.current_menu_x = self.current_menu_x - 1
    
                if self.current_menu_x < 1 or not self:isValidMenuLocation() then -- no vomit :)
                    self.current_menu_x = old
                end
    
                if self.current_menu_x ~= old then
                    self:playMoveSound()
                end
            end
        elseif Input.is("right", key) then
            if self:checkMoveDelay(key) then
                if self.current_menu_columns > 1 then
                    self:playMoveSound()
                end
                local old_position = self.current_menu_x
                self.current_menu_x = self.current_menu_x + 1
                if not self:isValidMenuLocation() then
                    self.current_menu_x = old_position
                end
            end
        end
        if Input.is("up", key) then
            if self:checkMoveDelay(key) then
                local old_position = self.current_menu_y
                self.current_menu_y = self.current_menu_y - 1
                if not self:isValidMenuLocation() then
                    self.current_menu_y = old_position
                end
                if self:isPagerMenu() or self.current_menu_y ~= old_position then
                    self:playMoveSound()
                end
            end
        elseif Input.is("down", key) then
            if self:checkMoveDelay(key) then
                local old_position = self.current_menu_y
                self.current_menu_y = self.current_menu_y + 1
                if not self:isValidMenuLocation() then
                    self.current_menu_y = old_position
                end
                if self:isPagerMenu() or self.current_menu_y ~= old_position then
                    self:playMoveSound()
                end
            end
        end
    elseif self.state == "BUTNOBODYCAME" then
        if Input.isConfirm(key) then
            self.music:stop()
            self.current_selecting = 0

            for _, battler in ipairs(self.party) do
                battler:setSleeping(false)
                battler.defending = false
                battler.action = nil

                if battler.chara:getHealth() <= 0 then
                    battler:revive()
                    battler.chara:setHealth(battler.chara:autoHealAmount())
                end
            end

            self:setState("TRANSITIONOUT")
            self.encounter:onBattleEnd()
        end

    elseif self.state == "ENEMYSELECT" or self.state == "XACTENEMYSELECT" then

        if Input.isConfirm(key) then
            self.enemyselect_cursor_memory[self.state_reason] = self.current_menu_y

            self:playSelectSound()
            if #self.enemies == 0 then return end
            self.selected_enemy = self.current_menu_y
            if self.state == "XACTENEMYSELECT" then
                local xaction = Utils.copy(self.selected_xaction)
                if xaction.default then
                    xaction.name = self.enemies[self.selected_enemy]:getXAction(self.party[self.current_selecting])
                end
                self:pushAction("XACT", self.enemies[self.selected_enemy], xaction)
            elseif self.state_reason == "ACT" then
                self:clearMenuItems()
                local enemy = self.enemies[self.selected_enemy]
                for _,v in ipairs(enemy.acts) do
                    local insert = not v.hidden
                    if v.character and self.party[self.current_selecting].chara.id ~= v.character then
                        insert = false
                    end
                    if v.party and (#v.party > 0) then
                        for _,party_id in ipairs(v.party) do
                            if not self:getPartyIndex(party_id) then
                                insert = false
                                break
                            end
                        end
                    end
                    if insert then
                        self:addMenuItem({
                            ["name"] = v.name,
                            ["tp"] = v.tp or 0,
                            ["description"] = v.description,
                            ["party"] = v.party,
                            ["color"] = v.color or {1, 1, 1, 1},
                            ["highlight"] = v.highlight or enemy,
                            ["icons"] = v.icons,
                            ["callback"] = function(menu_item)
                                self:pushAction("ACT", enemy, menu_item)
                            end
                        })
                    end
                end
                self:setState("MENUSELECT", "ACT")
            elseif self.state_reason == "ATTACK" then
                self:pushAction("ATTACK", self.enemies[self.selected_enemy])
            elseif self.state_reason == "SPELL" then
                self:pushAction("SPELL", self.enemies[self.selected_enemy], self.selected_spell)
            elseif self.state_reason == "ITEM" then
                self:pushAction("ITEM", self.enemies[self.selected_enemy], self.selected_item)
            else
                self:nextParty()
            end
            return
        end
        if Input.isCancel(key) then    
            if self.state_reason == "SPELL" then
                self:setState("MENUSELECT", "SPELL")
            else
                self:setState("ACTIONSELECT", "CANCEL")
            end
            return
        end
        if Input.is("up", key) then
            if self:checkMoveDelay(key) then
                if #self.enemies == 0 then return end
                local old_location = self.current_menu_y
                local give_up = 0
                repeat
                    give_up = give_up + 1
                    if give_up > 100 then return end
                    self.current_menu_y = self.current_menu_y - 1
                    if self.current_menu_y < 1 then
                        self.current_menu_y = 1
                    end
                until (self.enemies[self.current_menu_y].selectable)
    
                if self.current_menu_y ~= old_location then
                    self:playMoveSound()
                end
            end
        elseif Input.is("down", key) then
            if self:checkMoveDelay(key) then
                local old_location = self.current_menu_y
                if #self.enemies == 0 then return end
                local give_up = 0
                repeat
                    give_up = give_up + 1
                    if give_up > 100 then return end
                    self.current_menu_y = self.current_menu_y + 1
                    if self.current_menu_y > #self.enemies then
                        self.current_menu_y = #self.enemies
                    end
                until (self.enemies[self.current_menu_y].selectable)
    
                if self.current_menu_y ~= old_location then
                    self:playMoveSound()
                end
            end
        end
    elseif self.state == "PARTYSELECT" then
        if Input.isConfirm(key) then
            self:playSelectSound()
            if self.state_reason == "SPELL" then
                self:pushAction("SPELL", self.party[self.current_menu_y], self.selected_spell)
            elseif self.state_reason == "ITEM" then
                self:pushAction("ITEM", self.party[self.current_menu_y], self.selected_item)
            else
                self:nextParty()
            end
            return
        end
        if Input.isCancel(key) then
            if self.state_reason == "SPELL" then
                self:setState("MENUSELECT", "SPELL")
            else
                self:setState("ACTIONSELECT", "CANCEL")
            end
            return
        end
        if Input.is("up", key) then
            if self:checkMoveDelay(key) then
                self:playMoveSound()
                self.current_menu_y = self.current_menu_y - 1
                if self.current_menu_y < 1 then
                    self.current_menu_y = 1
                end
            end
            self:addMoveDelay()
        elseif Input.is("down", key) then
            if self:checkMoveDelay(key) then
                self:playMoveSound()
                self.current_menu_y = self.current_menu_y + 1
                if self.current_menu_y > #self.party then
                    self.current_menu_y = #self.party
                end
            end
        end
    elseif self.state == "BATTLETEXT" then
        -- Nothing here
    elseif self.state == "SHORTACTTEXT" then
        if Input.isConfirm(key) then
            if (not self.battle_ui.short_act_text_1:isTyping()) and
               (not self.battle_ui.short_act_text_2:isTyping()) and
               (not self.battle_ui.short_act_text_3:isTyping()) then
                self.battle_ui.short_act_text_1:setText("")
                self.battle_ui.short_act_text_2:setText("")
                self.battle_ui.short_act_text_3:setText("")
                for _,iaction in ipairs(self.short_actions) do
                    self:finishAction(iaction)
                end
                self.short_actions = {}
                self:setState("ACTIONS", "SHORTACTTEXT")
            end
        end
    elseif self.state == "ENEMYDIALOGUE" then
        -- Nothing here
    elseif self.state == "ACTIONSELECT" then
        self:handleActionSelectInput(key)
    elseif self.state == "ATTACKING" then
        self:handleAttackingInput(key)
    end
end

function DeltatravelerBattle:handleActionSelectInput(key)
    if not self.encounter.story then
        local actbox = self.battle_ui.action_boxes[self.current_selecting]

        if Input.isConfirm(key) then
            actbox:select()
            self:playSelectSound()
            return
        elseif Input.isCancel(key) then
            self:previousParty()
            return
        elseif Input.is("left", key) then
            if self:checkMoveDelay(key) then
                actbox.selected_button = actbox.selected_button - 1
                self:playMoveSound()
                if actbox then
                    actbox:snapSoulToButton()
                end
            end
        elseif Input.is("right", key) then
            if self:checkMoveDelay(key) then
                actbox.selected_button = actbox.selected_button + 1
                self:playMoveSound()
                if actbox then
                    actbox:snapSoulToButton()
                end
            end
        end
    end
end

function DeltatravelerBattle:handleAttackingInput(key)
    if Input.isConfirm(key) then

        if not self.attack_done and not self.cancel_attack and self.battle_ui.attack_box then
            local closest
            local closest_attacks = {}
            local close

            for _,attack in ipairs(self.battle_ui.attack_box.lanes) do
                if not attack.attacked then
                    close = self.battle_ui.attack_box:getClose(attack)
                    if not closest then
                        closest = close
                        table.insert(closest_attacks, attack)
                    elseif close == closest then
                        table.insert(closest_attacks, attack)
                    elseif close < closest then
                        closest = close
                        closest_attacks = {attack}
                    end
                end
            end

            if closest then
                for _,attack in ipairs(closest_attacks) do
                    local points, stretch = self.battle_ui.attack_box:hit(attack)

                    local action = self:getActionBy(attack.battler)
                    action.points = points

                    if self:processAction(action) then
                        self:finishAction(action)
                    end
                end
            end
        end
    end
end

function DeltatravelerBattle:updateAttacking()
    if self.cancel_attack then
        self:finishAllActions()
        self:setState("ACTIONSDONE")
    end

    if not self.attack_done then
        if not self.battle_ui.attacking then
            self:toggleSoul(false)
            self.battle_ui:beginAttack()
        end

        if #self.attackers == #self.auto_attackers and self.auto_attack_timer < 4 then
            self.auto_attack_timer = self.auto_attack_timer + DTMULT

            if self.auto_attack_timer >= 4 then
                local next_attacker = self.auto_attackers[1]

                local next_action = self:getActionBy(next_attacker)
                if next_action then
                    self:beginAction(next_action)
                    self:processAction(next_action)
                end
            end
        end
        
        local all_done = false
        if self.battle_ui.attack_box.timer > 8 then
            all_done = true
            for _,attacker in ipairs(self.battle_ui.attack_box.lanes) do
                if not attacker.attacked then

                    local box = self.battle_ui.attack_box
                    if box:checkMiss(attacker) and #attacker.bolts > 1 then

                        all_done = false
                        box:miss(attacker)

                    elseif box:checkMiss(attacker) then

                        local points = box:miss(attacker)

                        local action = self:getActionBy(attacker.battler)
                        if attacker.attack_type == "slice" then
                            action.force_miss = true
                            action.points = points or 0
                            action.stretch = 0
                        else
                            action.points = points
                        end

                        if self:processAction(action) then
                            self:finishAction(action)
                        end
                    else
                        all_done = false
                    end
                end
            end
        end

        if all_done then
            self.attack_done = true
        end
    else
        if self:allActionsDone() then
            self:setState("ACTIONSDONE")
        end
    end
end

function DeltatravelerBattle:checkMoveDelay(key)
    if not Kristal.getLibConfig("magical-glass-deltatraveled", "menu_move_delay") then
        return true
    else
        local value = true
        if      ((self.last_input == "right" and key == "left"  )
            or   (self.last_input == "left"  and key == "right" )
            or   (self.last_input == "down"  and key == "up"    )
            or   (self.last_input == "up"    and key == "down"  ))
        then
            if self.menu_move_delay > 0 then
                value = false
            end
            self.menu_move_delay = 6
        end
        self.last_input = key
        return value
    end
end

function DeltatravelerBattle:nextParty()
    table.insert(self.selected_character_stack, self.current_selecting)
    table.insert(self.selected_action_stack, Utils.copy(self.character_actions))

    local all_done = true
    local last_selected = self.current_selecting
    self.current_selecting = (self.current_selecting % #self.party) + 1
    while self.current_selecting ~= last_selected do
        if not self:hasAction(self.current_selecting) and self.party[self.current_selecting]:isActive() then
            all_done = false
            break
        end
        self.current_selecting = (self.current_selecting % #self.party) + 1
    end

    if all_done then
        self.selected_character_stack = {}
        self.selected_action_stack = {}
        self.current_action_processing = 1
        self.current_selecting = 0
        self:startProcessing()
    else
        if self:getState() ~= "ACTIONSELECT" then
            self:setState("ACTIONSELECT")
            self.battle_ui.encounter_text:setText("[instant]" .. self.battle_ui.current_encounter_text)
        else
            local party = self.party[self.current_selecting]
            party.chara:onActionSelect(party, false)
            self.encounter:onCharacterTurn(party, false)
        end
    end
end

function DeltatravelerBattle:previousParty()
    if #self.selected_character_stack == 0 then
        return
    end

    if self.current_selecting ~= #self.party then
        local actbox = self.battle_ui.action_boxes[self.current_selecting]
        local next_actbox = self.battle_ui.action_boxes[self.current_selecting + 1]
        actbox.selected_button = next_actbox.selected_button
    end

    self.current_selecting = self.selected_character_stack[#self.selected_character_stack] or 1
    local new_actions = self.selected_action_stack[#self.selected_action_stack-1] or {}

    for i,battler in ipairs(self.party) do
        local old_action = self.character_actions[i]
        local new_action = new_actions[i]
        if new_action ~= old_action then
            if old_action.cancellable == false then
                new_actions[i] = old_action
            else
                if old_action then
                    self:removeSingleAction(old_action)
                end
                if new_action then
                    self:commitSingleAction(new_action)
                end
            end
        end
    end

    self.selected_action_stack[#self.selected_action_stack-1] = new_actions

    table.remove(self.selected_character_stack, #self.selected_character_stack)
    table.remove(self.selected_action_stack, #self.selected_action_stack)

    local party = self.party[self.current_selecting]
    party.has_selected_action = false
    party.chara:onActionSelect(party, true)
    self.encounter:onCharacterTurn(party, true)
end

function DeltatravelerBattle:pushAction(action_type, target, data, character_id, extra)
    character_id = character_id or self.current_selecting

    local battler = self.party[character_id]
    battler.has_selected_action = true

    local current_state = self:getState()

    self:commitAction(battler, action_type, target, data, extra)

    if self.current_selecting == character_id then
        if current_state == self:getState() then
            self:nextParty()
        elseif self.cutscene then
            self.cutscene:after(function()
                self:nextParty()
            end)
        end
    end
end

function DeltatravelerBattle:hurt(amount, exact, target)
    -- Note: 0, 1 and 2 are to target a specific party member.
    -- In Kristal, we'll allow them to be objects as well.
    -- Also in Kristal, they're 1, 2 and 3.
    -- 3 is "ALL" in Kristal,
    -- while 4 is "ANY".
    target = target or "ANY"

    -- Alright, first let's try to adjust targets.

    if type(target) == "number" then
        target = self.party[target]
    end

    if isClass(target) and (target:includes(PartyBattler) or target:includes(LightPartyBattler)) then
        if (not target) or (target.chara:getHealth() <= 0) then -- Why doesn't this look at :canTarget()? Weird.
            target = self:randomTargetOld()
        end
    end

    if target == "ANY" then
        target = self:randomTargetOld()

        local party_average_hp = 1

        for _,battler in ipairs(self.party) do
            if battler.chara:getHealth() ~= battler.chara:getStat("health") then
                party_average_hp = 0
                break
            end
        end

        if target.chara:getHealth() / target.chara:getStat("health") < (party_average_hp / 2) then
            target = self:randomTargetOld()
        end
        if target.chara:getHealth() / target.chara:getStat("health") < (party_average_hp / 2) then
            target = self:randomTargetOld()
        end

        if (target == self.party[1]) and ((target.chara:getHealth() / target.chara:getStat("health")) < 0.35) then
            target = self:randomTargetOld()
        end

        target.should_darken = false
        target.targeted = true
    end

    if isClass(target) and target:includes(LightPartyBattler) then
        target:hurt(amount, exact, target.chara:getLightHurtColor())
        return {target}
    end

    if target == "ALL" then
        Assets.playSound("hurt")
        for _,battler in ipairs(self.party) do
            if not battler.is_down then
                battler:hurt(amount, exact, nil, {all = true})
            end
        end

        return Utils.filter(self.party, function(item) return not item.is_down end)
    end
end

return DeltatravelerBattle