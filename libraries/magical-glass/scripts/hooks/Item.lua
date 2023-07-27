---@class Item : Class
---@overload fun(...) : Item
local Item, super = Class("Item", true)

function Item:init()
    super.init(self)

    -- Short name for the light battle item menu
    self.short_name = nil
    -- Serious name for the light battle item menu
    self.serious_name = nil
    -- Should the item display how much HP was healed after its message?
    self.display_healing = true

end

function Item:getShortName() return self.short_name or self.serious_name or self.name end
function Item:getSeriousName() return self.serious_name or self.short_name or self.name end

return Item