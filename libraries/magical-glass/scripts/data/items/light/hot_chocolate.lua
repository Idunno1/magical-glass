local item, super = Class("light/hot_chocolate", true)

function item:init()
    super.init(self)

    self.short_name = "HotChoc"

    self.can_sell = false
end

function item:getLightBattleText(user, target)
    return "* You drank the hot chocolate."
end

function item:onLightBattleUse(user, target)
    Assets.playSound("swallow")
    Game.battle:battleText(self:getLightBattleText(user, target))
end

return item