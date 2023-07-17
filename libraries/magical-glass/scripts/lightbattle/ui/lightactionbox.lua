local LWActionBox, super = Class(Object)

function LWActionBox:init(x, y, index, battler)
    super.init(self, x, y)

    self.index = index
    self.battler = battler

    self.selected_button = 1

    self.revert_to = 40

    self.offset = 0

    self.soul = Game.battle.soul

    self.box = LWActionBoxDisplay(self)
    self:addChild(self.box)

    self.width = 200
    self.height = 70

    self.head_offset_x, self.head_offset_y = self.battler.chara:getLWHeadIconOffset()

    self.head_sprite = Sprite(self.battler.chara:getLWHeadIcons() .. "/head", 0 + self.head_offset_x, 0 + self.head_offset_y)
    self.head_sprite:setScale(2, 2)
    self.head_sprite:setOrigin(0.5, 0)
    self.head_sprite:setPosition(self.width / 2, -42)
    self.box:addChild(self.head_sprite)

    self.force_head_sprite = false

    -- ACTION: Selecting and performing actions, head is visible
    -- WAIT: Not selectiong nor performing actions
    -- DEFENDING: During DEFENDING state
    self.state = "ACTION"

--[[     self.hp_sprite = Sprite("ui/lwbattle/hp", 0, 0)
    self.hp_sprite:setScale(2, 2)
    self.box:addChild(self.hp_sprite) ]]

    self:createButtons()

end

function LWActionBox:createButtons()
    for _,button in ipairs(self.buttons or {}) do
        button:remove()
    end

    self.buttons = {}

    local btn_types = {"fight", "act", "magic", "item", "mercy"}

    if not self.battler.chara:hasAct() then Utils.removeFromTable(btn_types, "act") end
    if not self.battler.chara:hasSpells() then Utils.removeFromTable(btn_types, "magic") end

    for lib_id,_ in pairs(Mod.libs) do
        btn_types = Kristal.libCall(lib_id, "getActionButtons", self.battler, btn_types) or btn_types
    end
    btn_types = Kristal.modCall("getActionButtons", self.battler, btn_types) or btn_types

    for i,btn in ipairs(btn_types) do
        if type(btn) == "string" then
            --local button = LWActionButton(btn, self.battler, math.floor(start_x + ((i - 1) * 35)) + 0.5, 21)
            local button = LWActionButton(btn, self.battler, math.floor(66 + ((i - 1) * 156)) + 0.5, 183)

            if i == 2 then
                button.x = button.x - 3
            elseif i == 3 then
                button.x = button.x + 1
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

function LWActionBox:setHeadIcon(icon)
    self.force_head_sprite = true
    self.head_sprite:setSprite(self.battler.chara:getLWHeadIcons() .. "/" .. icon)
end

function LWActionBox:resetHeadIcon()
    self.force_head_sprite = false
    self.head_sprite = Sprite(self.battler.chara:getLWHeadIcons() .. "/head", 0 + self.head_offset_x, 0 + self.head_offset_y)
    if not self.head_sprite:getTexture() then
        self.head_sprite:setSprite(self.battler.chara:getLWHeadIcons() .. "/head")
    end
end

function LWActionBox:update()

    super.update(self)

end

function LWActionBox:select()
    self.buttons[self.selected_button]:select()
end

function LWActionBox:unselect()
    self.buttons[self.selected_button]:unselect()
end

function LWActionBox:drawBox()

    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)

    love.graphics.setColor(self.battler.chara:getColor())
    love.graphics.setLineWidth(4)
    love.graphics.rectangle("line", 0, 0, self.width, self.height)

end

function LWActionBox:draw()

    self:drawBox()

    super.draw(self)

--[[     local font = Assets.getFont("namelv")
    love.graphics.setFont(font)
    love.graphics.setColor(1, 1, 1, 1) -- needs to update in accordance with selected actions

    local name = self.battler.chara:getName():upper()
    local spacing = 5 - name:len()

    local offset = 0

    for i = 1, name:len() do
        local letter = name:sub(i, i)
        love.graphics.print(letter, (self.box.x + offset) + 20, self.box.y + 15)
        offset = offset + font:getWidth(letter) + spacing
    end ]]

    -- this shit's being moved to the display object

end

return LWActionBox