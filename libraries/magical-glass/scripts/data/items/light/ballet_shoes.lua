local item, super = Class(LightEquipItem, "light/ballet_shoes")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Ballet Shoes"
    self.short_name = "BallShoes"
    self.serious_name = "Shoes"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = "Weapon AT 7\n* These used shoes make you feel\nextra dangerous."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 7
    }

    self.attack_bolts = 3
    self.attack_speed = 10
    self.attack_speed_variance = nil
    self.attack_start = -50
    self.attack_miss_zone = 2
    self.display_healing = true

    self.attack_sound = "punchstrong"
    
end

function item:getLightBattleText()
    return "* You equipped Ballet Shoes."
end

function item:onAttack(battler, enemy, damage, stretch, crit)
    local src = Assets.stopAndPlaySound(self:getAttackSound() or "laz_c")
    src:setPitch(self:getAttackPitch() or 1)

    local sprite = Sprite("effects/attack/hyperfoot")
    sprite:setOrigin(0.5, 0.5)
    sprite:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
    sprite.layer = BATTLE_LAYERS["above_ui"] + 5
    sprite.color = battler.chara.color -- need to swap this to the get function
    enemy.parent:addChild(sprite)
    Game.battle:shakeCamera(3, 3, 2)

    if crit then
        sprite:setColor(1, 1, 130/255)
        Assets.stopAndPlaySound("saber3", 0.7)
    end

    Game.battle.timer:during(1, function() -- can't even tell if this is accurate
        sprite.x = sprite.x - 2 * DTMULT
        sprite.y = sprite.y - 2 * DTMULT
        sprite.x = sprite.x + Utils.random(4) * DTMULT
        sprite.y = sprite.y + Utils.random(4) * DTMULT
    end)

    sprite:play(2/30, false, function(this) -- timing may still be incorrect    
        local sound = enemy:getDamageSound() or "damage"
        if sound and type(sound) == "string" then
            Assets.stopAndPlaySound(sound)
        end
        enemy:hurt(damage, battler)

        battler.chara:onAttackHit(enemy, damage)
        this:remove()

        Game.battle:endAttack()

    end)

end

return item