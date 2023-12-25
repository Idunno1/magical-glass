---@class ActionBox : Object
---@overload fun(...) : ActionBox
local ActionBox, super = Class(Object)

function ActionBox:init(x, y, index, battler)
    super.init(self, x, y)

    self.battler = battler
    self.revert_to = 40

    self.data_offset = 0

    self.up = false
    
    self.down_states = {
        --"ENEMYDIALOGUE",
        "DEFENDING",
        "DEFENDINGBEGIN"
    }
    self.down = false

    self.box = DefendingActionBoxDisplay(self)
    self.box.layer = 1
    self:addChild(self.box)

    self.head_offset_x, self.head_offset_y = battler.chara:getHeadIconOffset()

    self.head_sprite = Sprite(battler.chara:getHeadIcons().."/"..battler:getHeadIcon(), 13 + self.head_offset_x - 6, 11 + self.head_offset_y - 2)
    if not self.head_sprite:getTexture() then
        self.head_sprite:setSprite(battler.chara:getHeadIcons().."/head")
    end
    self.force_head_sprite = false

    -- // Uncomment the line below to enable head sprites
    --self.box:addChild(self.head_sprite)
end

function ActionBox:setHeadIcon(icon)
    self.force_head_sprite = true

    local full_icon = self.battler.chara:getHeadIcons().."/"..icon
    if self.head_sprite:hasSprite(full_icon) then
        self.head_sprite:setSprite(full_icon)
    else
        self.head_sprite:setSprite(self.battler.chara:getHeadIcons().."/head")
    end
end

function ActionBox:resetHeadIcon()
    self.force_head_sprite = false

    local full_icon = self.battler.chara:getHeadIcons().."/"..self.battler:getHeadIcon()
    if self.head_sprite:hasSprite(full_icon) then
        self.head_sprite:setSprite(full_icon)
    else
        self.head_sprite:setSprite(self.battler.chara:getHeadIcons().."/head")
    end
end

function ActionBox:update()
    if not Utils.containsValue(self.down_states, Game.battle.state) then
        if Game.battle.current_selecting == self.index or action then
            if not self.up or self.down then
                self.down = false
                self.up = true
                TweenManager.tween(self, {y = -270}, 9, "outExpo")
            end
        else
            if self.up or self.down then
                self.up = false
                self.down = false
                TweenManager.tween(self, {y = -270-44}, 10, "outExpo")
            end
        end       
    else
        if not self.down then
            self.down = true
            TweenManager.tween(self, {y = -270}, 10, "outExpo")
        end
    end

    self.head_sprite.y = 11 - self.data_offset + self.head_offset_y - 2

    if not self.force_head_sprite then
        local current_head = self.battler.chara:getHeadIcons().."/"..self.battler:getHeadIcon()
        if not self.head_sprite:hasSprite(current_head) then
            current_head = self.battler.chara:getHeadIcons().."/head"
        end

        if not self.head_sprite:isSprite(current_head) then
            self.head_sprite:setSprite(current_head)
        end
    end

    super.update(self)
end

function ActionBox:draw()
    self:drawActionBox()

    super.draw(self)

    local font = Assets.getFont("namelv",24)
    love.graphics.setFont(font)
    Draw.setColor(1, 1, 1, 1)

    local name = self.battler.chara:getName():upper()
    local spacing = 7 - name:len()

    --[[
    local off = 0
    for i = 1, name:len() do
        local letter = name:sub(i, i)
        love.graphics.print(letter, self.box.x + 42 + off, self.box.y + 14 - self.data_offset - 1)
        off = off + font:getWidth(letter) + spacing
    end
    ]]
    
    -- // Uncomment the line below to enable compatibility with head sprites
    --love.graphics.print(name, self.box.x + 45, self.box.y + 12 - self.data_offset - 1)
    love.graphics.print(name, self.box.x + 13, self.box.y + 11 - self.data_offset - 1)

end

function ActionBox:drawActionBox()
    if Game.battle.current_selecting == self.index then
        Draw.setColor(self.battler.chara:getColor())
        love.graphics.setLineWidth(5)
        love.graphics.line(1  , 2, 1,   37)
        love.graphics.line(212, 2, 212, 37)
        love.graphics.line(0  , 6, 212, 6 )
    end
    Draw.setColor(1, 1, 1, 1)
end

return ActionBox