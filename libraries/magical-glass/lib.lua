LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightPartyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightpartybattler")
LightEnemyBattler        = libRequire("magical-glass", "scripts/lightbattle/lightenemybattler")
LightEnemySprite         = libRequire("magical-glass", "scripts/lightbattle/lightenemysprite")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
LightArenaSprite         = libRequire("magical-glass", "scripts/lightbattle/lightarenasprite")
LightArenaBackground     = libRequire("magical-glass", "scripts/lightbattle/lightarenabackground")
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
RandomEncounter          = libRequire("magical-glass", "scripts/randomencounter")

MagicalGlassLib = {}
local lib = MagicalGlassLib

function lib:load()
    if Kristal.getModOption("encounter") then
        Game.save_name = Kristal.Config["defaultName"] or "PLAYER"
    end
    
    if Game.is_new_file then
        Game:setFlag("#game_overs", 0)
        Game:setFlag("#default_battle_system", "undertale") -- undertale, deltarune
        Game:setFlag("#force_light_mode_in_light_battles", false)
        Game:setFlag("#serious_mode", false) -- makes items use their serious name in battle, if they have one
        Game:setFlag("#always_show_magic", false) -- always show the magic stat in the light world
        Game:setFlag("#undertale_text_skipping", true) -- can't skip with c or hold z to skip
        Game:setFlag("#undertale_save_menu", true)
        Game:setFlag("#undertale_stat_display", true) -- subtracts 10 from at and df in the stat menu
        Game:setFlag("#enable_lw_tp", false) -- enables tp in light world battles
        Game:setFlag("#enable_low_hp_tired", true) -- whether enemies become tired once their hp is low enough
        Game:setFlag("#button_flashing", true) -- flashes the spell/mercy buttons when an enemy is tired/sparable
        Game:setFlag("#lw_stat_menu_portraits", "magical_glass") -- magical_glass, deltatraveler
        Game:setFlag("#gauge_styles", "undertale") -- undertale, deltarune
        Game:setFlag("#name_color", COLORS.yellow) -- yellow, white, pink
        Game:setFlag("#remove_overheal", true)
        Game:setFlag("#prevent_turn_1_flee", false) -- used for the first froggit encounter
        Game:setFlag("#limit_hp_gauge_length", false) -- false: no limit, true: 99, integer

        Game:setFlag("#lw_stat_menu_style", "undertale") -- undertale, deltatraveler

        Game:setFlag("#hide_cell", false) -- if the cell phone isn't unlocked, it doesn't show it in the menu (like in undertale) instead of showing it grayed-out like in deltarune

        Game:setFlag("#savename_lw_menus", false) -- if true, will display the "savename" (the name you choose) instead of the party member's name if their "use_player_name" property is set to true.
    end
end

function lib:preInit()
    
    self.random_encounters = {}
    self.light_encounters = {}
    self.light_enemies = {}

    for _,path,rnd_enc in Registry.iterScripts("battle/randomencounters") do
        assert(rnd_enc ~= nil, '"randomencounters/'..path..'.lua" does not return value')
        rnd_enc.id = rnd_enc.id or path
        self.random_encounters[rnd_enc.id] = rnd_enc
    end

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
    
end

function lib:init()

    print(self.info.id .. " version " .. self.info.version .. ": Getting ready...")

    self.encounters_enabled = false
    self.steps_until_encounter = nil

    Utils.hook(Actor, "init", function(orig, self)
        orig(self)
        self.use_light_battler_sprite = true
        self.light_battle_width = 0
        self.light_battle_height = 0
        self.light_battler_parts = {}
    end)

    Utils.hook(Actor, "getWidth", function(orig, self)
        if Game.battle and Game.battle.light and self.use_light_battler_sprite then
            return self.light_battle_width
        else
            return self.width
        end
    end)

    Utils.hook(Actor, "getHeight", function(orig, self)
        if Game.battle and Game.battle.light and self.use_light_battler_sprite then
            return self.light_battle_height
        else
            return self.height
        end
    end)

    Utils.hook(Actor, "addLightBattlerPart", function(orig, self, id, data)
        self.light_battler_parts[id] = data
    end)

    Utils.hook(Actor, "getLightBattlerPart", function(orig, self, part)
        return self.light_battler_parts[part]
    end)

    Utils.hook(Actor, "createLightBattleSprite", function(orig, self)
        return LightEnemySprite(self)
    end)

    Utils.hook(DebugSystem, "registerDefaults", function(orig, self)
        -- wish i didn't have to do this but
    
        local in_game = function() return Kristal.getState() == Game end
        local in_battle = function() return in_game() and Game.state == "BATTLE" end
        local in_dark_battle = function() return in_game() and Game.state == "BATTLE" and not Game.battle.light end
        local in_light_battle = function() return in_game() and Game.state == "BATTLE" and Game.battle.light end
        local in_overworld = function() return in_game() and Game.state == "OVERWORLD" end 

        self:registerConfigOption("main", "Object Selection Pausing", "Pauses the game when the object selection menu is opened.", "objectSelectionSlowdown")

        self:registerOption("main", "Engine Options", "Configure various noningame options.", function()
            self:enterMenu("engine_options", 1)
        end)

        self:registerOption("main", "Fast Forward", function() return self:appendBool("Speed up the engine.", FAST_FORWARD) end, function() FAST_FORWARD = not FAST_FORWARD end)
        self:registerOption("main", "Debug Rendering", function() return self:appendBool("Draw debug information.", DEBUG_RENDER) end, function() DEBUG_RENDER = not DEBUG_RENDER end)
        self:registerOption("main", "Hotswap", "Swap out code from the files. Might be unstable.", function() Hotswapper.scan(); self:refresh() end)
        self:registerOption("main", "Reload", "Reload the mod. Hold shift to\nnot temporarily save.", function()
            if Kristal.getModOption("hardReset") then
                love.event.quit("restart")
            else
                if Mod then
                    Kristal.quickReload(Input.shift() and "save" or "temp")
                else
                    Kristal.returnToMenu()
                end
            end
        end)

        self:registerOption("main", "Noclip",
            function() return self:appendBool("Toggle interaction with solids.", NOCLIP) end,
            function() NOCLIP = not NOCLIP end,
            in_game
        )

        self:registerOption("main", "Give Item", "Give an item.", function()
            self:enterMenu("give_item", 0)
        end, in_game)

        self:registerOption("main", "Portrait Viewer", "Enter the portrait viewer menu.", function()
            self:setState("FACES")
        end, in_game)

        self:registerOption("main", "Flag Editor", "Enter the flag editor menu.", function()
            self:setState("FLAGS")
        end, in_game)

        self:registerOption("main", "Sound Test", "Enter the sound test menu.", function()
            self:fadeMusicOut()
            self:enterMenu("sound_test", 0)
        end, in_game)


        -- World specific
        self:registerOption("main", "Select Map", "Switch to a new map.", function()
            self:enterMenu("select_map", 0)
        end, in_overworld)

        self:registerOption("main", "Start Encounter", "Start an encounter.", function()
            self:enterMenu("encounter_select", 0)
        end, in_overworld)

        self:registerOption("main", "Start Light Encounter", "Start a light encounter.", function()
            self:enterMenu("light_encounter_select", 0)
        end, in_overworld)

        self:registerOption("main", "Enter Shop", "Enter a shop.", function()
            self:enterMenu("select_shop", 0)
        end, in_overworld)

        self:registerOption("main", "Play Cutscene", "Play a cutscene.", function()
            self:enterMenu("cutscene_select", 0)
        end, in_overworld)

        -- Battle specific
        self:registerOption("main", "Start Wave", "Start a wave.", function()
            self:enterMenu("wave_select", 0)
        end, in_dark_battle)

        self:registerOption("main", "Start Wave", "Start a wave.", function()
            self:enterMenu("wave_select_light", 0)
        end, in_light_battle)

        self:registerOption("main", "End Battle", "Instantly complete a battle.", function()
            Game.battle:setState("VICTORY")
        end, in_battle)

    end)

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

        local force
        if Game:getFlag("current_battle_system#") == "undertale" then
            force = "force_light"
        elseif Game:getFlag("current_battle_system#") == "deltarune" then
            force = "force_dark"
        end

        if force then
            if force == "force_light" then
                Game:encounterLight(encounter, transition, enemy, context)
            elseif force == "force_dark" then
                orig(self, encounter, transition, enemy, context)
            end
        elseif context then
            if isClass(context) and context:includes(ChaserEnemy) then
                if context.light_encounter then
                    Game:setFlag("current_battle_system#", "undertale")
                    Game:encounterLight(encounter, transition, enemy, context)
                elseif context.encounter then
                    Game:setFlag("current_battle_system#", "deltarune")
                    orig(self, encounter, transition, enemy, context)
                end
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
                    Game:setFlag("current_battle_system#", "undertale")
                    Game:encounterLight(encounter, transition, enemy, context)
                else
                    Game:setFlag("current_battle_system#", "deltarune")
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

        local should_make_ball = false
        for _,storage_id in ipairs(self.convert_order) do
            local storage = Utils.copy(self:getStorage(storage_id))
            for i = 1, storage.max do
                local item = storage[i]
                if item then
                    should_make_ball = true
                    local result = item:convertToLight(new_inventory) or (storage.id == "light" and item)
    
                    if result then
                        self:removeItem(item)
    
                        if type(result) == "string" then
                            result = Registry.createItem(result)
                        end
                        if isClass(result) then
                            result.fallback_dark_item = item
                            result.dark_location = {storage = storage.id, index = i}
                            new_inventory:addItem(result)
                        end
                    end
                end
            end
        end
    
        local ball = Registry.createItem("light/ball_of_junk", self)
        new_inventory:addItemTo("items", 1, ball)
    
        new_inventory.storage_enabled = was_storage_enabled
    
        return new_inventory
    end)

    Utils.hook(LightInventory, "convertToDark", function(orig, self)
        local new_inventory = DarkInventory()

        local was_storage_enabled = new_inventory.storage_enabled
        new_inventory.storage_enabled = true
    
        Kristal.callEvent("onConvertToDark", new_inventory)
    
        for _,storage_id in ipairs(self.convert_order) do
            local storage = Utils.copy(self:getStorage(storage_id))
            for i = 1, storage.max do
                local item = storage[i]
                if item then
                    local result = item:convertToDark(new_inventory)
    
                    if result then
                        self:removeItem(item)
    
                        if type(result) == "string" then
                            result = Registry.createItem(result)
                        end
                        if isClass(result) then
                            new_inventory:addItem(result)
                        end
                    end
                end
            end
        end
    
        for _,base_storage in pairs(self.storages) do
            local storage = Utils.copy(base_storage)
            for i = 1, storage.max do
                local item = storage[i]
                if item then
                    item.fallback_light_item = item

                    item.light_location = {storage = storage.id, index = i}
    
                    new_inventory:addItemTo("light", item)
    
                    self:removeItem(item)
                end
            end
        end
    
        new_inventory.storage_enabled = was_storage_enabled
    
        return new_inventory
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
        Game:setFlag("current_battle_system#", nil)
        if Game:getFlag("temporary_world_value#") == "light" then
            Game:setLight(true)
            MagicalGlassLib:loadStorageAndEquips()
            Game:setFlag("temporary_world_value#", nil)
        end
    end)

    Utils.hook(Wave, "init", function(orig, self)
        orig(self)
        self.has_soul = true
        self.darken = false
        self.auto_clear = true
    end)
    
    Utils.hook(Wave, "setArenaSize", function(orig, self, width, height)
        if Game.battle.light then
            self.arena_width = width
            self.arena_height = height or width
        else
            orig(self, x, y)
        end
    end)

    Utils.hook(Wave, "setArenaPosition", function(orig, self, x, y)
        if Game.battle.light then
            self.arena_x = x
            self.arena_y = y
        else
            orig(self, x, y)
        end
    end)

    Utils.hook(Wave, "getMenuAttackers", function(orig, self)
        local result = {}
        for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
            local wave = enemy.selected_menu_wave
            if type(wave) == "table" and wave.id == self.id or wave == self.id then
                table.insert(result, enemy)
            end
        end
        return result
    end)

    Utils.hook(Wave, "spawnBulletTo", function(orig, self, parent, bullet, ...)
        local new_bullet
        if isClass(bullet) and bullet:includes(Bullet) then
            new_bullet = bullet
        elseif Registry.getBullet(bullet) then
            new_bullet = Registry.createBullet(bullet, ...)
        else
            local x, y = ...
            table.remove(arg, 1)
            table.remove(arg, 1)
            new_bullet = Bullet(x, y, bullet, unpack(arg))
        end
        new_bullet.wave = self
        local attackers
        if Game.battle.light and #Game.battle.menu_waves > 0 then
            attackers = self:getMenuAttackers()
        end
        if #Game.battle.waves > 0 then
            attackers = self:getAttackers()
        end
        if #attackers > 0 then
            new_bullet.attacker = Utils.pick(attackers)
        end
        table.insert(self.bullets, new_bullet)
        table.insert(self.objects, new_bullet)
        if parent then
            new_bullet:setParent(parent)
        elseif not new_bullet.parent then
            Game.battle:addChild(new_bullet)
        end
        new_bullet:onWaveSpawn(self)
        return new_bullet
    end)

    Utils.hook(Item, "init", function(orig, self)
    
        orig(self)
        -- Short name for the light battle item menu
        self.short_name = nil
        -- Serious name for the light battle item menu
        self.serious_name = nil

        self.fallback_dark_item = nil
        self.fallback_light_item = nil

        self.tags = {}

        -- How this item is used on you (ate, drank, eat, etc.)
        self.use_method = "ate"
        -- How this item is used on other party members (eats, etc.)
        self.use_method_other = nil
    
    end)

    Utils.hook(Item, "getShortName", function(orig, self) return self.short_name or self.serious_name or self.name end)
    Utils.hook(Item, "getSeriousName", function(orig, self) return self.serious_name or self.short_name or self.name end)

    Utils.hook(Item, "getUseName", function(orig, self)
        if (Game.state == "OVERWORLD" and Game:isLight()) or (Game.state == "BATTLE" and Game.battle.light)  then
            return self.use_name or self:getName()
        else
            return self.use_name or self:getName():upper()
        end
    end)

    Utils.hook(Item, "getUseMethod", function(orig, self, target)
        if type(target) == "string" then
            if target == "other" and self.use_method_other then
                return self.use_method_other
            elseif target == "self" and self.use_method_self then
                return self.use_method
            else
                return self.use_method
            end
        elseif isClass(target) then
            if (target.id ~= Game.party[1].id and self.use_method_other and self.target ~= "party") or force_other then
                return self.use_method_other
            else
                return self.use_method
            end
        end
    end)

    Utils.hook(Item, "onLightBattleUse", function(orig, self, user, target)
        if self.getLightBattleText then
            Game.battle:battleText(self:getLightBattleText(user, target))
        else
            Game.battle:battleText("* "..user.chara:getName().." used the "..self:getName().."!")
        end
    end)

    Utils.hook(Item, "onLightAttack", function(orig, self, battler, enemy, damage, stretch)
        local src = Assets.stopAndPlaySound(self.getLightAttackSound and self:getLightAttackSound() or "laz_c") 
        src:setPitch(self.getLightAttackPitch and self:getLightAttackPitch() or 1)

        local sprite = Sprite(self.getLightAttackSprite and self:getLightAttackSprite() or "effects/attack/strike")
        local scale = (stretch * 2) - 0.5
        sprite:setScale(scale, scale)
        sprite:setOrigin(0.5, 0.5)
        sprite:setPosition(enemy:getRelativePos((enemy.width / 2) - 5, (enemy.height / 2) - 5))
        sprite.layer = BATTLE_LAYERS["above_ui"] + 5
        sprite.color = battler.chara:getLightAttackColor()
        enemy.parent:addChild(sprite)
        sprite:play((stretch / 4) / 1.5, false, function(this) -- timing may still be incorrect
            local sound = enemy:getDamageSound() or "damage"
            if sound and type(sound) == "string" then
                Assets.stopAndPlaySound(sound)
            end
            enemy:hurt(damage, battler)

            battler.chara:onAttackHit(enemy, damage)
            this:remove()

            Game.battle:endAttack()
        end)
    end)

    Utils.hook(Item, "onLightMiss", function(orig, self, battler, enemy, finish)
        enemy:hurt(0, battler, on_defeat, {battler.chara:getLightMissColor()})
        if finish then
            Game.battle:endAttack()
        end
    end)

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
        
    Utils.hook(Item, "onToss", function(orig, self)
        if Game:isLight() then
            local choice = love.math.random(30)
            if choice == 1 then
                Game.world:showText("* You bid a quiet farewell\n to the " .. self:getName() .. ".")
            elseif choice == 2 then
                Game.world:showText("* You put the " .. self:getName() .. "\non the ground and gave it a\nlittle pat.")
            elseif choice == 3 then
                Game.world:showText("* You threw the " .. self:getName() .. "\non the ground like the piece\nof trash it is.")
            elseif choice == 4 then
                Game.world:showText("* You abandoned the\n" .. self:getName() .. ".")
            else
                Game.world:showText("* The " .. self:getName() .. " was\nthrown away.")
            end
        end
        return true
    end)

    Utils.hook(Item, "onActionSelect", function(orig, self, battler) end)

    Utils.hook(Item, "load", function(orig, self, data)
        self.flags = data.flags or self.flags

        if data.dark_item then
            if type(data.dark_item) == "table" then
                self.dark_item = Registry.createItem(data.dark_item.id)
                self.dark_item:load(data.dark_item)
            else
                self.dark_item = data.dark_item
            end

            self.dark_location = data.dark_location
        elseif data.fallback_dark_item then 
            if type(data.fallback_dark_item) == "table" then
                self.fallback_dark_item = Registry.createItem(data.fallback_dark_item.id)
            else
                self.fallback_dark_item = data.fallback_dark_item
            end
        end

        if data.light_item then
            if type(data.light_item) == "table" then
                self.light_item = Registry.createItem(data.light_item.id)
                self.light_item:load(data.light_item)
            else
                self.light_item = data.light_item
            end

            self.light_location = data.light_location
        elseif data.fallback_light_item then 
            if type(data.fallback_light_item) == "table" then
                self.fallback_light_item = Registry.createItem(data.fallback_light_item.id)
            else
                self.fallback_light_item = data.fallback_light_item
            end
        end

        self:onLoad(data)
    end)
    
    Utils.hook(Battler, "lightStatusMessage", function(orig, self, x, y, type, arg, color, kill)
        x, y = self:getRelativePos(x, y)

        local offset = 0
        if not kill then
            offset = (self.hit_count * 20)
        end
        
        local offset_x, offset_y = Utils.unpack(self:getDamageOffset())
        
        local percent = LightDamageNumber(type, arg, x + offset_x, y + (offset_y - 2) - offset, color)
        if (type == "mercy" and self:getMercyVisibility()) or type == "damage" or type == "msg" then
            if kill then
                percent.kill_others = true
            end
            self.parent:addChild(percent)
        
            if not kill then
                self.hit_count = self.hit_count + 1
            end
        end

        if type ~= "msg" then
            if (type == "damage" and self:getHPVisibility()) or (type == "mercy" and self:getMercyVisibility()) then
                local gauge = LightGauge(type, arg, x + offset_x, y + offset_y + 8, self)
                self.parent:addChild(gauge)
            end
        end
    
        return percent
    end)

    Utils.hook(Textbox, "init", function(orig, self, x, y, width, height, default_font, default_font_size, battle_box)
        Textbox.__super.init(self, x, y, width, height)

        self.box = UIBox(0, 0, width, height)
        self.box.layer = -1
        self.box.debug_select = false
        self:addChild(self.box)
    
        self.battle_box = battle_box
        if battle_box then
            self.box.visible = false
        end

        if battle_box then
            if Game.battle.light then
                self.face_x = 6
                self.face_y = -2
        
                self.text_x = 0
                self.text_y = -2 
            else
                self.face_x = -4
                self.face_y = 2
        
                self.text_x = 0
                self.text_y = -2 -- TODO: This was changed 2px lower with the new font, but it was 4px offset. Why? (Used to be 0)
            end
        elseif Game:isLight() then
            self.face_x = 13
            self.face_y = 6
    
            self.text_x = 2
            self.text_y = -4
        else
            self.face_x = 18
            self.face_y = 6
    
            self.text_x = 2
            self.text_y = -4  -- TODO: This was changed with the new font but it's accurate anyways
        end
    
        self.actor = nil
    
        self.default_font = default_font or "main_mono"
        self.default_font_size = default_font_size
    
        self.font = self.default_font
        self.font_size = self.default_font_size
    
        self.face = Sprite(nil, self.face_x, self.face_y, nil, nil, "face")
        self.face:setScale(2, 2)
        self.face.getDebugOptions = function(self2, context)
            context = super.getDebugOptions(self2, context)
            if Kristal.DebugSystem then
                context:addMenuItem("Change", "Change this portrait to a different one", function()
                    Kristal.DebugSystem:setState("FACES", self)
                end)
            end
            return context
        end
        self:addChild(self.face)
    
        -- Added text width for autowrapping
        self.wrap_add_w = battle_box and 0 or 14
    
        self.text = DialogueText("", self.text_x, self.text_y, width + self.wrap_add_w, SCREEN_HEIGHT)
        self:addChild(self.text)
    
        self.reactions = {}
        self.reaction_instances = {}
    
        self.text:registerCommand("face", function(text, node, dry)
            if self.actor and self.actor:getPortraitPath() then
                self.face.path = self.actor:getPortraitPath()
            end
            self:setFace(node.arguments[1], tonumber(node.arguments[2]), tonumber(node.arguments[3]))
        end)
        self.text:registerCommand("facec", function(text, node, dry)
            self.face.path = "face"
            local ox, oy = tonumber(node.arguments[2]), tonumber(node.arguments[3])
            if self.actor then
                local actor_ox, actor_oy = self.actor:getPortraitOffset()
                ox = (ox or 0) - actor_ox
                oy = (oy or 0) - actor_oy
            end
            self:setFace(node.arguments[1], ox, oy)
        end)
    
        self.text:registerCommand("react", function(text, node, dry)
            local react_data
            if #node.arguments > 1 then
                react_data = {
                    text = node.arguments[1],
                    x = tonumber(node.arguments[2]) or (self.battle_box and self.REACTION_X_BATTLE[node.arguments[2]] or self.REACTION_X[node.arguments[2]]),
                    y = tonumber(node.arguments[3]) or (self.battle_box and self.REACTION_Y_BATTLE[node.arguments[3]] or self.REACTION_Y[node.arguments[3]]),
                    face = node.arguments[4],
                    actor = node.arguments[5] and Registry.createActor(node.arguments[5]),
                }
            else
                react_data = tonumber(node.arguments[1]) and self.reactions[tonumber(node.arguments[1])] or self.reactions[node.arguments[1]]
            end
            local reaction = SmallFaceText(react_data.text, react_data.x, react_data.y, react_data.face, react_data.actor)
            reaction.layer = 0.1 + (#self.reaction_instances) * 0.01
            self:addChild(reaction)
            table.insert(self.reaction_instances, reaction)
        end, {instant = false})
    
        self.advance_callback = nil
    end)

    Utils.hook(Textbox, "advance", function(orig, self)
        print(self.wait, "hi")
        self.timer:after(self.wait, function()
            self.text:advance()
        end)
    end)

    Utils.hook(DialogueText, "init", function(orig, self, text, x, y, w, h, options)
        orig(self, text, x, y, w, h, options)
        options = options or {}
        self.default_sound = options["default_sound"] or "default"
    end)

    Utils.hook(DialogueText, "resetState", function(orig, self)
        DialogueText.__super.resetState(self)
        self.state["typing_sound"] = self.default_sound
    end)

    Utils.hook(DialogueText, "update", function(orig, self)
        local speed = self.state.speed

        if not OVERLAY_OPEN then

            if Game:getFlag("#undertale_text_skipping") then

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

            love.graphics.printf("Use " .. item:getName() .. " on...", -45, 233, 400, "center")

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
        local result
        if item.target == "ally" then
            result = item:onWorldUse(Game.party[self.party_selecting])
        elseif item.target == "party" or item.target == "none" then
            result = item:onWorldUse(Game.party)
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
                message = item:getLightWorldHealingText(target, amount, maxed)
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

        self.use_player_name = false

        self.lw_portrait = nil

        self.light_color = {1, 1, 1}
        self.light_dmg_color = {1, 0, 0}
        self.light_miss_color = {192/255, 192/255, 192/255}
        self.light_attack_color = {1, 105/255, 105/255}
        self.light_multibolt_attack_color = {1, 1, 1}
        self.light_attack_bar_color = {1, 1, 1}
        self.light_xact_color = {1, 1, 1}

        self.lw_stats["magic"] = 0

    end)

    Utils.hook(PartyMember, "heal", function(orig, self, amount, playsound)
        if Game:isLight() then
            if playsound == nil or playsound then
                Assets.stopAndPlaySound("power")
            end
            if self:getHealth() < self:getStat("health") then
                self:setHealth(math.min(self:getStat("health"), self:getHealth() + amount))
            end
        else
            self:setHealth(math.min(self:getStat("health"), self:getHealth() + amount))
        end
        return self:getStat("health") == self:getHealth()
    end)

    Utils.hook(PartyMember, "getName", function(orig, self)
        if Game:getFlag("#savename_lw_menus") and Game.save_name and self:shouldUsePlayerName() then
            return Game.save_name
        else
            return self.name
        end
    end)

    Utils.hook(PartyMember, "onActionSelect", function(orig, self, battler, undo)
        if Game.battle.turn_count == 1 and not undo then
            if self:getWeapon() then
                self:getWeapon():onActionSelect(self)
            end
            if self:getArmor(1) then
                self:getArmor(1):onActionSelect(self)
            end
        end
    end)
    
    Utils.hook(PartyMember, "onTurnEnd", function(orig, self, battler)
        for _,equip in ipairs(self:getEquipment()) do
            if equip.onTurnEnd then
                equip:onTurnEnd(self)
            end
        end
    end)

    Utils.hook(PartyMember, "getNameOrYou", function(orig, self)
        if self.id == Game.party[1].id then
            return "You"
        else
            return self:getName()
        end
    end)

    Utils.hook(PartyMember, "shouldUsePlayerName", function(orig, self)
        return self.use_player_name
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
        if self.light_color and type(self.light_color) == "table" then
            return self.light_color
        end
    end)

    Utils.hook(PartyMember, "getLightDamageColor", function(orig, self)
        if self.light_dmg_color and type(self.light_dmg_color) == "table" then
            return self.light_dmg_color
        end
    end)

    Utils.hook(PartyMember, "getLightMissColor", function(orig, self)
        if self.light_miss_color and type(self.light_miss_color) == "table" then
            return self.light_miss_color
        end
    end)

    Utils.hook(PartyMember, "getLightAttackColor", function(orig, self)
        if self.light_attack_color and type(self.light_attack_color) == "table" then
            return self.light_attack_color
        end
    end)

    Utils.hook(PartyMember, "getLightMultiboltAttackColor", function(orig, self)
        if self.light_multibolt_attack_color and type(self.light_multibolt_attack_color) == "table" then
            return self.light_multibolt_attack_color
        end
    end)

    Utils.hook(PartyMember, "getLightAttackBarColor", function(orig, self)
        if self.light_attack_bar_color and type(self.light_attack_bar_color) == "table" then
            return self.light_attack_bar_color
        end
    end)

    Utils.hook(PartyMember, "getLightXActColor", function(orig, self)
        if self.light_xact_color and type(self.light_xact_color) == "table" then
            return self.light_xact_color
        end
    end)

    Utils.hook(LightMenu, "draw", function(orig, self)
        Object.draw(self)

        local offset = 0
        if self.top then
            offset = 270
        end
    
        local chara = Game.party[1]
    
        love.graphics.setFont(self.font)
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print(chara:getName(), 46, 60 + offset)
        love.graphics.setFont(self.font_small)
        love.graphics.print("LV  "..chara:getLightLV(), 46, 100 + offset)
        love.graphics.print("HP  "..chara:getHealth().."/"..chara:getStat("health"), 46, 118 + offset)
        -- pastency when -sam, to sam
        love.graphics.print(Game:getConfig("lightCurrencyShort"), 46, 136 + offset)
        love.graphics.print(Game.lw_money, 82, 136 + offset)
    
        love.graphics.setFont(self.font)
        if Game.inventory:getItemCount(self.storage, false) <= 0 then
            Draw.setColor(PALETTE["world_gray"])
        else
            Draw.setColor(PALETTE["world_text"])
        end
        love.graphics.print("ITEM", 84, 188 + (36 * 0))
        Draw.setColor(PALETTE["world_text"])
        love.graphics.print("STAT", 84, 188 + (36 * 1))
    
        if not Game:getFlag("#hide_cell") then
            if Game:getFlag("has_cell_phone") then
                if #Game.world.calls > 0 then
                    Draw.setColor(PALETTE["world_text"])
                else
                    Draw.setColor(PALETTE["world_gray"])
                end
                love.graphics.print("CELL", 84, 188 + (36 * 2))
            end
        else
            if Game:getFlag("has_cell_phone") then
                if #Game.world.calls > 0 then
                    Draw.setColor(PALETTE["world_text"])
                    love.graphics.print("CELL", 84, 188 + (36 * 2))
                end
            end
        end
    
        if self.state == "MAIN" then
            Draw.setColor(Game:getSoulColor())
            Draw.draw(self.heart_sprite, 56, 160 + (36 * self.current_selecting), 0, 2, 2)
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
        if Game:getFlag("#lw_stat_menu_portraits") == "magical_glass" and #Game.party > 1 then
            local name_offset = 0
            for _,chara in ipairs(Game.party) do
                love.graphics.printf(chara:getName(), name_offset - 18, 8, 100, "center")
                name_offset = name_offset + 110
            end
        else
            love.graphics.print("\"" .. Game.party[self.party_selecting]:getName() .. "\"", 4, 8)
        end

        local chara = Game.party[self.party_selecting]

        if Game:getFlag("#lw_stat_menu_portraits") == "deltatraveler" then
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
        elseif Game:getFlag("#lw_stat_menu_portraits") == "magical_glass" then
            local ox, oy = chara.actor:getPortraitOffset()
            if chara:getLightPortrait() then
                Draw.draw(Assets.getTexture(chara:getLightPortrait()), 180 + ox, 50 + oy, 0, 2, 2)
            end

            if #Game.party > 1 then
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, (110 * (self.party_selecting - 1)) + 22, -8, 0, 2, 2)
            end
        end

        Draw.setColor(PALETTE["world_text"])
        love.graphics.print("LV  "..chara:getLightLV(), 4, 68)
        love.graphics.print("HP  "..chara:getHealth().." / "..chara:getStat("health"), 4, 100)
    
        local exp_needed = math.max(0, chara:getLightEXPNeeded(chara:getLightLV() + 1) - chara:getLightEXP())
    
        local at = chara:getBaseStats()["attack"]
        local df = chara:getBaseStats()["defense"]
        
        if Game:getFlag("#undertale_stat_display") then
            at = at - 10
            df = df - 10
        end

        love.graphics.print("AT  "  .. at  .. " ("..chara:getEquipmentBonus("attack")  .. ")", 4, 164)
        love.graphics.print("DF  "  .. df  .. " ("..chara:getEquipmentBonus("defense") .. ")", 4, 196)
        local offset = 0
        if Game:getFlag("#always_show_magic") or chara.lw_stats.magic > 0 then
            love.graphics.print("MG  ", 4, 228)
            love.graphics.print(chara:getBaseStats()["magic"]   .. " ("..chara:getEquipmentBonus("magic")   .. ")", 44, 228)
            offset = 18
        end
        love.graphics.print("EXP: " .. chara:getLightEXP(), 172, 164)
        love.graphics.print("NEXT: ".. exp_needed, 172, 196)
    
        local weapon_name = chara:getWeapon() and chara:getWeapon():getName() or ""
        local armor_name = chara:getArmor(1) and chara:getArmor(1):getName() or ""
        
        love.graphics.print("WEAPON: "..weapon_name, 4, 256 + offset)
        love.graphics.print("ARMOR: "..armor_name, 4, 288 + offset)
    
        love.graphics.print(Game:getConfig("lightCurrency"):upper()..": "..Game.lw_money, 4, 328 + offset)
    end)

    Utils.hook(World, "registerCall", function(orig, self, name, scene, sound)
        table.insert(self.calls, {name, scene, sound})
    end)

    Utils.hook(LightCellMenu, "runCall", function(orig, self, call)
        if call[3] == nil or call[3] then
            Assets.playSound("phone", 0.7)
        end

        Game.world.menu:closeBox()
        Game.world.menu.state = "TEXT"
        Game.world:setCellFlag(call[2], Game.world:getCellFlag(call[2], -1) + 1)
        Game.world:startCutscene(call[2])
    end)

    Utils.hook(Savepoint, "init", function(orig, self, x, y, properties)
        orig(self, x, y, properties)
        self.undertale = properties["ut"] or false
        if self.undertale then
            self:setSprite("world/events/savepointut", 1/6)
        end
    end)

    Utils.hook(Savepoint, "onTextEnd", function(orig, self)
        if not self.world then return end

        if self.heals then
            for _,party in ipairs(Game.party) do
                party:heal(math.huge, false)
            end
        end
        
        if Game:isLight() then
            self.world:openMenu(LightSaveMenu(Game.save_id, self.marker, Game:getFlag("#undertale_save_menu")))
        elseif self.simple_menu or (self.simple_menu == nil and Game:getConfig("smallSaveMenu")) then
            self.world:openMenu(SimpleSaveMenu(Game.save_id, self.marker))
        else
            self.world:openMenu(SaveMenu(self.marker))
        end
    end)

    Utils.hook(SaveMenu, "init", function(orig, self, marker)
        orig(self, marker)
        if Game:isLight() then
            self.divider_sprite = Assets.getTexture("ui/box/light/top")
        else
            self.divider_sprite = Assets.getTexture("ui/box/dark/top")
        end
    end)

    Utils.hook(LightSaveMenu, "init", function(orig, self, save_id, marker, undertale)
        orig(self, save_id, marker, undertale)
        self.undertale = undertale
    end)

    Utils.hook(LightSaveMenu, "update", function(orig, self)
        if self.state == "MAIN" and ((Input.pressed("confirm") and self.selected_x == 1) or (Input.pressed("left") or Input.pressed("right"))) then
            Assets.playSound("ui_move")
        end
        orig(self)
    end)

    Utils.hook(LightSaveMenu, "draw", function(orig, self)
        if self.undertale then
            love.graphics.setFont(self.font)

            if self.state == "SAVED" then
                Draw.setColor(PALETTE["world_text_selected"])
            else
                Draw.setColor(PALETTE["world_text"])
            end
        
            local data      = self.saved_file or {}
            local name      = data.name      or "EMPTY"
            local level     = data.level     or 1
            local playtime  = data.playtime  or 0
            local room_name = data.room_name or "--"
        
            love.graphics.print(name,         self.box.x + 8,        self.box.y - 10 + 8)
            love.graphics.print("LV "..level, self.box.x + 210 - 42, self.box.y - 10 + 8)
        
            local minutes = math.floor(playtime / 60)
            local seconds = math.floor(playtime % 60)
            local time_text = string.format("%d:%02d", minutes, seconds)
            love.graphics.printf(time_text, self.box.x - 280 + 148, self.box.y - 10 + 8, 500, "right")
        
            love.graphics.print(room_name, self.box.x + 8, self.box.y + 38)
        
            if self.state == "MAIN" then
                love.graphics.print("Save",   self.box.x + 30  + 8, self.box.y + 98)
                love.graphics.print("Return", self.box.x + 210 + 8, self.box.y + 98)
        
                Draw.setColor(Game:getSoulColor())
                Draw.draw(self.heart_sprite, self.box.x + 10 + (self.selected_x - 1) * 180, self.box.y + 96 + 8, 0, 2, 2)
            elseif self.state == "SAVED" then
                love.graphics.print("File saved.", self.box.x + 30 + 8, self.box.y + 98)
            end
        
            Draw.setColor(1, 1, 1)
        
            LightSaveMenu.__super.draw(self)
        else
            orig(self)
        end
    end)

    Utils.hook(Spell, "onStart", function(orig, self, user, target)
        if Game.battle.light then
            local result = self:onLightCast(user, target)
            Game.battle:battleText(self:getLightCastMessage(user, target))
            if result or result == nil then
                Game.battle:finishActionBy(user)
            end
        else
            orig(self, user, target)
        end
    end)

    Utils.hook(Spell, "onLightCast", function(orig, self, user, target) end)

    Utils.hook(Spell, "getLightCastMessage", function(orig, self, user, target)
        return "* "..user.chara:getNameOrYou().." cast "..self:getName().."."
    end)

    Utils.hook(Spell, "getHealMessage", function(orig, self, user, target)
        local amount = self.amount
        local char_maxed
        local enemy_maxed
        if self.target == "ally" then
            char_maxed = target.chara:getHealth() >= target.chara:getStat("health")
        elseif self.target == "enemy" then
            enemy_maxed = target.health >= target.max_health
        end
        local message = ""
        if self.target == "ally" then
            if target.chara.id == Game.battle.party[1].chara.id and char_maxed then
                message = "* Your HP was maxed out."
            elseif char_maxed then
                message = "* " .. target.chara:getNameOrYou() .. "'s HP was maxed out."
            else
                message = "* " .. target.chara:getNameOrYou() .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "party" then
            if #Game.party > 1 then
                message = "* Everyone recovered " .. amount .. " HP."
            else
                message = "* You recovered " .. amount .. " HP."
            end
        elseif self.target == "enemy" then
            if enemy_maxed then
                message = "* " .. target.name .. "'s HP was maxed out."
            else
                message = "* " .. target.name .. " recovered " .. amount .. " HP."
            end
        elseif self.target == "enemies" then
            message = "* The enemies all recovered " .. amount .. " HP."
        end
        return message
    end)

    Utils.hook(SpeechBubble, "draw", function(orig, self)
        if not self.auto then
            if self.right and Game.battle.light then
                local width = self:getSpriteSize()
                Draw.draw(self:getSprite(), width - 12, 0, 0, -1, 1)
            else
                Draw.draw(self:getSprite(), 0, 0)
            end
        else
            orig(self)
        end

        SpeechBubble.__super.draw(self)
    end)

    Utils.hook(Game, "gameOver", function(orig, self, x, y)
        Game:setFlag("#game_overs", Game:getFlag("#game_overs") + 1)
        orig(self, x, y)
    end)

    PALETTE["pink_spare"] = {1, 167/255, 212/255, 1}

    PALETTE["energy_back"] = {53/255, 181/255, 89/255, 1}
    PALETTE["energy_fill"] = {186/255, 213/255, 60/255, 1}
end

function lib:registerRandomEncounter(id)
    self.random_encounters[id] = class
end

function lib:getRandomEncounter(id)
    return self.random_encounters[id]
end

function lib:createRandomEncounter(id, ...)
    if self.random_encounters[id] then
        return self.random_encounters[id](...)
    else
        error("Attempt to create non existent random encounter \"" .. tostring(id) .. "\"")
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

    debug:registerMenu("encounter_select", "Encounter Select", "search")
    -- loop through registry and add menu options for all encounters
    for id,_ in pairs(Registry.encounters) do
        debug:registerOption("encounter_select", id, "Start this encounter.", function()
            if Game:isLight() then
                Game:setFlag("temporary_world_value#", "light")
                MagicalGlassLib:saveStorageAndEquips()
                Game:setLight(false)
            end
            Game:encounter(id)
            debug:closeMenu()
        end)
    end

    debug:registerMenu("light_encounter_select", "Select Light Encounter", "search")
    for id,_ in pairs(self.light_encounters) do
        if id ~= "_nobody" then
            debug:registerOption("light_encounter_select", id, "Start this encounter.", function()
                if Game:getFlag("force_light_mode_in_light_battles") and not Game:isLight() then
                    Game:setFlag("temporary_world_value#", "dark")
                    MagicalGlassLib:saveStorageAndEquips()
                    Game:setLight(true)
                    Game:encounter(id)
                else
                    Game:setFlag("current_battle_system#", "undertale")
                    Game:encounterLight(id)
                end
                debug:closeMenu()
            end)
        end
    end

    debug:registerMenu("wave_select_light", "Wave Select", "search")

    local waves_list = {}
    for id,_ in pairs(Registry.waves) do
        table.insert(waves_list, id)
    end

    table.sort(waves_list, function(a, b)
        return a < b
    end)

    for _,id in ipairs(waves_list) do
        debug:registerOption("wave_select_light", id, "Start this wave.", function()
            Game.battle:setState("ENEMYDIALOGUE", {id})
            debug:closeMenu()
        end)
    end
end

function lib:changeSpareColor(color)
    if color == "yellow" then
        Game:setFlag("#name_color", COLORS.yellow)
    elseif color == "pink" then
        Game:setFlag("#name_color", PALETTE["pink_spare"])
    elseif color == "white" then
        Game:setFlag("#name_color", COLORS.white)
    end
end

function Game:encounterLight(encounter, transition, enemy, context)

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
        self.battle:postInit("TRANSITION", encounter)
    end

    self.stage:addChild(self.battle)

end

function lib:saveStorageAndEquips()
    Game:setFlag("temp_inventory#", Game.inventory:save())
    for _,party in ipairs(Game.party) do
        Game:setFlag("temp_equips_.."..party.id.."#", party:saveEquipment())
    end
end

function lib:loadStorageAndEquips()
    Game.inventory:load(Game:getFlag("temp_inventory#"))
    for _,party in ipairs(Game.party) do
        party:loadEquipment(Game:getFlag("temp_equips_.."..party.id.."#"))
        Game:setFlag("temp_equips_.."..party.id.."#", nil)
    end
    Game:setFlag("temp_inventory#", nil)
end

function lib:onFootstep()
    if Game.world and self.encounters_enabled then
        self.steps_until_encounter = self.steps_until_encounter - 1
    end
end

return lib