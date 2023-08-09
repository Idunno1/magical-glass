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
        "[wave:2]Ribbit,\nribbit.",
        "[wave:2]Croak,\ncroak.",
        "[wave:2]Hop,\nhop.",
        "[wave:2]Meow."
    }

    -- Check text (automatically has "ENEMY NAME - " at the start)
    self.check = "ATK 4 DEF 5\n* Life is difficult for\nthis enemy."

    -- Text randomly displayed at the bottom of the screen each turn
    self.text = {
        "* Froggit doesn't seem to\nknow why it's here.",
        "* Froggit hops to and fro.",
        "* The battlefield is filled\nwith the smell of mustard\nseed.",
        "* You are intimidated by\nFroggit's raw strength.[wait:40]\n* Only kidding."
    }
    
    self.low_health_text = "* Froggit is trying to\nrun away."
    self.spareable_text = "* Froggit seems reluctant\nto fight you."

    self:registerAct("Compliment")
    self:registerAct("Threaten")
end

function Dummy:onAct(battler, name)
    if name == "Compliment" then
        -- Give the enemy 100% mercy
        self:addMercy(100)
        -- Change this enemy's dialogue for 1 turn
        self.dialogue_override = "[wave:2](Blushes\ndeeply.)\nRibbit.."

        return "* Froggit didn't understand\nwhat you said,[wait:5] but was\nflattered anyway."

    elseif name == "Threaten" then
        -- Give the enemy 100% mercy
        self:addMercy(100)
        -- Change this enemy's dialogue for 1 turn
        self.dialogue_override = "[wave:2]Shiver,\nshiver."

        return "* Froggit didn't understand\nwhat you said,[wait:5] but was\nscared anyway."
    end

    -- If the act is none of the above, run the base onAct function
    -- (this handles the Check act)
    return super:onAct(self, battler, name)
end

return Dummy