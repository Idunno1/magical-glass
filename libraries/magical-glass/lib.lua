LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightBattleUI            = libRequire("magical-glass", "scripts/lightbattle/lightbattleui")
LightTensionBar          = libRequire("magical-glass", "scripts/lightbattle/lighttensionbar")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
LightActionButton        = libRequire("magical-glass", "scripts/lightbattle/lightactionbutton")
LightActionBox           = libRequire("magical-glass", "scripts/lightbattle/lightactionbox")
LightActionBoxSingle     = libRequire("magical-glass", "scripts/lightbattle/lightactionboxsingle")
LightActionBoxDisplay    = libRequire("magical-glass", "scripts/lightbattle/lightactionboxdisplay")
LightEncounter           = libRequire("magical-glass", "scripts/lightbattle/lightencounter")

MagicalGlassLib = {}
local lib = MagicalGlassLib

function lib:init()

    Utils.hook(Game, "encounter", function(orig, object, encounter, transition, enemy, context)
        -- For testing let's start our thingy instead
        -- when this shit's done, make a thing that checks for the class' type (encounter or encounterlight)
        object:encounterLight(encounter, transition, enemy, context)
        --orig(object, encounter, transition, enemy) 
    end)

    Utils.hook(LightItemMenu, "init", function(orig, self)
    
        orig(self)

        -- States: ITEMSELECT, ITEMOPTION, PARTYSELECT

        --self.party_select_bg = UIBox(-36, 242, 372, 52)
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

function lib:postInit()
    Game:setFlag("serious_mode", false)
    Game:setFlag("enable_tp", false)
    Game:setFlag("gauge_styles", "undertale") -- undertale, deltarune, deltatraveler
    Game:setFlag("name_color", PALETTE["pink_spare"]) -- yellow, white, pink
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

    if context then
        self.battle.encounter_context = context
    end

    self.state = "BATTLE"

    self.battle = LightBattle()

    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "ACTIONSELECT", encounter)
    end

    self.stage:addChild(self.battle)

end

return lib