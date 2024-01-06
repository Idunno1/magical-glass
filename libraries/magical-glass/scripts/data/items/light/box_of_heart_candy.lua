local item, super = Class("light/box_of_heart_candy", true)

function item:init(inventory)
    super.init(self)

    -- Display name
    self.short_name = "CandyBox"

    self.price = 50
    self.sell_price = 5
end

function item:onWorldUse()
    Game.world:startCutscene(function(cutscene)
        if Game.party[1]:getHealth() > 1 then
            Game.party[1]:setHealth(Game.party[1]:getHealth() - 1)
        end
        cutscene:text("* (You unhesitatingly devoured\nthe box of heart shaped\ncandies.)")
        cutscene:text("* (Your guts are being\ndestroyed.)")
        cutscene:text("* (You accept this destruction as\npart of life...)")
    end)
    return true
end

function item:getLightBattleText(user, target)
    return {"* (You unhesitatingly devoured\nthe box of heart shaped\ncandies.)","* (Your guts are being\ndestroyed.)","* (You accept this destruction as\npart of life...)"}
end

function item:onLightBattleUse(user, target)
    Assets.playSound("swallow")
    if user.chara:getHealth() > 1 then
        user.chara:setHealth(user.chara:getHealth() - 1)
    end
    Game.battle:battleText(self:getLightBattleText(user, target))
end

return item