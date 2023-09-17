---@class RandomEncounter : Object
---@overload fun(...) : RandomEncounter
local RandomEncounter, super = Class(Object, "RandomEncounter")

function RandomEncounter:init()
    -- Override the alert bubble that will show up above the player when a random encounter is triggered
    self.alert_override = nil
    
    -- "But Nobody Came" encounter used if you meet the Murder Level requirement
    self.nobody_encounter = "_nobody"
    
    -- Table with the encounters that can be triggered by this random encounter
    self.encounters = {}
end

function RandomEncounter:nobodyCame()
    return false
end

function RandomEncounter:start()
    Game:encounter(self.encounters[math.random(#self.encounters)] or self:nobodyCame() or "_nobody", true)
end

return RandomEncounter