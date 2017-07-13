require 'config'

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

seed_step = 2
seed_current = -1

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
    game.write_file(file_csv, str .. line_end, true, 0)
end

local function write_log(str)
    game.write_file(file_log, str .. line_end, true, 0)
end

local function new_surface()
    write_log("creating surface: test" .. seed_current)
    local settings = deepcopy(game.surfaces['nauvis'].map_gen_settings)
    settings['seed'] = seed_current
    local surface = game.create_surface('test' .. seed_current, settings)
    seed_current = seed_current + seed_step

    surface.request_to_generate_chunks(pos, scan_chunks+1)

    if player() then
        player().teleport(pos, surface)
        player().force.chart(surface, scan_box)
        surface.always_day = true
    end

    surface_current_checked = false
    return surface
end

local function check_surface(surface)
    write_log("checking surface: " .. surface.name .. " at tick " .. game.tick)
    local seed = surface.map_gen_settings.seed
    local rocks  = surface.count_entities_filtered{area=count_box, name="red-desert-rock-huge"}
    local copper = surface.count_entities_filtered{area=count_box, name="copper-ore"}
    local iron   = surface.count_entities_filtered{area=count_box, name="iron-ore"}
    local oil    = surface.count_entities_filtered{area=count_box, name="crude-oil"}
    local trees  = surface.count_entities_filtered{area=count_box, type="tree"}
    if iron > 6000 and copper > 4000 and trees < 2000 then
        write_csv(string.format("%07d,%05d,%05d,%03d,%05d,%d", seed, copper, iron, oil, trees, rocks))
        local name = string.format("map.s%07d-%05d-%05d-%03d-%05d-%d.png", seed, copper, iron, oil, trees, rocks)
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
    seed_current = game.surfaces['nauvis'].map_gen_settings['seed']
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
