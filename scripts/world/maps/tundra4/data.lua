return {
  version = "1.10",
  luaversion = "5.1",
  tiledversion = "1.10.2",
  class = "",
  orientation = "orthogonal",
  renderorder = "right-down",
  width = 28,
  height = 12,
  tilewidth = 40,
  tileheight = 40,
  nextlayerid = 13,
  nextobjectid = 146,
  properties = {
    ["light"] = true,
    ["name"] = "Snowdin - Box Road"
  },
  tilesets = {
    {
      name = "tundratiles",
      firstgid = 1,
      filename = "../../tilesets/tundratiles.tsx",
      exportfilename = "../../tilesets/tundratiles.lua"
    },
    {
      name = "objects",
      firstgid = 676,
      filename = "../../tilesets/objects.tsx",
      exportfilename = "../../tilesets/objects.lua"
    }
  },
  layers = {
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 28,
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
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 10, 11, 11, 11, 12, 1, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 19, 20, 20, 20, 14, 12, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 19, 20, 20, 20, 20, 21, 1, 1, 1, 1,
        1, 1, 1, 1, 1, 1, 10, 11, 11, 11, 11, 11, 11, 11, 11, 12, 3, 4, 28, 22, 20, 20, 20, 14, 12, 1, 1, 1,
        11, 11, 11, 11, 11, 11, 13, 20, 20, 20, 20, 20, 20, 20, 20, 14, 11, 11, 11, 13, 20, 20, 20, 20, 14, 11, 12, 1,
        20, 20, 20, 20, 20, 20, 20, 20, 23, 29, 29, 29, 29, 22, 20, 20, 20, 20, 20, 20, 20, 23, 22, 20, 20, 20, 14, 11,
        29, 29, 29, 29, 29, 29, 29, 29, 30, 1, 1, 1, 1, 28, 29, 29, 29, 29, 29, 29, 29, 30, 28, 29, 22, 20, 20, 20,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 28, 29, 29, 29,
        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 28,
      height = 12,
      id = 7,
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
        337, 310, 337, 310, 337, 310, 337, 310, 327, 310, 327, 310, 327, 310, 327, 310, 327, 310, 327, 408, 409, 408, 337, 408, 337, 408, 337, 408,
        310, 337, 310, 337, 310, 337, 310, 337, 310, 327, 310, 327, 310, 327, 310, 327, 310, 327, 338, 417, 418, 417, 326, 327, 408, 337, 408, 337,
        337, 310, 337, 310, 337, 310, 337, 310, 327, 310, 327, 310, 327, 310, 327, 310, 327, 338, 347, 426, 427, 426, 335, 336, 337, 408, 337, 408,
        310, 337, 310, 337, 310, 407, 408, 337, 310, 327, 310, 327, 310, 327, 310, 327, 338, 347, 356, 0, 0, 0, 344, 345, 326, 337, 408, 337,
        337, 310, 337, 310, 337, 330, 417, 418, 417, 418, 417, 418, 417, 418, 417, 418, 347, 356, 0, 0, 0, 0, 0, 334, 335, 326, 337, 408,
        416, 417, 416, 417, 346, 347, 426, 427, 426, 427, 426, 427, 426, 427, 426, 427, 356, 0, 0, 0, 0, 0, 0, 0, 344, 335, 326, 337,
        425, 426, 425, 426, 355, 356, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 344, 335, 346,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 344, 355,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
      objects = {}
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
          id = 80,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 440,
          width = 360,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 81,
          name = "",
          type = "",
          shape = "rectangle",
          x = 360,
          y = 400,
          width = 200,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 84,
          name = "",
          type = "",
          shape = "rectangle",
          x = 560,
          y = 440,
          width = 360,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 86,
          name = "",
          type = "",
          shape = "rectangle",
          x = 920,
          y = 400,
          width = 120,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 87,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1080,
          y = 440,
          width = 40,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 88,
          name = "",
          type = "",
          shape = "polygon",
          x = 360,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = 40 },
            { x = 0, y = 40 },
            { x = 0, y = 0 }
          },
          properties = {}
        },
        {
          id = 90,
          name = "",
          type = "",
          shape = "polygon",
          x = 920,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = -40, y = 40 },
            { x = 0, y = 40 },
            { x = 0, y = 0 }
          },
          properties = {}
        },
        {
          id = 89,
          name = "",
          type = "",
          shape = "polygon",
          x = 560,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = 40 },
            { x = 40, y = 40 }
          },
          properties = {}
        },
        {
          id = 91,
          name = "",
          type = "",
          shape = "polygon",
          x = 1040,
          y = 400,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = 40 },
            { x = 40, y = 40 }
          },
          properties = {}
        },
        {
          id = 94,
          name = "",
          type = "",
          shape = "polygon",
          x = 200,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = 40, y = -40 }
          },
          properties = {}
        },
        {
          id = 104,
          name = "",
          type = "",
          shape = "polygon",
          x = 640,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = 40, y = -40 }
          },
          properties = {}
        },
        {
          id = 105,
          name = "",
          type = "",
          shape = "polygon",
          x = 680,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = 40, y = -40 }
          },
          properties = {}
        },
        {
          id = 106,
          name = "",
          type = "",
          shape = "polygon",
          x = 720,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = 40, y = -40 }
          },
          properties = {}
        },
        {
          id = 96,
          name = "",
          type = "",
          shape = "rectangle",
          x = 200,
          y = 200,
          width = 440,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 107,
          name = "",
          type = "",
          shape = "polygon",
          x = 920,
          y = 160,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 }
          },
          properties = {}
        },
        {
          id = 109,
          name = "",
          type = "",
          shape = "polygon",
          x = 960,
          y = 200,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 }
          },
          properties = {}
        },
        {
          id = 110,
          name = "",
          type = "",
          shape = "polygon",
          x = 1000,
          y = 240,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 }
          },
          properties = {}
        },
        {
          id = 111,
          name = "",
          type = "",
          shape = "polygon",
          x = 1040,
          y = 280,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 }
          },
          properties = {}
        },
        {
          id = 112,
          name = "",
          type = "",
          shape = "polygon",
          x = 1080,
          y = 320,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          polygon = {
            { x = 0, y = 0 },
            { x = 0, y = -40 },
            { x = -40, y = -40 }
          },
          properties = {}
        },
        {
          id = 113,
          name = "",
          type = "",
          shape = "rectangle",
          x = 1080,
          y = 280,
          width = 40,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 115,
          name = "",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 240,
          width = 200,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 119,
          name = "",
          type = "",
          shape = "rectangle",
          x = 720,
          y = 88,
          width = 200,
          height = 32,
          rotation = 0,
          visible = true,
          properties = {}
        }
      }
    },
    {
      type = "objectgroup",
      draworder = "topdown",
      id = 12,
      name = "controllers",
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
          id = 141,
          name = "encounterzone",
          type = "",
          shape = "rectangle",
          x = 215.627,
          y = 120,
          width = 884.373,
          height = 320,
          rotation = 0,
          visible = true,
          properties = {
            ["encgroup"] = "test"
          }
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
          id = 126,
          name = "spawn",
          type = "",
          shape = "point",
          x = 100,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 127,
          name = "entry",
          type = "",
          shape = "point",
          x = 80,
          y = 360,
          width = 0,
          height = 0,
          rotation = 0,
          visible = true,
          properties = {}
        },
        {
          id = 129,
          name = "entry2",
          type = "",
          shape = "point",
          x = 1040,
          y = 360,
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
          id = 121,
          name = "",
          type = "",
          shape = "rectangle",
          x = 800,
          y = 220,
          width = 90,
          height = 144,
          rotation = 0,
          gid = 690,
          visible = true,
          properties = {}
        },
        {
          id = 125,
          name = "interactable",
          type = "",
          shape = "rectangle",
          x = 800,
          y = 100,
          width = 85,
          height = 40,
          rotation = 0,
          visible = true,
          properties = {
            ["text1"] = "* ...!?[wait:5]\n* There is a camera behind the...[wait:5]\n\"sentry station.\""
          }
        },
        {
          id = 128,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 0,
          y = 280,
          width = 40,
          height = 160,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "tundra3",
            ["marker"] = "entry2"
          }
        },
        {
          id = 122,
          name = "interactable",
          type = "",
          shape = "rectangle",
          x = 804,
          y = 182,
          width = 86,
          height = 38,
          rotation = 0,
          visible = true,
          properties = {
            ["solid"] = true,
            ["text1"] = "* There's some narration on this\ncardboard box.",
            ["text2"] = "[font:papyrus][voice:papyrus]YOU OBSERVE THE\nWELL-CRAFTED\nSENTRY STATION.",
            ["text3"] = "[font:papyrus][voice:papyrus]WHO COULD HAVE\nBUILT THIS,[wait:5] YOU\nPONDER...",
            ["text4"] = "[font:papyrus][voice:papyrus]I BET IT WAS\nTHAT VERY FAMOUS\nROYAL GUARDSMAN!",
            ["text5"] = "[font:papyrus][voice:papyrus](NOTE: NOT YET A\nVERY FAMOUS\nROYAL GUARDSMAN.[wait:5])"
          }
        },
        {
          id = 137,
          name = "transition",
          type = "",
          shape = "rectangle",
          x = 1100,
          y = 320,
          width = 20,
          height = 120,
          rotation = 0,
          visible = true,
          properties = {
            ["map"] = "darktundra1",
            ["marker"] = "entry"
          }
        }
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 28,
      height = 12,
      id = 11,
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 300, 301, 363, 364, 390, 301, 312, 0, 0, 0, 0, 0, 0, 0, 300, 301, 390, 301, 312, 0,
        389, 390, 389, 390, 389, 390, 389, 390, 309, 318, 319, 320, 319, 320, 321, 390, 389, 390, 389, 390, 389, 390, 309, 318, 319, 320, 321, 390,
        318, 319, 320, 399, 318, 319, 320, 399, 318, 319, 320, 399, 318, 319, 318, 319, 320, 399, 318, 319, 320, 399, 318, 319, 318, 319, 318, 319
      }
    },
    {
      type = "tilelayer",
      x = 0,
      y = 0,
      width = 28,
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
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
      }
    }
  }
}
