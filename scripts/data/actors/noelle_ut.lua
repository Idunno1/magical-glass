local actor, super = Class(Actor, "noelle_ut")

function actor:init()
    super.init(self)

    -- Display name (optional)
    self.name = "Noelle"

    -- Width and height for this actor, used to determine its center
    self.width = 58
    self.height = 117
    
    self.use_light_battler_sprite = false

    -- Hitbox for this actor in the overworld (optional, uses width and height by default)
    -- self.hitbox = {0, 25, 19, 14}

    -- Color for this actor used in outline areas (optional, defaults to red)
    self.color = {1, 1, 0}

    -- Whether this actor flips horizontally (optional, values are "right" or "left", indicating the flip direction)
    self.flip = nil

    -- Path to this actor's sprites (defaults to "")
    self.path = "enemies/noelle_ut"
    -- This actor's default sprite or animation, relative to the path (defaults to "")
    self.default = "idle"

    -- Sound to play when this actor speaks (optional)
    self.voice = "noelle"
    -- Path to this actor's portrait for dialogue (optional)
    self.portrait_path = nil
    -- Offset position for this actor's portrait (optional)
    self.portrait_offset = nil

    -- Table of talk sprites and their talk speeds (default 0.25)
    self.talk_sprites = {}
    
    -- Table of sprite offsets (indexed by sprite name)
    self.offsets = {
        ["idle"] = {-1, 0},
    }

    -- self:addLightBattlerPart("body", {
        -- -- path, function that returns a path, or a function that returns a sprite object
        -- -- if one's not defined, get the default animation
        -- ["sprite"] = function()
            -- self.sprite = Sprite(self.path.."/lightbattle/body")
            -- return self.sprite
        -- end,

        -- ["init"] = function() 
            -- self.siner = 0
        -- end
    -- })

end

return actor