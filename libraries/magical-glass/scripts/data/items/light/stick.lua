local item, super = Class(LightEquipItem, "light/stick")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Stick"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    -- self.check = "Weapon AT 0\n* Whoa-oh-oh-oh-oh-oh-oh-oh story of undertale"
    self.check = "Weapon AT 0\n* Its bark is worse than\nits bite."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.target = "none"

    -- Default dark item conversion for this item
    --self.dark_item = "woodier_blade"
end

function item:onWorldUse(target)
    Game.world:showText("* You threw the stick away.\n* Then picked it back up.")
    return false
end

function item:onLightBattleUse(user, target)
    return true
end

function item:getLightBattleText(user, target)
    if Game.battle.encounter.onStickUse then
        return Game.battle.encounter:onStickUse(self, user)
    end
    if user.id == Game.battle.party[1].id then
        return "* You threw the stick away.\n* Then picked it back up."
    end
end


return item