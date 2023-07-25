return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.1",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 20,
  height = 12,
  tilewidth = 40,
  tileheight = 40,
  nextlayerid = 12,
  nextobjectid = 81,
  properties = {
    ["light"] = false,
    ["name"] = "Snowdin? - Box Road"
  },
  tilesets = {
    {
      name = "tundratiles",
      firstgid = 1,
      filename = "../tilesets/tundratiles.tsx",
      exportfilename = "../tilesets/tundratiles.lua"
    },
    {
      name = "objects",
      firstgid = 676,
      filename = "../tilesets/objects.tsx",
      exportfilename = "../tilesets/objects.lua"
    },
    {
      name = "tundratiles_dark",
      firstgid = 691,
      filename = "../tilesets/tundratiles_dark.tsx",
      exportfilename = "../tilesets/tundratiles_dark.lua"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 1,
      name = "tiles",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        691, 691, 691, 691, 691, 691, 691, 691, 691, 709, 710, 711, 691, 691, 691, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 691, 691, 691, 691, 709, 710, 711, 691, 691, 691, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 691, 691, 691, 691, 709, 710, 711, 691, 691, 691, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 691, 691, 691, 691, 709, 710, 711, 691, 691, 691, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 691, 700, 701, 701, 703, 710, 704, 702, 691, 691, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 691, 709, 710, 710, 710, 710, 710, 704, 701, 702, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 700, 703, 710, 713, 719, 712, 710, 710, 710, 711, 691, 691, 691, 691, 691,
        691, 691, 691, 700, 701, 703, 710, 710, 711, 691, 718, 719, 712, 710, 704, 701, 701, 701, 701, 701,
        701, 701, 701, 703, 710, 710, 710, 713, 720, 691, 691, 691, 709, 710, 710, 710, 710, 710, 710, 710,
        710, 710, 710, 710, 710, 713, 719, 720, 691, 691, 691, 691, 718, 719, 719, 719, 719, 719, 719, 719,
        719, 719, 719, 719, 719, 720, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691,
        691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691, 691
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 11,
      name = "tiles2",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        1088, 1089, 1088, 1089, 1090, 1097, 1098, 1099, 1100, 0, 0, 0, 1096, 1088, 1089, 1090, 1089, 1090, 1089, 1090,
        1097, 1098, 1097, 1098, 1097, 1090, 1107, 1108, 1109, 0, 0, 0, 1015, 1089, 1098, 1089, 1108, 1089, 1108, 1089,
        1088, 1089, 1088, 1089, 1090, 1019, 1028, 1037, 1038, 0, 0, 0, 1015, 1088, 1089, 1108, 1089, 1108, 1089, 1108,
        1097, 1098, 1097, 1098, 1097, 1028, 1037, 1038, 0, 0, 0, 0, 1034, 1035, 1026, 1089, 1018, 1089, 1018, 1089,
        1088, 1089, 1090, 1019, 1090, 1037, 1038, 349, 0, 0, 0, 0, 343, 1034, 1035, 1036, 1089, 1018, 1089, 1018,
        1097, 1098, 1099, 1028, 1037, 1038, 357, 358, 0, 0, 0, 0, 0, 0, 1024, 1025, 1106, 1107, 1106, 1107,
        1106, 1107, 1108, 1037, 1038, 349, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1114, 1115, 1116, 1115, 1116,
        1115, 1116, 1117, 1118, 357, 358, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 9,
      name = "objects_decal",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 66,
          name = "",
          type = "",
          shape = "rectangle",
          x = 576,
          y = 432,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 693,
          visible = true,
          properties = {}
        },
        {
          id = 67,
          name = "",
          type = "",
          shape = "rectangle",
          x = 324,
          y = 160,
          width = 40,
          height = 40,
          rotation = 0,
          gid = 693,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 3,
      name = "collision",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 40,
          name = "",
          type = "",
          shape = "polygon",
          x = 280,
          y = 440,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 40, y = 0 }
          },
          properties = {}
        },
        {
          id = 41,
          name = "",
          type = "",
          shape = "polygon",
          x = 320,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 40, y = 0 }
          },
          properties = {}
        },
        {
          id = 42,
          name = "",
          type = "",
          shape = "polygon",
          x = 360,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 40, y = 0 }
          },
          properties = {}
        },
        {
          id = 43,
          name = "",
          type = "",
          shape = "rectangle",
          x = 400,
          y = 320,
          width = 40,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 45,
          name = "",
          type = "",
          shape = "polygon",
          x = 480,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = -40 },
            { x = -40, y = 0 }
          },
          properties = {}
        },
        {
          id = 46,
          name = "",
          type = "",
          shape = "polygon",
          x = 520,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = -40 },
            { x = -40, y = 0 }
          },
          properties = {}
        },
        {
          id = 47,
          name = "",
          type = "",
          shape = "polygon",
          x = 560,
          y = 440,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = -40 },
            { x = -40, y = 0 }
          },
          properties = {}
        },
        {
          id = 48,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 440,
          width = 280,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 49,
          name = "",
          type = "",
          shape = "rectangle",
          x = 560,
          y = 440,
          width = 240,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 50,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 280,
          width = 120,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 51,
          name = "",
          type = "",
          shape = "polygon",
          x = 120,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 52,
          name = "",
          type = "",
          shape = "polygon",
          x = 160,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 53,
          name = "",
          type = "",
          shape = "polygon",
          x = 200,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 54,
          name = "",
          type = "",
          shape = "polygon",
          x = 240,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 55,
          name = "",
          type = "",
          shape = "polygon",
          x = 280,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 69,
          name = "",
          type = "",
          shape = "polygon",
          x = 320,
          y = 120,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 40, y = -40 },
            { x = 0, y = -40 }
          },
          properties = {}
        },
        {
          id = 56,
          name = "",
          type = "",
          shape = "rectangle",
          x = 320,
          y = 0,
          width = 40,
          height = 80,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 58,
          name = "",
          type = "",
          shape = "rectangle",
          x = 640,
          y = 240,
          width = 160,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 59,
          name = "",
          type = "",
          shape = "rectangle",
          x = 600,
          y = 160,
          width = 40,
          height = 80,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 63,
          name = "",
          type = "",
          shape = "polygon",
          x = 640,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 },
            { x = 0, y = 0 }
          },
          properties = {}
        },
        {
          id = 64,
          name = "",
          type = "",
          shape = "rectangle",
          x = 524,
          y = 154,
          width = 80,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 65,
          name = "",
          type = "",
          shape = "rectangle",
          x = 484,
          y = 0,
          width = 40,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 5,
      name = "markers",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 20,
          name = "spawn",
          type = "",
          shape = "point",
          x = 260,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 75,
          name = "entry2",
          type = "",
          shape = "point",
          x = 740,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 77,
          name = "entry3",
          type = "",
          shape = "point",
          x = 420,
          y = 80,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 76,
          name = "entry",
          type = "",
          shape = "point",
          x = 60,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 4,
      name = "objects",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      objects = {
        {
          id = 68,
          name = "savepoint",
          type = "",
          shape = "rectangle",
          x = 180,
          y = 300,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {
            ["text1"] = "* (The power of familiar roads shines within you.)"
          }
        },
        {
          id = 72,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = -20,
          y = 320,
          width = 40,
          height = 120,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra4",
            ["marker"] = "entry2"
          }
        },
        {
          id = 74,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 780,
          y = 280,
          width = 40,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra4",
            ["marker"] = "entry"
          }
        },
        {
          id = 78,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 360,
          y = -20,
          width = 120,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra3A",
            ["marker"] = "spawn"
          }
        },
        {
          id = 80,
          name = "enemy",
          type = "",
          shape = "rectangle",
          x = 530,
          y = 230,
          width = 40,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {
            ["actor"] = "dummy",
            ["encounter"] = "dummy"
          }
        }
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 7,
      name = "tiles3",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        1051, 1052, 1053, 1052, 1053, 1052, 1053, 1052, 1053, 1052, 1055, 0, 0, 0, 0, 1051, 1052, 1053, 1052, 1053,
        1060, 1061, 1062, 1061, 1062, 1061, 1062, 1061, 1062, 1063, 1064, 0, 0, 0, 0, 1060, 1061, 1062, 1061, 1062
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 20,
      height = 12,
      id = 6,
      name = "tiles4",
      class = "",
      visible = true,
      opacity = 1,
      offsetx = 0,
      offsety = 0,
      parallaxx = 1,
      parallaxy = 1,
      properties = {},
      encoding = "lua",
      data = {
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 298, 989, 990, 991, 992, 993, 304, 304, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 307, 998, 999, 1000, 1001, 1002, 313, 313, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 1006, 1007, 1008, 1009, 1010, 1011, 1012, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 1006, 1007, 1008, 1009, 1008, 1009, 1008, 1011, 1012, 0, 0, 0, 0, 0,
        1007, 1006, 1007, 1006, 1007, 1006, 1007, 1006, 1007, 1018, 1009, 1018, 1009, 1018, 1011, 1007, 1006, 1007, 1006, 1007
      }
    }
  }
}
