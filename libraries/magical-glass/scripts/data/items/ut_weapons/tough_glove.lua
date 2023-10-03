local item, super = Class(LightEquipItem, "ut_weapons/tough_glove")

function item:init()
    super.init(self)

    -- Display name
    self.name = "Tough Glove"
    self.short_name = "TuffGlove"
    self.serious_name = "Glove"

    -- Item type (item, key, weapon, armor)
    self.type = "weapon"
    -- Whether this item is for the light world
    self.light = true

    -- Default shop price (sell price is halved)
    self.price = 50
    -- Default shop sell price
    self.sell_price = 50
    -- Whether the item can be sold
    self.can_sell = true

    -- Light world check text
    self.check = "Weapon AT 5\n* A worn pink leather glove.[wait:10]\nFor five-fingered folk."

    -- Where this item can be used (world, battle, all, or none)
    self.usable_in = "all"
    -- Item this item will get turned into when consumed
    self.result_item = nil

    self.bonuses = {
        attack = 1
    }

    self.bolt_speed = self.bolt_speed * 1.2
    self.attack_punches = 4
    self.attack_punch_time = 1
    self.bolt_direction = "random"

    self.attack_sound = "punchstrong"

    self.ignore_no_damage = true

    self.tags = {"punch"}

end

function item:showEquipText(target)
    Game.world:showText("* " .. target:getNameOrYou() .." equipped Tough Glove.")
end

function item:getLightBattleText(user, target)
    return "* "..target.chara:getNameOrYou().." equipped Tough Glove."
end

function item:onLightAttack(battler, enemy, damage, stretch, crit)
    local state = "PRESS" -- PRESS, PUNCHING, DONE
    local punches = 0
    local punch_time = 0

    local press_z = Sprite("ui/lightbattle/pressz")
    local press_timer = 3
    press_z:setOrigin(0.5, 0.5)
    press_z:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
    press_z.layer = BATTLE_LAYERS["above_ui"] + 5

    local function finishAttack()
        if press_z then
            press_z:remove()
        end

        if damage <= 0 then
            return self:onLightMiss(battler, enemy, true)
        end

        if punches > 0 then
            local sound = enemy:getDamageSound() or "damage"
            if sound and type(sound) == "string" then
                Assets.stopAndPlaySound(sound)
            end
            local new_damage = math.ceil(damage * (punches / self.attack_punches))
            enemy:hurt(new_damage, battler)
    
            battler.chara:onAttackHit(enemy, damage)
    
            Game.battle:endAttack()
        else
            self:onLightMiss(battler, enemy)
        end

    end

    Game.battle.timer:during(self.attack_punch_time, function()
        press_timer = press_timer - 1 * DTMULT

        if press_timer < 0 then
            if press_z.visible == false then
                press_timer = 6
                press_z.visible = true
            else
                press_z.visible = false
                press_timer = 3
            end
        end

        if Input.pressed("confirm") and state ~= "DONE" then

            if state == "PRESS" then
                enemy.parent:addChild(press_z)
                state = "PUNCHING"
            elseif state == "PUNCHING" then

                punches = punches + 1

                if punches < self.attack_punches then
                    if press_z then
                        press_z:remove()
                    end

                    Assets.playSound("punchweak")
                    local small_punch = Sprite("effects/attack/hyperfist")
                    small_punch:setOrigin(0.5, 0.5)
                    small_punch:setScale(0.5, 0.5)
                    small_punch.layer = BATTLE_LAYERS["above_ui"] + 5
                    small_punch.color = battler.chara:getLightMultiboltAttackColor()
                    small_punch:setPosition(enemy:getRelativePos((love.math.random(enemy.width)), (love.math.random(enemy.height))))
                    enemy.parent:addChild(small_punch)
                    small_punch:play(2/30, false, function(s) s:remove() end)
                else
                    state = "DONE"
                    local src = Assets.stopAndPlaySound(self:getLightAttackSound() or "laz_c")
                    src:setPitch(self:getLightAttackPitch() or 1)
                    
                    local punch = Sprite("effects/attack/hyperfist")
                    punch:setOrigin(0.5, 0.5)
                    punch.layer = BATTLE_LAYERS["above_ui"] + 5
                    punch.color = battler.chara:getLightMultiboltAttackColor()
                    punch:setPosition(enemy:getRelativePos((enemy.width / 2), (enemy.height / 2)))
                    enemy.parent:addChild(punch)
                    punch:play(2/30, false, function(s) s:remove() finishAttack() end)
                end

            end
        end
    end,
    function()
        if state ~= "DONE" then
            finishAttack()
            state = "DONE" 
        end
    end)
end

return item