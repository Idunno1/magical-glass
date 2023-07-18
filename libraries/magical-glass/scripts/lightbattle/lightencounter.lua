local LightEncounter = Class()

function LightEncounter:init()
    -- Text that will be displayed when the battle starts
    self.text = "* A skirmish breaks out!"

    -- Whether the default grid background is drawn
    self.background = true

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
end

function LightEncounter:onBattleInit()

    self.flee_chance = Utils.random(0, 100, 1)
    -- needs to account for lightequipitems that affect flee chance

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
    local message = Utils.random(0, 20, 1)
    if message == 0 or message == 1 then
        message = self.flee_messages[1]
    elseif message == 2 then
        message = self.flee_messages[2]
    elseif message > 3 then
        message = self.flee_messages[3]
    elseif message == 3 then
        message = self.flee_messages[4]
    elseif Game.battle.used_violence then
        message = "* Ran away with " .. Game.battle.xp .. "EXP and " .. Game.battle.money .. " " .. Game:getConfig("lightCurrency"):upper() .. "."
    end

    local soul_x, soul_y = Game.battle.soul:getPosition()
    local gtfo = Sprite("player/heartgtfo", soul_x - 7, soul_y - 8)

    Game.battle.battle_ui.arena:setBackgroundColor(r,g,b,0) --todo:separate the arena's frame from its background and put it on 

    gtfo:setColor(Game:getSoulColor())
    gtfo:setAnimation({"player/heartgtfo", 1/15, true})
    gtfo.layer = BATTLE_LAYERS["ui"] - 1
    Game.battle:addChild(gtfo)
    Game.battle.soul.visible = false
    gtfo.physics.speed_x = -3

    Game.battle:battleText(message, function()
        Game.battle:setState("TRANSITIONOUT")
        Game.battle.battle_ui.arena:setBackgroundColor(r,g,b,1)
        Game.battle.encounter:onBattleEnd()
        return true
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
function LightEncounter:drawBackground(fade) end

-- Functions

function LightEncounter:addEnemy(enemy, x, y, ...)
    local enemy_obj
    if type(enemy) == "string" then
        enemy_obj = Registry.createEnemy(enemy, ...)
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
            chance = Utils.random(0, 100, 1)
        else
            chance = chance + 10
        end
    end
    orig(self)

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