# SimpleRPG

A small top-down 2D RPG prototype built with Godot 4.7.2. It is the product of a four-week ICT challenge, so the scope is deliberately one player, three slimes, one combat loop and two connected levels.

## Documentation and where to edit

| Document | Role | Location |
| --- | --- | --- |
| `First Uni Project - Documentation` | **Canonical technical reference. Edit this one first.** | Obsidian vault, `~/.obsidian/Obsidian/` |
| `docs/Technical Documentation.md` | Mirror of the canonical note, kept in the repo so the reference travels with the code | this repo |
| `README.md` | This file: run instructions, controls, features, limitations | this repo |

The vault note is the single source of truth for technical detail; the repo copy is a mirror. Change the vault note first, then copy the change across, so the two can never disagree about a scene, a value or a collision layer.

## Requirements

- Godot 4.7.2 (any platform). Built and checked on 4.7.2 stable.
- Nothing else. Godot is the only dependency, and every asset is committed to the repository.

## Running it

1. Open Godot, choose **Import**, and select `simple-rpg/project.godot`.
2. Press **F5**. The main scene is `sceens/world.tscn`, so F5 starts the full level, not the player alone.

You can check that the project loads without opening the editor:

```bash
godot --path simple-rpg --headless --quit-after 60 res://sceens/world.tscn
```

The scene folder is spelled `sceens`. That typo is left in place on purpose, because every hardcoded `res://` path in `world.gd` and `cliff_side.gd` depends on it and renaming it in the last week of the challenge would risk a broken import.

## Controls

| Action | Input |
| --- | --- |
| Move | Arrow keys, gamepad d-pad, or gamepad left stick |
| Attack | `E` |
| Pause and resume | `Escape` |

**WASD is not bound.** Movement uses Godot's built-in `ui_left`, `ui_right`, `ui_up` and `ui_down` actions, which map to the arrow keys and a gamepad. The only custom actions in the project are `attack`, bound to the physical `E` key, and `pause`, bound to the physical `Escape` key. Both are bound by physical keycode, so they follow the key's position rather than the printed layout. Verified against the project's input map.

Movement is four-directional with no diagonals. Holding two directions favours the first one checked, in the order right, left, down, up.

## What the prototype does

- **Player:** 100 HP, 100 px/s, directional idle, walk and attack animations. Left and right share the `side*` animations and flip with `flip_h`.
- **Melee attack:** `E` starts a 0.5 second attack window. While it is open, a slime takes 20 damage when its own `enemyhitbox` reaches the player's body, about 17 px away, gated by 0.5 second i-frames, so five hits kill it. The player's `playerHitbox` does not deal this damage, it tracks which slimes are in contact range.
- **Slimes:** three of them, at `(192, 56)`, `(-120, 40)` and `(60, 110)`. Each one detects the player inside a roughly 65 px `detectionArea` and then chases with `velocity = (player.position - position).normalized() * 60` and `move_and_slide()`, so chase speed does not depend on distance and slimes stop at walls.
- **Taking damage:** contact with a slime removes 15 HP, gated by a 0.7 second cooldown. The player regenerates 15 HP every 3 seconds.
- **Health bars:** the player and each slime have a `ProgressBar` above them that hides at full health, plus a 1.0 second `deathTimer` that keeps the bar off a dying body.
- **HUD:** one scene, `hud.tscn`, instanced by both levels: a `CanvasLayer` at layer 10 with a `Label` showing `HP: <number>`. The layer writes the first value in `_ready()` and reads the live player health every frame after that, so there is one implementation of the text and a level that is built while the game is paused still shows it. It is pausable, so the number freezes with the world.
- **Pause:** `Escape` sets `get_tree().paused`, which freezes both levels. One scene, `pause.tscn`, is instanced by both levels: a `CanvasLayer` at layer 20 with `process_mode = Always` and a single label reading `PAUSED` over `Press Escape to resume`. The layer stays awake on both sides of the pause, so the same key resumes.
- **Death:** the player plays its `dead` animation, stops accepting input, and reloads the level after 1.0 second. A slime plays its `death` animation, stops chasing and stops dealing damage immediately, then frees itself after 1.0 second.
- **Two connected levels:** `world.tscn` and `cliff_side.tscn`, connected in both directions by an `Area2D` each. The spawn position and the transition flag live in the `global` autoload.
- **Dust:** the player kicks up dust while walking and stops when standing still or dead. It is a `GPUParticles2D` at the feet, emitting in world space so the trail stays behind instead of following the body. Cosmetic only, with no effect on movement or collision.
- **Sorting and collision:** `y_sort_enabled` on both level roots and both `Props` layers. The tilemaps are `ground`, `mountains` and `Props`, with a hand-drawn `CollisionPolygon2D` for the level boundary.

## Gameplay numbers

**Canonical values:** the technical note `First Uni Project - Documentation`, mirrored in this repo at `docs/Technical Documentation.md`. Edit there first. The table below is a view of those numbers, not their source.

| Value | Where | Number |
| --- | --- | --- |
| Player speed | `player.gd` `const speed` | 100 px/s |
| Player max health | `player.gd` | 100 |
| Contact damage to the player | `player.gd` `enemyAttack()` | 15 |
| Player damage cooldown | `attackCooldown` timer | 0.7 s |
| Player regeneration | `regenTimer` | 15 HP every 3 s |
| Attack window | `dealAttackTimer` | 0.5 s |
| Damage per valid swing | `enemy.gd` `dealWithDamage()` | 20 |
| Slime max health | `enemy.gd` | 100 |
| Slime damage cooldown | `takeDamageCooldown` timer | 0.5 s |
| Slime chase speed | `enemy.gd` `var speed` | 60 px/s |
| Slime detection radius | `detectionArea` shape | 65.03 px |
| Death animation timer | player and slime `deathTimer` | 1.0 s |
| Camera | player `Camera2D` | zoom 4x, limits -192/-80/288/192 |

## Project structure

```
GodotFirstProject/            repo root (.gitignore, .gitattributes, README)
├── docs/
│   └── Technical Documentation.md   scene structure, collision, engine settings, combat flow
└── simple-rpg/               the Godot 4.7.2 project
    ├── project.godot         engine config, autoload, input map, main scene
    ├── addons/godot-git-plugin/
    ├── scripts/
    │   ├── player.gd         input, movement, animation, attack, damage, regen, death, dust
    │   └── global.gd         autoload: attack flag, transition state, spawn positions
    ├── sceens/               scenes (spelling kept on purpose)
    │   ├── world.tscn        level 1: tilemaps, three slimes, player, HUD, pause, transition area
    │   ├── cliff_side.tscn   level 2: tilemaps, player, HUD, pause, exit area
    │   ├── player.tscn       player body, sprite, dust particles, hitbox, timers, camera
    │   ├── enemy.tscn        slime body, sprite, hitbox, detection area, timers
    │   ├── hud.tscn          HUD layer: one label, instanced by both levels
    │   ├── pause.tscn        pause layer: one label, instanced by both levels
    │   ├── world.gd          spawn placement, scene switch
    │   ├── cliff_side.gd     scene switch
    │   ├── hud.gd            HUD text, one implementation for both levels, reads the level's `player` sibling
    │   ├── pause.gd          Escape toggles get_tree().paused
    │   └── enemy.gd          detection, chase, damage, death
    └── sprites/
        ├── characters/       player.png (48x48 grid), slime.png (32x32 grid), README.txt
        ├── tilesets/         plains, grass, walls, floors
        ├── objects/          objects.png with collision polygons
        └── particles/        dust_particles_01.png (48x12, 4 frames, used by the player)
```

`simple-rpg/sprites/characters/README.txt` documents the sprite grid and the animation row layout, so it is not repeated here.

## Known limitations

- **WASD is not bound.** Arrow keys or a gamepad only.
- No sound, no save system, no start menu. Pausing exists, but the pause layer only stops the game: there are no options, no restart and no menu to reach from it.
- Damage does not scale with the number of slimes. Three slimes deal the same 15 damage on the same 0.7 second cooldown as one, so a pile is not more dangerous, only harder to walk away from.
- A chasing slime can push the player around, because there is no knockback resistance.
- The player's body collider is a 4 px circle against 16 px tiles, so the character overlaps the base of a prop slightly before being stopped.
- The slime `death` animation is five frames at 5 fps and loops, so it runs exactly as long as the 1.0 second `deathTimer`. A frame hitch could clip or repeat the last frame.
- `VisibleOnScreenNotifier2D` is not used. Slimes keep chasing while the player is inside their detection radius even if the slime is off camera.
- Git LFS rules are declared in `.gitattributes`, but no file is actually tracked by LFS yet.
- Naming that was left alone on purpose: folder `sceens`, node `colisions`, animations `frontAtack`, `backAtack`, `sideAtack`, variable `attackIP`.

## Credits

Built while following [DevWorm's RPG from scratch series](https://www.youtube.com/@dev-worm). Extra lessons from the journal ([[Project Planning]] / [Videos GODOT list](Videos%20GODOT%20list.md) in the vault): [Smooth Pathfinding](https://www.youtube.com/watch?v=Zy9Ra5zHOsY) (`NavigationAgent2D`), [Save & Load](https://www.youtube.com/watch?v=_DP5QLJxVVI) (`FileAccess`/`ResourceSaver`), [7 Greatest Tips](https://www.youtube.com/watch?v=7aNTmYRjVT8), [Inventory (step by step)](https://www.youtube.com/watch?v=X3J0fSodKgs) and [Collectables](https://www.youtube.com/watch?v=B91iuXU3AZ0). The Godot project-setup, Git workflow and spawner/METSYS videos are also listed in the portfolio sources section. Engine: [Godot](https://godotengine.org).
