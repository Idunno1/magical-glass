local LightActionBoxSingle, super = Class(Object)

function LightActionBoxSingle:init(x, y, index, battler)
    super.init(self, x, y)

    self.index = 1
    self.battler = battler

    self.selected_button = 1
    self.last_button = 1

    self.revert_to = 40

    self.data_offset = 0

    if not Game.battle.encounter.story then
        self:createButtons()
    end
end

function LightActionBoxSingle:getButtons(battler) end

function LightActionBoxSingle:createButtons()
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
--[[             local button = LightActionButton(btn, self.battler, math.floor(67 + ((i - 1) * 156)), 175)

            if #btn_types == 4 then
                if i == 2 then
                    button.x = button.x - 3
                elseif i == 3 then
                    button.x = button.x + 1
                end
            end ]]

            local spacing = #btn_types
            local x = math.floor(67 + ((i - 1) * 156))
            local button = LightActionButton(btn, self.battler, x, 175)

            if #btn_types == 4 then
                if i == 2 then
                    button.x = button.x - 3
                elseif i == 3 then
                    button.x = button.x + 1
                end
            end

            button.actbox = self
            table.insert(self.buttons, button)
            self:addChild(button)
        else
            btn:setPosition(math.floor(66 + ((i - 1) * 156)) + 0.5, 183)
            btn.battler = self.battler
            btn.actbox = self
            table.insert(self.buttons, btn)
            self:addChild(btn)
        end
    end

    self.selected_button = Utils.clamp(self.selected_button, 1, #self.buttons)

end

function LightActionBoxSingle:snapSoulToButton()
    if self.buttons then
        if self.selected_button < 1 then
            self.selected_button = #self.buttons
        end

        if self.selected_button > #self.buttons then
            self.selected_button = 1
        end

        Game.battle.soul.x = self.buttons[self.selected_button].x - 19
        Game.battle.soul.y = self.buttons[self.selected_button].y + 279
        Game.battle:toggleSoul(true)
    end
end

function LightActionBoxSingle:update()
    if self.buttons then
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

function LightActionBoxSingle:select()
    self.buttons[self.selected_button]:select()
    self.last_button = self.selected_button
end

function LightActionBoxSingle:unselect()
    self.buttons[self.selected_button]:unselect()
end

function LightActionBoxSingle:drawStatusStripStory()
    local x, y = 180, 130
    local level = self.battler.chara:getLightLV()

    love.graphics.setFont(Assets.getFont("namelv", 24))
    love.graphics.setColor(COLORS["white"])
    love.graphics.print("LV " .. level, x, y)

    love.graphics.draw(Assets.getTexture("ui/lightbattle/hpname"), x + 74, y + 5)

    local max = self.battler.chara:getStat("health")
    local current = self.battler.chara.lw_health

    if current < 10 then
        current = "0" .. tostring(current)
    end

    local size = max * 1.25

    local length = current
    if type(Game:getFlag("#limit_hp_gauge_length")) == "boolean" and Game:getFlag("#limit_hp_gauge_length") == true then
        if length >= 99 then
            length = 99
        end

        if size >= 99 then
            size = 99
        end
    elseif type(Game:getFlag("#limit_hp_gauge_length")) == "number" then
        if length >= Game:getFlag("#limit_hp_gauge_length") then
            length = Game:getFlag("#limit_hp_gauge_length")
        end

        if size >= Game:getFlag("#limit_hp_gauge_length") then
            size = Game:getFlag("#limit_hp_gauge_length")
        end
    end

    love.graphics.setColor(COLORS["red"])
    love.graphics.rectangle("fill", x + 110, y, size, 21)
    love.graphics.setColor(COLORS["yellow"])
    love.graphics.rectangle("fill", x + 110, y, length * 1.25, 21)

    love.graphics.setColor(COLORS["white"])
    love.graphics.print(current .. " / " .. max, x + 115 + size + 14, y)
end

function LightActionBoxSingle:drawStatusStrip()
    local x, y = 10, 130
    local name = self.battler.chara:getName()
    local level = self.battler.chara:getLightLV()

    love.graphics.setFont(Assets.getFont("namelv", 24))
    love.graphics.setColor(COLORS["white"])
    love.graphics.print(name .. "   LV " .. level, x, y)

    love.graphics.draw(Assets.getTexture("ui/lightbattle/hpname"), x + 214, y + 5)

    local max = self.battler.chara:getStat("health")
    local current = self.battler.chara.lw_health
    if current < 10 then
        current = "0" .. tostring(current) -- do i need to even do this
    end
    local size = max * 1.25

    local length = current
    if type(Game:getFlag("#limit_hp_gauge_length")) == "boolean" and Game:getFlag("#limit_hp_gauge_length") then
        if length >= 99 then
            length = 99
        end

        if size >= 99 then
            size = 99
        end
    elseif type(Game:getFlag("#limit_hp_gauge_length")) == "number" then
        if length >= Game:getFlag("#limit_hp_gauge_length") then
            length = Game:getFlag("#limit_hp_gauge_length")
        end

        if size >= Game:getFlag("#limit_hp_gauge_length") then
            size = Game:getFlag("#limit_hp_gauge_length")
        end
    end

    love.graphics.setColor(COLORS["red"])
    love.graphics.rectangle("fill", x + 245, y, size, 21)
    love.graphics.setColor(COLORS["yellow"])
    love.graphics.rectangle("fill", x + 245, y, length * 1.25, 21)

    love.graphics.setColor(COLORS["white"])
    love.graphics.print(current .. " / " .. max, x + 245 + size + 14, y)
end

function LightActionBoxSingle:draw()

    if Game.battle.encounter.story then
        self:drawStatusStripStory()
    else
        self:drawStatusStrip()
    end

    super.draw(self)

end

return LightActionBoxSingle