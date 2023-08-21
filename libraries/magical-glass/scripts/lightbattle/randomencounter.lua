---@class RandomEncounter : Object
---@overload fun(...) : RandomEncounter
local RandomEncounter, super = Class(Object, "RandomEncounter")

function RandomEncounter:init()
    -- Override the alert bubble that will show up above the player when a random encounter is triggered
    self.alert_override = nil

    -- Use "But Nobody Came" encounter
    self.use_geno_enc = true

    -- Murder Level required for "But Nobody Came" encounter
    self.mrd_lvl = 1
    
    -- "But Nobody Came" encounter used if you meet the Murder Level requirement
    self.geno_enc = "_nobody"
    
    -- Table with the encounters that can be triggered by this random encounter
    self.encounters = {}
end

function RandomEncounter:start()
    Game:encounter(self.encounters[math.random(#self.encounters)] or self.geno_enc or "_nobody", true)
end

return RandomEncounter