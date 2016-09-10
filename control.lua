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

-- Use 0 to use seed of initial map
seed_base = 0
seed_chunks = 32
seed_increment = 2
seed_current = nil
--seed_current = 1762966940

surface_current = nil

x = 0
y = 0
chunk_size = 32
count_radius = 160
scan_chunks = 6
scan_size = scan_chunks * chunk_size
pos = {x,y}
sentry_chunk_pos = {scan_chunks, scan_chunks}
x_size = count_radius
y_size = count_radius
min_iron = 1600
min_copper = 1600
max_trees = 2000
count_box = {{x - x_size, y - y_size}, {x + x_size, y + y_size}}
scan_box = {{-scan_size, -scan_size}, {scan_size, scan_size}}
zoom_level = 0.08
save_name = "seed_seeker"

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
    player().force.chart(surface, scan_box)
    player().print("Created new surface: " .. surface.name)
    seed_current = seed_current + seed_increment
    return surface
end

local function check_surface(surface)
    player().print("Checking surface: " .. surface.name)
    local seed = surface.map_gen_settings.seed
    l:log("check seed: " .. seed)
    local copper = count_resources(surface, count_box, "copper-ore")
    local iron   = count_resources(surface, count_box, "iron-ore")
    local oil    = count_resources(surface, count_box, "crude-oil")
    local trees  = count_trees(surface, count_box)
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

    if seed_base == 0 then
        seed_base = game.surfaces['nauvis'].map_gen_settings['seed']
    end
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
            --player().print("Chunk generated: " .. event.area.left_top.x .. "," .. event.area.left_top.y .. "," .. event.area.right_bottom.x .. "," .. event.area.right_bottom.y)
            if surface_current.is_chunk_generated(sentry_chunk_pos) then
                check_surface(surface_current)
                surface_current = new_surface()
            end
        end
    end
end)
