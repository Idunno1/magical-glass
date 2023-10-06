local room, super = Class(Map)

function room:load()
    super.load(self)

    for _,tree in pairs(Game.world.map:getEvents("tree")) do
        tree.wrap_texture_x = false
        tree.parallax_x = 1.7
        tree.x = (tree.x * 1.6) + 50
    end
end

return room
