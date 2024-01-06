local item, super = Class(LightEquipItem, "light/eraser")

function item:init()
    super.init(self)

    self.price = 50
end

return item