script.on_event(defines.events, function(event)
    if event.name == defines.events.on_chunk_generated then
        for k,v in pairs(event.surface.find_entities_filtered{area=event.area, type="decorative"}) do
            v.destroy()
        end
--        local counter = 0
--        for k,v in pairs(event.surface.find_entities_filtered{area=event.area, type="tree"}) do
--            counter = counter + 1
--            if counter % 5 ~= 0 then
--                v.destroy()
--            end
--        end
    end
end)
