---@class LightEquipItem : Item
---@overload fun(...) : LightEquipItem
local LightEquipItem, super = Class("LightEquipItem", true)

function LightEquipItem:init()
    super.init(self)

    self.attack_bolts = 1

    self.attack_speed = Utils.pick({-10, 10})
    self.attack_speed_variance = 2

    self.attack_zone = {-295, 295}

    -- Sound played when attacking, defaults to laz_c
    self.attack_sound = "laz_c"

    self.attack_pitch = 1

end

function LightEquipItem:onAttack(battler, enemy, damage, stretch)

    local sprite = Sprite("effects/attack/strike")
    local scale = (stretch * 2) - 0.5
    sprite:setScale(scale, scale)
    sprite:setOrigin(0.5, 0.5)
    sprite:setPosition(enemy:getRelativePos((enemy.width / 2) - 5, (enemy.height / 2) - 5))
    sprite.layer = enemy.layer + 0.01
    sprite.color = battler.chara.color
    enemy.parent:addChild(sprite)
    sprite:play((stretch / 4) / 1.3, false, function(this)
    
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

function LightEquipItem:onMiss(battler, enemy)
    enemy:lightStatusMessage("msg", "miss", {battler.chara:getDamageColor()}, false) -- needs a special miss message that doesn't animate
    Game.battle:endAttack()
end

function LightEquipItem:getAttackSound() return self.attack_sound end
function LightEquipItem:getAttackPitch() return self.attack_pitch end

return LightEquipItem