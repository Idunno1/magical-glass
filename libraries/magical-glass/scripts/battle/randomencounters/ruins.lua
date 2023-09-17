local Ruins, super = Class(RandomEncounter)

function Ruins:init()
    super:init(self)
    
    -- Table with the encounters that can be triggered by this random encounter
    self.encounters = {"froggit", "_nobody"}
end

return Ruins