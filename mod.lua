function Mod:init()
    print("Loaded "..self.info.name.."!")
end

function Mod:postInit()
    Game:setFlag("#hide_cell", true)
    Game:setFlag("has_cell_phone", true)
    Game:setFlag("#savename_lw_menus", true)
end