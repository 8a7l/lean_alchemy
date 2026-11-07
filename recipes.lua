-- SPDX-License-Identifier: GPL-3.0-only
-- Copyright (C) 2026 8a7l

return {
    -- Нічний зір: 2 вугілля + 1 червоний гриб
    { input = { "default:coal_lump", "default:coal_lump", "flowers:mushroom_red" }, output = "lean_alchemy:potion_night_vision" },
    -- Здоров'я (регенерація): 3 травички
    { input = { "default:grass_1", "default:grass_1", "default:grass_1" }, output = "lean_alchemy:potion_health" },
    -- Швидкість: 2 кактуси + 1 золотий самородок
    { input = { "default:cactus", "default:cactus", "default:gold_lump" }, output = "lean_alchemy:potion_speed" },
    -- Водне дихання: 3 папіруси
    { input = { "default:papyrus", "default:papyrus", "default:papyrus" }, output = "lean_alchemy:potion_water_breathing" },
    -- Вогнестійкість: 2 вугілля + 1 лід
    { input = { "default:coal_lump", "default:coal_lump", "default:ice" }, output = "lean_alchemy:potion_fire_resistance" },
    -- Невидимість: 3 скла
    { input = { "default:glass", "default:glass", "default:glass" }, output = "lean_alchemy:potion_invisibility" },
    -- Стрибучість: 2 травички + 1 яблуко
    { input = { "default:grass_1", "default:grass_1", "default:apple" }, output = "lean_alchemy:potion_jump_boost" },
    -- Повільне падіння: 2 листя + 1 папір
    { input = { "default:leaves", "default:leaves", "default:paper" }, output = "lean_alchemy:potion_slow_falling" },
    -- Миттєве зцілення: 2 яблука + 1 золотий самородок
    { input = { "default:apple", "default:gold_lump", "default:apple" }, output = "lean_alchemy:potion_instant_health" },
    -- Опір: 2 камені + 1 залізний злиток
    { input = { "default:stone", "default:stone", "default:steel_ingot" }, output = "lean_alchemy:potion_resistance" },
}