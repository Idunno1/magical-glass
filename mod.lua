function Mod:init()
    print("Loaded "..self.info.name.."!")
end

function Mod:postInit()
    Game:setFlag("#hide_cell", false)
    Game:setFlag("has_cell_phone", true)
    Game:setFlag("#savename_lw_menus", true)

end

function Mod:load()
    Game.world:registerCall("Dimensional Box A", "cell.box_a")
    Game.world:registerCall("Dimensional Box B", "cell.box_b")
end