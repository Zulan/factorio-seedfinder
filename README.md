# Tools for Factorio to search for speedrun seeds

Works only on 0.14.
In Factorio, there is one general map - for each combination of map settings (frequency).
The offset where you will start within this map is limited to 2000 x 2000 chunks.
The starting area of the map is modified (added ore patches, added water).

## Workflow

1. Find a good general area to start in
  * Load the shrink mod (reduces decoratives/entities).
  * Select your favorite map options
  * Disable aliens.
  * Use map seed 16775230 (will have offset 0,0)
  * /c game.speed = 100
  * /c game.forces.player.chart(game.player.surface, {{x=0,y=0},{x=64000,y=64000}})
  * This will be the entire available map for starting positions, you should go through that in smaller regions unless you have hundreds of gigabytes of ram.
  * Wait
  * Find a good spot, get the chunk coordinates, remember each chunk is 32 x 32 tiles
  
2. Find map seeds with the right offset
  * Compile the program in search_offset
  * ./a.out chunk_x chunk_y > seeds.lua
  * This will generate a json list of available map seeds with that starting position offset

3. Generate images of the actual starting area for those map seeds
  * Copy seeds.lua to mods/seedmapper_0.0.1/
  * Run the game with the seedmapper mod and your actual favorite starting positions
  * The script-output directory will now contain images of all starting positions with the given offset
  * Find a good one

4. Now you can fine-tune things like coal-frequency
