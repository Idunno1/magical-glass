local EncGroup, super = Class(RandomEncounter, "test")

function EncGroup:init()
    super.init(self)
    
    -- Table with the encounters that can be triggered by this random encounter
    self.encounters = {"froggit"}
end

return EncGroup