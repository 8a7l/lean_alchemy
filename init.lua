-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2026 8a7l

local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)

local after = minetest.after
local chat_send = minetest.chat_send_player

-- ============================================================
-- СИСТЕМА УПРАВЛІННЯ ЕФЕКТАМИ ТА HUD
-- ============================================================
lean_alchemy = {}
lean_alchemy.recipes = dofile(minetest.get_modpath(modname) .. "/recipes.lua")

local active_effects = {}
local hud_timer_running = false

local function revert_effect(player, effect_name)
    if not player or not player:is_player() then return end
    if effect_name == "speed" then player:set_physics_override({ speed = 1.0 })
    elseif effect_name == "night_vision" then player:override_day_night_ratio(nil)
    elseif effect_name == "fire_resistance" then player:get_meta():set_int("lean_alchemy_fire_resist", 0)
    elseif effect_name == "invisibility" then player:set_properties({ visual_size = { x = 1, y = 1, z = 1 } })
    elseif effect_name == "jump_boost" then player:set_physics_override({ jump = 1.0 })
    elseif effect_name == "slow_falling" then player:set_physics_override({ gravity = 1.0 })
    elseif effect_name == "resistance" then player:get_meta():set_int("lean_alchemy_resist", 0)
    end
end

local function update_hud_loop()
    local global_any_active = false
    for p_name, player_data in pairs(active_effects) do
        local player = minetest.get_player_by_name(p_name)
        if player then
            local hud_text = ""
            local to_remove = {}
            for effect_name, data in pairs(player_data.effects) do
                data.time_left = data.time_left - 1
                if data.time_left <= 0 then table.insert(to_remove, effect_name)
                else
                    global_any_active = true
                    local display_name = effect_name:gsub("_", " "):gsub("^%l", string.upper)
                    hud_text = hud_text .. display_name .. ": " .. data.time_left .. "s\n"
                end
            end
            for _, effect_name in ipairs(to_remove) do
                revert_effect(player, effect_name)
                player_data.effects[effect_name] = nil
            end
            if hud_text ~= "" then
                if player_data.hud_id then player:hud_change(player_data.hud_id, "text", hud_text)
                else player_data.hud_id = player:hud_add({ hud_elem_type = "text", position = {x = 0.98, y = 0.05}, alignment = {x = -1, y = 1}, text = hud_text, number = 0xFFFFFF, scale = {x = 100, y = 100} })
                end
            else
                if player_data.hud_id then player:hud_remove(player_data.hud_id); player_data.hud_id = nil end
            end
        else active_effects[p_name] = nil end
    end
    if global_any_active then after(1, update_hud_loop) else hud_timer_running = false end
end

local function add_effect(player, effect_name, duration)
    if not player or not player:is_player() then return end
    local p_name = player:get_player_name()
    if not active_effects[p_name] then active_effects[p_name] = { effects = {}, hud_id = nil } end
    active_effects[p_name].effects[effect_name] = { time_left = duration }
    if not hud_timer_running then hud_timer_running = true; after(0, update_hud_loop) end
end

-- ============================================================
-- ЕФЕКТИ ЗІЛЬ
-- ============================================================
function lean_alchemy.apply_health(player)
    local ticks = 5
    local function regen()
        if not player or not player:is_player() then return end
        if player:get_hp() > 0 then player:set_hp(math.min(player:get_hp() + 1, 20)) end
        ticks = ticks - 1
        if ticks > 0 then after(2, regen) end
    end
    after(1, regen)
end

function lean_alchemy.apply_instant_health(player)
    if player and player:is_player() then player:set_hp(math.min(player:get_hp() + 10, 20)) end
end
function lean_alchemy.apply_speed(player) player:set_physics_override({ speed = 1.5 }); add_effect(player, "speed", 15) end
function lean_alchemy.apply_night_vision(player) player:override_day_night_ratio(1.0); add_effect(player, "night_vision", 30) end

function lean_alchemy.apply_water_breathing(player)
    local p_name = player:get_player_name()
    add_effect(player, "water_breathing", 30)
    local function loop()
        if not player or not player:is_player() then return end
        local data = active_effects[p_name]
        if not data or not data.effects["water_breathing"] then return end
        player:set_breath(11)
        after(1, loop)
    end
    loop()
end

function lean_alchemy.apply_fire_resistance(player) player:get_meta():set_int("lean_alchemy_fire_resist", 1); add_effect(player, "fire_resistance", 15) end
function lean_alchemy.apply_invisibility(player) player:set_properties({ visual_size = { x = 0.01, y = 0.01, z = 0.01 } }); add_effect(player, "invisibility", 15) end
function lean_alchemy.apply_jump_boost(player) player:set_physics_override({ jump = 1.5 }); add_effect(player, "jump_boost", 20) end
function lean_alchemy.apply_slow_falling(player) player:set_physics_override({ gravity = 0.3 }); add_effect(player, "slow_falling", 20) end
function lean_alchemy.apply_resistance(player) player:get_meta():set_int("lean_alchemy_resist", 1); add_effect(player, "resistance", 20) end

minetest.register_on_player_hpchange(function(player, hp_change, reason)
    if hp_change < 0 then
        if player:get_meta():get_int("lean_alchemy_fire_resist") == 1 then
            local is_fire = false
            if reason and reason.node and (reason.node:find("lava") or reason.node:find("fire")) then is_fire = true
            elseif reason and reason.type == "node" then
                local pos = player:get_pos()
                local feet = minetest.get_node(pos).name
                local head = minetest.get_node({x=pos.x, y=pos.y+1, z=pos.z}).name
                if feet:find("lava") or feet:find("fire") or head:find("lava") or head:find("fire") then is_fire = true end
            end
            if is_fire then return 0 end
        end
        if player:get_meta():get_int("lean_alchemy_resist") == 1 then return math.floor(hp_change * 0.5) end
    end
    return hp_change
end, true)

minetest.register_on_leaveplayer(function(player)
    local p_name = player:get_player_name()
    if active_effects[p_name] then
        for effect_name, _ in pairs(active_effects[p_name].effects) do revert_effect(player, effect_name) end
        active_effects[p_name] = nil
    end
end)

-- ============================================================
-- РЕЄСТРАЦІЯ ПЛЯШЕЧОК
-- ============================================================
local function register_potion(name, def)
    minetest.register_craftitem("lean_alchemy:potion_" .. name, {
        description = def.description,
        inventory_image = "lean_alchemy_potion.png^[makealpha:0,0,0^[colorize:" .. def.color .. ":150",
        stack_max = 10,
        on_use = function(itemstack, user, pointed_thing)
            if not user or not user:is_player() then return end
            def.effect(user)
            itemstack:take_item()
            return itemstack
        end,
    })
end

register_potion("health", { description = S("Healing Potion"), color = "#ff0000", effect = lean_alchemy.apply_health })
register_potion("instant_health", { description = S("Potion of Instant Health"), color = "#ff5555", effect = lean_alchemy.apply_instant_health })
register_potion("speed", { description = S("Potion of Swiftness"), color = "#00ff00", effect = lean_alchemy.apply_speed })
register_potion("night_vision", { description = S("Potion of Night Vision"), color = "#0000ff", effect = lean_alchemy.apply_night_vision })
register_potion("water_breathing", { description = S("Potion of Water Breathing"), color = "#00ffff", effect = lean_alchemy.apply_water_breathing })
register_potion("fire_resistance", { description = S("Potion of Fire Resistance"), color = "#ff8800", effect = lean_alchemy.apply_fire_resistance })
register_potion("invisibility", { description = S("Potion of Invisibility"), color = "#ffffff", effect = lean_alchemy.apply_invisibility })
register_potion("jump_boost", { description = S("Potion of Jumping"), color = "#88ff00", effect = lean_alchemy.apply_jump_boost })
register_potion("slow_falling", { description = S("Potion of Slow Falling"), color = "#dddddd", effect = lean_alchemy.apply_slow_falling })
register_potion("resistance", { description = S("Potion of Resistance"), color = "#888888", effect = lean_alchemy.apply_resistance })

-- ============================================================
-- НАБІР АЛХІМІКА ТА КНИГА РЕЦЕПТІВ
-- ============================================================

local function build_recipe_string()
    local lines = {}
    for _, r in ipairs(lean_alchemy.recipes) do
        local out_desc = minetest.registered_items[r.output] and minetest.registered_items[r.output].description or r.output
        local ins = {}
        for _, item in ipairs(r.input) do
            local desc = minetest.registered_items[item] and minetest.registered_items[item].description or item
            table.insert(ins, desc)
        end
        local final_str = out_desc .. " = " .. table.concat(ins, " + ")
        local clean_str = (final_str:gsub(",", ";")) 
        table.insert(lines, clean_str)
    end
    return table.concat(lines, ",")
end

local recipe_formspec = 
    "size[10,7]" ..
    "label[0.5,0.5;Alchemy Recipes]" ..
    "textlist[0.5,1;9,5.5;recipes;" .. build_recipe_string() .. ";0;]" ..
    "button[4,6.5;2,0.8;close;Close]"

local formspec = 
    "size[8,6]" ..
    "label[0,0;Alchemist's Kit]" ..
    "list[current_name;input;1,1;3,1;]" ..
    "label[4.5,1.2;→]" ..
    "list[current_name;output;5.5,1;1,1;]" ..
    "button[3,2.5;2,1;brew;Brew]" ..
    "button[6,2.5;1.5,1;view_recipes;Recipes]" ..
    "list[current_player;main;0,3.5;8,4;]"

minetest.register_node("lean_alchemy:kit", {
    description = S("Alchemist's Kit"),
    tiles = {
        "lean_alchemy_kit_top.png", "lean_alchemy_kit_bottom.png",
        "lean_alchemy_kit_right.png", "lean_alchemy_kit_right.png", 
        "lean_alchemy_kit_right.png", "lean_alchemy_kit_front.png",
    },
    groups = { choppy = 2, oddly_breakable_by_hand = 2 },
    paramtype2 = "facedir",
    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("formspec", formspec)
        meta:set_string("infotext", "Alchemist's Kit")
        local inv = meta:get_inventory()
        inv:set_size("input", 3)
        inv:set_size("output", 1)
    end,
    on_receive_fields = function(pos, formname, fields, sender)
        local p_name = sender:get_player_name()
        
        if fields.view_recipes then
            minetest.show_formspec(p_name, "lean_alchemy:recipes", recipe_formspec)
            return
        end

        if not fields.brew then return end
        local inv = minetest.get_meta(pos):get_inventory()
        
        local input_counts = {}
        for i = 1, 3 do
            local stack = inv:get_stack("input", i)
            if not stack:is_empty() then
                local name = stack:get_name()
                input_counts[name] = (input_counts[name] or 0) + stack:get_count()
            end
        end

        local matched, max_batches = nil, 0
        for _, r in ipairs(lean_alchemy.recipes) do
            local req = {}
            for _, item in ipairs(r.input) do req[item] = (req[item] or 0) + 1 end
            local possible = nil
            for item, count in pairs(req) do
                if count and count > 0 then
                    local can = math.floor((input_counts[item] or 0) / count)
                    if possible == nil or can < possible then possible = can end
                end
            end
            if possible and possible > 0 then matched, max_batches = r, possible break end
        end

        if not matched then return chat_send(p_name, "Invalid recipe.") end
        
        -- Перевірка, чи існує предмет взагалі
        if not minetest.registered_items[matched.output] then
            return chat_send(p_name, "Error: Invalid output item in recipe.")
        end

        local out = inv:get_stack("output", 1)
        if not out:is_empty() then
            if out:get_name() ~= matched.output then return chat_send(p_name, "Output full.") end
            max_batches = math.min(max_batches, (out:get_stack_max() or 99) - out:get_count())
        else
            max_batches = math.min(max_batches, ItemStack(matched.output):get_stack_max() or 99)
        end

        if max_batches <= 0 then return chat_send(p_name, "Output full.") end

        local to_remove = {}
        for _, item in ipairs(matched.input) do 
            to_remove[item] = (to_remove[item] or 0) + max_batches 
        end
        
        for i = 1, 3 do
            local stack = inv:get_stack("input", i)
            if not stack:is_empty() then
                local name = stack:get_name()
                local to_rm = to_remove[name]
                -- БЕЗПЕЧНА ПЕРЕВІРКА: чи є цей предмет у списку на видалення і чи його кількість > 0
                if to_rm and to_rm > 0 then
                    local rm = math.min(stack:get_count(), to_rm)
                    stack:set_count(stack:get_count() - rm)
                    to_remove[name] = to_rm - rm
                    inv:set_stack("input", i, stack)
                end
            end
        end

        local res = ItemStack(matched.output)
        res:set_count(max_batches)
        if out:is_empty() then inv:set_stack("output", 1, res) else out:set_count(out:get_count() + max_batches); inv:set_stack("output", 1, out) end
        chat_send(p_name, "Brewed " .. max_batches .. " item(s).")
    end,
    allow_metadata_inventory_put = function(pos, list, idx, stack) if list == "output" then return 0 end return stack:get_count() end,
    allow_metadata_inventory_take = function(pos, list, idx, stack) return stack:get_count() end,
    allow_metadata_inventory_move = function(pos, fl, fi, tl, ti, count) if tl == "output" then return 0 end return count end,
})

minetest.register_on_player_receive_fields(function(player, formname, fields)
    if formname == "lean_alchemy:recipes" and fields.close then
        minetest.close_formspec(player:get_player_name(), formname)
    end
end)

minetest.register_craft({
    output = "lean_alchemy:kit",
    recipe = {
        {"default:wood", "default:wood", "default:wood"},
        {"default:wood", "default:stone", "default:glass"},
        {"", "", ""},
    }
})