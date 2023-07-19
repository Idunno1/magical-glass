local LightBattleUI, super = Class(Object)

function LightBattleUI:init()
    super.init(self, 0, 270)

    self.layer = BATTLE_LAYERS["ui"]

    self.current_encounter_text = Game.battle.encounter.text

    self.style = Game:getFlag("gauge_styles")

    self.arena = LightArena(SCREEN_WIDTH/2, 385)
    self.arena.layer = BATTLE_LAYERS["ui"] -- change to the arena layer when wave starts
    self.arena.collider.colliders.layer = self.arena.layer + 2
    Game.battle:addChild(self.arena)

    self.encounter_text = Textbox(14, 17, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, "main_mono", nil, true)
    self.encounter_text.text.hold_skip = false
    self.encounter_text.text.line_offset = 5
    self.encounter_text.text.style = "none"
    self.encounter_text.text.state.typing_sound = "ut"
    self.encounter_text:setText("")
    self.encounter_text.text.state.typing_sound = "ut"
    self.encounter_text.debug_rect = {-30, -12, SCREEN_WIDTH+1, 124}
    self.arena:addChild(self.encounter_text)

    self.choice_box = Choicebox(56, 49, 529, 103, true)
    self.choice_box.active = false
    self.choice_box.visible = false
    self:addChild(self.choice_box)

    self.short_act_text_1 = DialogueText("", 30, 51, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false})
    self.short_act_text_2 = DialogueText("", 30, 51 + 30, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false})
    self.short_act_text_3 = DialogueText("", 30, 51 + 30 + 30, SCREEN_WIDTH - 30, SCREEN_HEIGHT - 53, {wrap = false})
    self:addChild(self.short_act_text_1)
    self:addChild(self.short_act_text_2)
    self:addChild(self.short_act_text_3)

    self.attack_box = nil
    self.action_boxes = {}
    
    self.attacking = false

    -- for the deltatraveler stuff, disabled for now
--[[     local size_offset = 0
    local box_gap = 0

    if #Game.battle.party == 3 then
        size_offset = 0
        box_gap = 0
    elseif #Game.battle.party == 2 then
        size_offset = 108
        box_gap = 1
    elseif #Game.battle.party == 1 then
        size_offset = 213
        box_gap = 0
    end

    for i,battler in ipairs(Game.battle.party) do
        local action_box = LightActionBox(20 + i, 0, i, battler)
        self:addChild(action_box)
        table.insert(self.action_boxes, action_box)
        battler.chara:onActionBox(action_box, false)
    end ]]

    self.action_box_ut = LightActionBoxSingle(20, 0, 1, Game.battle.party[1])
    self:addChild(self.action_box_ut)
    table.insert(self.action_boxes, self.action_box_ut)
    Game.battle.party[1].chara:onActionBox(self.action_box_ut, false)

    self.shown = true 

    if self.style == "deltarune" then
        self.sparestar = Assets.getTexture("ui/battle/sparestar")
        self.tiredmark = Assets.getTexture("ui/battle/tiredmark")
    end

end

function LightBattleUI:clearEncounterText()
    self.encounter_text:setActor(nil)
    self.encounter_text:setFace(nil)
    self.encounter_text:setFont()
    self.encounter_text:setAlign("left")
    self.encounter_text:setSkippable(true)
    self.encounter_text:setAdvance(true)
    self.encounter_text:setAuto(false)
    self.encounter_text:setText("")
end

function LightBattleUI:beginAttack()
    local attack_order = Utils.pickMultiple(Game.battle.normal_attackers, #Game.battle.normal_attackers)

    local last_offset = -1
    local offset = 0

    self.attack_box = AttackBox(self.arena.x + 20, self.arena.y + 20)
    self:addChild(self.attack_box)

    self.attacking = true
end

function LightBattleUI:endAttack()
    Game.battle.cancel_attack = false
    self.attack_box.scale_y = (self.attack_box.scale_y - 0.08) * DTMULT
    self.attack_box:fadeOutSpeedAndRemove(1) -- needs scale shit
    self.attacking = false
end

function LightBattleUI:drawActionArea()
    self:drawState()
end

function LightBattleUI:drawState()

    local state = Game.battle.state
    if state == "MENUSELECT" then

        local page = math.ceil(Game.battle.current_menu_x / Game.battle.current_menu_columns) - 1
        local max_page = math.ceil(#Game.battle.menu_items / (Game.battle.current_menu_columns * Game.battle.current_menu_rows)) - 1

        local x = 0
        local y = 0

        local menu_offsets = { -- {soul, text}
            ["ACT"] = {12, 16},
            ["ITEM"] = {0, 0},
            ["MERCY"] = {0, 0}, --doesn't matter lmao
        }

        local extra_offset
        for name, offset in pairs(menu_offsets) do
            if name == Game.battle.state_reason then
                extra_offset = offset
            end
        end

        --Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248), 255 + ((Game.battle.current_menu_y) * 31.5))
        Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * (248 + extra_offset[1])), 255 + ((Game.battle.current_menu_y) * 31.5))

        local font = Assets.getFont("main_mono")
        love.graphics.setFont(font, 32)

        local col = Game.battle.current_menu_columns
        local row = Game.battle.current_menu_rows
        local draw_amount = col * row

        local page_offset = page * draw_amount

        for i = page_offset + 1, math.min(page_offset + (draw_amount), #Game.battle.menu_items) do
            local item = Game.battle.menu_items[i]

            Draw.setColor(1, 1, 1, 1)
            local text_offset = 0
            -- Are we able to select this?
            local able = Game.battle:canSelectMenuItem(item)
            if item.party then
                if not able then
                    -- We're not able to select this, so make the heads gray.
                    Draw.setColor(COLORS.gray)
                end

                for index, party_id in ipairs(item.party) do
                    local chara = Game:getPartyMember(party_id)

                    -- Draw head only if it isn't the currently selected character
                    -- above statement might conflict with deltatraveler -sam
                    if Game.battle:getPartyIndex(party_id) ~= Game.battle.current_selecting then
                        local ox, oy = chara:getHeadIconOffset()
                        Draw.draw(Assets.getTexture(chara:getHeadIcons() .. "/head"), text_offset + 90 + (x * (230 + extra_offset[2])) + ox, 5 + (y * 32) + oy)
                        text_offset = text_offset + 37
                    end
                end
            end

            if item.icons then
                if not able then
                    -- We're not able to select this, so make the heads gray.
                    Draw.setColor(COLORS.gray)
                end

                for _, icon in ipairs(item.icons) do
                    if type(icon) == "string" then
                        icon = {icon, false, 0, 0, nil}
                    end
                    if not icon[2] then
                        local texture = Assets.getTexture(icon[1])
                        Draw.draw(texture, text_offset + 100 + (x * (240 + extra_offset[2])) + (icon[3] or 0), 50 + (y * 32) + (icon[4] or 0))
                        text_offset = text_offset + (icon[5] or texture:getWidth())
                    end
                end
            end

            if able then
                Draw.setColor(item.color or {1, 1, 1, 1})
            else
                Draw.setColor(COLORS.gray)
            end

            local highlight_spare
            for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
                if enemy.mercy >= 100 then
                    highlight_spare = true
                end
            end

            if highlight_spare and item.name == "Spare" then
                love.graphics.setColor(Game:getFlag("name_color"))
            end

            local name = item.name
            if item.shortname then
                name = item.shortname
            elseif item.seriousname and Game:getFlag("serious_mode") then
                name = item.seriousname
            end

            if #item.party > 0 then
                love.graphics.print(name, text_offset + 89 + (x * (240 + extra_offset[2])), (y * 32))
            else
                love.graphics.print("* " .. name, text_offset + 100 + (x * (240 + extra_offset[2])), (y * 32))
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

        -- Print information about currently selected item
        local tp_offset = 0
        local current_item = Game.battle.menu_items[Game.battle:getItemIndex()]
        if current_item.description then
            Draw.setColor(COLORS.gray)
            love.graphics.print(current_item.description, 260 + 240, 50)
            Draw.setColor(1, 1, 1, 1)
            _, tp_offset = current_item.description:gsub('\n', '\n')
            tp_offset = tp_offset + 1
        end

        if current_item.tp and current_item.tp ~= 0 then
            Draw.setColor(PALETTE["tension_desc"])
            love.graphics.print(math.floor((current_item.tp / Game:getMaxTension()) * 100) .. "% "..Game:getConfig("tpName"), 260 + 240, 50 + (tp_offset * 32))
            Game:setTensionPreview(current_item.tp)
        else
            Game:setTensionPreview(0)
        end

        Draw.setColor(1, 1, 1, 1)

        for _,menu in ipairs(Game.battle.pager_menus) do
            if Game.battle.state_reason == menu then
                love.graphics.print("PAGE " .. page + 1, 388, 64)
            end
        end

    elseif state == "ENEMYSELECT" or state == "XACTENEMYSELECT" then
        local enemies = Game.battle:getActiveEnemies()
        local reason = Game.battle.state_reason

        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#enemies / 3) - 1
        local page_offset = page * 3

        Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248), 255 + ((Game.battle.current_menu_y) * 31.5))
        local font_main = Assets.getFont("main")
        local font_mono = Assets.getFont("main_mono")

        local draw_mercy = Kristal.getLibConfig("magical-glass", "mercyBar")
        local draw_percents = Kristal.getLibConfig("magical-glass", "enemyBarPercentages")

        Draw.setColor(1, 1, 1, 1)

        --[[
        if draw_mercy and draw_percents and self.style ~= "undertale" then
            love.graphics.setFont(font_main)
            if Game.battle.state == "ENEMYSELECT" and self.style ~= "undertale" and Game.battle.state_reason ~= "ACT" then
                love.graphics.print("HP", 400, -10, 0, 1, 0.5)
            end
            love.graphics.print("MERCY", 500, -10, 0, 1, 0.5)
        end
        --]]

        if draw_percents and self.style ~= "undertale" then
            love.graphics.setFont(font_main)
            if Game.battle.state == "ENEMYSELECT" and self.style ~= "undertale" and Game.battle.state_reason ~= "ACT" then
                love.graphics.print("HP", 400, -10, 0, 1, 0.5)
            end
            if draw_mercy then
                love.graphics.print("MERCY", 500, -10, 0, 1, 0.5)
            end
        end

        love.graphics.setFont(font_mono)

        for index = page_offset + 1, math.min(page_offset + 3, #enemies) do

            local enemy = enemies[index]
            local y_offset = (index - page_offset - 1) * 30

            local name_colors = enemy:getNameColors()
            if type(name_colors) ~= "table" then
                name_colors = {name_colors}
            end

            if #name_colors <= 1 then
                Draw.setColor(name_colors[1] or enemy.selectable and {1, 1, 1} or {0.5, 0.5, 0.5})
                love.graphics.print("* " .. enemy.name, 100, 0 + y_offset)
            else
                local canvas = Draw.pushCanvas(font_mono:getWidth("* " .. enemy.name), font_mono:getHeight())
                Draw.setColor(1, 1, 1)
                love.graphics.print("* " .. enemy.name)
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
                Draw.draw(canvas, 100, 0 + y_offset)
                love.graphics.setShader()
            end

            Draw.setColor(1, 1, 1)

            if self.style == "deltarune" then
                local spare_icon = false
                local tired_icon = false

                if enemy.tired and enemy:canSpare() then
                    Draw.draw(self.sparestar, 140 + font_mono:getWidth(enemy.name) + 20, 10 + y_offset)
                    Draw.draw(self.tiredmark, 140 + font_mono:getWidth(enemy.name) + 40, 10 + y_offset)
                    spare_icon = true
                    tired_icon = true
                elseif enemy.tired then
                    Draw.draw(self.tiredmark, 140 + font_mono:getWidth(enemy.name) + 40, 10 + y_offset)
                    tired_icon = true
                elseif enemy.mercy >= 100 then
                    Draw.draw(self.sparestar, 140 + font_mono:getWidth(enemy.name) + 20, 10 + y_offset)
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

            if Game.battle.state == "XACTENEMYSELECT" then
                Draw.setColor(Game.battle.party[Game.battle.current_selecting].chara:getXActColor())
                if Game.battle.selected_xaction.id == 0 then
                    love.graphics.print(enemy:getXAction(Game.battle.party[Game.battle.current_selecting]), 282, 50 + y_off)
                else
                    love.graphics.print(Game.battle.selected_xaction.name, 282, 50 + y_off)
                end
            end

            if Game.battle.state == "ENEMYSELECT" then -- in dr/dt mode, hp and mercy is shown while acting

                if Game.battle.state_reason ~= "ACT" then
                    local namewidth = font_mono:getWidth(enemy.name)

                    Draw.setColor(128/255, 128/255, 128/255, 1)

                    if ((80 + namewidth + 60 + (font_mono:getWidth(enemy.comment) / 2)) < 415) then
                        love.graphics.print(enemy.comment, 80 + namewidth + 60, 50 + y_offset)
                    else
                        love.graphics.print(enemy.comment, 80 + namewidth + 60, 50 + y_offset, 0, 0.5, 1)
                    end

                    local hp_percent = enemy.health / enemy.max_health
                    local hp_x = self.style ~= "undertale" and 400 or 318

                    if enemy.selectable then
                        -- I swear, the kristal team using math.ceil for the gauges here despite people asking them to change it to floor
                        -- is an in-joke

                        if self.style == "undertale" then
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x, 10 + y_offset, 101, 17)

                            Draw.setColor(PALETTE["action_health"])
                            love.graphics.rectangle("fill", hp_x, 10 + y_offset, math.floor(hp_percent * 101), 17)
                        else
                            Draw.setColor(PALETTE["action_health_bg"])
                            love.graphics.rectangle("fill", hp_x, 10 + y_offset, 81, 17)
        
                            Draw.setColor(PALETTE["action_health"])
                            love.graphics.rectangle("fill", hp_x, 10 + y_offset, math.floor(hp_percent * 81), 17)
                        end

                        if draw_percents and self.style ~= "undertale" then
                            Draw.setColor(PALETTE["action_health_text"])
                            love.graphics.print(math.floor(hp_percent * 100) .. "%", hp_x + 4, 10 + y_offset, 0, 1, 0.5)
                        end
                    end
                end

                if draw_mercy and self.style ~= "undertale" then
                    if enemy.selectable then
                        Draw.setColor(PALETTE["battle_mercy_bg"])
                    else
                        Draw.setColor(127/255, 127/255, 127/255, 1)
                    end
                    love.graphics.rectangle("fill", 500, 10 + y_offset, 81, 16)
    
                    if enemy.disable_mercy then
                        Draw.setColor(PALETTE["battle_mercy_text"])
                        love.graphics.setLineWidth(2)
                        love.graphics.line(500, 11 + y_offset, 500 + 81, 10 + y_offset + 16 - 1)
                        love.graphics.line(500, 10 + y_offset + 16 - 1, 500 + 81, 11 + y_offset)
                    else
                        Draw.setColor(1, 1, 0, 1)
                        love.graphics.rectangle("fill", 500, 10 + y_offset, ((enemy.mercy / 100) * 81), 16)
    
                        if draw_percents and enemy.selectable then
                            Draw.setColor(PALETTE["battle_mercy_text"])
                            love.graphics.print(math.floor(enemy.mercy) .. "%", 504, 10 + y_offset, 0, 1, 0.5)
                        end
                    end
                end
            end
        end
    elseif state == "PARTYSELECT" then
        local page = math.ceil(Game.battle.current_menu_y / 3) - 1
        local max_page = math.ceil(#Game.battle.party / 3) - 1
        local page_offset = page * 3

        Game.battle.soul:setPosition(72 + ((Game.battle.current_menu_x - 1 - (page * 2)) * 248), 255 + ((Game.battle.current_menu_y) * 31.5))

        local font = Assets.getFont("main_mono")
        love.graphics.setFont(font)

        for index = page_offset + 1, math.min(page_offset + 3, #Game.battle.party) do
            Draw.setColor(1, 1, 1, 1)
            love.graphics.print("* " .. Game.battle.party[index].chara:getName(), 100, 0 + ((index - page_offset - 1) * 32))

            if self.style == "undertale" then
                Draw.setColor(PALETTE["action_health_bg"])
                love.graphics.rectangle("fill", 318, 10 + ((index - page_offset - 1) * 32), 101, 17)

                local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                Draw.setColor(PALETTE["action_health"])
                love.graphics.rectangle("fill", 318, 10 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
            else
                Draw.setColor(PALETTE["action_health_bg"])
                love.graphics.rectangle("fill", 400, 10 + ((index - page_offset - 1) * 32), 101, 17)

                local percentage = Game.battle.party[index].chara:getHealth() / Game.battle.party[index].chara:getStat("health")
                Draw.setColor(PALETTE["action_health"])
                love.graphics.rectangle("fill", 400, 10 + ((index - page_offset - 1) * 32), math.ceil(percentage * 101), 17)
            end
        end

    end

    if state == "ATTACKING" or self.attacking then
        -- dumbtarget shit goes here
    end

end

function LightBattleUI:draw()
    self:drawState()
    super.draw(self)
end

return LightBattleUI