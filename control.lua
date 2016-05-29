require "defines"

local logger = require 'libs/logger'
local l = logger.new_logger()

local function count_resources(surface, bb, res_name)
    entities = surface.find_entities_filtered{area=bb, name=res_name}
    l:log(res_name .. ": " .. #entities)
    return #entities
end

local function count_trees(surface, bb)
    entities = surface.find_entities_filtered{area=bb, type="tree"}
    l:log("trees: " .. #entities)
    return #entities
end

local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

seed_base = 1337001000
seed_chunks = 100
seed_increment = 2
seed_current = nil
--seed_current = 1762966940

surface_current = nil

x = 0
y = 0
radius = 100
pos = {x,y}
chunk_pos = {4,4}
x_size = radius
y_size = radius
min_iron = 1600
min_copper = 1600
box = {{x - x_size, y - y_size}, {x + x_size, y + y_size}}
zoom_level = 0.11
save_name = "seed_seeker"

local function new_surface()
    if (seed_current >= seed_end) then
        game.load(save_name)
        -- I suppose this should never be reached
        return nil
    end
    
    local settings = deepcopy(game.surfaces['nauvis'].map_gen_settings)
    settings['seed'] = seed_current
    
    local surface = game.create_surface('test' .. seed_current, settings)
    game.player.teleport(pos, surface)
    game.player.print("Created new surface: " .. surface.name)
    seed_current = seed_current + seed_increment
    return surface
end

local function check_surface(surface)
    game.player.print("Checking surface: " .. surface.name)
    local seed = surface.map_gen_settings.seed
    l:log("check seed: " .. seed)
    local copper = count_resources(surface, box, "copper-ore")
    local iron   = count_resources(surface, box, "iron-ore")
    local trees  = count_trees(surface, box)
    local message = string.format("Copper: %05d, Iron: %05d, Trees: %d", copper, iron, trees)
    game.player.print(message)
    
    if copper > min_copper and iron > min_iron then
        local name = string.format("sr.%07d.%05d.%05d.%05d.png", seed, copper, iron, trees)
        game.take_screenshot{resolution={x=1920,y=1080}, zoom=zoom_level, path = name}
    end
    l:dump()
end

initialized = false
wait_for_tick = false

local function init()
    initialized = true

    game.always_day = true
    seed_current = seed_base + game.tick
    seed_end = seed_current + seed_chunks
    wait_for_tick = game.tick + seed_chunks
    
    game.player.print("Initializing @ " .. game.tick .. " waiting util " .. wait_for_tick .. ", seeds from " .. seed_current .. " to " .. seed_end) 
end

local function start()
    wait_for_tick = false
    game.player.print("Starting @ " .. game.tick .. ", seeds from " .. seed_current .. " to " .. seed_end) 
    game.save(save_name)
    surface_current  = new_surface()
end

--script.on_init(init)
script.on_event(defines.events, function(event)
    if not initialized then
        init()
    end
    if (event.name == defines.events.on_tick) and (wait_for_tick ~= false) and (game.tick >= wait_for_tick) then
        start()
    end

    if event.name == defines.events.on_chunk_generated then
        if surface_current ~= nil then
            if surface_current.is_chunk_generated(chunk_pos) then
                check_surface(surface_current)
                surface_current = new_surface()
            end
        end
    end
end)
