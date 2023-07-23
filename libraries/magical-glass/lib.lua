LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
LightArenaBorder         = libRequire("magical-glass", "scripts/lightbattle/lightarenaborder")
LightArenaSprite         = libRequire("magical-glass", "scripts/lightbattle/lightarenasprite")
LightEncounter           = libRequire("magical-glass", "scripts/lightbattle/lightencounter")
LightSoul                = libRequire("magical-glass", "scripts/lightbattle/lightsoul")
LightBattleUI            = libRequire("magical-glass", "scripts/lightbattle/ui/lightbattleui")
LightTensionBar          = libRequire("magical-glass", "scripts/lightbattle/ui/lighttensionbar")
LightActionButton        = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbutton")
LightActionBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionbox")
LightActionBoxSingle     = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionboxsingle")
LightActionBoxDisplay    = libRequire("magical-glass", "scripts/lightbattle/ui/lightactionboxdisplay")
LightAttackBox           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbox")
LightAttackBar           = libRequire("magical-glass", "scripts/lightbattle/ui/lightattackbar")

MagicalGlassLib = {}
local lib = MagicalGlassLib

function lib:init()

    Utils.hook(Game, "encounter", function(orig, object, encounter, transition, enemy, context)
        -- For testing let's start our thingy instead
        -- when this shit's done, make a thing that checks for the class' type (encounter or encounterlight)
        object:encounterLight(encounter, transition, enemy, context)
        --orig(object, encounter, transition, enemy) 
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

    Utils.hook(Bullet, "init", function(orig, self, x, y, texture)
    
        orig(self, x, y, texture)
        if Game:isLight() then
            self.inv_timer = 1
        end

    end)

    Utils.hook(EnemyBattler, "getLightAttackDamage", function(orig, self, damage, battler, points, stretch)
        if damage > 0 then
            return damage
        end

        local total_damage = (battler.chara:getStat("attack") - self.defense) + Utils.random(0, 2, 1)
        if points <= 12 then
            total_damage = Utils.round(total_damage * 2.2)
        elseif points >= 12 then
            total_damage = Utils.round((total_damage * stretch) * 2)
        end
        
        return total_damage
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

        LightItemMenu.__super.draw(self)

    end)

    Utils.hook(LightItemMenu, "useItem", function(orig, self, item)
        
        if item.target == "ally" then
            local result = item:onWorldUse(Game.party[self.party_selecting])
        elseif item.target == "party" then
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

    Utils.hook(World, "heal", function(orig, self, target, amount, text, item, display_healing)
  
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
            if item.target == "ally" and display_healing then
                if target.id == Game.party[1].id and maxed then
                    message = "* Your HP was maxed out."
                elseif target.id == Game.party[1].id and not maxed then
                    message = "* You recovered " .. amount .. " HP!"
                elseif maxed then
                    message = target.name .. "'s HP was maxed out."
                else
                    message = target.name .. " recovered " .. amount .. " HP!"
                end
            elseif item.target == "party" and display_healing then
                message = "* Everyone recovered " .. amount .. " HP!"
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

--[[         self.portrait = Sprite(Assets.getTexture("face/susie/neutral"), 20, 20)
        self.portrait:setColor(1, 1, 1, 1)
        self.portrait.layer = 1000
        self.portrait:setOrigin(0.5, 1)
        self:addChild(self.portrait)
 ]]
    end)

    Utils.hook(LightStatMenu, "update", function(orig, self)
        local chara = Game.party[self.party_selecting]
    
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

        love.graphics.print("\"" .. chara:getName() .. "\"", 4, 8)
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
        love.graphics.print(Game:getConfig("lightCurrency"):upper()..": "..Game.lw_money, 4, 328)

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

function lib:load()
    Game:setFlag("serious_mode", false)
    Game:setFlag("always_show_magic", false)
    Game:setFlag("undertale_textbox_skipping", true)
    Game:setFlag("enable_lw_tp", true)
    Game:setFlag("lw_stat_menu_portraits", true)
    Game:setFlag("gauge_styles", "undertale") -- undertale, deltarune, deltatraveler
    Game:setFlag("name_color", PALETTE["pink_spare"]) -- yellow, white, pink

    Game:setFlag("lw_stat_menu_style", "undertale") -- undertale, deltatraveler
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
        self.battle:postInit(transition and "TRANSITION" or "ACTIONSELECT", encounter)
    end

    self.stage:addChild(self.battle)

end

return lib