local item, super = Class(LightEquipItem, "weapons/torn_notebook")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Torn Notebook"
    self.short_name = "TorNotbo"
    self.serious_name = "Notebook"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Light world check text
    self.check = {
        "Weapon AT 2\n* Contains illegible scrawls.\n* Increases INV by 6.",
        "* (After you get hurt by an attack[wait:2],\nyou stay invulnerable for longer.)" -- doesn't show up in UT???
    }

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 2
    }

    self.bolt_count = 2
    self.bolt_speed = 10
    self.bolt_speed_variance = nil
    self.bolt_start = {-50, -25} 
    self.bolt_miss_threshold = 2
    self.bolt_direction = "left"
    self.multibolt_variance = {{0, 25, 50}}
    self.inv_bonus = 15/30

    self.attack_sound = "bookspin"
    self.attack_pitch = 0.9
    
end

function item:onAttack(battler, enemy, damage, stretch, crit)
    local src = Assets.stopAndPlaySound(self:getAttackSound() or "laz_c")
    src:setPitch(self:getAttackPitch() or 1)

    local sprite = Sprite("effects/attack/notebook_attack")
    local impact = "effects/attack/frypan_impact"
    local siner = 0
    local timer = 0
    local hit = false
    sprite:setOrigin(0.5, 0.5)
    sprite:setScale(2, 2)
    sprite:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
    sprite.layer = BATTLE_LAYERS["above_ui"] + 5
    sprite.color = battler.chara.light_color -- need to swap this to the get function
    enemy.parent:addChild(sprite)

    if crit then
        sprite:setColor(1, 1, 130/255)
    end
    
    Game.battle.timer:during(27/30, function()
        timer = timer + DTMULT
        siner = siner + DTMULT

        if timer < 15 then
            sprite.scale_x = (math.cos(siner / 2) * 2)
        elseif timer > 15 then
            if not hit then
                sprite:setScale(2, 2)
                Assets.stopAndPlaySound("punchstrong", 1.3)
                if crit then
                    Assets.stopAndPlaySound("saber3", 0.8)
                end
                sprite:setAnimation({impact, 2/30, true})
                hit = true
            else
                sprite.scale_x = sprite.scale_x + 0.5 * DTMULT
                sprite.scale_y = sprite.scale_y + 0.5 * DTMULT

                if sprite.scale_x > 4 then
                    sprite.alpha = sprite.alpha - 0.2 * DTMULT
                end

                if sprite.alpha < 0.1 then
                    sprite:remove()
                end
            end
        end

    end,
    function(this)
        local sound = enemy:getDamageSound() or "damage"
        if sound and type(sound) == "string" then
            Assets.stopAndPlaySound(sound)
        end
        enemy:hurt(damage, battler)
        sprite:remove()

        battler.chara:onAttackHit(enemy, damage)

        Game.battle:endAttack()
    end)
end

return item