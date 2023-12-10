local item, super = Class(HealItem, "ut_items/bandage")

function item:init(inventory)
    super.init(self)

    -- Display name
    self.name = "Bandage"

    -- Item type (item, key, weapon, armor)
    self.type = "item"
    -- Whether this item is for the light world
    self.light = true

    self.heal_amount = 10

    -- Default shop sell price
    self.sell_price = 150
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = Kristal.getLibConfig("magical-glass", "ut_bandage") and "Heals 10 HP\n* It has already been used\nseveral times." or "Heals 10 HP\n* It has cartoon characters on it."

    -- Consumable target mode (ally, party, enemy, enemies, or none)
    self.target = "ally"
    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil
    -- Will this item be instantly consumed in battles?
    self.instant = false
end

function item:getWorldUseText(target)
    if target.id == Game.party[1].id then
        if not MagicalGlassLib.serious_mode and Kristal.getLibConfig("magical-glass", "ut_bandage") then
            return "* You re-applied the bandage.\n* Still kind of gooey."
        else
            return "* You re-applied the bandage."
        end
    else
        return "* " .. target:getName() .. " applied the bandage."
    end
end

function item:getLightBattleText(user, target)
    if target.chara.id == Game.battle.party[1].chara.id then
        if not MagicalGlassLib.serious_mode and Kristal.getLibConfig("magical-glass", "ut_bandage") then
            return "* You re-applied the bandage.\n* Still kind of gooey."
        else
            return "* You re-applied the bandage."
        end
    else
        return "* "..target.chara:getName().." applied the bandage."
    end
end

function item:worldUseSound(target)
    Assets.stopAndPlaySound("power")
end

function item:battleUseSound(user, target)
    Assets.stopAndPlaySound("power")
end

return item