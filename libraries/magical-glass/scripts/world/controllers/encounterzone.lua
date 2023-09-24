local EncounterZone, super = Class(Event, "encounterzone")

function EncounterZone:init(data)
    super.init(self)

    data = data or {}

    self.x = data.x
    self.y = data.y
    self.width = data.width
    self.height = data.height

    self.group = MagicalGlassLib:createRandomEncounter(data.properties["encgroup"])

    if MagicalGlassLib.steps_until_encounter == nil or MagicalGlassLib.steps_until_encounter < 0 then
        self.group:resetSteps()
    end

    local s = data.shape
    if s == "rectangle" or s == "circle" or s == "ellipse" or s == "polygon" or s == "polyline" then
        self.type = "zone"
        self.collider = Utils.colliderFromShape(self, data)
    else
        self.type = "map"
    end

    self.accepting = false
end

function EncounterZone:update()
    super.update(self)

    if Game.world.player and not Game.battle then
        if self.type == "map" or (self.type == "zone" and self.collider:collidesWith(Game.world.player)) then
            self.accepting = true
        else
            self.accepting = false
        end
    end

    if MagicalGlassLib.steps_until_encounter <= 0 then
        self.group:resetSteps()
        self.group:start()
    end

end

function EncounterZone:onAdd(parent)
    super.onAdd(self, parent)
    MagicalGlassLib.encounters_enabled = true
end

function EncounterZone:onRemove(parent)
    super.onRemove(self, parent)
    MagicalGlassLib.encounters_enabled = false
end

function EncounterZone:draw()
    super.draw(self)
    if DEBUG_RENDER and self.collider and Game.world.player and (self.collider:collidesWith(Game.world.player) or self.type == "map") then
        Game.world.player:setColor(1, 0, 0)
    else
        Game.world.player:setColor(1, 1, 1)
    end
end

return EncounterZone