function Mod:init()
    print("Loaded "..self.info.name.."!")
end

function Mod:postInit()
    Game:setFlag("has_cell_phone", true)
end

function Mod:load()
    Game.world:registerCall("Dimensional Box A", "cell.box_a", false, 5/30)
    Game.world:registerCall("Dimensional Box B", "cell.box_b", false, 5/30)
end