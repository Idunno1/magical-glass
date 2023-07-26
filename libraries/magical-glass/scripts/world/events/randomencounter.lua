---@class REController : Event
---@overload fun(...) : REController
local REController, super = Class(Event, "randomencounter")

function REController:init(properties)
    super.init(self)
end

function REController:update()
    super.update(self)
end

return REController