local item, super = Class("light/bouquet", true)

function item:init()
    super.init(self)

    self.can_sell = false
    self.result_item = "light/bouquet"
end

return item