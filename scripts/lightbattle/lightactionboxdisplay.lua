local LWActionBoxDisplay, super = Class(Object)

function LWActionBoxDisplay:init(box, x, y)
    super.init(self, x, y)

    self.font = Assets.getFont("small")

    self.actbox = box
end

return LWActionBoxDisplay