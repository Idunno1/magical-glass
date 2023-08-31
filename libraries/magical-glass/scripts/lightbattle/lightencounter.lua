local LightEncounter = Class()

function LightEncounter:init()
    -- Text that will be displayed when the battle starts
    self.text = "* A skirmish breaks out!"

    -- Is a "But Nobody Came"/"Genocide" Encounter
    self.nobody_came = false

    -- Whether the default grid background is drawn
    self.background = true
    self.background_image = "ui/lightbattle/backgrounds/battle"

    -- The music used for this encounter
    self.music = "battleut"

    -- Whether characters have the X-Action option in their spell menu
    self.default_xactions = Game:getConfig("partyActions")

    -- Should the battle skip the YOU WON! text?
    self.no_end_message = false

    -- Table used to spawn enemies when the battle exists, if this encounter is created before
    self.queued_enemy_spawns = {}

    -- A copy of battle.defeated_enemies, used to determine how an enemy has been defeated.
    self.defeated_enemies = nil

    self.can_flee = true

    self.flee_chance = nil
    self.flee_messages = {
        "* I'm outta here.", -- 1/20
        "* I've got better to do.", --1/20
        "* Escaped...", --17/20
        "* Don't slow me down." --1/20
    }

    self.used_flee_message = nil
end

function LightEncounter:isLight()
    return true
end

function LightEncounter:onBattleInit()

    self.flee_chance = Utils.random(0, 100, 1)
    -- needs to account for lightequipitems that affect flee chance
    -- needs to work

end
function LightEncounter:onBattleStart() end
function LightEncounter:onBattleEnd() end

function LightEncounter:onTurnStart() end
function LightEncounter:onTurnEnd() end

function LightEncounter:onActionsStart() end
function LightEncounter:onActionsEnd() end

function LightEncounter:onCharacterTurn(battler, undo) end

function LightEncounter:onFlee()

    Assets.playSound("escaped")

    if Game.battle.used_violence then -- level up shit

        local money = self:getVictoryMoney(Game.battle.money) or Game.battle.money
        local xp = self:getVictoryXP(Game.battle.xp) or Game.battle.xp

        Game.lw_money = Game.lw_money + money

        if (Game.lw_money < 0) then
            Game.lw_money = 0
        end

        self.used_flee_message = "* Ran away with " .. xp .. " EXP\n  and " .. money .. " " .. Game:getConfig("lightCurrency") .. "."

        for _,member in ipairs(self.party) do
            local lv = member.chara:getLightLV()
            member.chara:gainLightEXP(self.xp, true)

            if lv ~= member.chara:getLightLV() then
                win_text = "* YOU WON!\n* You earned " .. self.xp .. " EXP and " .. self.money .. " " .. Game:getConfig("lightCurrency"):upper() .. ".\n* Your LOVE increased."
            end
        end

    else
        self.used_flee_message = self:getFleeMessage()
    end

    Game.battle.soul.collidable = false
    Game.battle.soul.y = Game.battle.soul.y + 4
    Game.battle.soul.sprite:setAnimation({"player/heartgtfo", 1/15, true})
    Game.battle.soul.physics.speed_x = -3

    Game.battle.timer:script(function(wait)
        wait(1)
        Game.battle:setState("TRANSITIONOUT")
        self:onBattleEnd()
    end)

end

function LightEncounter:beforeStateChange(old, new) end
function LightEncounter:onStateChange(old, new) end

function LightEncounter:onActionSelect(battler, button) end
function LightEncounter:onMenuSelect(state, item, can_select) end

function LightEncounter:onGameOver() end
function LightEncounter:onReturnToWorld(events) end

function LightEncounter:getDialogueCutscene() end

function LightEncounter:getVictoryMoney(money) end
function LightEncounter:getVictoryXP(xp) end
function LightEncounter:getVictoryText(text, money, xp) end

function LightEncounter:update() end

function LightEncounter:draw(fade) end
function LightEncounter:drawBackground(fade)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Assets.getTexture(self.background_image) or Assets.getTexture("ui/lightbattle/backgrounds/battle"), 15, 9)
end

-- Functions

function LightEncounter:addEnemy(enemy, x, y, ...)
    local enemy_obj
    if type(enemy) == "string" then
        enemy_obj = MagicalGlassLib:createLightEnemy(enemy, ...)
    else
        enemy_obj = enemy
    end

    local enemies = self.queued_enemy_spawns
    if Game.battle and Game.state == "BATTLE" then
        enemies = Game.battle.enemies
    end

    if x and y then
        enemy_obj:setPosition(x, y)
    else
        for _,enemy in ipairs(enemies) do
            enemy.x = enemy.x - 10
            enemy.y = enemy.y - 45
        end
        local x, y = SCREEN_WIDTH/2 - 100 + (50 * #enemies), SCREEN_HEIGHT / 2
        enemy_obj:setPosition(x, y)
    end

    enemy_obj.encounter = self
    table.insert(enemies, enemy_obj)
    if Game.battle and Game.state == "BATTLE" then
        Game.battle:addChild(enemy_obj)
    end
    return enemy_obj
end

function LightEncounter:getFleeMessage()
    local message = Utils.random(0, 20, 1)

    if message == 0 or message == 1 then
        return self.flee_messages[1]
    elseif message == 2 then
        return self.flee_messages[2]
    elseif message > 3 then
        return self.flee_messages[3]
    elseif message == 3 then
        return self.flee_messages[4]
    end
end

function LightEncounter:getUsedFleeMessage()
    return self.used_flee_message
end

function LightEncounter:getEncounterText()
    local enemies = Game.battle:getActiveEnemies()
    local enemy = Utils.pick(enemies, function(v)
        if not v.text then
            return true
        else
            return #v.text > 0
        end
    end)
    if enemy then
        return enemy:getEncounterText()
    else
        return self.text
    end
end

function LightEncounter:getNextWaves()
    local waves = {}
    for _,enemy in ipairs(Game.battle:getActiveEnemies()) do
        local wave = enemy:selectWave()
        if wave then
            table.insert(waves, wave)
        end
    end
    return waves
end

function LightEncounter:getSoulColor()
    return Game:getSoulColor()
end

function LightEncounter:onDialogueEnd()
    Game.battle:setState("DEFENDINGBEGIN")
end

function LightEncounter:onWavesDone()

    local chance = self.flee_chance

    if Game.battle.turn_count > 2 then
        if chance == 0 or chance == nil then
            self.flee_chance = Utils.random(0, 100, 1)
        else
            self.flee_chance = self.flee_chance + 10
        end
    end

    if Game.battle.soul then
        Game.battle.soul:remove()
    end

    Game.battle:setState("DEFENDINGEND", "WAVEENDED")
end

function LightEncounter:getDefeatedEnemies()
    return self.defeated_enemies or Game.battle.defeated_enemies
end

function LightEncounter:createSoul(x, y, color)
    return LightSoul(x, y, color)
end

function LightEncounter:setFlag(flag, value)
    Game:setFlag("encounter#"..self.id..":"..flag, value)
end

function LightEncounter:getFlag(flag, default)
    return Game:getFlag("encounter#"..self.id..":"..flag, default)
end

function LightEncounter:addFlag(flag, amount)
    return Game:addFlag("encounter#"..self.id..":"..flag, amount)
end

function LightEncounter:canDeepCopy()
    return false
end

return LightEncounter