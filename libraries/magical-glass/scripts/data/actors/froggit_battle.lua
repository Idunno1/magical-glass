local actor, super = Class(Actor, "froggit_battle")

function actor:init()
    super.init(self)

    self.width = 112
    self.height = 112
    self.hitbox = {0, 0, 16, 16}
    self.flip = "right"
    self.path = "enemies/froggit/lightbattle"

    self.parts = { -- same settings as animations
        ["head"] = {"head", 1, true},
        ["body"] = {"body", 1, true},
    }

    self.part_offsets = {
        ["head"] = {0, -10},
        ["body"] = {0, 0},
    }

    self.animations = {
        ["hurt"] = {"hurt"},
        ["spared"] = {"hurt"},
    }

end

function actor:getPart(part)
    return self.parts[part]
end

function actor:getPartSprite(part)
    return self.parts[part][1]
end

function actor:createSprite()
    return LightEnemySprite(self)
end

return actor