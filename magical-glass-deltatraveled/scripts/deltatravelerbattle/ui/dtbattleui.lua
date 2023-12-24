local DTBattleUI, super = Class(LightBattleUI)

function DTBattleUI:init()
    LightBattleUI.__super.init(self, 0, 270)

    self.layer = BATTLE_LAYERS["ui"]
    
    self.current_encounter_text = Game.battle.encounter.text

    self.arena = Game.battle.arena

    self.style = Kristal.getLibConfig("magical-glass", "gauge_style")
    self.draw_mercy = Kristal.getLibConfig("magical-glass", "mercy_bar")
    self.draw_percents = Kristal.getLibConfig("magical-glass", "enemy_bar_percentages")

    -- deltatraveler has different spacing for lines and just normal spaces
    self.encounter_text = Textbox(14, 19, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "DTM-Mono", nil, true)
    self.encounter_text.text.default_sound = "ut"
    self.encounter_text.text.hold_skip = false
    self.encounter_text.text.line_offset = 5
    self.encounter_text.text.style = "none"
    self.encounter_text:setText("")
    self.encounter_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    Game.battle.arena:addChild(self.encounter_text)

    self.choice_box = Choicebox(56, 49, 529, 103, true)
    self.choice_box.active = false
    self.choice_box.visible = false
    Game.battle.arena:addChild(self.choice_box)

    self.text_choice_box = TextChoicebox(14, 19, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "DTM-Mono", nil, true)
    self.text_choice_box:setText("")
    self.text_choice_box.active = false
    self.text_choice_box.visible = false
    Game.battle.arena:addChild(self.text_choice_box)

    self.short_act_text_1 = DialogueText("", 14, 17, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self.short_act_text_2 = DialogueText("", 14, 17 + 30, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    self.short_act_text_3 = DialogueText("", 14, 17 + 30 + 30, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false, line_offset = 0})
    Game.battle.arena:addChild(self.short_act_text_1)
    Game.battle.arena:addChild(self.short_act_text_2)
    Game.battle.arena:addChild(self.short_act_text_3)

    if Kristal.getLibConfig("magical-glass", "item_info") == "deltatraveler" then
        self.help_window = HelpWindow(SCREEN_WIDTH/2, 397) -- height is 99px in dt
        self.help_window.layer = BATTLE_LAYERS["ui"] - 6
        Game.battle:addChild(self.help_window)
    end

    self.attack_box = nil
    self.action_boxes = {}
    
    self.attacking = false

    local size_offset = 0
    local box_gap = 0

    if #Game.battle.party == 3 then
        size_offset = 40
        box_gap = 5
    elseif #Game.battle.party == 2 then
        size_offset = 100
        box_gap = 75
    elseif #Game.battle.party == 1 then
        size_offset = 230
    end

    for i,battler in ipairs(Game.battle.party) do
        local action_box = DTActionBox((size_offset + (i - 1) * (185 + box_gap)), 283, i, battler)
        action_box.layer = BATTLE_LAYERS["below_ui"]
        Game.battle:addChild(action_box)
        table.insert(self.action_boxes, action_box)
        battler.chara:onActionBox(action_box, false)
    end
    
    self.shown = true 

    self.sparestar = Assets.getTexture("ui/battle/sparestar")
    self.tiredmark = Assets.getTexture("ui/battle/tiredmark")
end

function DTBattleUI:beginAttack()
    Game.battle.current_selecting = 0

    self.attack_box = DTAttackBox()
    Game.battle:addChild(self.attack_box)

    self.attacking = true
end

function DTBattleUI:endAttack()
    if not Game.battle:retargetEnemy() then
        Game.battle.cancel_attack = true
    else
        self.attack_box.fading = true
    end

    for _,lane in ipairs(self.attack_box.lanes) do
        for _,bolt in ipairs(lane.bolts) do
            bolt:remove()
        end
    end

    self.attacking = false
end

function DTBattleUI:drawState()
    local state = Game.battle.state
    if state == "MENUSELECT" then
        local page = math.ceil(Game.battle.current_menu_x / Game.battle.current_menu_columns) - 1
        local max_page = math.ceil(#Game.battle.menu_items / (Game.battle.current_menu_columns * Game.battle.current_menu_rows)) - 1

        local x = 0
        local y = 0

        local menu_offsets = { -- {soul, text}
            ["ACT"] = {-8, 0},
            ["ITEM"] = {0, 0},
            ["SPELL"] = {-8, 0},
            ["MERCY"] = {0, 0}, --doesn't matter lmao
        }

        local extra_offset
        for name, offset in pairs(menu_offsets) do
            if name == Game.battle.state_reason then
                extra_offset = offset
            end
        end

        --Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248), 255 + ((Game.battle.current_menu_y) * 31.5))
        Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * (248 + extra_offset[1])), 291 + ((Game.battle.current_menu_y) * 31.5))


        local font
        if Kristal.getLibConfig("magical-glass-deltatraveled", "accurate_fonts") then
            font = Assets.getFont("main_mono")
        else
            font = Assets.getFont("DTM-Mono")
        end
        love.graphics.setFont(font, 32)

        local col = Game.battle.current_menu_columns
        local row = Game.battle.current_menu_rows
        local draw_amount = col * row

        local page_offset = page * draw_amount

        for i = page_offset + 1, math.min(page_offset + (draw_amount), #Game.battle.menu_items) do
            local item = Game.battle.menu_items[i]

            Draw.setColor(1, 1, 1, 1)
            local text_offset = 0
            local head_offset = 0
            local able = Game.battle:canSelectMenuItem(item)
            if item.party then  
                for index, party_id in ipairs(item.party) do
                    local chara = Game:getPartyMember(party_id)

                    if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                        local ox, oy = chara:getHeadIconOffset()
                        Draw.draw(Assets.getTexture(chara:getHeadIcons() .. "/head"), head_offset + 102 + (x * (230 + extra_offset[2])) + ox, 41 + (y * 32) + oy)
                        head_offset = head_offset + 34
                        text_offset = (text_offset + 39) + (-2 * #item.party)
                    end
                end
            end

            if item.icons then  
                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = {icon, false, 0, 0, nil}
                    end
                    if not icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 102 + (x * (240 + extra_offset[2])) + (icon[3] or 0), 50 + (y * 32) + (icon[4] or 0))
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if able or item.tp and (item.tp > Game:getTension()) then
                if #item.party == 1 then
                    Draw.setColor(Game:getPartyMember(item.party[1]):getLightXActColor())
                else
                    Draw.setColor(item.color or {1, 1, 1, 1})
                end
            else
                Draw.setColor(COLORS.gray)
            end

            for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                if enemy.mercy >= 100 and item.special == "spare" then
                    love.graphics.setColor(MagicalGlassLib.name_color)
                end
            end

            local name = item.name
            if item.seriousname and MagicalGlassLib.serious_mode then
                name = item.seriousname
            elseif item.shortname then
                name = item.shortname
            end

            if #item.party > 0 then
                love.graphics.print(name, text_offset + 95 + (x * (240 + extra_offset[2])), 36 + (y * 32))
            else
                love.graphics.print("* " .. name, text_offset + 100 + (x * (240 + extra_offset[2])), 36 + (y * 32))
            end

            text_offset = text_offset + font:getWidth(item.name)

            if item.icons then
                if able then
                    Draw.setColor(1, 1, 1)
                end

                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = {icon, false, 0, 0, nil}
                    end
                    if icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 30 + (x * 230) + (icon[3] or 0), 50 + (y * 30) + (icon[4] or 0))
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if Game.battle.current_menu_columns == 1 then
                if x == 0 then
                    y = y + 1
                end
            else
                if x == 0 then
                    x = 1
                else
                    x = 0
                    y = y + 1
                end
            end

        end

        local tp_offset = 0
        local current_item = Game.battle.menu_items[Game.battle:getItemIndex()] or Game.battle.menu_items[1] -- crash prevention in case of an invalid option
        if current_item.description then
            if self.help_window then
                if #current_item.description > 0 then
                    self.help_window:setDescription(current_item.description)
                end
            elseif Kristal.getLibConfig("magical-glass", "item_info") == "magical_glass" then
                Draw.setColor(COLORS.gray)
                local str = current_item.description:gsub('\n', ' ')
                love.graphics.print(str, 100 - 16, 64)
            end
        end

        if current_item.tp and current_item.tp ~= 0 then
            if self.help_window then
                self.help_window:setTension(current_item.tp)
                Game:setTensionPreview(current_item.tp)
            elseif Kristal.getLibConfig("magical-glass", "item_info") == "magical_glass" then
                Draw.setColor(PALETTE["tension_desc"])
                love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% "..Game:getConfig("tpName"), 260 + 208, 64)
                Game:setTensionPreview(current_item.tp)
            end
        else
            Game:setTensionPreview(0)
        end

        Draw.setColor(1, 1, 1, 1)

        local offset = 0
        if Game.battle:isPagerMenu() then
            if Game.battle.state_reason == "SPELL" then
                offset = 96
            end
            love.graphics.print("PAGE " .. page + 1, 386 + offset, 100)
        end

    elseif state == "ENEMYSELECT" or state == "XACTENEMYSELECT" then
        --self:clearMenuText()

        local enemies = Game.battle.enemies
        local reason = Game.battle.state_reason

        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#enemies / 3) - 1
        local page_offset = page * 3

        Game.battle.soul:setPosition(72, 291 + ((Game.battle.current_menu_y - (page * 3)) * 31.5))
        local font_main = Assets.getFont("main")
        local font_mono
        local font_namelv

        if Kristal.getLibConfig("magical-glass-deltatraveled", "accurate_fonts") then
            font_mono = Assets.getFont("main_mono")
            font_namelv = Assets.getFont("namelv")
        else
            font_mono = Assets.getFont("DTM-Mono")
            font_namelv = Assets.getFont("battlehud")
        end

        Draw.setColor(1, 1, 1, 1)

        if self.draw_percents and self.style == "deltatraveler_new" then
            love.graphics.setFont(font_main)
            love.graphics.print("HP", 412, 21, 0, 1, 0.75)
            love.graphics.print("MERCY", 502, 21, 0, 1, 0.75)
        elseif self.draw_percents and self.style == "deltarune" then
            love.graphics.setFont(font_main)
            if Game.battle.state == "ENEMYSELECT" and Game.battle.state_reason ~= "ACT" then
                love.graphics.print("HP", 400, 25, 0, 1, 0.5)
            end
            if self.draw_mercy then
                love.graphics.print("MERCY", 500, 25, 0, 1, 0.5)
            end
        end

        love.graphics.setFont(font_mono)

        for index = page_offset + 1, math.min(page_offset + 3, #enemies) do

            local enemy = enemies[index]
            local y_offset = (index - page_offset - 1) * 32

            local name_colors = enemy:getNameColors()
            if type(name_colors) ~= "table" then
                name_colors = {name_colors}
            end

            local name = "* " .. enemy.name
            if #Game.battle.enemies <= 3 then
                if not enemy.done_state then
                    if index == 1 and #Game.battle.enemies > 1 then
                        if #Game.battle.enemies == 3 then
                            if enemy.id == enemies[2].id or enemy.id == enemies[3].id then
                                name = name .. " A"
                            end
                        else
                            if enemy.id == enemies[2].id then
                                name = name .. " A"
                            end
                        end
                    elseif index == 2 and #Game.battle.enemies > 1 then
                        if enemy.id == enemies[1].id then
                            name = name .. " B"
                        end
                    elseif index == 3 and #Game.battle.enemies > 2 then
                        if enemy.id == enemies[2].id then
                            name = name .. " C"
                        end
                    end
                end
            end

            if not enemy.done_state then
                if #name_colors <= 1 then
                    Draw.setColor(name_colors[1] or enemy.selectable and {1, 1, 1} or {0.5, 0.5, 0.5})
                    love.graphics.print(name, 100, 36 + y_offset)
                else
                    local canvas = Draw.pushCanvas(font_mono:getWidth("* " .. enemy.name), font_mono:getHeight())
                    Draw.setColor(1, 1, 1)
                    love.graphics.print("* " .. enemy.name) -- todo: exclude the * from the gradient
                    Draw.popCanvas()

                    local color_canvas = Draw.pushCanvas(#name_colors, 1)
                    for i = 1, #name_colors do
                        -- Draw a pixel for the color
                        Draw.setColor(name_colors[i])
                        love.graphics.rectangle("fill", i-1, 0, 1, 1)
                    end
                    Draw.popCanvas()

                    Draw.setColor(1, 1, 1)

                    local shader = Kristal.Shaders["DynGradient"]
                    love.graphics.setShader(shader)
                    shader:send("colors", color_canvas)
                    shader:send("colorSize", {#name_colors, 1})
                    Draw.draw(canvas, 100, 36 + y_offset)
                    love.graphics.setShader()
                end
            end

            Draw.setColor(1, 1, 1)

            if self.style == "deltarune" then
                local spare_icon = false
                local tired_icon = false

                if enemy.tired and enemy:canSpare() then
                    if enemy:getMercyVisibility() then
                        Draw.draw(self.sparestar, 140 + font_mono:getWidth(enemy.name) + 10, 10 + y_offset)
                        spare_icon = true
                    end
                    
                    Draw.draw(self.tiredmark, 140 + font_mono:getWidth(enemy.name) + 30, 10 + y_offset)
                    tired_icon = true
                elseif enemy.tired then
                    Draw.draw(self.tiredmark, 140 + font_mono:getWidth(enemy.name) + 30, 10 + y_offset)
                    tired_icon = true
                elseif enemy.mercy >= 100 and enemy:getMercyVisibility() then
                    Draw.draw(self.sparestar, 140 + font_mono:getWidth(enemy.name) + 10, 10 + y_offset)
                    spare_icon = true
                end

                for i = 1, #enemy.icons do
                    if enemy.icons[i] then
                        if (spare_icon and (i == 1)) or (tired_icon and (i == 2)) then
                            -- Skip the custom icons if we're already drawing spare/tired ones
                        else
                            Draw.setColor(1, 1, 1, 1)
                            Draw.draw(enemy.icons[i], 80 + font:getWidth(enemy.name) + (i * 20), 60 + y_off)
                        end
                    end
                end
            end

--[[                 if Game.battle.state == "XACTENEMYSELECT" then
                Draw.setColor(Game.battle.party[Game.battle.current_selecting].chara:getXActColor())
                if Game.battle.selected_xaction.id == 0 then
                    love.graphics.print(enemy:getXAction(Game.battle.party[Game.battle.current_selecting]), 282, 35 + y_offset)
                else
                    love.graphics.print(Game.battle.selected_xaction.name, 282, 35 + y_offset)
                end
            end ]]


            if self.style == "deltatraveler_new" or Game.battle.state_reason ~= "ACT" then
                local namewidth = font_mono:getWidth(enemy.name)

                Draw.setColor(128/255, 128/255, 128/255, 1)

                if Kristal.getLibConfig("magical-glass", "gauge_styles") == "deltarune" then
                    if ((80 + namewidth + 110 + (font_mono:getWidth(enemy.comment) / 2)) < 338) then
                        love.graphics.print(enemy.comment, 80 + namewidth + 110, 0 + y_offset)
                    else
                        love.graphics.print(enemy.comment, 80 + namewidth + 110, 0 + y_offset, 0, 0.5, 1)
                    end
                end

                local hp_percent = enemy.health / enemy.max_health

                local max_width = 0
                local hp_x = self.style == "undertale" and 190 or 400

                if enemy.selectable then
                    -- I swear, the kristal team using math.ceil for the gauges here despite people asking them to change it to floor
                    -- is an in-joke

                    if self.style == "undertale" then
                        if enemy:getHPVisibility() then
                            local name_length = 0

                            for _,enemy in ipairs(enemies) do
                                if string.len(enemy.name) > name_length then
                                    name_length = string.len(enemy.name)
                                end
                            end

                            hp_x = hp_x + (name_length * 16)

                            Draw.setColor(1,0,0,1)
                            love.graphics.rectangle("fill", hp_x, 10 + y_offset, 101, 17)

                            Draw.setColor(PALETTE["action_health"])
                            love.graphics.rectangle("fill", hp_x, 10 + y_offset, math.floor(hp_percent * 101), 17)
                        end
                    elseif self.style == "deltarune" then
                        if enemy:getHPVisibility() then
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x, 44 + y_offset, 81, 17)
        
                            Draw.setColor(PALETTE["action_health"])
                            love.graphics.rectangle("fill", hp_x, 44 + y_offset, math.floor(hp_percent * 81), 17)
                        else
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x, 44 + y_offset, 81, 17)
                        end

                        if self.draw_percents then
                            Draw.setColor(PALETTE["action_health_text"])
                            if enemy:getHPVisibility() then
                                love.graphics.print(math.floor(hp_percent * 100) .. "%", hp_x + 4, 44 + y_offset, 0, 1, 0.5)
                            else
                                love.graphics.print("???", hp_x + 4, 10 + y_offset, 0, 1, 0.5)
                            end
                        end

                        if self.draw_mercy then
                            if enemy.selectable then
                                Draw.setColor(PALETTE["battle_mercy_bg"])
                            else
                                Draw.setColor(127/255, 127/255, 127/255, 1)
                            end
                            love.graphics.rectangle("fill", 500, 44 + y_offset, 81, 16)
            
                            if enemy.disable_mercy then
                                Draw.setColor(PALETTE["battle_mercy_text"])
                                love.graphics.setLineWidth(2)
                                love.graphics.line(500, 11 + y_offset, 500 + 81, 10 + y_offset + 16 - 1)
                                love.graphics.line(500, 10 + y_offset + 16 - 1, 500 + 81, 11 + y_offset)
                            else
                                Draw.setColor(1, 1, 0, 1)
                                if enemy:getMercyVisibility() then
                                    love.graphics.rectangle("fill", 500, 44 + y_offset, ((enemy.mercy / 100) * 81), 16)
                                end
            
                                if self.draw_percents and enemy.selectable then
                                    Draw.setColor(PALETTE["battle_mercy_text"])
                                    if enemy:getMercyVisibility() then
                                        love.graphics.print(math.floor(enemy.mercy) .. "%", 504, 44 + y_offset, 0, 1, 0.5)
                                    else
                                        love.graphics.print("???", 504, 44 + y_offset, 0, 1, 0.5)
                                    end
                                end
                            end
                        end
                    elseif self.style == "deltatraveler_new" then
                        if enemy:getHPVisibility() then
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x + 12, 47 + y_offset, 75, 17)
        
                            Draw.setColor(PALETTE["action_health"])
                            love.graphics.rectangle("fill", hp_x + 12, 47 + y_offset, math.floor(hp_percent * 75), 17)
                        else
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x + 12, 47 + y_offset, 75, 17)
                        end

                        if self.draw_percents then
                            love.graphics.setFont(font_namelv)
                            local shadow_offset = 1

                            Draw.setColor(COLORS.black)
                            if enemy:getHPVisibility() then
                                love.graphics.printf(math.floor(hp_percent * 100) .. "%", (hp_x + 20) + shadow_offset, (46 + y_offset) + shadow_offset, 64, "center")
                            else
                                love.graphics.print("???", (hp_x + 32) + shadow_offset, (46 + y_offset) + shadow_offset)
                            end

                            Draw.setColor(PALETTE["action_health_text"])
                            if enemy:getHPVisibility() then
                                love.graphics.printf(math.floor(hp_percent * 100) .. "%", hp_x + 20, 46 + y_offset, 64, "center")
                            else
                                love.graphics.print("???", hp_x + 35, 46 + y_offset)
                            end
                        end

                        if self.draw_mercy then
                            love.graphics.setFont(font_namelv)
                            local shadow_offset = 1

                            Draw.setColor(PALETTE["battle_mercy_bg"])

                            love.graphics.rectangle("fill", 502, 47 + y_offset, 75, 17)
            
                            if enemy.disable_mercy then
                                Draw.setColor(PALETTE["battle_mercy_text"])
                                love.graphics.setLineWidth(2)
                                love.graphics.line(500, 11 + y_offset, 500 + 75, 10 + y_offset + 16 - 1)
                                love.graphics.line(500, 10 + y_offset + 16 - 1, 500 + 75, 11 + y_offset)
                            else
                                Draw.setColor(1, 1, 0, 1)
                                if enemy:getMercyVisibility() then
                                    love.graphics.rectangle("fill", 502, 47 + y_offset, ((enemy.mercy / 100) * 75), 17)
                                end
            
                                if self.draw_percents then
                                    Draw.setColor(COLORS.black)
                                    if enemy:getHPVisibility() then
                                        love.graphics.printf(math.floor(enemy.mercy) .. "%", 509 + shadow_offset, (46 + y_offset) + shadow_offset, 64, "center")
                                    else
                                        love.graphics.print("???", 509 + shadow_offset, (46 + y_offset) + shadow_offset)
                                    end

                                    Draw.setColor({142/255, 12/255, 0})
                                    if enemy:getMercyVisibility() then
                                        love.graphics.printf(math.floor(enemy.mercy) .. "%", 509, 46 + y_offset, 64, "center")
                                    else
                                        love.graphics.print("???", 509, 46 + y_offset)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    elseif state == "PARTYSELECT" then
        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#Game.battle.party / 3) - 1
        local page_offset = page * 3

        Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248), 291 + ((Game.battle.current_menu_y) * 31.5))
        
        local font
        if Kristal.getLibConfig("magical-glass-deltatraveled", "accurate_fonts") then
            font = Assets.getFont("main_mono")
        else
            font = Assets.getFont("DTM-Mono")
        end
        love.graphics.setFont(font)

        for index = page_offset + 1, math.min(page_offset + 3, #Game.battle.party) do
            Draw.setColor(1, 1, 1, 1)
            love.graphics.print("* " .. Game.battle.party[index].chara:getName(), 100, 36 + ((index - page_offset - 1) * 32))

            if self.style == "undertale" then
                Draw.setColor(PALETTE["action_health_bg"])
                love.graphics.rectangle("fill", 318, 10 + ((index - page_offset - 1) * 32), 101, 17)

                local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                Draw.setColor(PALETTE["action_health"])
                love.graphics.rectangle("fill", 318, 10 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
            elseif self.style == "deltarune" then
                Draw.setColor(PALETTE["action_health_bg"])
                love.graphics.rectangle("fill", 400, 10 + ((index - page_offset - 1) * 32), 101, 17)

                local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                Draw.setColor(PALETTE["action_health"])
                love.graphics.rectangle("fill", 400, 10 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
            elseif self.style == "deltatraveler_old" or self.style == "deltatraveler_new" then
                Draw.setColor(PALETTE["action_health_bg"])
                love.graphics.rectangle("fill", 272, 47 + ((index - page_offset - 1) * 32), 101, 17)

                local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                Draw.setColor(PALETTE["action_health"])
                love.graphics.rectangle("fill", 272, 47 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
            end
         end
    elseif state == "FLEEING" or state == "TRANSITIONOUT" then
        local font
        if Kristal.getLibConfig("magical-glass-deltatraveled", "accurate_fonts") then
            font = Assets.getFont("main_mono")
        else
            font = Assets.getFont("DTM-Mono")
        end
        love.graphics.setFont(font, 32)
        local message = Game.battle.encounter:getUsedFleeMessage() or ""

        Draw.setColor(1, 1, 1, 1)
        love.graphics.print(message, 100, 36)
    end
end


return DTBattleUI