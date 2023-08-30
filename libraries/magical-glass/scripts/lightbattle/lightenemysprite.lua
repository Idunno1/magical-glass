local LightEnemySprite, super = Class(Object)

function LightEnemySprite:init(actor, parts)
    if type(actor) == "string" then
        actor = Registry.createActor(actor)
    end

    super.init(self)

    self.actor = actor
    self.parts = parts
    
    for _,part in pairs(self.parts) do
        part.sprite = part:init()
        self:addChild(part.sprite)
    end

    if actor then
        actor:onSpriteInit(self)
    end

    --self:resetSprite()
end

--[[ function LightEnemySprite:resetSprite(ignore_actor_callback)
    if not ignore_actor_callback and self.actor:preResetSprite(self) then
        return
    end
    if self.actor:getDefaultAnim() then
        self:setAnimation(self.actor:getDefaultAnim())
    elseif self.actor:getDefaultSprite() then
        self:setSprite(self.actor:getDefaultSprite())
    else
        self:set(self.actor:getDefault())
    end
    self.actor:onResetSprite(self)
end ]]

function LightEnemySprite:update()
    if self.run_away then
        self.run_away_timer = self.run_away_timer + DTMULT
    end

    for _,part in pairs(self.parts) do
        if part.update then
            part:update(part.sprite)
        end
    end

    super.update(self)

    self.actor:onSpriteUpdate(self)
end

function LightEnemySprite:draw()
    if self.actor:preSpriteDraw(self) then
        return
    end

    if self.texture and self.run_away then
        local r,g,b,a = self:getDrawColor()
        for i = 0, 80 do
            local alph = a * 0.4
            Draw.setColor(r,g,b, ((alph - (self.run_away_timer / 8)) + (i / 200)))
            Draw.draw(self.texture, i * 2, 0)
        end
        return
    end

    super.draw(self)
end

return LightEnemySprite