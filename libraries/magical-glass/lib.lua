LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightPartyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightpartybattler")
LightEnemyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightenemybattler")
LightEnemySprite         = libRequire("magical-glass", "scripts/lightbattle/lightenemysprite")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
--LightArenaBorder         = libRequire("magical-glass", "scripts/lightbattle/lightarenaborder")
--LightArenaSprite         = libRequire("magical-glass", "scripts/lightbattle/lightarenasprite")
LightEncounter           = libRequire("magical-glass", "scripts/lightbattle/lightencounter")
LightSoul                = libRequire("magical-glass", "scripts/lightbattle/lightsoul")
LightBattleUI            = libRequire("magical-glass", "scripts/lightbattle/ui/lightbattleui")
LightDamageNumber        = libRequire("magical-glass", "scripts/lightbattle/ui/lightdamagenumber")
LightGauge               = libRequire("magical-glass", "scripts/lightbattle/ui/lightgauge")
LightTensionBar          = libRequire("magical-glass", "scripts/lightbattle/ui/lighttensionbar")
LightActionButton        = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbutton")
LightActionBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbox")
LightActionBoxSingle     = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionboxsingle")
LightActionBoxDisplay    = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionboxdisplay")
LightAttackBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbox")
LightAttackBar           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbar")

MagicalGlassLib = {}
local lib = MagicalGlassLib

function lib:postInit(new_file)
    self.random_encounter = love.math.random(20, 100)
end

function lib:load()
    if Game.is_new_file then
        Game:setFlag("serious_mode", false) -- useful for genocide or boss battles
        Game:setFlag("always_show_magic", false)
        Game:setFlag("undertale_textbox_skipping", true)
        Game:setFlag("enable_lw_tp", false)
        Game:setFlag("lw_stat_menu_portraits", true)
        Game:setFlag("gauge_styles", "undertale") -- undertale, deltarune, deltatraveler
        Game:setFlag("name_color", COLORS.yellow) -- yellow, white, pink

        Game:setFlag("lw_stat_menu_style", "undertale") -- undertale, deltatraveler

        Game:setFlag("undertale_currency", false) -- use GOLD instead of money (separate currency, with separate values!)
        Game:setFlag("hide_cell", false) -- if the cell phone isn't unlocked, it doesn't show it in the menu (like in undertale) instead of showing it grayed-out like in deltarune

        Game:setFlag("savename_lw_menus", false) -- if true, will display the "savename" (the name you choose) instead of the party member's name when possible.

        Game:setFlag("random_encounter_table", {})
    end
end

function lib:registerLightEncounter(id)
    self.light_encounters[id] = class
end

function lib:getLightEncounter(id)
    return self.light_encounters[id]
end

function lib:createLightEncounter(id, ...)
    if self.light_encounters[id] then
        return self.light_encounters[id](...)
    else
        error("Attempt to create non existent light encounter \"" .. tostring(id) .. "\"")
    end
end

function lib:registerLightEnemy(id)
    self.light_enemies[id] = class
end

function lib:getLightEnemy(id)
    return self.light_enemies[id]
end

function lib:createLightEnemy(id, ...)
    if self.light_enemies[id] then
        return self.light_enemies[id](...)
    else
        error("Attempt to create non existent light enemy \"" .. tostring(id) .. "\"")
    end
end

function lib:registerDebugOptions(debug)
    local in_game = function() return Kristal.getState() == Game end
    local in_battle = function() return in_game() and Game.state == "BATTLE" end
    local in_overworld = function() return in_game() and Game.state == "OVERWORLD" end 

    debug:registerOption("main", "Start Light Encounter", "Start a light encounter.", function()
        debug:enterMenu("light_encounter_select", 0)
    end, in_overworld)

    debug:registerMenu("encounter_select", "Encounter Select", "search")
    -- loop through registry and add menu options for all encounters
    for id,_ in pairs(Registry.encounters) do
        debug:registerOption("encounter_select", id, "Start this encounter.", function()
            if Game:isLight() then
                Game:setLight(false)
                Game:setFlag("temporary_world_value#", "light")
            end
            Game:encounter(id)
            debug:closeMenu()
        end)
    end

    debug:registerMenu("light_encounter_select", "Select Light Encounter", "search")
    for id,_ in pairs(self.light_encounters) do
        if id ~= "_nobody" then
            debug:registerOption("light_encounter_select", id, "Start this encounter.", function()
                if not Game:isLight() then
                    Game:setLight(true)
                    Game:setFlag("temporary_world_value#", "dark")
                end
                Game:encounter(id)
                debug:closeMenu()
            end)
        end
    end
end

function lib:init()

    self.light_encounters = {}
    self.light_enemies = {}

    for _,path,light_enc in Registry.iterScripts("battle/lightencounters") do
        assert(light_enc ~= nil, '"lightencounters/'..path..'.lua" does not return value')
        light_enc.id = light_enc.id or path
        self.light_encounters[light_enc.id] = light_enc
    end

    for _,path,light_enemy in Registry.iterScripts("battle/lightenemies") do
        assert(light_enemy ~= nil, '"lightenemies/'..path..'.lua" does not return value')
        light_enemy.id = light_enemy.id or path
        self.light_enemies[light_enemy.id] = light_enemy
    end

    Utils.hook(Game, "load", function(orig, self, data, index, fade)

        orig(self, data, index, fade)
        self.is_new_file = data == nil

        data = data or {}
  
        if Game:getFlag("temporary_world_value#") then
            if Game:getFlag("temporary_world_value#") == "light" then
                self.inventory = DarkInventory()
            elseif Game:getFlag("temporary_world_value#") == "dark" then
                self.inventory = LightInventory()
            end
    
            if data.inventory then
                self.inventory:load(data.inventory)
            else
                local default_inv = Kristal.getModOption("inventory") or {}
                if not self.light and not default_inv["key_items"] then
                    default_inv["key_items"] = {"cell_phone"}
                end
                for storage,items in pairs(default_inv) do
                    for i,item in ipairs(items) do
                        self.inventory:setItem(storage, i, item)
                    end
                end
            end
        
            local loaded_light = data.light or false
        
            -- Party members have to be converted to light initially, due to dark world defaults
            if loaded_light ~= self.light then
                if self.light then
                    for _,chara in pairs(self.party_data) do
                        chara:convertToLight()
                    end
                else
                    for _,chara in pairs(self.party_data) do
                        chara:convertToDark()
                    end
                end
            end
        
            if self.is_new_file then
                if self.light then
                    Game:setFlag("has_cell_phone", Kristal.getModOption("cell") ~= false)
                end
        
                for id,equipped in pairs(Kristal.getModOption("equipment") or {}) do
                    if equipped["weapon"] then
                        self.party_data[id]:setWeapon(equipped["weapon"] ~= "" and equipped["weapon"] or nil)
                    end
                    local armors = equipped["armor"] or {}
                    for i = 1, 2 do
                        if armors[i] then
                            if self.light and i == 2 then
                                local main_armor = self.party_data[id]:getArmor(1)
                                if not main_armor:includes(LightEquipItem) then
                                    error("Cannot set 2nd armor, 1st armor must be a LightEquipItem")
                                end
                                main_armor:setArmor(2, armors[i])
                            else
                                self.party_data[id]:setArmor(i, armors[i] ~= "" and armors[i] or nil)
                            end
                        end
                    end
                end
            end
        end
    end)

    Utils.hook(Game, "encounter", function(orig, self, encounter, transition, enemy, context)
        -- the worst thing ever

        if context then
            if context.light_encounter then
                Game:encounterLight(encounter, transition, enemy, context)
            elseif context.encounter then
                orig(self, encounter, transition, enemy, context)
            end
        else
            if Game:getFlag("temporary_world_value#") then
                if Game:getFlag("temporary_world_value#") == "dark" then
                    if Game:isLight() then
                        Game:setLight(true)
                    else
                        Game.light = true
                    end
                    Game:encounterLight(encounter, transition, enemy, context)
                elseif Game:getFlag("temporary_world_value#") == "light" then
                    if not Game:isLight() then
                        Game:setLight(false)
                    else
                        Game.light = false
                    end
                    orig(self, encounter, transition, enemy, context)
                end
            else
                if Game:isLight() then
                    Game:encounterLight(encounter, transition, enemy, context)
                else
                    orig(self, encounter, transition, enemy, context)
                end
            end
        end

    end)

    Utils.hook(DarkInventory, "convertToLight", function(orig, self)
        local new_inventory = LightInventory()

        local was_storage_enabled = new_inventory.storage_enabled
        new_inventory.storage_enabled = true
    
        Kristal.callEvent("onConvertToLight", new_inventory)
    
        for _,storage_id in ipairs(self.convert_order) do
            local storage = Utils.copy(self:getStorage(storage_id))
            for i = 1, storage.max do
                local item = storage[i]
                if item then
                    local result = item:convertToLight(new_inventory) or (storage.id == "light" and item)
    
                    if result then
                        self:removeItem(item)
    
                        if type(result) == "string" then
                            result = Registry.createItem(result)
                        end
                        if isClass(result) then
                            result.dark_item = item
                            result.dark_location = {storage = storage.id, index = i}
                            new_inventory:addItem(result)
                        end
                    end
                end
            end
        end
    
        if Game:getFlag("temporary_world_value#") then
            local ball = Registry.createItem("light/ball_of_junk", self)
            new_inventory:addItemTo("items", 1, ball)
        end
    
        new_inventory.storage_enabled = was_storage_enabled
    
        return new_inventory
    end)

    Utils.hook(LightInventory, "getDarkInventory", function(orig, self)
        orig(self)
        
    end)

    Utils.hook(ChaserEnemy, "init", function(orig, self, actor, x, y, properties)
    
        ChaserEnemy.__super.init(self, actor, x, y)

        properties = properties or {}
    
        if properties["sprite"] then
            self.sprite:setSprite(properties["sprite"])
        elseif properties["animation"] then
            self.sprite:setAnimation(properties["animation"])
        end
    
        if properties["facing"] then
            self:setFacing(properties["facing"])
        end
    
        self.encounter = properties["encounter"]
        self.light_encounter = properties["lightencounter"]

        self.enemy = properties["enemy"]
        self.light_enemy = properties["lightenemy"]

        self.group = properties["group"]
    
        self.path = properties["path"]
        self.speed = properties["speed"] or 6
    
        self.progress = (properties["progress"] or 0) % 1
        self.reverse_progress = false
    
        self.can_chase = properties["chase"]
        self.chase_speed = properties["chasespeed"] or 9
        self.chase_dist = properties["chasedist"] or 200
        self.chasing = properties["chasing"] or false
    
        self.alert_timer = 0
        self.alert_icon = nil
    
        self.noclip = true
        self.enemy_collision = true
    
        self.remove_on_encounter = true
        self.encountered = false
        self.once = properties["once"] or false
    
        if properties["aura"] == nil then
            self.sprite.aura = Game:getConfig("enemyAuras")
        else
            self.sprite.aura = properties["aura"]
        end

    end)

    Utils.hook(ChaserEnemy, "onCollide", function(orig, self, player)

        if self:isActive() and player:includes(Player) then
            self.encountered = true
            local encounter
            local enemy
            
            if self.encounter and self.light_encounter then
                if Game:isLight() then
                    encounter = self.light_encounter
                    enemy = self.light_enemy
                else
                    encounter = self.encounter
                    enemy = self.enemy
                end
            elseif self.encounter then
                encounter = self.encounter
                enemy = self.enemy
            elseif self.light_encounter then
                encounter = self.light_encounter
                enemy = self.light_enemy
            end

            if not encounter then
                if Game:isLight() and MagicalGlassLib:getLightEnemy(self.enemy or self.actor.id) then
                    encounter = LightEncounter()
                    encounter:addEnemy(self.actor.id)
                elseif not Game:isLight() and Registry.getEnemy(self.light_enemy or self.actor.id) then
                    encounter = Encounter()
                    encounter:addEnemy(self.actor.id)
                end
            end

            if encounter then
                self.world.encountering_enemy = true
                self.sprite:setAnimation("hurt")
                self.sprite.aura = false
                Game.lock_movement = true
                self.world.timer:script(function(wait)
                    Assets.playSound("tensionhorn")
                    wait(8/30)
                    local src = Assets.playSound("tensionhorn")
                    src:setPitch(1.1)
                    wait(12/30)
                    self.world.encountering_enemy = false
                    Game.lock_movement = false
                    local enemy_target = self
                    if enemy then
                        enemy_target = {{enemy, self}}
                    end
                    Game:encounter(encounter, true, enemy_target, self)
                end)
            end

        end
    end)

    Utils.hook(Battle, "postInit", function(orig, self, state, encounter)
        self.state = state
    
        if type(encounter) == "string" then
            self.encounter = Registry.createEncounter(encounter)
        else
            self.encounter = encounter
        end

        if self.encounter:includes(LightEncounter) then
            error("Attempted to create a LightEncounter in a Dark battle")
        end

        if Game.world.music:isPlaying() and self.encounter.music then
            self.resume_world_music = true
            Game.world.music:pause()
        end
    
        if self.encounter.queued_enemy_spawns then
            for _,enemy in ipairs(self.encounter.queued_enemy_spawns) do
                if state == "TRANSITION" then
                    enemy.target_x = enemy.x
                    enemy.target_y = enemy.y
                    enemy.x = SCREEN_WIDTH + 200
                end
                table.insert(self.enemies, enemy)
                self:addChild(enemy)
            end
        end
    
        self.battle_ui = BattleUI()
        self:addChild(self.battle_ui)
    
        self.tension_bar = TensionBar(-25, 40, true)
        self:addChild(self.tension_bar)
    
        self.battler_targets = {}
        for index, battler in ipairs(self.party) do
            local target_x, target_y = self.encounter:getPartyPosition(index)
            table.insert(self.battler_targets, {target_x, target_y})
    
            if state ~= "TRANSITION" then
                battler:setPosition(target_x, target_y)
            end
        end
    
        for _,enemy in ipairs(self.enemies) do
            self.enemy_beginning_positions[enemy] = {enemy.x, enemy.y}
        end
        if Game.encounter_enemies then
            for _,from in ipairs(Game.encounter_enemies) do
                if not isClass(from) then
                    local enemy = self:parseEnemyIdentifier(from[1])
                    from[2].visible = false
                    from[2].battler = enemy
                    self.enemy_beginning_positions[enemy] = {from[2]:getScreenPos()}
                    self.enemy_world_characters[enemy] = from[2]
                    if state == "TRANSITION" then
                        enemy:setPosition(from[2]:getScreenPos())
                    end
                else
                    for _,enemy in ipairs(self.enemies) do
                        if enemy.actor and from.actor and enemy.actor.id == from.actor.id then
                            from.visible = false
                            from.battler = enemy
                            self.enemy_beginning_positions[enemy] = {from:getScreenPos()}
                            self.enemy_world_characters[enemy] = from
                            if state == "TRANSITION" then
                                enemy:setPosition(from:getScreenPos())
                            end
                            break
                        end
                    end
                end
            end
        end
    
        if self.encounter_context and self.encounter_context:includes(ChaserEnemy) then
            for _,enemy in ipairs(self.encounter_context:getGroupedEnemies(true)) do
                enemy:onEncounterStart(enemy == self.encounter_context, self.encounter)
            end
        end
    
        if state == "TRANSITION" then
            self.transitioned = true
            self.transition_timer = 0
            self.afterimage_count = 0
        else
            self.transition_timer = 10
    
            if state ~= "INTRO" then
                self:nextTurn()
            end
        end
    
        if not self.encounter:onBattleInit() then
            self:setState(state)
        end

    end)

    Utils.hook(Battle, "returnToWorld", function(orig, self)
    
        orig(self)
        if Game:getFlag("temporary_world_value#") == "light" then
            Game:setLight(true)
            Game:setFlag("temporary_world_value#", nil)
        end

    end)
    
    Utils.hook(Wave, "setTargetSize", function(orig, self, width, height)
        self.arena_width = width
        self.arena_height = height or width
    end)

    Utils.hook(Item, "init", function(orig, self)
    
        orig(self)
        -- Short name for the light battle item menu
        self.short_name = nil
        -- Serious name for the light battle item menu
        self.serious_name = nil
    
    end)

    Utils.hook(Item, "getShortName", function(orig, self) return self.short_name or self.serious_name or self.name end)
    Utils.hook(Item, "getSeriousName", function(orig, self) return self.serious_name or self.short_name or self.name end)

    Utils.hook(Item, "onCheck", function(orig, self)
        if type(self.check) == "string" then
            Game.world:showText("* \""..self:getName().."\" - "..self:getCheck())
        elseif type(self.check) == "table" then
            local text = {}
            for i, check in ipairs(self:getCheck()) do
                if i > 1 then
                    table.insert(text, check)
                end
            end
            Game.world:showText({{"* \""..self:getName().."\" - "..self:getCheck()[1]}, text})
        end
    end)
    
    Utils.hook(Battler, "lightStatusMessage", function(orig, self, x, y, type, arg, color, kill)
        x, y = self:getRelativePos(x, y)

        local offset = 0
        if not kill then
            offset = (self.hit_count * 20)
        end
        
        local offset_x, offset_y = Utils.unpack(self:getDamageOffset())

        if type ~= "msg" and self:getHPVisibility() then
            if self.gauge then
                self.gauge.amount = self.gauge.amount + arg
                self.gauge.timer = 0
            else
                self.gauge = LightGauge(type, arg, x + offset_x, y + offset_y + 8, self)
                self.parent:addChild(self.gauge)
            end
        end
    
        local percent = LightDamageNumber(type, arg, x + offset_x, y + offset_y - offset, color)
        if kill then
            percent.kill_others = true
        end
        self.parent:addChild(percent)
    
        if not kill then
            self.hit_count = self.hit_count + 1
        end
    
        return percent
    end)

    Utils.hook(DialogueText, "init", function(orig, self, ...)
    
        orig(self, ...)
        self.hold_skip = true

    end)

    Utils.hook(DialogueText, "update", function(orig, self)
        local speed = self.state.speed

        if not OVERLAY_OPEN then

            if not self.hold_skip then

                local input = self.can_advance and (Input.pressed("confirm") or (Input.down("menu") and self.fast_skipping_timer >= 1))

                if input or self.auto_advance or self.should_advance then
                    self.should_advance = false
                    if not self.state.typing then
                        self:advance()
                    end
                end
        
                if self.skippable and (Input.pressed("cancel") and not self.state.noskip) then
                    if not self.skip_speed then
                        self.state.skipping = true
                    else
                        speed = speed * 2
                    end
                end

            else
                if Input.pressed("menu") then
                    self.fast_skipping_timer = 1
                end
        
                local input = self.can_advance and (Input.pressed("confirm") or (Input.down("menu") and self.fast_skipping_timer >= 1))
        
                if input or self.auto_advance or self.should_advance then
                    self.should_advance = false
                    if not self.state.typing then
                        self:advance()
                    end
                end
        
                if Input.down("menu") then
                    if self.fast_skipping_timer < 1 then
                        self.fast_skipping_timer = self.fast_skipping_timer + DTMULT
                    end
                else
                    self.fast_skipping_timer = 0
                end
                
                if self.skippable and ((Input.down("cancel") and not self.state.noskip) or (Input.down("menu") and not self.state.noskip)) then
                    if not self.skip_speed then
                        self.state.skipping = true
                    else
                        speed = speed * 2
                    end
                end
            end
    
        end
    
        if self.state.waiting == 0 then
            self.state.progress = self.state.progress + (DT * 30 * speed)
        else
            self.state.waiting = math.max(0, self.state.waiting - DT)
        end
    
        if self.state.typing then
            self:drawToCanvas(function()
                while (math.floor(self.state.progress) > self.state.typed_characters) or self.state.skipping do
                    local current_node = self.nodes[self.state.current_node]
    
                    if current_node == nil then
                        self.state.typing = false
                        break
                    end
    
                    self:playTextSound(current_node)
                    self:processNode(current_node, false)
    
                    if self.state.skipping then
                        self.state.progress = self.state.typed_characters
                    end
    
                    self.state.current_node = self.state.current_node + 1
                end
            end)
        end
    
        self:updateTalkSprite(self.state.talk_anim and self.state.typing)
    
        DialogueText.__super.update(self)
    
        self.last_talking = self.state.talk_anim and self.state.typing
    end)

    -- bullets need a min and max damage argument

    Utils.hook(Bullet, "init", function(orig, self, x, y, texture)
    
        orig(self, x, y, texture)
        if Game:isLight() then
            self.inv_timer = 1
        end

    end)

    Utils.hook(LightItemMenu, "init", function(orig, self)
    
        orig(self)

        -- States: ITEMSELECT, ITEMOPTION, PARTYSELECT

        self.party_select_bg = UIBox(-36, 242, 372, 52)
        self.party_select_bg.visible = false
        self.party_select_bg.layer = -1
        self.party_selecting = 1
        self:addChild(self.party_select_bg)

    end)

    Utils.hook(LightItemMenu, "update", function(orig, self)
    
        if self.state == "ITEMOPTION" then
            if Input.pressed("cancel") then
                self.state = "ITEMSELECT"
                return
            end
    
            local old_selecting = self.option_selecting
    
            if Input.pressed("left") then
                self.option_selecting = self.option_selecting - 1
            end
            if Input.pressed("right") then
                self.option_selecting = self.option_selecting + 1
            end
    
            -- this wraps in deltatraveler lmao
            self.option_selecting = Utils.clamp(self.option_selecting, 1, 3)
    
            if self.option_selecting ~= old_selecting then
                self.ui_move:stop()
                self.ui_move:play()
            end
    
            if Input.pressed("confirm") then
                local item = Game.inventory:getItem(self.storage, self.item_selecting)
                if self.option_selecting == 1 then
                    if #Game.party > 1 and item.target == "ally" then
                        self.ui_select:stop()
                        self.ui_select:play()
                        self.party_select_bg.visible = true
                        self.party_selecting = 1
                        self.state = "PARTYSELECT"
                    elseif #Game.party > 1 and item.target == "party" then
                        self.ui_select:stop()
                        self.ui_select:play()
                        self.party_select_bg.visible = true
                        self.party_selecting = "all"
                        self.state = "PARTYSELECT"
                    else
                        self:useItem(item)
                    end
                elseif self.option_selecting == 2 then
                    item:onCheck()
                else
                    self:dropItem(item)
                end
            end
        elseif self.state == "PARTYSELECT" then
            if Input.pressed("cancel") then
                self.party_select_bg.visible = false
                self.state = "ITEMOPTION"
                return
            end
    
            if self.party_selecting ~= "all" then
                local old_selecting = self.party_selecting

                if Input.pressed("right") then
                    self.party_selecting = self.party_selecting + 1
                end
        
                if Input.pressed("left") then
                    self.party_selecting = self.party_selecting - 1
                end

                self.party_selecting = Utils.clamp(self.party_selecting, 1, #Game.party)

                if self.party_selecting ~= old_selecting then
                    self.ui_move:stop()
                    self.ui_move:play()
                end

                if Input.pressed("confirm") then
                    local item = Game.inventory:getItem(self.storage, self.item_selecting)
                    self:useItem(item, self.party_selecting)
                end
            else
                if Input.pressed("confirm") then
                    local item = Game.inventory:getItem(self.storage, self.item_selecting)
                    self:useItem(item, Game.party)
                end
            end

        else
            orig(self)
        end

    end)

    Utils.hook(LightItemMenu, "draw", function(orig, self)
        love.graphics.setFont(self.font)

        local inventory = Game.inventory:getStorage(self.storage)
    
        for index, item in ipairs(inventory) do
            if item.usable_in == "world" or item.usable_in == "all" then
                Draw.setColor(PALETTE["world_text"])
            else
                Draw.setColor(PALETTE["world_text_unusable"])
            end
            if self.state == "PARTYSELECT" then
                love.graphics.setScissor(self.x, self.y, 300, 220)
            end
            love.graphics.print(item:getName(), 20, -28 + (index * 32))
            love.graphics.setScissor()
        end

        if self.state ~= "PARTYSELECT" then
            Draw.setColor(PALETTE["world_text"])
            love.graphics.print("USE" , 20 , 284)
            love.graphics.print("INFO", 116, 284)
            love.graphics.print("DROP", 230, 284)
        end
    
        Draw.setColor(Game:getSoulColor())
        if self.state == "ITEMSELECT" then
            Draw.draw(self.heart_sprite, -4, -20 + (32 * self.item_selecting), 0, 2, 2)
        elseif self.state == "ITEMOPTION" then
            if self.option_selecting == 1 then
                Draw.draw(self.heart_sprite, -4, 292, 0, 2, 2)
            elseif self.option_selecting == 2 then
                Draw.draw(self.heart_sprite, 92, 292, 0, 2, 2)
            elseif self.option_selecting == 3 then
                Draw.draw(self.heart_sprite, 206, 292, 0, 2, 2)
            end
        elseif self.state == "PARTYSELECT" then
            local item = Game.inventory:getItem(self.storage, self.item_selecting)
            Draw.setColor(PALETTE["world_text"])

            love.graphics.printf("Use " .. item:getName() .. " on...", 5, 233, 300, "center")

            if #Game.party == 2 then
                local offset = 0
                for _,party in ipairs(Game.party) do
                    love.graphics.print(party.name, 68 + offset, 269)
                    offset = offset + 122
                end

                Draw.setColor(Game:getSoulColor())
                if self.party_selecting == 1 then
                    Draw.draw(self.heart_sprite, 35, 277, 0, 2, 2)
                elseif self.party_selecting == 2 then
                    Draw.draw(self.heart_sprite, 157, 277, 0, 2, 2)
                else
                    Draw.draw(self.heart_sprite, 35, 277, 0, 2, 2)
                    Draw.draw(self.heart_sprite, 157, 277, 0, 2, 2)
                end

            elseif #Game.party == 3 then
                local offset = 0
                for _,party in ipairs(Game.party) do
                    love.graphics.print(party.name, -2 + offset, 269)
                    offset = offset + 122
                end

                Draw.setColor(Game:getSoulColor())
                if self.party_selecting == 1 then
                    Draw.draw(self.heart_sprite, -35, 277, 0, 2, 2)
                elseif self.party_selecting == 2 then
                    Draw.draw(self.heart_sprite, 87, 277, 0, 2, 2)
                elseif self.party_selecting == 3 then
                    Draw.draw(self.heart_sprite, 209, 277, 0, 2, 2)
                else
                    Draw.draw(self.heart_sprite, -35, 277, 0, 2, 2)
                    Draw.draw(self.heart_sprite, 87, 277, 0, 2, 2)
                    Draw.draw(self.heart_sprite, 209, 277, 0, 2, 2)
                end
            end

        end

        LightItemMenu.__super.draw(self)

    end)

    Utils.hook(LightItemMenu, "useItem", function(orig, self, item)
        
        if item.target == "ally" then
            local result = item:onWorldUse(Game.party[self.party_selecting])
        elseif item.target == "party" or item.target == "none" then
            local result = item:onWorldUse(Game.party)
        end
        
        if (item.type == "item" and (result == nil or result)) or (item.type ~= "item" and result) then
            if item:hasResultItem() then
                Game.inventory:replaceItem(item, item:createResultItem())
            else
                Game.inventory:removeItem(item)
            end
        end

    end)

    Utils.hook(World, "heal", function(orig, self, target, amount, text, item)
  
        if type(target) == "string" then
            target = Game:getPartyMember(target)
        end
        
        local play_sound = true
        if Game:isLight() then
            play_sound = false
        end

        local maxed = target:heal(amount, play_sound)

        if Game:isLight() then
            local message
            if item then
                message = item:getWorldHealingText(target, amount, maxed)
            end

            if text then
                message = text .. " \n" .. message
            end

            if not Game.cutscene_active then
                Game.world:showText(message)
            end
        elseif self.healthbar then
            for _, actionbox in ipairs(self.healthbar.action_boxes) do
                if actionbox.chara.id == target.id then
                    local text = HPText("+" .. amount, self.healthbar.x + actionbox.x + 69, self.healthbar.y + actionbox.y + 15)
                    text.layer = WORLD_LAYERS["ui"] + 1
                    Game.world:addChild(text)
                    return
                end
            end
        end
    
    end)

    Utils.hook(PartyMember, "init", function(orig, self)
    
        orig(self)

        self.dw_weapon_default = "wood_blade"
        if Game.chapter >= 2 then
            self.dw_armor_default = {"amber_card", "amber_card"}
        else
            self.dw_armor_default = {}
        end

        self.lw_portrait = nil

        self.light_color = nil
        self.light_dmg_color = nil
        self.light_attack_bar_color = nil
        self.light_xact_color = nil

        self.lw_stats = {
            health = 20,
            attack = 10,
            defense = 10,
            magic = 0
        }

    end)

    Utils.hook(PartyMember, "onLightLevelUp", function(orig, self)

        if self:getLightLV() < #self.lw_exp_needed then
            local old_lv = self:getLightLV()

            local new_lv
            for lv, exp in pairs(self.lw_exp_needed) do
                if self.lw_exp >= exp then
                    new_lv = lv
                end
            end

            if old_lv ~= new_lv and new_lv <= #self.lw_exp_needed then
                Assets.stopAndPlaySound("levelup")
                self:setLightLV(new_lv)

                self.lw_stats = {
                    health = (16 + (self:getLightLV() * 4)),
                    attack = (8 + (self:getLightLV() * 2)),
                    defense = (9 + math.ceil(self:getLightLV() / 4)),
                    magic = 0
                }
        
                if self:getLightLV() >= #self.lw_exp_needed then
                    self.lw_stats = {
                        health = 99,
                        attack = 99,
                        defense = 99,
                        magic = 0
                    }
                end
            end
        end

    end)

    Utils.hook(PartyMember, "setLightEXP", function(orig, self, exp, level_up)
        self.lw_exp = exp

        if level_up then
            self:onLightLevelUp()
        end
    end)

    Utils.hook(PartyMember, "gainLightEXP", function(orig, self, exp, level_up)
        self.lw_exp = self.lw_exp + exp

        if level_up then
            self:onLightLevelUp()
        end
    end)

    Utils.hook(PartyMember, "setLightLV", function(orig, self, level)
        self.lw_lv = level
        self:onLightLevelUp(level)
    end)

    Utils.hook(PartyMember, "forceLV", function(orig, self, level, ignore_cap)
        self.lw_lv = level

        if self.lw_lv >= #self.lw_exp_needed then
            self.lw_exp = self.lw_exp_needed[#self.lw_exp_needed]
        else
            self.lw_exp = self:getLightEXPNeeded(level)
        end

        self.lw_stats = {
            health = (16 + (self:getLightLV() * 4)),
            attack = (8 + (self:getLightLV() * 2)),
            defense = (9 + math.ceil(self:getLightLV() / 4)),
            magic = 0
        }

        if not ignore_cap then
            if self:getLightLV() >= #self.lw_exp_needed then
                self.lw_stats = {
                    health = 99,
                    attack = 99,
                    defense = 99,
                    magic = 0
                }
            end
        end
    end)

    Utils.hook(PartyMember, "getLightPortrait", function(orig, self) return self.lw_portrait end)

    Utils.hook(PartyMember, "getLightColor", function(orig, self)
        if self.light_color then
            return Utils.unpackColor(self.light_color)
        else
            return self:getColor()
        end
    end)

    Utils.hook(PartyMember, "getLightDamageColor", function(orig, self)
        if self.light_dmg_color then
            return Utils.unpackColor(self.light_dmg_color)
        else
            return self:getLightColor()
        end
    end)

    Utils.hook(PartyMember, "getLightAttackBarColor", function(orig, self)
        if self.light_attack_bar_color then
            return Utils.unpackColor(self.light_attack_bar_color)
        else
            return self:getLightColor()
        end
    end)

    Utils.hook(PartyMember, "getLightXActColor", function(orig, self)
        if self.light_xact_color then
            return Utils.unpackColor(self.light_xact_color)
        else
            return self:getLightColor()
        end
    end)

    Utils.hook(LightStatMenu, "init", function(orig, self)
    
        orig(self)
        self.party_selecting = 1
        
    end)

    Utils.hook(LightStatMenu, "update", function(orig, self)
        local chara = Game.party[self.party_selecting]

        local old_selecting = self.party_selecting
    
        if Input.pressed("right") then
            self.party_selecting = self.party_selecting + 1
        end

        if Input.pressed("left") then
            self.party_selecting = self.party_selecting - 1
        end

        if self.party_selecting > #Game.party then
            self.party_selecting = 1
        end

        if self.party_selecting < 1 then
            self.party_selecting = #Game.party
        end

        if self.party_selecting ~= old_selecting then
            self.ui_move:stop()
            self.ui_move:play()
        end

        if Input.pressed("cancel") then
            self.ui_move:stop()
            self.ui_move:play()
            Game.world.menu:closeBox()
            return
        end

        LightStatMenu.__super.update(self)

    end)

    Utils.hook(LightStatMenu, "draw", function(orig, self)
    
        love.graphics.setFont(self.font)
        Draw.setColor(PALETTE["world_text"])
    
        local chara = Game.party[self.party_selecting]
        local offset = 0

        if Game:getFlag("lw_stat_menu_portraits") then
            local ox, oy = chara.actor:getPortraitOffset()
            if chara:getLightPortrait() then
                Draw.draw(Assets.getTexture(chara:getLightPortrait()), 180 + ox, 7 + oy, 0, 2, 2)
            end

            if #Game.party > 1 then
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, 212, 124, 0, 2, 2)

                Draw.setColor(PALETTE["world_text"])
                love.graphics.print("<                >", 162, 116)
            end
        end

        if Game.save_name and Game:getFlag("savename_lw_menus", false) == true then
            love.graphics.print("\"" .. Game.save_name .. "\"", 4, 8)
        else
            love.graphics.print("\"" .. chara:getName() .. "\"", 4, 8)
        end 
        love.graphics.print("LV  "..chara:getLightLV(), 4, 68)
        love.graphics.print("HP  "..chara:getHealth().." / "..chara:getStat("health"), 4, 100)
    
        local exp_needed = math.max(0, chara:getLightEXPNeeded(chara:getLightLV() + 1) - chara:getLightEXP())
    
        love.graphics.print("AT  "  .. chara:getBaseStats()["attack"]  .. " ("..chara:getEquipmentBonus("attack")  .. ")", 4, 164)
        love.graphics.print("DF  "  .. chara:getBaseStats()["defense"] .. " ("..chara:getEquipmentBonus("defense") .. ")", 4, 196)
        if Game:getFlag("always_show_magic") or chara.lw_stats.magic > 0 then
            --love.graphics.print("MG  ", 4, 228)
            --love.graphics.print(chara:getBaseStats()["magic"]   .. " ("..chara:getEquipmentBonus("magic")   .. ")", 44, 228)
            love.graphics.print("MG  ", 4, 132)
            love.graphics.print(chara:getBaseStats()["magic"]   .. " ("..chara:getEquipmentBonus("magic")   .. ")", 44, 132)
            --offset = 18
        end
        love.graphics.print("EXP: " .. chara:getLightEXP(), 172, 164)
        love.graphics.print("NEXT: ".. exp_needed, 172, 196)
    
        local weapon_name = chara:getWeapon() and chara:getWeapon():getName() or ""
        local armor_name = chara:getArmor(1) and chara:getArmor(1):getName() or ""
    
        --[[
        love.graphics.print("WEAPON: "..weapon_name, 4, 256 + offset)
        love.graphics.print("ARMOR: "..armor_name, 4, 288 + offset)
        ]]
        love.graphics.print("WEAPON: "..weapon_name, 4, 256)
        love.graphics.print("ARMOR: "..armor_name, 4, 288)
    
        --love.graphics.print(Game:getConfig("lightCurrency"):upper()..": "..Game.lw_money, 4, 328 + offset)
        if not Game:getFlag("undertale_currency", false) then
            love.graphics.print(Game:getConfig("lightCurrency"):upper()..": "..Game.lw_money, 4, 328)
        else
            love.graphics.print(Kristal.getLibConfig("magical-glass", "undertaleCurrency"):upper()..": "..Game.ut_money or 0, 4, 328)
        end

    end)

    Utils.hook(Game, "save", function(orig, self, x, y)
        orig(self, x, y)

        local data = {
            chapter = self.chapter,

            name = self.save_name,
            level = self.save_level,
            playtime = self.playtime,

            light = self.light,

            room_name = self.world and self.world.map and self.world.map.name or "???",
            room_id = self.world and self.world.map and self.world.map.id,

            money = self.money,
            xp = self.xp,

            tension = self.tension,
            max_tension = self.max_tension,

            lw_money = self.lw_money,

            ut_money = self.ut_money or 0,

            level_up_count = self.level_up_count,

            border = self.border,

            temp_followers = self.temp_followers,

            flags = self.flags
        }

        if x then
            if type(x) == "string" then
                data.spawn_marker = x
            elseif type(x) == "table" then
                data.spawn_position = x
            elseif x and y then
                data.spawn_position = { x, y }
            end
        end

        data.party = {}
        for _, party in ipairs(self.party) do
            table.insert(data.party, party.id)
        end

        data.inventory = self.inventory:save()

        data.party_data = {}
        for k, v in pairs(self.party_data) do
            data.party_data[k] = v:save()
        end

        Kristal.callEvent("save", data)

        return data
    end)

    Utils.hook(Game, "load", function(orig, self, data, index, fade)
        orig(self, data, index, fade)

        self.is_new_file = data == nil

        data = data or {}

        self.ut_money = data.ut_money or 0
    end)

    Utils.hook(Inventory, "getItemIndex", function(orig, self, item)
        if type(item) == "string" then
            for k,v in pairs(self.stored_items) do
                if k.id == item then
                    return v.storage, v.index
                end
            end
        else
            local stored = self.stored_items[item]
            if stored then
                return stored.storage, stored.index
            end
        end
    end)

    Utils.hook(Inventory, "replaceItem", function(orig, self, item, new)
        local storage, index = self:getItemIndex(item)
        if storage and new then
            return self:setItem(storage, index, new)
        end
    end)


    PALETTE["pink_spare"] = {1, 167/255, 212/255, 1}
    BATTLE_LAYERS["arena_frame"] = BATTLE_LAYERS["arena"] + 10

end

function lib:changeSpareColor(color)
    if color == "yellow" then
        Game:setFlag("name_color", COLORS.yellow)
    elseif color == "pink" then
        Game:setFlag("name_color", PALETTE["pink_spare"])
    elseif color == "white" then
        Game:setFlag("name_color", COLORS.white)
    end
end

function Game:encounterLight(encounter, transition, enemy, context)

    if not self.light then
        self.light = true
    end

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

    self.battle = LightBattle()

    if context then
        self.battle.encounter_context = context
    end

    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "ACTIONSELECT", encounter)
    end

    self.stage:addChild(self.battle)

end

function lib:onFootstep(chara, num)
    
    if Game.world.map:getEvent("random_encounter") ~= nil then

        self.random_encounter = self.random_encounter - 1

        if chara == Game.world.player and self.random_encounter < 0 then
            if not Game.world.cutscene and not Game.battle then
                Game.world:startCutscene(function(cutscene)
                    Assets.stopAndPlaySound("alert")
                    local sprite = Sprite("effects/alert", Game.world.player.width/2)
                    sprite:setScale(1,1)
                    sprite:setOrigin(0.5, 1)
                    Game.world.player:addChild(sprite)
                    sprite.layer = WORLD_LAYERS["above_events"]
                    cutscene:wait(0.75)
                    sprite:remove()
                    cutscene:startEncounter("dummy", true)
                end)
                self.random_encounter = love.math.random(20, 100)
            end
        end

    end

end

return lib