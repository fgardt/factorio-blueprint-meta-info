local ev = defines.events

script.on_event(ev.on_player_setup_blueprint, function(event)
    local player = game.get_player(event.player_index)
    if not player then return end

    local active_mods = script.active_mods
    local not_vanilla = false

    for mod, _ in pairs(active_mods) do
        not_vanilla = not_vanilla or mod ~= "base"
    end

    -- dont do anything if it is just the base mod
    if not not_vanilla then return end

    local bp = player.blueprint_to_setup
    if not bp or not bp.valid or not bp.valid_for_read or not bp.is_blueprint_setup() then
        log("Unable to add meta info to blueprint.")
        return
    end

    local entities = bp.get_blueprint_entities()
    if not entities then return end

    local startup = {}
    for setting_name, setting_value in pairs(settings.startup) do
        startup[setting_name] = setting_value.value
    end

    local data = {
        ["mods"] = active_mods,
        ["startup"] = startup,
    }

    if settings.get_player_settings(player)["blueprint-meta-info_spam-mode"].value then
        local e_count = #entities
        for i = 1, e_count do
            bp.set_blueprint_entity_tag(i, "bp_meta_info", data)
        end
    else
        local min_x, max_x, min_y, max_y = math.huge, -math.huge, math.huge, -math.huge

        for _, entity in pairs(entities) do
            local pos = entity.position

            if pos.x < min_x then
                min_x = pos.x
            end

            if pos.x > max_x then
                max_x = pos.x
            end

            if pos.y < min_y then
                min_y = pos.y
            end

            if pos.y > max_y then
                max_y = pos.y
            end
        end

        -- calculate position based on tiles if no entities are present
        local meta_position = { x = 0, y = 0 }
        if #entities == 0 then
            local tiles = bp.get_blueprint_tiles()

            if not tiles then goto continue end

            for _, tile in pairs(tiles) do
                local pos = tile.position

                if pos.x < min_x then
                    min_x = pos.x
                end

                if pos.x > max_x then
                    max_x = pos.x
                end

                if pos.y < min_y then
                    min_y = pos.y
                end

                if pos.y > max_y then
                    max_y = pos.y
                end
            end

            meta_position = {
                x = min_x + (max_x - min_x) / 2,
                y = min_y + (max_y - min_y) / 2
            }

            ::continue::
        else
            meta_position = {
                x = min_x + (max_x - min_x) / 2,
                y = min_y + (max_y - min_y) / 2
            }
        end

        entities[#entities + 1] = {
            name = "blueprint-meta-info",
            position = meta_position,
            entity_number = #entities + 1,
            tags = {
                ["bp_meta_info"] = data,
            },
        }

        bp.set_blueprint_entities(entities)
    end
end)

---@param event
---| EventData.on_built_entity
---| EventData.script_raised_built
---| EventData.on_trigger_created_entity
local function destroy_info_entity(event)
    local entity = event.created_entity or event.entity

    if not entity or not entity.valid then return end
    if not (entity.name == "blueprint-meta-info" or (entity.type == "entity-ghost" and entity.ghost_name == "blueprint-meta-info")) then return end

    entity.destroy()
end

script.on_event(ev.on_built_entity, destroy_info_entity)
script.on_event(ev.script_raised_built, destroy_info_entity)
script.on_event(ev.on_trigger_created_entity, destroy_info_entity)
