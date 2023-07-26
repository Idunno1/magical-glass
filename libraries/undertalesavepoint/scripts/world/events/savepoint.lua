---@class Savepoint : Interactable
---@overload fun(...) : Savepoint
local Savepoint, super = Class(Interactable)

function Savepoint:init(data)
    super.init(self, data.x, data.y, 0, 0, data.properties)

    self.marker = data.properties["marker"]
    self.simple_menu = data.properties["simple"]
    self.text_once = data.properties["text_once"]
    self.heals = data.properties["heals"] ~= false
    self.undertale = data.properties["ut"] or false

    self.solid = true

    self:setOrigin(0.5, 0.5)
    if self.undertale then
        self:setSprite("world/events/savepointut", 0.15)
    else
        self:setSprite("world/events/savepoint", 1/6)
    end

    self.used = false

    -- The hitbox is ALMOST half the size of the sprite, but not quite.
    -- It's 9 pixels tall, 10 pixels away from the top.
    -- So divide by 2, round, then multiply by 2 to get the right size for 2x.
    local width, height = self:getSize()
    self:setHitbox(0, math.ceil(height / 4) * 2, width, math.floor(height / 4) * 2)
end

function Savepoint:onInteract(player, dir)
    Assets.playSound("power")

    if self.text_once and self.used then
        self:onTextEnd()
        return
    end

    if self.text_once then
        self.used = true
    end

    super.onInteract(self, player, dir)
    return true
end

function Savepoint:onTextEnd()
    if not self.world then return end

    if self.heals then
        for _,party in ipairs(Game.party) do
            party:heal(math.huge, false)
        end
    end
    
    if self.undertale then
        self.world:openMenu(UTSaveMenu(Game.save_id, self.marker))
    elseif Game:isLight() then
        self.world:openMenu(LightSaveMenu(Game.save_id, self.marker))
    elseif self.simple_menu or (self.simple_menu == nil and Game:getConfig("smallSaveMenu")) then
        self.world:openMenu(SimpleSaveMenu(Game.save_id, self.marker))
    else
        self.world:openMenu(SaveMenu(self.marker))
    end
end

return Savepoint