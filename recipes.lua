-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2026 8a7l

return {
    -- ================= ЗВИЧАЙНІ (Трава, листя) =================
    -- Здоров'я (регенерація): 3 травички (цілющі трави)
    { input = { "default:grass_1", "default:grass_1", "default:grass_1" }, output = "lean_alchemy:potion_health" },
    -- Стрибучість: 2 травички + 1 яблуко (енергія)
    { input = { "default:grass_1", "default:grass_1", "default:apple" }, output = "lean_alchemy:potion_jump_boost" },

    -- ================= СЕРЕДНІ (Папір, скло, лід, кактус) =================
    -- Водне дихання: 3 папіруси (ростуть біля води)
    { input = { "default:papyrus", "default:papyrus", "default:papyrus" }, output = "lean_alchemy:potion_water_breathing" },
    -- Невидимість: 3 скла (прозорість)
    { input = { "default:glass", "default:glass", "default:glass" }, output = "lean_alchemy:potion_invisibility" },
    -- Повільне падіння: 2 листя + 1 папір (легкість)
    { input = { "default:leaves", "default:leaves", "default:paper" }, output = "lean_alchemy:potion_slow_falling" },

    -- ================= РІДКІСНІ (Вугілля, золото, сталь, кактус) =================
    -- Швидкість: 2 кактуси + 1 золотий самородок (небезпечна швидкість)
    { input = { "default:cactus", "default:cactus", "default:gold_lump" }, output = "lean_alchemy:potion_speed" },
    -- Вогнестійкість: 2 вугілля + 1 лід (гаряче і холодне)
    { input = { "default:coal_lump", "default:coal_lump", "default:ice" }, output = "lean_alchemy:potion_fire_resistance" },
    -- Опір: 2 камені + 1 залізний злиток (міцність)
    { input = { "default:stone", "default:stone", "default:steel_ingot" }, output = "lean_alchemy:potion_resistance" },
    -- Миттєве зцілення: 2 яблука + 1 золотий самородок (золоте яблуко)
    { input = { "default:apple", "default:gold_lump", "default:apple" }, output = "lean_alchemy:potion_instant_health" },

    -- ================= МАГІЧНІ (Кристал Месе) =================
    -- Нічний зір: 2 вугілля + 1 кристал месе (магічне світло)
    { input = { "default:coal_lump", "default:coal_lump", "default:mese_crystal" }, output = "lean_alchemy:potion_night_vision" },
}
