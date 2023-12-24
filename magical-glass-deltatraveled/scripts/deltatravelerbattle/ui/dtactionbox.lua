local DTActionBox, super = Class(Object)

function DTActionBox:init(x, y, index, battler)
    super.init(self, x, y)

    self.up = false

    self.down_states = {
        "ENEMYDIALOGUE",
        "DEFENDING",
        "DEFENDINGBEGIN"
    }
    self.down = false

    self.index = index
    self.battler = battler

    local ox, oy = self.battler.actor:getLightBattleOffsetDown()
    self.battler:setPosition((self.x + 90) + ox, self.y + (self.battler.actor.height * 2) + oy)

    self.display = DTActionBoxDisplay(self)
    self:addChild(self.display)

    self.selected_button = 1
    self.last_button = nil

    self.data_offset = 0

    if not Game.battle.encounter.story then
        self:createButtons()
    end
end

function DTActionBox:getButtons(battler) end

function DTActionBox:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end

    self.buttons = {}

    local btn_types = {"fight", "act", "spell", "item", "mercy"}

    if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
    if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "spell") end

    for lib_id,_ in pairs(Mod.libs) do
        btn_types = Kristal.libCall(lib_id, "getActionButtons", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getActionButtons", self.battler, btn_types) or btn_types

    for i,btn in ipairs(btn_types) do
        if type(btn) == "string" then
            local x
            local loc = 2
            if #btn_types <= 4 then
                if btn == "fight" then
                    loc = 1
                elseif btn == "act" or btn == "spell" then
                    loc = 2
                elseif btn == "item" then
                    loc = 3
                elseif btn == "mercy" then
                    loc = 4
                end
                x = math.floor(87 + ((loc - 1) * 156))
                if loc == 2 then
                    x = x - 3
                elseif loc == 3 then
                    x = x + 1
                end
            else
                x = math.floor(80 + ((i - 1) * 117))
            end
            
            local button = LightActionButton(btn, self.battler, x, 445)
            button.actbox = self
            table.insert(self.buttons, button)
            Game.battle:addChild(button)
        else
            btn:setPosition(math.floor(80 + ((i - 1) * 156)) + 0.5, 183)
            btn.battler = self.battler
            btn.actbox = self
            table.insert(self.buttons, btn)
            Game.battle:addChild(btn)
        end
    end

    self.selected_button = Utils.clamp(self.selected_button, 1, #self.buttons)
end

function DTActionBox:update()
    for _,button in ipairs(self.buttons) do
        if self.index == 1 or Game.battle.current_selecting == self.index then
            button.visible = true
        else
            button.visible = false
        end
    end

    local action = false
    for _,iaction in ipairs(Game.battle.current_actions) do
        if iaction.character_id == Game.battle:getPartyIndex(self.battler.chara.id) then
            action = true
        end
    end

    if not Utils.containsValue(self.down_states, Game.battle.state) or self.battler.force_action_box == "down" then
        if Game.battle.current_selecting == self.index or action or self.battler.force_action_box == "up" then
            if not self.up or self.down then
                self.battler.visible = true
                self.down = false
                self.up = true
                local ox, oy = self.battler.actor:getLightBattleOffsetUp()
                TweenManager.tween(self, {y = 275.5}, 9, "outExpo")
                TweenManager.tween(self.display, {y = 0}, 9, "outExpo")
                TweenManager.tween(self.battler, {x = (self.x + 90) + ox, y = 275.5 + oy}, 11, "outExpo")
            end
        else
            if self.up or self.down then
                self.up = false
                self.down = false
                local ox, oy = self.battler.actor:getLightBattleOffsetDown()
                TweenManager.tween(self, {y = 283.5}, 10, "outExpo")
                TweenManager.tween(self.display, {y = 0}, 9, "outExpo")
                TweenManager.tween(self.battler, {x = (self.x + 90) + ox, y = 283.5 + (self.battler.actor.height * 2) + oy}, 11, "outExpo")
            end
        end       
    else
        if not self.down then
            self.down = true
            local ox, oy = self.battler.actor:getLightBattleOffsetDown()
            self.battler.visible = false
            TweenManager.tween(self, {y = 407.5}, 10, "outExpo")
            TweenManager.tween(self.display, {y = 8.5}, 9, "outExpo")
            TweenManager.tween(self.battler, {x = (self.x + 90) + ox, y = 283.5 + (self.battler.actor.height * 2) + oy}, 11, "outExpo")
        end
    end

    if self.buttons and (Game.battle.current_selecting == self.index) then
        for i,button in ipairs(self.buttons) do
            if (Game.battle.current_selecting == self.index) then
                button.selectable = true
                button.hovered = (self.selected_button == i)
            else
                button.selectable = false
                button.hovered = false
            end
        end
    end

    super.update(self)
end

function DTActionBox:select()
    self.buttons[self.selected_button]:select()
    self.last_button = self.selected_button
end

function DTActionBox:unselect()
    self.buttons[self.selected_button]:unselect()
end

function DTActionBox:snapSoulToButton()
    if self.buttons then
        if self.selected_button < 1 then
            self.selected_button = #self.buttons
        end

        if self.selected_button > #self.buttons then
            self.selected_button = 1
        end

        Game.battle.soul.x = self.buttons[self.selected_button].x - 39
        Game.battle.soul.y = self.buttons[self.selected_button].y + 9
        Game.battle:toggleSoul(true)
    end
end

function DTActionBox:draw()

    -- boxes are also darkened during the defending phase and the battler isn't being attacked
    -- see spinning robo's spin act or mondo mole's grab attack
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, -30, 180, 45)

    if self.battler.is_down then
        love.graphics.setColor(COLORS.gray)
    else
        love.graphics.setColor(self.battler.chara:getLightColor())
    end
    love.graphics.setLineWidth(5)
    love.graphics.rectangle("line", 0, -30, 180, 45)

    super.draw(self)

end

return DTActionBox