local Noelle, super = Class(LightEnemyBattler)

function Noelle:init()
    super:init(self)

    -- Enemy name
    self.name = "Noelle"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("noelle_ut")

    -- Enemy health
    self.max_health = 90
    self.health = 90
    -- Enemy attack (determines bullet damage)
    self.attack = 6
    -- Enemy defense (usually 0)
    self.defense = 2
    -- Enemy reward
    self.money = 87
    self.experience = 50
    
    if Game:getFlag("debug", false) then
        self.can_freeze = true
    end

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
        "scud_storm"
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "Let's take a\nselfie together!",
        "I can teach you\nhow to build a\nSCUD Storm!",
        "Let's be\nfriends!"
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "ATK 6 DEF 2\n* Seems like she wants to show you\nhow to construct a SCUD Storm."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* It's getting a bit cold here,\nisn't it?",
        "* Noelle is posing like her life depends on it.",
        "* Noelle is looking into your eyes directly."
    }
    
    self.dialogue_bubble = "ut_round"
    self.dialogue_offset = {0, -40}
    
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* " .. self.name .. " is afraid of dying."
    self.spareable_text = "* " .. self.name .. " doesn't want to\nfight anymore."

    self:registerAct("Sniff")
    self:registerAct("Befriend")

    -- can be a table or a number. if it's a number, it determines the width, and the height will be 13 (the ut default).
    -- if it's a table, the first value is the width, and the second is the height
    self.gauge_size = 150

    self.damage_offset = {0,40}
    
    self.sniff = 0
    self.befriend = 0
end

function Noelle:onAct(battler, name)
    if name == "Sniff" then
        self.sniff = self.sniff + 1
        if self.sniff == 1 then
           self.dialogue_override = "I know I'm Smelly."
           return "* You sniffed " .. self.name .. ".\n* Smells like lemons."
        elseif self.sniff == 2 then
           self.dialogue_override = "Oranges are\na funny smell!"
           return "* You sniffed " .. self.name .. " again.\n* Smells like oranges."
        elseif self.sniff == 3 then
           self.dialogue_override = {"My apples\nshampoo is\nalmost empty.","I'm getting sleepy\nfrom all those\nsniffes of yours..."}
           self.tired = true
           return "* You sniffed " .. self.name .. " again.\n* Smells like apples."
        else
           self.dialogue_override = "..."
           return "* You've sniffed " .. self.name .. " enough."
        end
    elseif name == "Befriend" or name == "Standard" then
        self.befriend = self.befriend + 1
        if self.befriend == 1 then
           self:addMercy(20)
           return "* You asked " .. self.name .. " if she can be\nyour pal.\n* She's really excited about that."
        elseif self.befriend == 2 then
            self:addMercy(20)
           return "* You asked " .. self.name .. " if you two \ncan get along.\n* She's planning a surprise!"
        elseif self.befriend == 3 then
           self.dialogue_override = {"Together, we will\nbe able to\ncapture the\nGLA and...","Build our own\nSCUD Storm!"}
           self:addMercy(100)
           self.waves = {}
           self.defense = -80
           return "* You asked " .. self.name .. " to be\nyour friend."
        else
           self.dialogue_override = "..."
           return "* " .. self.name .. " is already accepting your friendship."
        end
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super:onAct(self, battler, name)
end

return Noelle