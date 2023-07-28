local encounter, super = Class(LightEncounter)

function encounter:init()
    super:init(self)

    -- Text displayed at the bottom of the screen at the start of the encounter
    self.text = "[font:main_mono,15]* But nobody came."

    -- Is a "But Nobody Came"/"Genocide" Encounter
    self.nobodycame = true

    -- Battle music ("battleut" is undertale)
    self.music = "toomuch"
end

return encounter