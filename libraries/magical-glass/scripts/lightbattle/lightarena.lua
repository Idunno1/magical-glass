local LightArena, super = Class(Arena)

function LightArena:init(x, y, shape)
    super:init(self, x, y)

    self.home_x = x
    self.home_y = y

    self.color = {1, 1, 1}
    self.bg_color = {0, 0, 0}

    self.line_width = 5 -- must call setShape again if u change this
    self.default_dim = {565, 130}
    self:setShape(shape or {{0, 0}, {self.default_dim[1], 0}, {self.default_dim[1], self.default_dim[2]}, {0, self.default_dim[2]}})

    self.mask.layer = BATTLE_LAYERS["above_ui"]

--[[     self.border_mask = ArenaSprite(self)
    self.border_mask:setOrigin(0.5, 1)
    self.border_mask:setPosition(self:getRelativePos(self.width / 2, self.height / 2))
    self.border_mask.color = self.color
    self.border_mask.background = false
    Game.battle:addChild(self.border_mask)
    self.border_mask.layer = BATTLE_LAYERS["above_bullets"] ]]
    
    self:setOrigin(0.5, 1)

end

function LightArena:setSize(width, height)
    self:setShape{{0, 0}, {width, 0}, {width, height}, {0, height}}
end

function LightArena:setShape(shape)
    self.shape = Utils.copy(shape, true)
    self.processed_shape = Utils.copy(shape, true)

    local min_x, min_y, max_x, max_y
    for _,point in ipairs(self.shape) do
        min_x, min_y = math.min(min_x or point[1], point[1]), math.min(min_y or point[2], point[2])
        max_x, max_y = math.max(max_x or point[1], point[1]), math.max(max_y or point[2], point[2])
    end
    for _,point in ipairs(self.shape) do
        point[1] = point[1] - min_x
        point[2] = point[2] - min_y
    end
    self.width = max_x - min_x
    self.height = max_y - min_y

    self.processed_width = self.width
    self.processed_height = self.height

    self.left = math.floor(self.x - self.width)
    self.right = math.floor(self.x)
    self.top = math.floor(self.y - self.height)
    self.bottom = math.floor(self.y)

    self.triangles = love.math.triangulate(Utils.unpackPolygon(self.shape))

    self.border_line = {Utils.unpackPolygon(Utils.getPolygonOffset(self.shape, self.line_width/2))}

    self.clockwise = Utils.isPolygonClockwise(self.shape)

    self.area_collider = PolygonCollider(self, Utils.copy(shape, true))

    self.collider.colliders = {}
    for _,v in ipairs(Utils.getPolygonEdges(self.shape)) do
        table.insert(self.collider.colliders, LineCollider(self, v[1][1], v[1][2], v[2][1], v[2][2]))
    end
end

function LightArena:setBackgroundColor(r, g, b, a)
    self.bg_color = {r, g, b, a or 1}
end

function LightArena:getBackgroundColor()
    return self.bg_color
end

function LightArena:getCenter()
    return self:getRelativePos(self.width/2, self.height/2)
end

function LightArena:getTopLeft() return self:getRelativePos(0, 0) end
function LightArena:getTopRight() return self:getRelativePos(self.width, 0) end
function LightArena:getBottomLeft() return self:getRelativePos(0, self.height) end
function LightArena:getBottomRight() return self:getRelativePos(self.width, self.height) end

function LightArena:getLeft() local x, y = self:getTopLeft(); return x end
function LightArena:getRight() local x, y = self:getBottomRight(); return x end
function LightArena:getTop() local x, y = self:getTopLeft(); return y end
function LightArena:getBottom() local x, y = self:getBottomRight(); return y end

function LightArena:onAdd(parent)
    self.sprite:setScale(1)
    self.sprite.alpha = 1
    self.sprite.rotation = math.pi
end

function LightArena:onRemove(parent)
end

function LightArena:update()
    if not Utils.equal(self.processed_shape, self.shape, true) then
        self:setShape(self.shape)
    elseif self.processed_width ~= self.width or self.processed_height ~= self.height then
        self:setSize(self.width, self.height)
    end

    super:update(self)

    if NOCLIP then return end

    local soul = Game.battle.soul
    if soul and Game.battle.soul.collidable then
        Object.startCache()
        local angle_diff = self.clockwise and -(math.pi/2) or (math.pi/2)
        for _,line in ipairs(self.collider.colliders) do
            local angle
            while soul:collidesWith(line) do
                if not angle then
                    local x1, y1 = self:getRelativePos(line.x, line.y, Game.battle)
                    local x2, y2 = self:getRelativePos(line.x2, line.y2, Game.battle)
                    angle = Utils.angle(x1, y1, x2, y2)
                end
                Object.uncache(soul)
                soul:setPosition(
                    soul.x + (math.cos(angle + angle_diff)),
                    soul.y + (math.sin(angle + angle_diff))
                )
            end
        end
        Object.endCache()
    end
end

function LightArena:drawMask()
    love.graphics.push()
    self.sprite:preDraw()
    self.sprite:drawBackground()
    self.sprite:postDraw()
    self.border_mask:preDraw()
    self.border_mask:postDraw()
    love.graphics.pop()
end

function LightArena:draw()
    super:draw(self)

    if DEBUG_RENDER and self.collider then
        self.collider:draw(0, 0, 1)
    end
end

return LightArena