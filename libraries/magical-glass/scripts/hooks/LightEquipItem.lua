local LightEquipItem, super = Class("LightEquipItem", true)

function LightEquipItem:init()
    super.init(self)
    
    self.index = nil
    self.storage = nil

    self.equip_display_name = nil

    self.target = "ally"

    self.heal_bonus = 0
    self.inv_bonus = 0

    self.bolt_count = 1

    self.bolt_speed = 11
    self.bolt_speed_variance = 2

    self.bolt_start = -16 -- number or table of where the bolt spawns. if it's a table, a value is chosen randomly
    self.multibolt_variance = {{0, 25, 50}, {100, 125, 150}}

    self.bolt_direction = "right" -- "right", "left", or "random"

    self.bolt_miss_threshold = 296

    self.attack_sprite = "effects/attack/strike"

    -- Sound played when attacking, defaults to laz_c
    self.attack_sound = "laz_c"

    self.attack_pitch = 1
end

function LightEquipItem:getEquipDisplayName()
    if self.equip_display_name then
        return self.equip_display_name
    else
        return self:getName()
    end
end
function LightEquipItem:getFleeBonus() return 0 end

function LightEquipItem:applyHealBonus(value) return value + self.heal_bonus end
function LightEquipItem:applyInvBonus(value) return value + self.inv_bonus end

function LightEquipItem:getBoltCount() return self.bolt_count end

function LightEquipItem:getBoltSpeed()
    if self:getBoltSpeedVariance() then
        return self.bolt_speed + self:getBoltSpeedVariance()
    else
        return self.bolt_speed
    end
end
function LightEquipItem:getBoltSpeedVariance() return self.bolt_speed_variance end

function LightEquipItem:getBoltStart()
    if type(self.bolt_start) == "table" then
        return Utils.pick(self.bolt_start)
    elseif type(self.bolt_start) == "number" then
        return self.bolt_start
    end
end

function LightEquipItem:onBattleSelect(user, target)
    self.storage, self.index = Game.inventory:getItemIndex(self)
    return true
end

function LightEquipItem:getMultiboltVariance(index)
    if self.multibolt_variance[index] then
        return Utils.pick(self.multibolt_variance[index])
    else
        local value
        if self.bolt_direction == "left" then
            value = Utils.pick(self.multibolt_variance[#self.multibolt_variance]) - (self:getBoltStart() * (index - #self.multibolt_variance))
        else
            value = Utils.pick(self.multibolt_variance[#self.multibolt_variance]) + (-self:getBoltStart() * (index - #self.multibolt_variance))
        end
        return value
    end
end

function LightEquipItem:getBoltDirection() 
    if self.bolt_direction == "random" then
        return Utils.pick({"right", "left"})
    else
        return self.bolt_direction
    end
end

function LightEquipItem:getAttackMissZone() return self.bolt_miss_threshold end

function LightEquipItem:getLightAttackSprite() return self.attack_sprite end

function LightEquipItem:getLightAttackSound() return self.attack_sound end
function LightEquipItem:getLightAttackPitch() return self.attack_pitch end

function LightEquipItem:onTurnEnd() end

function LightEquipItem:showEquipText(target)
    Game.world:showText("* " .. target:getNameOrYou() .. " equipped the " .. self:getName() .. ".")
end

function LightEquipItem:onWorldUse(target)
    self.storage, self.index = Game.inventory:getItemIndex(self)
    Assets.playSound("item")
    if self.type == "weapon" then
        if target:getWeapon() then
            Game.inventory:addItemTo(self.storage, self.index, target:getWeapon())
        end
        target:setWeapon(self)
    elseif self.type == "armor" then
        if target:getArmor(1) then
            Game.inventory:addItemTo(self.storage, self.index, target:getArmor(1))
        end
        target:setArmor(1, self)
    else
        error("LightEquipItem "..self.id.." invalid type: "..self.type)
    end

    self.storage, self.index = nil, nil
    self:showEquipText(target)
    return true
end

function LightEquipItem:getLightBattleText(user, target)
    if user == target then
        return "* ".. user.chara:getNameOrYou() .. " equipped the " .. self:getUseName() .. "."
    else
        return "* "..user.chara:getNameOrYou().." gave the "..self:getUseName().." to "..target.chara:getNameOrYou(true).." and "..target.chara:getNameOrYou(true).." equppied it."
    end
end

function LightEquipItem:getBattleText(user, target)
    if user == target then
        return "* ".. user.chara:getName() .. " equipped the " .. self:getUseName() .. "!"
    else
        return "* "..user.chara:getName().." gave the "..self:getUseName().." to "..target.chara:getName().." and "..target.chara:getName().." equppied it!"
    end
end

function LightEquipItem:onLightBattleUse(user, target)
    Assets.playSound("item")
    local chara = target.chara
    if self.type == "weapon" then
        if chara:getWeapon() then
            Game.inventory:addItemTo(self.storage, self.index, chara:getWeapon())
        end
        chara:setWeapon(self)
    elseif self.type == "armor" then
        if chara:getArmor(1) then
            Game.inventory:addItemTo(self.storage, self.index, chara:getArmor(1))
        end
        chara:setArmor(1, self)
    else
        error("LightEquipItem "..self.id.." invalid type: "..self.type)
    end
    self.storage, self.index = nil, nil
    Game.battle:battleText(self:getLightBattleText(user, target))
end

function LightEquipItem:onBattleUse(user, target)
    Assets.playSound("item")
    local chara = target.chara
    if self.type == "weapon" then
        if chara:getWeapon() then
            Game.inventory:addItemTo(self.storage, self.index, chara:getWeapon())
        end
        chara:setWeapon(self)
    elseif self.type == "armor" then
        if chara:getArmor(1) then
            Game.inventory:addItemTo(self.storage, self.index, chara:getArmor(1))
        end
        chara:setArmor(1, self)
    else
        error("LightEquipItem "..self.id.." invalid type: "..self.type)
    end
    self.storage, self.index = nil, nil
end

function LightEquipItem:onBoltHit(battler) end
function LightEquipItem:scoreHit(battler, score, eval, close)
    local new_score = score
    new_score = new_score + eval

    if new_score > 430 then
        new_score = new_score * 1.8
    end
    if new_score >= 400 then
        new_score = new_score * 1.25
    end

    return new_score
end

return LightEquipItem