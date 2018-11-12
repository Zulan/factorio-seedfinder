resolution         = {x=1200,y=1200}
zoom               = 1/12
scan_chunks        = 6
rocks_count_chunks = 4
file_prefix        = 'seedfinder'
line_end           = "\r\n"

iron_min       = 0
copper_min     = 0
trees_min      = 0
trees_max      = 9999999
oil_min        = 5000
grass_min      = 0
coal_min       = 0
coal_rocks_min = 2

use_seed_list = true
no_gui = true


map_gen_settings =
{
  autoplace_controls = {
    coal = {
      frequency = "normal",
      richness = "very-high",
      size = "very-high"
    },
    ["copper-ore"] = {
      frequency = "very-low",
      richness = "very-high",
      size = "very-high"
    },
    ["crude-oil"] = {
      frequency = "very-high",
      richness = "very-high",
      size = "very-high"
    },
    desert = {
      frequency = "normal",
      richness = "normal",
      size = "none"
    },
    dirt = {
      frequency = "normal",
      richness = "normal",
      size = "none"
    },
    ["enemy-base"] = {
      frequency = "normal",
      richness = "normal",
      size = "none"
    },
    grass = {
      frequency = "normal",
      richness = "normal",
      size = "very-high"
    },
    ["iron-ore"] = {
      frequency = "very-low",
      richness = "very-high",
      size = "very-high"
    },
    sand = {
      frequency = "very-high",
      richness = "normal",
      size = "none"
    },
    stone = {
      frequency = "very-high",
      richness = "very-high",
      size = "low"
    },
    trees = {
      frequency = "low",
      richness = "very-low",
      size = "very-low"
    },
    ["uranium-ore"] = {
      frequency = "normal",
      richness = "very-high",
      size = "none"
    }
  },
  cliff_settings = {
    cliff_elevation_0 = 1024,
    cliff_elevation_interval = 10,
    name = "cliff"
  },
  height = 2000000,
  peaceful_mode = true,
  seed = 1,
  starting_area = "very-high",
  starting_points = { {
      x = 0,
      y = 0
    } },
  terrain_segmentation = "very-high",
  water = "very-low",
  width = 2000000
}

