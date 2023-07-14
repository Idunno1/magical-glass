LightBattle              = libRequire("magical-glass", "scripts/lightbattle")
LightBattleUI            = libRequire("magical-glass", "scripts/lightbattle/lightbattleui")
LightTensionBar          = libRequire("magical-glass", "scripts/lightbattle/lighttensionbar")
LightArena               = libRequire("magical-glass", "scripts/lightbattle/lightarena")
LightActionButton        = libRequire("magical-glass", "scripts/lightbattle/lightactionbutton")
LightActionBox           = libRequire("magical-glass", "scripts/lightbattle/lightactionbox")
LightActionBoxSingle     = libRequire("magical-glass", "scripts/lightbattle/lightactionboxsingle")
LightActionBoxDisplay    = libRequire("magical-glass", "scripts/lightbattle/lightactionboxdisplay")
LightEncounter           = libRequire("magical-glass", "scripts/lightbattle/lightencounter")

MagicalGlassLib = {}
local lib = MagicalGlassLib

function lib:init()

    Utils.hook(Game, "encounter", function(orig, object, encounter, transition, enemy, context)
        -- For testing let's start our thingy instead
        -- when this shit's done, make a thing that checks for the class' type (encounter or encounterlight)
        object:encounterLight(encounter, transition, enemy, context)
        --orig(object, encounter, transition, enemy) 
    end)

    PALETTE["pink_spare"] = {1, 167/255, 212/255, 1}

end

function lib:postInit()
    Game:setFlag("enable_tp", false)
    Game:setFlag("gauge_styles", "undertale") -- undertale, deltarune, deltatraveler
    Game:setFlag("name_color", PALETTE["pink_spare"]) -- yellow, white, pink
end

function lib:changeSpareColor(color)
    if color == "yellow" then
        Game:setFlag("name_color", COLORS.yellow)
    elseif color == "pink" then
        Game:setFlag("name_color", PALETTE["pink_spare"])
    elseif color == "white" then
        Game:setFlag("name_color", COLORS.white)
    end
end

function lib:preUpdate(dt)
end

function Game:encounterLight(encounter, transition, enemy, context)

    if transition == nil then transition = true end

    if self.battle then
        error("Attempt to enter light battle while already in battle")
    end
    
    if enemy and not isClass(enemy) then
        self.encounter_enemies = enemy
    else
        self.encounter_enemies = {enemy}
    end

    if context then
        self.battle.encounter_context = context
    end

    self.state = "BATTLE"

    self.battle = LightBattle()

    if type(transition) == "string" then
        self.battle:postInit(transition, encounter)
    else
        self.battle:postInit(transition and "TRANSITION" or "ACTIONSELECT", encounter)
    end

    self.stage:addChild(self.battle)

end

return lib