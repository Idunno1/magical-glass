local actor, super = Class(Actor, "dummy")

function actor:init()
    super:init(self)

    -- Display name (optional)
    self.name = "Dummy"

    -- Width and height for this actor, used to determine its center
    self.width = 49
    self.height = 53

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    self.hitbox = {0, 25, 19, 14}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 0, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "enemies/dummy_ut"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "body"

    -- Sound to play when this actor speaks (optional)
    self.voice = nil
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}

    -- Table of sprite animations
    self.animations = {
        -- Looping animation with 0.25 seconds between each frame
        -- (even though there's only 1 idle frame)
        ["hurt"] = {"hurt", 1, true}
    }

    self:addLightBattlerPart("body", {
        ["init"] = function() -- this must return a sprite object
            self.siner = 0
            self.sprite = Sprite(self.path.."/"..self.default)
            return self.sprite
        end
    })

end

return actor