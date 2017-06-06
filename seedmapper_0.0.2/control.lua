local logger = require 'libs/logger'
local l = logger.new_logger()

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

seed_start = 1337000
seed_step = 2
seed_current = seed_start

x = 0
y = 0
chunk_size = 32
count_radius = 160
scan_chunks = 6
scan_size = scan_chunks * chunk_size
pos = {x,y}
sentry_chunk_pos = {-scan_chunks, -scan_chunks + 1}
x_size = count_radius
y_size = count_radius
scan_box = {{-scan_size, -scan_size}, {scan_size, scan_size}}
count_box = scan_box
zoom_level = 0.08
save_name = "seed_mapper"
tock_tick = -1
current_surface_checked = false

local function player()
    return game.players[1]
end

local function ll(str)
    game.write_file("seed_mapper.csv", str .. "\r\n", true)
end

local function new_surface()
    local settings = deepcopy(game.surfaces['nauvis'].map_gen_settings)

    settings['seed'] = seed_current
    local surface = game.create_surface('test' .. seed_current, settings)
	seed_current = seed_current + seed_step

    player().teleport(pos, surface)
    player().force.chart(surface, scan_box)
    player().print("Created new surface: " .. surface.name)
    surface.always_day = true
	current_surface_checked = false
    return surface
end

local function check_surface(surface)
    player().print("Checking surface: " .. surface.name)
    local seed = surface.map_gen_settings.seed
	local rocks  = surface.count_entities_filtered{area=count_box, name="red-desert-rock-huge"}
    local copper = surface.count_entities_filtered{area=count_box, name="copper-ore"}
    local iron   = surface.count_entities_filtered{area=count_box, name="iron-ore"}
    local oil    = surface.count_entities_filtered{area=count_box, name="crude-oil"}
    local trees  = surface.count_entities_filtered{area=count_box, type="tree"}
    ll(string.format("%07d, %05d, %05d, %03d, %05d, %d", seed, copper, iron, oil, trees, rocks))
    --if rocks > 0 then
    local name = string.format("map.s%07d-%05d-%05d-%03d-%05d-%d.png", seed, copper, iron, oil, trees, rocks)
    game.take_screenshot{resolution={x=1920,y=1080}, zoom=zoom_level, path=name}
    --end
    -- We can't delete the surface, because the screenshot is deferred
    tock_tick = game.tick + 5 -- for good measure
    current_surface_checked = true
end

initialized = false

local function init()
    ll("seed, copper, iron, oil, trees, rocks")
    initialized = true
end

local function start()
    surface_current  = new_surface()
end

--script.on_init(init)
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
    if event.name == defines.events.on_chunk_generated then
        if surface_current ~= nil and current_surface_checked == false then
            --player().print("Chunk generated: " .. event.area.left_top.x .. "," .. event.area.left_top.y .. "," .. event.area.right_bottom.x .. "," .. event.area.right_bottom.y)
            if surface_current.is_chunk_generated(sentry_chunk_pos) then
                check_surface(surface_current)
            end
        end
    end
end)
