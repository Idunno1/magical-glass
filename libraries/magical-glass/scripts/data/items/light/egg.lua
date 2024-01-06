local item, super = Class("light/egg", true)

function item:init()
    super.init(self)

    self.can_sell = false
    -- Item this item will get turned into when consumed
    self.result_item = "light/egg"
end

function item:battleUseSound(user, target)
    Assets.playSound("egg")
end

function item:onBattleUse(user, target)
    Assets.playSound("egg")
    return true
end

return item