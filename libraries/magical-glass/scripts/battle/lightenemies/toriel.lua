local Toriel, super = Class(LightEnemyBattler)

function Toriel:init()
    super:init(self)

    -- Enemy name
    self.name = "Toriel"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("toriel_battle")

    -- Enemy health
    self.max_health = 440
    self.health = 440
    -- Enemy attack (determines bullet damage)
    self.attack = 6
    -- Enemy defense (usually 0)
    self.defense = 1
    -- Enemy reward
    self.money = 0
    self.experience = 150

    -- The Speech bubble style
    self.dialogue_bubble = "ut_tall_right"
    self.dialogue_offset = {300, 60}

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 0

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
--[[         "basic",
        "aiming",
        "movingarena" ]]
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {}

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "ATK 80 DEF 80\n* Knows best for you."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* Toriel looks through you.",
        "* Toriel prepares a magical attack.",
        "* Toriel takes a deep breath.",
        "* Toriel is acting aloof."
    }
	
    self:registerAct("Talk")
	
    self.talk_count = 0
    self.spare_count = 0
end

function Toriel:onAct(battler, name)
    if name == "Talk" then
		self.talk_count = self.talk_count + 1
	    if self.talk_count == 1 then
            return {
                "* You couldn't think of any conversation topics."
            }
	    elseif self.talk_count == 2 then
            return {
                "* You tried to think of something\nto say again, but..."
            }
	    elseif self.talk_count >= 3 then
            return {
                "* Ironically, talking does not\nseem to be the solution to this situation."
            }
        end
    end
    return super:onAct(self, battler, name)
end

return Toriel