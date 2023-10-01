---@type data.SimpleEntityWithOwnerPrototype
local meta_entity = {
    name = "blueprint-meta-info",
    type = "simple-entity-with-owner",

    collision_mask = {},
    collision_box = { { 0, 0 }, { 0, 0 } },

    -- icon = "__core__/graphics/empty.png",
    -- icon_size = 1,
    -- icon_mipmaps = 0,
    picture = {
        filename = "__core__/graphics/empty.png",
        size = 1,
    },

    flags = {
        "hidden",
        "not-on-map",
        "player-creation",
        "placeable-off-grid",
    },

    placeable_by = {
        item = "blueprint-meta-info",
        count = 1,
    },
}

---@type data.ItemPrototype
local meta_item = {
    type = "item",
    name = "blueprint-meta-info",
    stack_size = 1,

    icon = "__base__/graphics/icons/info.png",
    icon_size = 64,
    icon_mipmaps = 4,

    flags = {
        "hidden",
        "only-in-cursor",
    }
}

data:extend({
    meta_entity,
    meta_item,
})
