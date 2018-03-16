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
The mod then checks the resource & tree count and if it was deemed to have potential.
For good maps a screenshot is made (if not headless), and an entry is added to a csv file.
 
## Note from the author

The implementation is completely prototypic. I am currently not firm with lua, so please bear with me - I wanted to share it anyway. The documentation is very rough.
