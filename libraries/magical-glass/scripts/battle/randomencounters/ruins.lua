local Ruins, super = Class(RandomEncounter)

function Ruins:init()
    super:init(self)

    -- Use "But Nobody Came" encounter
    self.use_geno_enc = true

    -- Murder Level required for "But Nobody Came" encounter
    self.mrd_lvl = 1
    
    -- "But Nobody Came" encounter used if you meet the Murder Level requirement
    self.geno_enc = "_nobody"
    
    -- Table with the encounters that can be triggered by this random encounter
    self.encounters = {"froggit", "_nobody"}
end

return Ruins