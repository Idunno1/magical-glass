local actor, super = Class(Actor, "froggit")

function actor:init()
    -- Display name (optional)
    self.name = "Froggit"

    -- Width and height for this actor, used to determine its center
    self.width = 112
    self.height = 112

    self.hitbox = {0, 0, 16, 16}

    self.flip = "right"

    self.path = "enemies/froggit"
    self.default = "idle"

    self.light_battle_actor = "enemies/froggit_battle"
end

return actor