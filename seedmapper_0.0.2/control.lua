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
sentry_chunk_pos = {scan_chunks, scan_chunks}
x_size = count_radius
y_size = count_radius
scan_box = {{-scan_size, -scan_size}, {scan_size, scan_size}}
count_box = scan_box
zoom_level = 0.08
save_name = "seed_mapper"

local function player()
    return game.players[1]
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
    return surface
end

local function check_surface(surface)
    player().print("Checking surface: " .. surface.name)
    local seed = surface.map_gen_settings.seed
    local name = string.format("map.s%07d.png", seed)
    l:log("check seed: " .. name)
	local rocks = surface.count_entities_filtered{area=count_box, name='red-desert-rock-huge'}
	--if rocks > 0 then
		game.take_screenshot{resolution={x=1920,y=1080}, zoom=zoom_level, path=name}
	--end
	game.delete_surface(surface)
    l:dump()
end

initialized = false

local function init()
    initialized = true
end

local function start()
    surface_current  = new_surface()
end

--script.on_init(init)
script.on_event(defines.events, function(event)
    if not initialized then
        init()
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
