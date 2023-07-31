local Dummy, super = Class(LightEnemyBattler)

function Dummy:init()
    super:init(self)

    -- Enemy name
    self.name = "Froggit"
    -- Sets the actor, which handles the enemy's sprites (see scripts/data/actors/dummy.lua)
    self:setActor("froggit_battle")

    -- Enemy health
    self.max_health = 30
    self.health = 30
    -- Enemy attack (determines bullet damage)
    self.attack = 5
    -- Enemy defense (usually 0)
    self.defense = 4
    -- Enemy reward
    self.money = 2
    self.experience = 3
    -- Hide HP in UNDERTALE battles
    self.hidehp = false

    -- Mercy given when sparing this enemy before its spareable (20% for basic enemies)
    self.spare_points = 0

    -- List of possible wave ids, randomly picked each turn
    self.waves = {
--[[         "basic",
        "aiming",
        "movingarena" ]]
    }

    -- Dialogue randomly displayed in the enemy's speech bubble
    self.dialogue = {
        "Ribbit, ribbit.",
        "Croak, croak.",
        "Hop, hop.",
        "Meow."
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "AT 4 DF 5\n* Life is difficult for this enemy."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* Froggit doesn't seem to know\n  why it's here.",
        "* Froggit hops to and fro.",
        "* The battlefield is filled with\n  the smell of mustard seed.",
        "* You are intimidated by Froggit's raw strength.\n  Only kidding."
    }
    -- Text displayed at the bottom of the screen when the enemy has low health
    self.low_health_text = "* Froggit is trying to run away."

    self:registerAct("Compliment")
    self:registerAct("Threaten")
end

function Dummy:onAct(battler, name)
    if name == "Compliment" then
        -- Give the enemy 100% mercy
        self:addMercy(100)
        return "* Froggit didn't understand what you said,\n  but was flattered anyway."

    elseif name == "Threaten" then
        -- Give the enemy 100% mercy
        self:addMercy(100)
        return "* Froggit didn't understand what you said,\n  but was scared anyway."
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super:onAct(self, battler, name)
end

return Dummy