local actor, super = Class("noelle", true)

function actor:init()
    super.init(self)

    if Kristal.getLibConfig("magical-glass", "debug") then
        self.undertale_movement = true
    end
end

return actor