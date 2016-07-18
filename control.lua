local logger = require 'libs/logger'
local l = logger.new_logger()

local function count_resources(surface, bb, res_name)
    entities = surface.count_entities_filtered{area=bb, name=res_name}
    l:log(res_name .. ": " .. entities)
    return entities
end

local function count_trees(surface, bb)
    entities = surface.count_entities_filtered{area=bb, type="tree"}
    l:log("trees: " .. entities)
    return entities
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
seed_base = 1337100000
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
max_trees = 1000
box = {{x - x_size, y - y_size}, {x + x_size, y + y_size}}
zoom_level = 0.11
save_name = "seed_seeker"
player_name = "Zulan"

local function player()
    return game.players[1]
end

local function new_surface()
    if (seed_current >= seed_end) then
        game.load(save_name)
        -- I suppose this should never be reached
        return nil
    end
    
    local settings = deepcopy(game.surfaces['nauvis'].map_gen_settings)
    settings['seed'] = seed_current
    
    local surface = game.create_surface('test' .. seed_current, settings)
    player().teleport(pos, surface)
    player().print("Created new surface: " .. surface.name)
    seed_current = seed_current + seed_increment
    return surface
end

local function check_surface(surface)
    player().print("Checking surface: " .. surface.name)
    local seed = surface.map_gen_settings.seed
    l:log("check seed: " .. seed)
    local copper = count_resources(surface, box, "copper-ore")
    local iron   = count_resources(surface, box, "iron-ore")
	local oil    = count_resources(surface, box, "crude-oil")
    local trees  = count_trees(surface, box)
    local message = string.format("Copper: %05d, Iron: %05d, Oil: %03d, Trees: %d", copper, iron, oil, trees)
    player().print(message)
    
    if copper > min_copper and iron > min_iron and trees < max_trees then
        local name = string.format("sr.s%07d.cu%05d.fe%05d.oil%03d.tree%05d.png", seed, copper, iron, oil, trees)
        game.take_screenshot{resolution={x=1920,y=1080}, zoom=zoom_level, path = name}
    end
    l:dump()
end

initialized = false
wait_for_tick = false

local function init(tick)
    initialized = true

    seed_current = seed_base + game.tick
    seed_end = seed_current + seed_chunks
    wait_for_tick = tick + seed_chunks
    
    player().print("Initializing @ " .. tick .. " waiting util " .. wait_for_tick .. ", seeds from " .. seed_current .. " to " .. seed_end) 
end

local function start()
    wait_for_tick = false
    player().print("Starting @ " .. game.tick .. ", seeds from " .. seed_current .. " to " .. seed_end) 
    game.save(save_name)
    surface_current  = new_surface()
	surface_current.always_day = true
end

--script.on_init(init)
script.on_event(defines.events, function(event)
    if not initialized then
        init(event.tick)
    end
    if (event.name == defines.events.on_tick) and (wait_for_tick ~= false) and (event.tick >= wait_for_tick) then
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
