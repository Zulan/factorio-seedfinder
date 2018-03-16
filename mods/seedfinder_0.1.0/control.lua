require 'config'
require 'seeds'

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

surface_current = nil

if (use_seeds) then
    seed_index = 1
else
    seed_current = -1
end

local function get_seed()
    if (use_seeds) then
        seed = seeds[seed_index]
        seed_index = seed_index + 1
        return seed
    else
        seed_current = seed_current + 2
        return seed_current
    end
end

x = 0
y = 0
chunk_size = 32
scan_size = scan_chunks * chunk_size
pos = {x,y}
--sentry_chunk_pos = {-scan_chunks, -scan_chunks + 1}
sentry_chunk_pos = {scan_chunks, scan_chunks}
x_size = count_radius
y_size = count_radius
scan_box = {{-scan_size, -scan_size}, {scan_size, scan_size}}
rocks_scan_size = rocks_count_chunks * chunk_size
rocks_scan_box = {{-rocks_scan_size, -rocks_scan_size}, {rocks_scan_size, rocks_scan_size}}
count_box = scan_box
tock_tick = -1
surface_current_checked = false
file_csv = file_prefix .. ".csv"
file_log = file_prefix .. ".log"

local function player()
    return game.players[1]
end

force = nil

local function write_csv(str)
    game.write_file(file_csv, str .. line_end, true)
end

local function write_log(str)
    game.print(str)
    game.write_file(file_log, str .. line_end, true)
end

local function new_surface()
    seed = get_seed()
    write_log("creating surface: test" .. seed)
    local settings = deepcopy(game.surfaces['nauvis'].map_gen_settings)
    settings['seed'] = seed
    local surface = game.create_surface('test' .. seed, settings)

    surface.request_to_generate_chunks(pos, scan_chunks+1)

    if player() then
        player().teleport(pos, surface)
        player().force.chart(surface, scan_box)
        surface.always_day = true
    end

    surface_current_checked = false
    return surface
end

local inspect = require('inspect')

local function check_surface(surface)
    write_log("checking surface: " .. surface.name .. " at tick " .. game.tick)
    write_log(inspect(surface.map_gen_settings))
    local seed = surface.map_gen_settings.seed
    -- I think the 'red-desert-rock-huge' only remains in translation files, but let's be sure
    local coal_rocks = surface.count_entities_filtered{area=rocks_scan_box, name="rock-huge"} + surface.count_entities_filtered{area=count_box, name="red-desert-rock-huge"}
    local copper     = surface.count_entities_filtered{area=count_box, name="copper-ore"}
    local iron       = surface.count_entities_filtered{area=count_box, name="iron-ore"}
    local oil        = surface.count_entities_filtered{area=count_box, name="crude-oil"}
    -- Trees no longer interesting with tunable setting
    -- local trees      = surface.count_entities_filtered{area=count_box, type="tree"}
    write_log(string.format("copper: %05d, iron: %05d, oil: %03d, coal rocks: %03d", copper, iron, oil, coal_rocks))
    if iron >= iron_min and copper >= copper_min and oil >= oil_min and coal_rocks >= coal_rocks_min then
        write_csv(string.format("%07d,%05d,%05d,%03d,%03d", seed, copper, iron, oil, coal_rocks))
        local name = string.format("map.s%07d-%05d-%05d-%03d-%03d.png", seed, copper, iron, oil, coal_rocks)
        if player() then
            game.take_screenshot{resolution=resolution, zoom=zoom, path=name}
        end
    end
    -- We can't delete the surface yet, because the screenshot is deferred
    tock_tick = game.tick + 5 -- for good measure
    surface_current_checked = true
end

initialized = false

local function init()
    if (use_seeds) then
        seed_current = game.surfaces['nauvis'].map_gen_settings['seed']
    end
    file_csv = file_prefix .. "-" .. seed_current .. ".csv"
    file_log = file_prefix .. "-" .. seed_current .. ".log"

    write_log("initializing seed mapper")
    write_csv("seed,copper,iron,oil,trees,rocks")
    initialized = true
    game.speed = 100
end

local function start()
    surface_current = new_surface()
end

script.on_event({defines.events.on_tick, defines.events.on_chunk_generated} , function(event)
    if not initialized then
        init()
        start()
    end
    if event.name == defines.events.on_tick then
        if game.tick == tock_tick then
            game.delete_surface(surface_current)
            surface_current = new_surface()            
        end
    end
    if not surface_current_checked and surface_current.is_chunk_generated(sentry_chunk_pos) then
        check_surface(surface_current)
    end
end)
