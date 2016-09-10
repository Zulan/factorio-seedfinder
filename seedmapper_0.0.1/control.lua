local logger = require 'libs/logger'
local l = logger.new_logger()

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

index_current = 0
index_chunksize = 32
index_last = #seeds

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
zoom_level = 0.08
save_name = "seed_mapper"

local function player()
    return game.players[1]
end

local function new_surface()
    if (index_current >= index_end) then
        game.load(save_name)
        -- I suppose this should never be reached
        return nil
    end
    
    local settings = deepcopy(game.surfaces['nauvis'].map_gen_settings)
    settings['seed'] = seeds[index_current]
    
    local surface = game.create_surface('test' .. index_current, settings)
    player().teleport(pos, surface)
    player().force.chart(surface, scan_box)
    player().print("Created new surface: " .. surface.name)
    index_current = index_current + 1
    surface.always_day = true
    return surface
end

local function check_surface(surface)
    player().print("Checking surface: " .. surface.name)
    local seed = surface.map_gen_settings.seed
    local shift = surface.map_gen_settings['shift']
    local name = string.format("map.%04d.%04d.s%07d.png", shift.x, shift.y, seed)
    l:log("check seed: " .. name)
    game.take_screenshot{resolution={x=1920,y=1080}, zoom=zoom_level, path = name}
    l:dump()
end

initialized = false
wait_for_tick = false

local function init(tick)
    initialized = true

    game.speed = 20
    index_current = game.tick    
    index_end = index_current + index_chunksize
    wait_for_tick = tick + index_chunksize
    
    player().print("Initializing @ " .. tick .. " waiting util " .. wait_for_tick .. ", seeds from " .. index_current .. " to " .. index_end) 
end

local function start()
    wait_for_tick = false
    player().print("Starting @ " .. game.tick .. ", seeds from " .. index_current .. " to " .. index_end) 
    game.save(save_name)
    surface_current  = new_surface()
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
