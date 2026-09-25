# SimpleRPG: Technical Documentation

> **This file is a mirror.** The canonical copy is the Obsidian note `First Uni Project - Documentation` at `~/.obsidian/Obsidian/First Uni Project - Documentation.md`, which the portfolio document links to twice. Edit the vault note first, then mirror the change here, so the two can never disagree. One deliberate difference: the note on tile collision alignment lives only in the vault note.

## Overview

**SimpleRPG** is a top-down 2D RPG prototype built with **Godot 4.7.2** (Forward+ renderer). It was my first real game development project, built while following [DevWorm's RPG tutorial series](https://www.youtube.com/@dev-worm) and adapting what I learned.

The playable slice contains:

- a player character with four-directional movement and directional idle, walk and attack animations
- a melee attack on `E` with an attack window, hitbox-based damage and cooldowns
- three slime enemies that idle, detect the player, chase, deal contact damage and die
- two tilemap levels, a field and a cliff side, connected in both directions
- health and regeneration, an on-screen health bar per character, and a HUD label showing current HP
- a pause layer on `Escape`, and dust particles at the player's feet while walking

## Requirements

- [Godot 4.7.2](https://godotengine.org/download) (any platform)
- The repository cloned with git:

```bash
git clone <repo-url>
cd GodotFirstProject
```

## Running the game

1. Open Godot → **Import** → select `simple-rpg/project.godot`
2. Press **F5** to run the project

> [!note] Main scene
> `run/main_scene` is **`sceens/world.tscn`**, so F5 starts the full level. An earlier version of this note said the main scene was `player.tscn` and that the level had to be started with F6. That was corrected after checking `project.godot`.

## Controls

| Action | Input |
| --- | --- |
| Move | Arrow keys, gamepad d-pad, gamepad left stick |
| Attack | `E` (custom `attack` action, physical keycode 69) |
| Pause and resume | `Escape` (custom `pause` action, physical keycode 4194305) |

Movement uses Godot's built-in `ui_left`, `ui_right`, `ui_up` and `ui_down` actions. **WASD is not bound** to them, which I confirmed by reading the project's input map rather than assuming it.

`attack` and `pause` are the only custom actions. Both are bound by physical keycode, so they follow the key's position on the keyboard rather than the character printed on the layout.

## Gameplay systems

### Player: `sceens/player.tscn` + `scripts/player.gd`

`CharacterBody2D` with an `AnimatedSprite2D`, a small circular body collision, a `playerHitbox` `Area2D` that detects enemies, and four timers.

- **Health:** 100 HP in `health`, regenerating 15 HP every 3 seconds while below 100. At 0 the player dies.
- **Movement:** constant `speed = 100`, direction taken from the `ui_*` actions; `velocity` is set per axis and applied with `move_and_slide()`. Four-directional, no diagonals.
- **Animation:** one animation per facing and state (`frontIdle`, `frontWalk`, `backIdle`, `backWalk`, `sideIdle`, `sideWalk`) selected in `playAnimation()`. Left and right share the `side*` animations, flipped with `flip_h`, never with `scale.x * -1` (see [[#Lessons learned]]).
- **Attacking:** pressing `E` plays the facing attack animation (`frontAtack`, `sideAtack`, `backAtack`), starts the `dealAttackTimer` (0.5 s) and sets `global.playerCurrentAttack = true`. While that flag is up, any enemy whose own `enemyhitbox` is overlapping the player's body takes damage. `currentDirection` starts as `"down"`, so the first attack from a standing start always has a valid animation.
- **Taking damage:** `enemyAttack()` subtracts **15 HP** when at least one enemy is inside `playerHitbox`, gated by the `attackCooldown` timer (0.7 s).
- **Who is in range:** `enemiesInRange` is an array of the enemies currently overlapping the hitbox, added on `body_entered` and erased on `body_exited`. Every physics frame it is filtered with `is_instance_valid`, so a slime freed while overlapping cannot leave damage stuck on, and `enemyAttack()` reads the array directly instead of a cached flag. This replaced a single bool that could not tell one slime from three.
- **Dying:** `playerDie()` sets `playerAlive = false` (stopping input and damage), plays the `dead` animation and starts the `deathTimer` (1.0 s). Its timeout calls `global.resetGame()` and reloads the level, so death returns to a playable world at the start position.
- **Dust:** `dustParticles`, a `GPUParticles2D` at the player's feet, emits while `get_real_velocity()` is not zero and the player is alive, so it stops when the player stands still, is blocked by a wall, or dies. The particles are emitted in world space (`local_coords = false`), so the trail stays where the player left it instead of dragging along with the body.

### Enemy (Slime): `sceens/enemy.tscn` + `sceens/enemy.gd`

`CharacterBody2D` with an `AnimatedSprite2D`, a body collision, an `enemyhitbox` `Area2D` that receives the player's attacks, a large `detectionArea` `Area2D` (radius about 65 px), and two timers. `world.tscn` holds three instances, at `(192, 56)`, `(-120, 40)` and `(60, 110)`.

- **AI:** idles until the player enters `detectionArea` → `playerChase = true` and the player reference is stored. While chasing it plays `walk`, sets `velocity = (player.position - position).normalized() * speed` with `speed = 60`, and calls `move_and_slide()`. So the slime keeps a constant 60 px/s at any distance and stops at walls instead of passing through them. Facing flips with `flip_h`.
- **Detection guard:** the enter and exit handlers check `body.has_method("player")`, like every other area handler in the project.
- **Health:** 100 HP. If the player is inside `enemyhitbox` while `global.playerCurrentAttack` is true, it takes **20 damage** per swing, gated by `takeDamageCooldown` (0.5 s i-frames). Health is clamped at 0.
- **Dying:** at 0 HP, `slimeDie()` sets `slimeAlive = false` so chasing and damage stop, disables the body collider, hides the health bar, plays the `death` animation and starts the `deathTimer` (1.0 s). Its timeout calls `queue_free()`. The slime now dies visibly instead of vanishing, and it stops hurting the player the moment it dies.

### Global state: `scripts/global.gd` (autoload)

Registered in Project Settings → Autoload as `global`. It holds the state shared between scenes:

```gdscript
var playerCurrentAttack = false
var currentScene = "world"
var transitionScene = false
var playerExitCliffSide_posX = 280.0
var playerExitCliffSide_posY = 38.0
var playerStart_posX = 0
var playerStart_posY = 0
var gameFirstLoading = true
```

`playerCurrentAttack` is how an enemy knows a swing is active without the two scenes referencing each other. The rest is scene transition state: `currentScene` and `transitionScene` track the loaded level and a pending transition, `finishChangingScenes()` flips them, and `resetGame()` returns them to the world on death so the player does not spawn at a stale transition position.

### HUD

Both levels instance `sceens/hud.tscn`: a `CanvasLayer` named `Hud` at **layer 10** containing one `Label` named `HealthLabel`, with a black outline so the text stays readable over light grass. The layer sits beside the level's `player`, finds it by name and owns the text, so the format exists in one file and neither level script mentions the HUD:

```gdscript
func _ready():
	updateHealth()

func _process(delta: float) -> void:
	updateHealth()

func updateHealth():
	$HealthLabel.text = "HP: "+str(get_parent().get_node("player").health)
```

`_ready()` writes the first value through the same function. That matters in one case: a level created while the tree is already paused never gets a `_process` call until the player resumes, so without it the label would arrive blank and stay blank for as long as the pause lasts.

The label was missing from `cliff_side.tscn` at first, so HP was only readable in the field. Both levels have it now.

### Pause

Both levels instance `sceens/pause.tscn`: a `CanvasLayer` named `Pause` at **layer 20** holding one `Label` named `PauseLabel`. That label carries both lines, `PAUSED` and `Press Escape to resume`, at 26 px, so the whole overlay is one node in one file. The layer carries `sceens/pause.gd`, which toggles `get_tree().paused` on the `pause` action and shows the layer while the tree is paused:

```gdscript
func togglePause():
	var paused = not get_tree().paused
	get_tree().paused = paused
	visible = paused
```

The layer's `process_mode` is **Always**, not `When Paused` as the layer plan in the journal suggests. One node has to hear the action in both directions: while the game is running, to pause it, and while it is paused, to resume it. A `When Paused` node is asleep exactly when the first press happens, so a second always-on node would be needed just to start the pause. Setting this one layer to Always keeps the whole feature in one place. The HUD layer stays pausable, so HP freezes with the world.

`_ready()` sets `visible` from `get_tree().paused` rather than hiding the layer unconditionally. Same reason as the HUD label above: a level created while the tree is already paused has to show the overlay immediately, because its `_process` never runs and no key press is coming. This is reachable in play: pausing on the frame a transition is pending lets the transition go through, so the next level is built while the tree is paused.

### Combat flow at a glance

```text
Player presses E ──▶ global.playerCurrentAttack = true (0.5 s window)
                          │
Enemy's enemyhitbox on the ▼
player's body (Area2D) ──▶ health -= 20 (0.5 s i-frames) ──▶ health <= 0 ──▶ death anim ──▶ queue_free()

Enemy body touches playerHitbox ──▶ player health -= 15 (0.7 s cooldown)
                                          │
                     health <= 0 ──▶ dead anim ──▶ global.resetGame() ──▶ reload the level
```

## Project structure

```text
GodotFirstProject/            # git repo root (.gitattributes with LFS rules, .gitignore)
├── README.md                 # how to run, controls, features, limitations
├── IMPLEMENTATION_PLAN.md    # analysis and the remaining work
├── docs/
│   └── Technical Documentation.md
└── simple-rpg/               # Godot 4.7.2 project
    ├── project.godot         # engine config, autoload, input map, main scene
    ├── icon.svg
    ├── scripts/
    │   ├── player.gd         # movement, animation, combat, damage, regen, death
    │   ├── global.gd         # autoload singleton
    │   └── *.uid
    ├── sceens/               # scenes *(sic)* plus enemy.gd
    │   ├── world.tscn        # level 1
    │   ├── cliff_side.tscn   # level 2
    │   ├── player.tscn
    │   ├── enemy.tscn
    │   ├── hud.tscn          # the HUD layer, instanced by both levels
    │   ├── pause.tscn        # the pause layer, instanced by both levels
    │   └── world.gd / cliff_side.gd / enemy.gd / hud.gd / pause.gd
    └── sprites/
        ├── characters/       # player.png (48×48 frames), slime.png (32×32), README.txt
        ├── tilesets/         # plains.png, grass.png, walls/, floors/
        ├── objects/          # objects.png, props with collision polygons
        └── particles/        # dust_particles_01.png (48×12, 4 frames, used by the player)
```

## Scenes & nodes

### `world.tscn` — the field level

| Node | Type | Purpose |
| --- | --- | --- |
| `world` | `Node2D` (y-sorted) | Root; y-sort keeps props and entities layered correctly |
| `ground`, `mountains`, `Props` | `TileMapLayer` | Terrain, border rocks, decorative props. Props are multi-tile sprites with collision polygons and y-sort origins |
| `enemy`, `enemy2`, `enemy3` | instances of `enemy.tscn` | The three slimes |
| `player` | instance of `player.tscn` | Spawns at the start position, or at the cliff side exit position when returning |
| `colisions` | `StaticBody2D` + `CollisionPolygon2D` | Hand-drawn level boundary |
| `CliffSideTransition` | `Area2D` (30×42 at `(304, 38)`) | Switches to the cliff side level |
| `Hud` / `HealthLabel` | instance of `hud.tscn`: `CanvasLayer` (layer 10) + one `Label` | Shows `HP: <number>` |
| `Pause` / `PauseLabel` | instance of `pause.tscn`: `CanvasLayer` (layer 20, `process_mode` Always) + one `Label` | Freezes the tree on `Escape` and says how to resume |

All three tile layers share one `TileSet` with a physics layer for collisions. An earlier version also had a root-level `Camera2D` beside the player's; it was unused and has been removed.

### `player.tscn`

- `AnimatedSprite2D` — `SpriteFrames` from `player.png` atlas regions (48×48), `offset = (0, -15)`
- `CollisionShape2D` — circle radius 4 at `(1, -2)`
- `playerHitbox` (`Area2D`) — radius ~17 at `(0, -7)`, wired to the enter and exit handlers
- `attackCooldown` (`Timer`, 0.7 s) — incoming damage cooldown
- `dealAttackTimer` (`Timer`, 0.5 s) — active attack window
- `regenTimer` (`Timer`, 3.0 s, autostart) — restores 15 HP when not at full health
- `deathTimer` (`Timer`, 1.0 s) — starts on death, reloads the level
- `Camera2D` — zoom 4×, limits `-192 / -80 / 288 / 192`, drag on both axes
- `healthBar` (`ProgressBar`) — scale 0.1, hidden at full health
- `dustParticles` (`GPUParticles2D`) — at `(0, 2)`, 8 particles, 0.35 s lifetime, a `CanvasItemMaterial` with `particles_animation = true` over `dust_particles_01.png` (48×12 sheet → 4×12×12 frames), world-space emission, driven by `updateDust()` in `player.gd` using `get_real_velocity()`

### `enemy.tscn`

- `AnimatedSprite2D` — `idle`, `walk`, `death` from `slime.png` (32×32), `offset = (0, -4)`
- `CollisionShape2D` — circle radius 8 at `(0, -3)`, disabled by `slimeDie()`
- `enemyhitbox` (`Area2D`) — radius ~13, reports `playerAttackZone` while the player is inside
- `detectionArea` (`Area2D`, layer/mask 2) — radius ~65, the chase trigger
- `takeDamageCooldown` (`Timer`, 0.5 s) — damage i-frames
- `deathTimer` (`Timer`, 1.0 s) — frees the node after the death animation
- `healthBar` (`ProgressBar`) — scale 0.15, hidden at full health and on death

### `cliff_side.tscn` — the second level

Root `CliffSide` (`Node2D`, y-sorted), the same three tile layers, a player instance, a `CliffSideExit` `Area2D` at `(-208, 39)`, a `colisions` body, and the `Hud` and `Pause` layers. There is no enemy on this level, so death can only happen in `world.tscn`.

## Collision & signals

- The **player body** sits on collision layers 1–2 (`collision_layer = 3`) and its mask is layer 1, which is what the tilemaps and the boundary polygon use. The enemy's `detectionArea` watches layer 2, which is how it "sees" the player.
- Cross-node checks use duck typing: `body.has_method("enemy")` / `body.has_method("player")`. Each scene exposes a matching empty method (`func player(): pass` / `func enemy(): pass`). It is fragile, and groups or collision layers would be cleaner, but it is consistent across the project.
- All signals are connected in the editor (see the `[connection]` blocks in the `.tscn` files) rather than in code.
- All node access is a direct path such as `$AnimatedSprite2D` or `$healthBar`. The project has no `@onready` and no `@export` variables.

### A note on tile collision alignment

While checking the level I mapped every cell the player cannot stand in and compared it with the tile each layer draws there. The rocks, the props and the boundary polygon all block exactly where their art is. The props are 3×4 tile (48×64 px) sprites, so their collision polygon sits at the trunk base, one or two cells below the cell the tile is anchored to, which is correct for a tall tree. No invisible walls were found inside the playable field.

## Key values and settings (`project.godot` plus the scenes)

| Setting | Value | Why |
| --- | --- | --- |
| Renderer | Forward Plus | Godot 4.7 default; the game is 2D only |
| Stretch mode / aspect | `canvas_items` / `expand` | Pixel-art friendly scaling. **No stretch scale is set** |
| Camera zoom | 4×, on the player's `Camera2D` | The chunky pixels come from this, not from a project stretch setting |
| Default texture filter | Nearest | Keeps pixel art crisp (no blur) |
| Autoload | `global` | Shared combat and transition state |
| Main scene | `sceens/world.tscn` | F5 runs the full level |
| Input map | `attack` on physical `E`, `pause` on physical `Escape`; movement is Godot's built-in `ui_*` | |
| Physics engine (3D) | Jolt | Project default; unused by this 2D gameplay |
| Slime detection radius | 65.03 px, the `detectionArea` circle on `enemy.tscn` | The chase trigger. The `enemy.tscn` list above rounds this to about 65 px |
| Contact damage against regeneration | 15 HP per 0.7 s, about 21 HP/s while in contact, against 15 HP per 3 s, 5 HP/s | Regeneration is relief rather than safety, about four times slower than staying in contact |
| Player speed in tiles | 100 px/s at the 16 px tile size, so 6.25 tiles per second | The Game Doc's prototype table rounds this to about 6 tiles per second |
| Attack reach | 17.04 px, about 1.06 tiles: the enemy's 13.04 px hitbox plus the player's 4 px body radius | This is how close the slime has to be for a swing to land. The 0.5 s window separately lets the player cover 50 px, 3.13 tiles, which is where the prototype table's earlier "about 3 tiles of reach" figure came from |

## Development background

The project started as a smart-home idea, but the heavy hardware and electrical-engineering focus did not match my software interests. After researching alternatives I found **Godot**, which was simple and beginner-friendly, and committed to building an RPG guided by [DevWorm's RPG-from-scratch series](https://www.youtube.com/@dev-worm). The full journal is in [[Project Planning]].

## Lessons learned

- **`offset` vs `position`:** `offset` moves the node's rendering; `position` moves the node *and its children*.
- **Flip with `flip_h`,** never `scale.x * -1` — negative scale breaks physics, child nodes and collision shapes.
- **Watch `preload`:** preloading everything eagerly can overload memory; load heavy assets when needed.
- **`VisibleOnScreenNotifier2D`:** an enemy that chases rather than being spawned on level load should only run while visible. Not applied here yet, see the limitations.
- **Static typing:** GDScript allows dynamic typing, but annotating types catches errors early. The project still mixes both styles.
- **Use version control from day one.** This repo uses git with a Godot `.gitignore` and LFS rules for art and audio.
- **A frame-rate independent chase is three lines:** `velocity = (player.position - position).normalized() * speed` then `move_and_slide()`. Dividing the position difference by a number instead made the slime's speed depend on how far away the player was, and let it pass through walls.
- **Process modes decide who hears input while paused.** A node set to `When Paused` is asleep exactly when the player presses the key that starts the pause, so the node that toggles `get_tree().paused` has to be `Always`. The layer that is only meant to exist during the pause is a different node from the one that creates it.
- **A moving enemy needs a count, not a bool.** Contact damage was tracked with one `enemyInAttackRange` bool, which broke as soon as a second slime existed: leaving one slime cleared the flag while the other was still touching the player.

## Known issues & limitations

- WASD is not bound to the movement actions. Arrow keys or a gamepad only.
- Damage does not scale with the number of enemies. Three slimes deal the same 15 damage on the same 0.7 second cooldown as one.
- `player()` / `enemy()` empty methods plus `has_method()` string checks are fragile; groups or collision layers would be cleaner.
- The player's body collider is a 4 px circle against 16 px tiles, so the character can overlap the base of a prop before being stopped.
- The slime `death` animation is five frames at 5 fps and loops, so it runs for exactly as long as the 1.0 second `deathTimer`.
- `VisibleOnScreenNotifier2D` is still not used, so a slime that has started chasing keeps working while off camera.
- No sound, no save system, no menus, and no scenes beyond the two levels. Pausing exists, but the pause layer only stops the game and offers nothing else: no options, no restart, no way to reach a menu from it.
- Git LFS is configured in `.gitattributes`, but no file is actually tracked by LFS yet.

## Future work

- Apply the `VisibleOnScreenNotifier2D` lesson to the slimes, or decide explicitly that it is not needed for three enemies on a small map.
- Add a **spawner** (see [Use A Godot Spawner Instead of Dragging Enemies](https://www.youtube.com/watch?v=gVYeNZhROxM)) instead of hand-placing enemies.
- Restructure into the layered setup from the project setup video: `Main Game` with `Systems`, a `World` level root holding `LevelRoot`, `EntityRoot` and `EffectRoot`, a `HudLayer` at 10, a `PauseLayer` at 20, a `TransitionLayer` at 100 and a `DebugLayer` at 128, with the process modes that make pausing work.
- Larger maps with the **METSYS** metroidvania map plugin ([Making a Massive Metroidvania Map](https://www.youtube.com/watch?v=FI0-yz5Xcz0)): a rooms map, world rooms with map data, and transition nodes whose triggers sit outside the camera, while keeping exit/entry positions aligned so transitions do not drop the player.

## Resources & credits

- [DevWorm](https://www.youtube.com/@dev-worm) — the RPG-from-scratch tutorial series the project follows
- [10 Things I Wish I Knew Before Starting a Large Godot Project](https://www.youtube.com/watch?v=zLdTvkLsmgA)
- [The Godot Project Setup I Wish I'd Used From the Start](https://youtu.be/V4SO7foDoW4?si=A8G0VNAk7csyeekc) — layer/scene structure and pause notes
- [Git Made Simple - Godot Workflow from Start to Finish](https://www.youtube.com/watch?v=9yfNX0OdSAw) — git + LFS workflow
- [Use A Godot Spawner Instead of Dragging Enemies](https://www.youtube.com/watch?v=gVYeNZhROxM)
- [Making a Massive Metroidvania Map (The Right Way)](https://www.youtube.com/watch?v=FI0-yz5Xcz0) — METSYS
- [How to Create SMOOTH PATHFINDING in Godot](https://www.youtube.com/watch?v=Zy9Ra5zHOsY) — NavigationRegion2D / NavigationAgent2D pathfinding (consolidated in [[Project Planning]])
- [How to Create SAVE & LOAD in Godot 4](https://www.youtube.com/watch?v=_DP5QLJxVVI&pp=0gcJCSAMAYcqIYzv) — JSON / ConfigFile / ResourceSaver save pattern (consolidated in [[Project Planning]])
- [The 7 Greatest TIPS for Any Game Developer](https://www.youtube.com/watch?v=7aNTmYRjVT8) — scope, structure and playtesting tips (consolidated in [[Project Planning]])
- [How to Create a INVENTORY in Godot 4 (step by step)](https://www.youtube.com/watch?v=X3J0fSodKgs) — Item/Inventory Resource + CanvasLayer grid (consolidated in [[Project Planning]])
- [How to Make Collectable Objects in Godot 4 (coins, apples, etc)](https://www.youtube.com/watch?v=B91iuXU3AZ0) — Area2D collectable pattern (consolidated in [[Project Planning]])
- [Godot](https://godotengine.org), [Git](https://git-scm.com) + [Git LFS](https://git-lfs.com), with the Godot `.gitattributes` template
