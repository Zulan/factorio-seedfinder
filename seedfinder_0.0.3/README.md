# Seed finding for Factorio

The goal of this mod is to find seeds with specific properties (huge resources) for speedrunning Factorio.

## How to install

Clone the repository as "seedfinder_x.x.x" into your mods directory where "x.x.x" is the version as specified in info.json.

## How to use

You probably have to mess with the hardcoded stuff in control.lua and understand how the mod is working in order to use it.
The settings you use to start the game initially are the ones used for searching the seed.

## How it works

Basically the mod creates new surfaces with incremental mapseeds and teleports the player into it.
It initiates to chart the area around the player.
Hoever, the chunks are not generated instantly, so we wait until a "sentry chunk" is generated.
The mod then checks the resource & tree count and if it was deemed to have potential, a screenshot is made.

Unfortuantely you cannot delete a surface, so that would leak resources and not last very long.
So the mod automatically saves and loads the game to avoid that.
However, you cannot save persistent information except for the save itself, so another workaround is needed:
The game tick count is used as offset to the seed.
Basically there is a loop:

 1. Wait seed_chunks ticks
 2. Save
 3. Search within seed_chunks seeds for good seeds, use the game ticks as offset
 4. Load the last save
 
## Note from the author

The implementation is completely prototypic. I am currently not firm with lua, so please bear with me - I wanted to share it anyway. The documentation is very rough.

## Acknowledgements

- libs/logger.lua is from the excellent rso-mod: https://forums.factorio.com/viewforum.php?f=79
