local item, super = Class("light/bouquet", true)

function item:init()
    super.init(self)

    self.price = 80
    self.result_item = "light/bouquet"
end

return item