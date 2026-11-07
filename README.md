# Lean Alchemy

A minimalist alchemy system for Luanti (Minetest Game / Lean Core). 

This mod adds a simple, lag-free way to brew potions using vanilla items. No new plants, no complex machines, no `globalstep` — just a kit, recipes, and useful effects.

## Features

- **10 balanced potions:** Healing, Instant Health, Swiftness, Night Vision, Water Breathing, Fire Resistance, Invisibility, Jumping, Slow Falling, and Resistance.
- **Alchemist's Kit:** A single block where you combine ingredients. Supports batch crafting (e.g., put 30 grass in and get 10 potions).
- **In-game Recipe Book:** Click the "Recipes" button inside the kit to see all combinations without leaving the game.
- **Smart HUD Timers:** Shows active potion effects in the top-right corner. The timer loop completely pauses when no effects are active.
- **Multi-crafting:** Automatically calculates how many potions can be made from the ingredients provided.
- **Vanilla integration:** Uses only items already present in the base game (grass, coal, cactus, gold, ice, etc.).

## How to use

1. Craft the **Alchemist's Kit**:
   ```
   [ Wood ] [ Wood ] [ Wood ]
   [ Wood ] [ Stone] [ Glass]
   ```
2. Place the kit on the ground and right-click it.
3. Put ingredients into the 3 left slots.
4. Click **Brew**. The potion will appear in the right slot.
5. Take the potion and right-click while holding it to drink.

## API

Other mods can register their own potions and recipes:

```lua
-- Register a potion effect
lean_alchemy.register_potion("my_potion", {
    description = "My Custom Potion",
    color = "#ff00ff",
    effect = function(player) 
        -- your code here
    end
})

-- Add a recipe (returns "lean_alchemy:potion_my_potion")
table.insert(lean_alchemy.recipes, {
    input = { "default:dirt", "default:dirt", "default:dirt" },
    output = "lean_alchemy:potion_my_potion"
})
```

## Dependencies

- `default`
- `flowers`

## License

- **Code:** GPL-3.0-only (Copyright (C) 2026 8a7l)
- **Textures/Graphics:** CC-BY-SA-4.0 (Copyright (C) 2026 8a7l)

You are free to use, modify, and distribute this mod under the terms of these licenses.
```

