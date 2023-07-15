return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.0",
  name = "objects",
  class = "",
  tilewidth = 20,
  tileheight = 20,
  spacing = 0,
  margin = 0,
  columns = 0,
  objectalignment = "unspecified",
  tilerendersize = "tile",
  fillmode = "stretch",
  tileoffset = {
    x = 0,
    y = 0
  },
  grid = {
    orientation = "orthogonal",
    width = 1,
    height = 1
  },
  properties = {},
  wangsets = {},
  tilecount = 5,
  tiles = {
    {
      id = 0,
      image = "../../../assets/sprites/objects/npc_sign.png",
      width = 20,
      height = 20
    },
    {
      id = 1,
      image = "../../../assets/sprites/objects/waterdivot_blue_1.png",
      width = 20,
      height = 20,
      animation = {
        {
          tileid = 1,
          duration = 200
        },
        {
          tileid = 2,
          duration = 200
        },
        {
          tileid = 3,
          duration = 200
        },
        {
          tileid = 4,
          duration = 200
        },
        {
          tileid = 3,
          duration = 200
        },
        {
          tileid = 2,
          duration = 200
        }
      }
    },
    {
      id = 2,
      image = "../../../assets/sprites/objects/waterdivot_blue_2.png",
      width = 20,
      height = 20
    },
    {
      id = 3,
      image = "../../../assets/sprites/objects/waterdivot_blue_3.png",
      width = 20,
      height = 20
    },
    {
      id = 4,
      image = "../../../assets/sprites/objects/waterdivot_blue_4.png",
      width = 20,
      height = 20
    }
  }
}
