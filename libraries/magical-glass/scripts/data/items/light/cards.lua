local item, super = Class("light/cards", true)

function item:init()
    super.init(self)

    self.can_sell = false
    self.result_item = "light/cards"
end

return item