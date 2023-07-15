local item, super = Class(Item, "light/monster_candy")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Monster Candy"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop price (sell price is halved)
    self.price = 25
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Heals 10 HP\n* Has a distinct,\nnon licorice flavor."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false

end

function item:onWorldUse(target)
    if target.lw_health == target.lw_stats.health then
        Game.world:showText("* You ate the Monster Candy.\n* Your HP was maxed out.")
    else
        Game.world:showText("* You ate the Monster Candy.\n* You recovered 10 HP!")
    end
    target.lw_health = target.lw_health + 10
    return false
end



function item:onWorldUse(target)

    target = Game.party[1]


    local function worlduse(target1, usename)
        target1.lw_health = target1.lw_health + 10
        if target1.lw_health >= target1.lw_stats.health then
            Game.world:showText("* ".. usename .. " ate the Monster Candy.\n* Your HP was maxed out.")
            target1.lw_health = target1.lw_stats.health
        else
            Game.world:showText("* You ate the Monster Candy.\n* You recovered 10 HP!")
        end
    end

    worlduse(Game.party[1], "You")

    --[[]
    -- if #Game.party ~= 1 then
    Game.world:startCutscene(function(cutscene)
        if #Game.party == 1 then
            worlduse(Game.party[1], "You")
            return false
        else
            local response

            if #Game.party == 2 then
                response = cutscene:choicer({Game.party[1]:getName(), Game.party[2]:getName()})
            elseif #Game.party == 3 then
                response = cutscene:choicer({Game.party[1]:getName(), Game.party[2]:getName(), Game.party[3]:getName()})
            elseif #Game.party == 4 then
                response = cutscene:choicer({Game.party[1]:getName(), Game.party[2]:getName(), Game.party[3]:getName(),Game.party[4]:getName()})
            end

            if response == 1 then
                target = Game.party[1]
                worlduse(Game.party[1], Game.party[1].name)
                return false
            elseif response == 2 then
                target = Game.party[2]
                worlduse(Game.party[2], Game.party[2].name)
                return false
            elseif response == 3 then
                target = Game.party[3]
                worlduse(Game.party[3], Game.party[3].name)
                return false
            elseif response == 4 then
                target = Game.party[4]
                worlduse(Game.party[4], Game.party[4].name)
                return false
            end
        end
    end)
    --]]
end



function item:onToss()
    Game.world:showText("* The Monster Candy was\nthrown away.")
    return false
end

return item