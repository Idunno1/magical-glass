local wave, super = Class(Wave)

function wave:init()
    super.init(self)
    self.soul_offset_x = -3
    self.soul_offset_y = -2
    self:setArenaSize(291, 130)
    self.time = 1/60
end

return wave