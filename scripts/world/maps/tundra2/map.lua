local room, super = Class(Map)

function room:load()
  super:load(self)

  for _, tree in pairs(Game.world.map:getEvents("tree")) do
    tree.wrap_texture_x = true
    tree.parallax_x = 0.9
    tree.parallax_y = 1
  end
  
end

return room
