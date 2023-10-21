local HelpWindow, super = Class(Object)

function HelpWindow:init(x, y)
    super.init(self, x, y)

    self.showing = false
    self.show_progress = 0
    self.show_done = true
    self.up = false

    self.box_fill = Rectangle(0, 0, 560, 45)
    self.box_fill:setOrigin(0.5)
    self.box_fill.color = COLORS.black
    self:addChild(self.box_fill)

    self.box_line = Rectangle(0, 0, 560, 45)
    self.box_line.line = true
    self.box_line.line_width = 5
    self.box_fill:addChild(self.box_line)

    self.description_text = Text("", 15, 1, 400, 32, {color = COLORS.gray, font = "main_mono"})
    self.box_fill:addChild(self.description_text)

    self.cost_text = Text("", 12, 1, 539, 32, {color = PALETTE["tension_desc"], align = "right", font = "main_mono"})
    self.box_fill:addChild(self.cost_text)
end

function HelpWindow:getBounds()
    return 237, 280
end

function HelpWindow:show()
    if not self.showing then
        self.up = true
        self.show_progress = 0
        self.show_done = false
        self.showing = true
    end
end

function HelpWindow:hide()
    if self.showing then
        self.up = false
        self.show_progress = 0
        self.show_done = false
        self.showing = false
    end
end

function HelpWindow:update()
    if Game.battle.state == "MENUSELECT" and #Game.battle.menu_items > 0 then
        local item = Game.battle.menu_items[Game.battle:getItemIndex()]
        if (#item.description > 0 or (item.tp and item.tp > 0)) then
            if Game.battle.tension_bar then
                Game.battle.tension_bar:shiftUp()
            end
            self:show()
        else
            if Game.battle.tension_bar then
                Game.battle.tension_bar:shiftDown()
            end
            self:hide()
        end
    else
        if Game.battle.tension_bar then
            Game.battle.tension_bar:shiftDown()
        end
        self:hide()
    end

    if not self.show_done then

        self.show_progress = self.show_progress + DTMULT

        local limit = 12

        if self.show_progress > limit + 1 then
            self.show_done = true
            self.show_progress = limit + 1
        end

        local lower, upper = self:getBounds()
        if self.up then
            self.y = Ease.outExpo(math.min(limit, self.show_progress), upper, lower - upper, limit)
        else
            self.y = Ease.outExpo(math.min(limit, self.show_progress), lower, upper - lower, limit)
        end

    end
    
    super.update(self)
end

function HelpWindow:setDescription(text)
    local str = text:gsub('\n', ' ')
    self.description_text:setText(str)
end

function HelpWindow:setTension(tension)
    if tension ~= 0 then
        self.cost_text:setText(tostring(tension).."% TP")
    else
        self.cost_text:setText("")
    end
end

return HelpWindow