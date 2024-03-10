local item, super = Class("light/wristwatch", true)

function item:init()
    super.init(self)

    -- Display name
    self.short_name = "Watch"

    self.price = 300
    
    Utils.merge(self.bonuses, {
        graze_time = 0.1,
    }, false)
end

return item