local spell, super = Class("ice_shock", true)

function spell:onLightCast(user, target)
    self:onCast(user, target)
end

return spell