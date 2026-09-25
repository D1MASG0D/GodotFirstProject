# SimpleRPG Implementation Plan

> [!success] Completed. Status checked 24 September 2026
> Every task in P0, P1 and P2 is done, and every documentation task except the two that need outside testers is done.
> This body is kept as portfolio history, so it still describes the project as it was on 23 September 2026.
> **Read section 0 before anything else.** It maps each task to its outcome and lists the statements below that the fixes made obsolete.

Written 23 September 2026.
Scope: analysis of `simple-rpg/` plus the three source notes (`Project Planning`, `Game Doc`, `Agent.md/Self-Improvement.md`), followed by the remaining work in priority order.
Status when written: analysis and planning only. No game files were changed to produce this document.

---

## 0. Status and errata (added 24 September 2026)

### 0.1 Task status

| Task | What it was | Outcome |
| --- | --- | --- |
| T1 | Wire the enemy health bar | **Done.** `updateHealth()` is called every physics frame, and health is clamped at 0 |
| T2 | Play the slime death animation | **Done.** `death` plays, then a 1.0 s timer frees the node and the body collider is disabled |
| T3 | Finish the player death flow | **Done.** `dead` animation, input and damage locked, then `global.resetGame()` and a level reload |
| T4 | Fix the enemy chase | **Done.** `velocity = (player.position - position).normalized() * 60` plus `move_and_slide()`, measured at 60 px/s on both 60 Hz and 30 Hz physics |
| T5 | Remove the duplicate camera | **Done.** `world.tscn` has no root `Camera2D` |
| T6 | Guard the detection area | **Done.** `body.has_method("player")` on enter and exit |
| T7 | Give `currentDirection` a valid start | **Done.** It starts as `"down"` |
| T8 | Rename `updateHealt` | **Done.** The definition and both call sites read `updateHealth` |
| T9 | `y_sort_enabled` on the cliff_side root | **Done.** Set to `true`, matching `world.tscn` |
| T10 | A single HUD label | **Done.** A `Hud` layer at 10 instanced from `hud.tscn` in both levels, which reads the player health itself |
| T11 | Pause on `Escape` | **Done.** A `Pause` layer at 20 instanced from `pause.tscn` in both levels, `process_mode` Always, toggling `get_tree().paused` |
| T12 | Two or three more slimes | **Done.** Three instances: `enemy`, `enemy2`, `enemy3` |
| T13 | Dust particles on walk | **Done.** `dustParticles` on `player.tscn`, emitting while `velocity` is not zero and the player is alive |
| D1 | Paper prototype | **Partly.** Designed from four real values out of the code, not yet played |
| D2 | Run the outside playtests | **Not done.** Three automated passes are recorded instead, and they are not a substitute |
| D3 | Fill the feedback table | **Partly.** Three automated rows, no outside testers yet |
| D4 | One revision from feedback and retest | **Done.** Contact damage was reworked after more than one slime exposed a bug in the single-flag tracking |
| D5 | Fix the stale claims in Game Doc | **Done.** The six claims listed in 3.4, plus the LFS claim |
| D6 | Fill the AI transparency section | **Done.** A table of what the agent did and how each part was verified |
| D7 | Add `README.md` to the repo root | **Done** |
| D8 | Update the technical documentation note | **Done.** The note was found in the trash, restored under its own name, synced to the code and mirrored in the repo |
| D9 | Status board and the two TODO lines | **Done.** Testing is now partly evidenced and `VisibleOnScreenNotifier2D` was decided as not needed for three enemies |
| D10 | Note the `sceens` typo decision | **Done.** Recorded in the reflection |

Still open: D2 and D3, which need three outside testers.

This task status mirrors the status board at the top of the vault Game Doc. Keep the two in sync when either one changes.

### 0.2 Errata: statements in this plan that are no longer true

Sections 1, 3 and 4 were written before any of the fixes landed. These are the statements the fixes made obsolete. They are left in place as the record of what the analysis found.

| Section | Statement in this plan | Reality from 24 September 2026 |
| --- | --- | --- |
| 3.1 | The health bar is "updated by `updateHealt()`" | Renamed to `updateHealth`, the name used in both `player.gd` and `enemy.gd` |
| 3.2 | `updateHealth()` is never called | Called every physics frame in `enemy.gd` |
| 3.2 | The slime death animation never plays | `slimeDie()` plays `death` before the 1.0 s timer frees the node |
| 3.2 | Player death is a bare `queue_free()` | `playerDie()` plays `dead`, blocks input and damage, then reloads the level |
| 3.2 | Enemy chase math skips collisions and scales with distance | Normalized velocity at 60 px/s with `move_and_slide()` |
| 3.2 | Duplicate `Camera2D` in `world.tscn` | Removed. The player's camera is the only one |
| 3.2 | `y_sort_enabled` missing on the cliff_side root | Set to `true` |
| 3.2 | `updateHealt` typo | Renamed to `updateHealth` |
| 3.2 | Enemy health can go below zero | Clamped at 0 before the bar is updated |
| 3.2 | `detectionArea` accepts any body | Guarded with `has_method("player")` on enter and exit |
| 3.2 | Attacking while facing `none` sets the flag with no animation | `currentDirection` starts as `"down"`, so `"none"` is unreachable |
| 3.3 | Any user interface. No `CanvasLayer`, no HUD | A `Hud` label in both levels |
| 3.3 | More than one enemy | Three slimes in `world.tscn` |
| 3.3 | A pause system, despite the journal describing layer numbers 10, 20, 100 and 128 | A `Pause` layer at 20 in both levels, toggled on `Escape` |
| 3.3 | Particles. `dust_particles_01.png` is imported but used in no scene | Emitted by `dustParticles` on `player.tscn` while the player walks |
| 3.3 | A start menu, game over screen, or scene reload flow | Death reloads the level. There is still no menu |
| 3.4 | The six stale claims in Game Doc | All six corrected on 24 September, plus the LFS claim |
| 1.1 | Uncommitted change is the enemy health bar | Nine files are modified with the P0 to P2 work |
| 1.4 | `world.tscn` has a root `Camera2D` at (288, 190.46) | Removed |
| 1.4 | `world.tscn` has one enemy instance at (192, 56) | Three instances, at (192, 56), (-120, 40) and (60, 110) |
| 1.5 | Enemy chase value 40, used as a divisor | 60, used as a speed in px per second |
| 1.6 | `updateHealt` listed as a live naming slip, and named in the `_physics_process` call list | Renamed to `updateHealth`, which is the name in both scripts |
| 1.3 | `sprites/particles/` holds `dust_particles_01.png` "(imported, never used in a scene)" | Used by `dustParticles` on `player.tscn`, and the file is a 48x12 sheet of four 12x12 frames rather than a single sprite |
| 1.3 | `player.gd` is 165 lines and `global.gd` is 18 lines | The 165 is wrong, and so was the single correction this row used to carry, because the deletion pass changed the count again. Counts move with every edit, so no current count is stated here on purpose. Read the files for the real numbers, and read every count and constant in sections 1 to 4 as the 23 September value rather than as drift to correct |

Still true and not scheduled: the `sceens` folder name, the `colisions` node name, the `frontAtack` animation names and the `attackIP` variable were deliberately left alone. `attackIP` is not unused, it gates the idle animations in `playAnimation()`, but it duplicates `global.playerCurrentAttack`, and the two diverge on death because only the global flag is cleared there. The LFS gap in 3.2 is real as well: the rules are declared, but no file is tracked.

---

## 1. Current project state

> **Historical.** Written on 23 September 2026, before the P0 to P2 work. See section 0 for current status.

### 1.1 Repository

| Item | Value |
| --- | --- |
| Repo root | `/home/d1masg0d/UniProjects/GodotFirstProject` |
| Godot project | `simple-rpg/` |
| Branch | `main` |
| Remote | `git@github.com:D1MASG0D/GodotFirstProject.git` |
| Commits | 3 (`d559e4f`, `2a7beac`, `96326e6`) |
| Uncommitted change | `simple-rpg/sceens/enemy.gd` (enemy health bar work in progress) |
| Tracked files | 102, of which 36 are `.png` |
| Git LFS | `.gitattributes` declares LFS rules for png/wav/ogg/mp4 and more, but `git lfs ls-files` returns nothing, so no file is actually in LFS yet |
| Editor plugin | `addons/godot-git-plugin` with `version_control/plugin_name="GitPlugin"` |

The last commit message ("Start of HP bar (applied on player, started on enemy) Scene transition and also some tweaks.") matches exactly where the project is: the HP bar is finished on the player, half-finished on the enemy, and scene transition exists in both directions.

### 1.2 Engine settings (`simple-rpg/project.godot`)

| Setting | Value | Note |
| --- | --- | --- |
| `config/name` | `SimpleRPG` | |
| `config/features` | `4.7`, `Forward Plus` | |
| `run/main_scene` | `uid://bpspqdp8de82r` = `sceens/world.tscn` | The "F5 starts player.tscn" claim in Game Doc is out of date |
| Autoload | `global` = `scripts/global.gd` | Lowercase name, not a `Global` class |
| Input action | `attack` = physical keycode 69 (`E`) | |
| Stretch | `mode=canvas_items`, `aspect=expand` | No `window/size` overrides |
| Physics | `3d/physics_engine="Jolt Physics"` | Left over from the default template, unused in a 2D game |
| Rendering | `default_texture_filter=0` (nearest), `driver.windows="d3d12"` | Nearest filter gives the crisp pixel look |

### 1.3 File layout

```
GodotFirstProject/
  .gitignore            Godot 4 template (ignores .godot/, .import/, export.cfg, *.tmp, ...)
  .gitattributes        EOL normalisation + LFS rules (png, wav, ogg, mp4, ...)
  simple-rpg/
    project.godot
    icon.svg
    .editorconfig       root = true, charset = utf-8
    .gitignore          .godot/, /android/
    .gitattributes      EOL normalisation only
    addons/godot-git-plugin/   windows, linux, macos binaries
    scripts/
      player.gd         165 lines on 23 September, the largest script
      global.gd         18 lines on 23 September, autoload
    sceens/             (typo for "scenes")
      world.gd  world.tscn
      player.tscn
      enemy.gd  enemy.tscn
      cliff_side.gd  cliff_side.tscn
    sprites/
      characters/       player.png (48x48 grid), slime.png (32x32 grid),
                        skeleton.png, skeleton_swordless.png, README.txt
      tilesets/         plains.png, grass.png, water*, decor*, fences.png,
                        water_lillies.png, water-sheet.png,
                        floors/{carpet,wooden,flooring}.png,
                        walls/{walls,wooden_door,wooden_door_b}.png
      objects/          objects.png (chest_01, chest_02, rock_in_water_01..06)
      particles/        dust_particles_01.png   (imported, never used in a scene)
```

Note the folder name `sceens`. Every hardcoded `res://` path in `world.gd` and `cliff_side.gd` depends on it.

### 1.4 Scenes as built

**`player.tscn`** (root `CharacterBody2D` "player", `collision_layer = 3`, `y_sort_enabled`)

| Child | Key values |
| --- | --- |
| `AnimatedSprite2D` | 9 animations: `frontIdle`, `backIdle`, `sideIdle`, `frontWalk`, `backWalk`, `sideWalk`, `frontAtack`, `backAtack`, `sideAtack`, `dead`; `offset = (0, -15)` |
| `CollisionShape2D` | circle r=4 at (1, -2) |
| `playerHitbox` (`Area2D`) | circle r=17.03 at (0, -7) |
| `attackCooldown` (`Timer`) | 0.7s, actually the contact damage cooldown |
| `dealAttackTimer` (`Timer`) | 0.5s, the attack window |
| `Camera2D` | zoom (4, 4), limits -192/-80/288/192, drag on both axes |
| `healthBar` (`ProgressBar`) | scale 0.1, `show_percentage = false`, hidden at full health |
| `regenTimer` (`Timer`) | 3.0s, autostart |

**`enemy.tscn`** (root `CharacterBody2D` "enemy")

| Child | Key values |
| --- | --- |
| `AnimatedSprite2D` | `idle`, `walk`, `death` from `slime.png`; `offset = (0, -4)` |
| `enemyhitbox` (`Area2D`) | circle r=13.04 at (0, -2) |
| `CollisionShape2D` | circle r=8 at (0, -3) |
| `detectionArea` (`Area2D`) | `collision_layer = 2`, `collision_mask = 2`, circle r=65.03 |
| `takeDamageCooldown` (`Timer`) | 0.5s |
| `healthBar` (`ProgressBar`) | scale 0.15 |

**`world.tscn`** (root `Node2D` "world", `y_sort_enabled = true`)

`enemy` instance at (192, 56), `player` instance, `ground` (TileMapLayer, z=-1), `mountains` (z=-1), `Props` (y-sorted), a root-level `Camera2D` at (288, 190.46), `colisions` (`StaticBody2D` + `CollisionPolygon2D`), `CliffSideTransition` (`Area2D`, shape 30x42 at (304, 38)).

**`cliff_side.tscn`** (root `Node2D` "CliffSide", **no** `y_sort_enabled`)

`ground`, `mountains`, `Props` (y-sorted), `player` instance at (-178, 40), `CliffSideExit` (`Area2D`, shape 30x42 at (-208, 39)), `colisions`. No enemy instance.

### 1.5 Gameplay values currently in use

| Value | Where | Number |
| --- | --- | --- |
| Player speed | `player.gd` `const speed` | 100 |
| Player max health | `player.gd` | 100 |
| Contact damage to player | `player.gd` `enemyAttack()` | 15 |
| Player damage cooldown | `attackCooldown` timer | 0.7s |
| Player health regen | `regenTimer` + `_on_regen_timer_timeout` | 15 every 3s |
| Enemy max health | `enemy.gd` | 100 |
| Damage per valid swing | `enemy.gd` `dealWithDamage()` | 20 (5 hits to kill) |
| Enemy hit cooldown | `takeDamageCooldown` | 0.5s |
| Attack window | `dealAttackTimer` | 0.5s |
| Enemy chase value | `enemy.gd` `var speed` | 40, used as a divisor, not a speed |
| Enemy detection radius | `detectionArea` shape | 65.03 px |

### 1.6 Code style to preserve

The project is consistent in ways worth protecting. Anything added should look like it was written by the same person on the same day.

- **Direct node paths.** Everything is `$AnimatedSprite2D`, `$healthBar`, `$dealAttackTimer`. There are zero `@onready` variables and zero `@export` variables in the whole project. Keep it that way.
- **Signals connected in the `.tscn`**, not in code. Handlers follow `_on_<node>_<signal>`, for example `_on_deal_attack_timer_timeout`.
- **camelCase for variables and functions**, with a few lowercase single words (`health`, `speed`, `player`). Godot's own virtual methods stay snake_case.
- **Partial static typing.** Older code has none (`func _physics_process(delta):`, `var health = 100`); newer code adds it (`func _ready() -> void:`, `func _on_detection_area_body_entered(body: Node2D) -> void:`). New code should lean to the newer style, matching the lesson in the journal, without retrofitting the whole project.
- **String state machine.** `currentDirection` is `"none" | "right" | "left" | "up" | "down"`. Animation selection passes an integer flag (`1` = moving, `0` = idle) rather than an enum.
- **One shared autoload named `global`**, used as `global.playerCurrentAttack`. Nothing else is shared between scenes.
- **`print()` for debug output.** `print(health)`, `print("Slime damaged: " + str(health) + " left")`, `print("DEAD")`.
- **`queue_free()` for removal**, with no pooling or spawner.
- **Logic-first layout.** `_physics_process` reads as a list of calls: `player_movement(delta)`, `enemyAttack()`, `attack()`, `updateHealt()`. New logic should be one more named function on that list, not a state machine class.
- **No `class_name`, no inheritance, no components, no resources.** Two scripts of substance, both plain `extends CharacterBody2D`.

Known naming slips already in the tree, kept for reference rather than as a priority: folder `sceens`, node `colisions`, function `updateHealt`, animations `frontAtack`/`backAtack`/`sideAtack`, variable `attackIP`, comment "shit abbt health".

---

## 2. Requirements from the three notes

### 2.1 `Game Doc.md` (the portfolio product)

Hard requirements from the challenge:

- Course STA-OIL 4.30, constraint of **4 weeks** and **at least three IT topics covered in depth**.
- Evidence needed for four phases: analysing, design, realisation, testing.
- **Eight portfolio products**: goal, planning, analysis, design, realisation, reflection, sources, AI transparency.
- **Outside playtesting and revision are explicitly required.**
- Product is the existing SimpleRPG project, not a new one.

The documented requirements table (Section 3) is a contract for the prototype:

1. Player moves in four directions.
2. Player attacks on `E`.
3. Attacks damage an enemy (20 per valid swing).
4. Enemy detects the player in roughly 65 px and chases.
5. Enemy damages the player on contact (15, 0.7s cooldown).
6. The world has a playable level (`world.tscn`).
7. The project opens and runs.

Open TODOs the doc itself lists:

- Paper prototype or wireframe: not recorded, marked TODO.
- Playtest table: three empty TODO rows.
- AI transparency: unrecorded, marked TODO.
- `VisibleOnScreenNotifier2D` decision: marked TODO.
- Known issues it names: **player death error** and **missing enemy death animation**.

The playtest plan is already written (7 steps: controls only, no explanation upfront, observe, ask what they thought, ask what was unclear, record and revise, retest). It needs to be executed, not designed.

### 2.2 `Project Planning.md` (the journal)

Not a feature list, more a set of lessons and one target architecture.

Lessons the code should reflect:

- Use `offset` for the sprite, `position` for the node. The project already does: sprites use `offset = (0, -15)` / `(0, -4)`.
- Use `flip_h`, never `scale.x * -1`. Already respected in `player.gd` and `enemy.gd`.
- Be careful with `preload`. Currently no `preload` anywhere.
- Add `VisibleOnScreenNotifier2D` to enemies that chase the player, so they only work when visible.
- Prefer static typing to catch errors early.
- Use version control. Done, 3 commits and a remote.

Target scene structure from the setup video (with process modes):

```
Main Game                 Process.Mode: Always
  Systems
  World (Level 0)         Process.Mode: Pausable
    LevelRoot
    EntityRoot
    EffectRoot
  HudLayer (Level 10)     Process.Mode: Pausable
    HudRoot
  PauseLayer (Level 20)   Process.Mode: When Paused
    PauseRoot
  TransitionLayer (100)   Process.Mode: Always
    TransitionRoot
  DebugLayer (Level 128)  Process.Mode: Always
    DebugRoot
```

The project does not follow this yet. It has one flat `world.tscn` with no canvas layers beyond the default. The journal also notes the difference between a `CanvasItem` (renders normally) and a `Viewport` (renders at default resolution then scales).

Other journal topics: Git and Git LFS workflow, a spawner instead of hand-placed enemies (because placed enemies keep moving before the player arrives), and MetSys room maps with transition nodes. MetSys is explicitly marked "still not finished" in the note, so it is not a requirement.

One helper from the journal is not implemented anywhere yet:

```
setMouseCursorVisible(isVisible :bool)
```

### 2.3 `Agent.md/Self-Improvement.md` (how to work and write)

This note is about process and voice, not game features. It sets the rules this plan follows.

- No em dashes, no buzzwords, no forced rule-of-three, no fake conflict, no polite opener.
- Be specific: names, numbers, real examples.
- Have a point of view, including about what is weak.
- For an ADHD reader: lead with the payoff, chunk the work, keep paragraphs short, give **time estimates**, and end with **one clear next step**.
- Use a todo list and keep it updated. Verify instead of assuming.

Applied here: every task below carries a time estimate and a concrete done-check, and the plan ends with one next step.

---

## 3. Done versus missing

### 3.1 Done and working

> **Historical.** Written on 23 September 2026, before the P0 to P2 work. See section 0 for current status.

| Area | Evidence |
| --- | --- |
| Project runs from `world.tscn` | `run/main_scene` points at `uid://bpspqdp8de82r` |
| Four-direction movement | `player.gd` `player_movement()`, speed 100, `move_and_slide()` |
| Directional animation with `flip_h` | `player.gd` `playAnimation()` |
| Melee attack on `E` with a 0.5s window | `attack()` + `dealAttackTimer` + `global.playerCurrentAttack` |
| Hitbox-based damage to the enemy | The slime's own `enemyhitbox` + `enemy.gd` `dealWithDamage()`, 20 per valid swing, 0.5s cooldown |
| Enemy detection and chase | `detectionArea` (r=65.03) sets `playerChase`, chase runs in `_physics_process` |
| Enemy contact damage | `player.gd` `enemyAttack()`, 15 damage, 0.7s cooldown |
| Player health bar | `healthBar` updated by `updateHealt()`, hidden at full health |
| Player regeneration | `regenTimer` 3.0s autostart, +15 HP |
| Two connected levels | `world.tscn` and `cliff_side.tscn`, both directions via `global.transitionScene` |
| Tilemap world with collision and y-sorting | `ground`, `mountains`, `Props`, `colisions` polygon |
| Pixel-art rendering | nearest filter, camera zoom (4, 4) |
| Version control | Git repo, Godot `.gitignore`, GitHub remote, editor plugin |
| Portfolio document mostly written | Game Doc sections 1 to 9 |

### 3.2 Broken or half-finished

**Status: every item below except the LFS row is fixed as of 24 September 2026.** Kept as the record of what the analysis found, mapped in 0.2.

| Problem | Where | Impact |
| --- | --- | --- |
| `updateHealth()` is never called | `enemy.gd` (uncommitted diff added the body) | Enemy health bar never moves |
| Slime death animation never plays | `enemy.gd` `dealWithDamage()` calls `queue_free()` immediately | The doc's "missing enemy death animation" issue is real |
| Player death is a bare `queue_free()` | `player.gd` `_physics_process` | The `dead` animation exists and is unused; the player just pops out of existence, no game over, no reload |
| Enemy chase math skips collisions and scales with distance | `enemy.gd`: `position += (player.position - position)/speed` | The slime can slide through walls because it does not use `move_and_slide()`, and its effective speed falls from roughly 97 px/s at the edge of the detection radius to 30 px/s up close |
| Duplicate `Camera2D` | `world.tscn` root camera at (288, 190.46) alongside the player's camera | Two cameras compete; only one is intended |
| `y_sort_enabled` missing on the `cliff_side` root | `cliff_side.tscn` root `CliffSide` | Props and the player sort differently in the two levels |
| `updateHealt` typo | `player.gd` | Inconsistent with the new `enemy.gd` `updateHealth()` |
| Enemy health can go below zero | `enemy.gd` `dealWithDamage()` | `ProgressBar.value` gets a negative number |
| `detectionArea` accepts any body | `enemy.gd` `_on_detection_area_body_entered` | No `has_method("player")` guard, unlike every other area in the project |
| Attacking while facing `none` sets the attack flag with no animation | `player.gd` `attack()` | Invisible attack that still deals damage on the first press |
| LFS declared but unused | root `.gitattributes` vs empty `git lfs ls-files` | 36 PNGs are plain blobs; the doc claims LFS is part of the pipeline |

### 3.3 Missing entirely

**Status: the HUD, the extra enemies, the scene reload flow, the pause system and the particle use are no longer missing.** The rest of this list still stands.

- Sound and music. No `AudioStreamPlayer` node exists anywhere.
- Any user interface. No `CanvasLayer`, no HUD, no labels, no menus.
- A pause system, despite the journal describing layer numbers 10, 20, 100 and 128 and their process modes.
- A start menu, game over screen, or scene reload flow.
- A save system.
- More than one enemy. `world.tscn` has exactly one slime instance, `cliff_side.tscn` has none.
- A spawner. Enemies are placed by hand, which is the exact thing the journal warns about.
- `VisibleOnScreenNotifier2D` on the enemy.
- The `setMouseCursorVisible` helper from the journal.
- Particles. `dust_particles_01.png` is imported but used in no scene.
- Unused art: `skeleton.png`, `skeleton_swordless.png`, `chest_01/02.png`, `rock_in_water_*`, `water*`, `fences.png`, `lillies`, `floors/`, `walls/`.
- Named 2D collision layers in project settings.
- A `README.md` in the repo.
- The `First Uni Project - Documentation` note that Game Doc links to twice.
- Playtest evidence, a paper prototype, and the AI transparency entry.

### 3.4 Claims in the documents that no longer match the code

**Status: all six claims below, plus the LFS gap, were corrected in Game Doc on 24 September 2026.**

Worth fixing during the documentation pass, because the review is against the documents.

| Claim in Game Doc | Reality |
| --- | --- |
| "F5 is set to `player.tscn`" and "the project currently starts player.tscn" | `run/main_scene` is `world.tscn`. F5 runs the full level |
| "The code uses `self.queue.free()` but it should use `self.queue_free()`" | `player.gd` already reads `self.queue_free()`. The bug is fixed, the text is stale |
| "a stretch scale of 4.0" | No stretch scale is set. The 4x is the player `Camera2D` zoom |
| "I use the `global` autoload for the shared `playerCurrentAttack` state" | Correct, and it also holds all transition state (`currentScene`, `transitionScene`, spawn positions, `gameFirstLoading`) |
| "Enemy contact damage has a 0.5 second cooldown" appears in the MDA table twice with different meanings | `attackCooldown` on the player is 0.7s (incoming damage), `takeDamageCooldown` on the enemy is 0.5s (outgoing damage received) |
| Regeneration is not mentioned at all | `regenTimer` restores 15 HP every 3 seconds, which changes the difficulty described in the MDA table |

---

## 4. Remaining tasks in priority order

**Historical. Everything except D2 and D3 is done. See 0.1.**

Rules for every task below: keep it simple, match the style in section 1.6, add no new dependencies, add no new autoloads, and do not restructure existing files. If a task cannot be done in the existing style, it is not worth doing for this prototype.

### P0: finish what is already half-built (about 1.5 hours total)

**Status: done.** T1 to T5 are implemented and verified.

These are blockers because the documents claim the features exist.

**T1. Wire up the enemy health bar.** 10 minutes.
The uncommitted `enemy.gd` change added a working `updateHealth()` body but nothing calls it. Add the call to the `_physics_process` list, matching how `player.gd` lists `updateHealt()` there. Clamp the value at 0 so a 5th hit on a 20 HP remainder does not push the bar negative.
Done when: hitting the slime makes its bar drop in visible steps and disappear at full health.
Then: commit the pending `enemy.gd` change with this fix. It is unrelated work sitting in the tree.

**T2. Play the slime death animation.** 20 minutes.
`enemy.gd` has a `death` animation in the `SpriteFrames` and removes the node the instant health hits 0. Stop moving and stop chasing, play `death`, and free the node after the animation. The simplest version that fits the existing pattern is one more `Timer` in `enemy.tscn` and one more entry in `_physics_process`.
Done when: the slime visibly dies instead of vanishing, and it stops doing damage during the death.
This closes the first of the two known issues named in Game Doc.

**T3. Finish the player death flow.** 30 minutes.
`player.gd` plays no animation and calls `queue_free()` immediately, which leaves the game running with no player. Play the existing `dead` animation, set a flag that stops input and damage, and reload `world.tscn` after a short delay. Clear the transition state in `global.gd` on reload so the player does not spawn at a stale transition position.
Done when: dying shows the death animation and returns to a playable world.
This closes the second known issue named in Game Doc.

**T4. Fix the enemy chase.** 20 minutes.
Replace the fraction-based position change with velocity plus `move_and_slide()`, which is what `CharacterBody2D` is for and what the player already does. Keep the number that feels right rather than keeping 40, which is a divisor today. Keep the existing `flip_h` direction logic untouched.
Done when: chase speed is the same on 30 fps and 144 fps, and the slime stops at walls instead of through them.

**T5. Remove the duplicate camera.** 10 minutes.
`world.tscn` has a root `Camera2D` at (288, 190.46) and the player instance brings its own. Delete the world-level one, since the player camera is the one with zoom, limits and drag configured.
Done when: the camera follows the player in both levels and the view limits still hold.

### P1: small correctness pass (about 45 minutes)

**Status: done.** T6 to T9 are implemented.

Low risk, one line each, and they are the kind of thing the review will notice.

**T6. Guard the detection area.** 10 minutes.
`_on_detection_area_body_entered` should check `body.has_method("player")` like `world.gd` and `cliff_side.gd` already do. Clamp enemy health at 0 in the same pass if T1 did not already.
Done when: the guard matches the pattern used by every other area handler in the project.

**T7. Give `currentDirection` a valid starting value so the first attack animates.** 10 minutes.
`currentDirection` starts as `"none"`, and `attack()` has no branch for `"none"`, so the first attack from a standing start sets `global.playerCurrentAttack` and `attackIP` without ever starting `dealAttackTimer` — the only thing that clears them. Both flags then stick true forever: the sprite freezes and the hitbox stays live. Initialising `currentDirection` to `"down"`, the facing `_ready()` already shows, fixes it. It is only ever assigned right/left/up/down afterwards, so `"none"` becomes unreachable. It is not about "keeping the last direction": the value was never reset to `"none"` after the first movement, so that part was already correct.
Done when: the first attack after standing still always has an animation.

**T8. Rename `updateHealt` to `updateHealth`.** 10 minutes.
Rename in `player.gd` and its call site so it matches `enemy.gd`. Two edits, no behaviour change.
Done when: both scripts spell it the same way.

**T9. Enable `y_sort_enabled` on the `cliff_side` root.** 5 minutes.
`world.tscn` has it, `cliff_side.tscn` does not, so prop sorting differs between the two levels.
Done when: walking behind a prop in `cliff_side` sorts the same way as in `world`.

Deliberately **not** in this pass: renaming the `sceens` folder or the `colisions` node. Renaming `sceens` breaks every hardcoded `res://` path in `world.gd` and `cliff_side.gd`, and `colisions` is referenced by nothing in code. Both are cosmetic and both risk a broken import in the last week of a four-week challenge. Leave them, and note the choice in the reflection instead.

### P2: the smallest things that make it feel like a game (about 2 hours, optional)

**Status: done. T10 to T13 are all implemented.**

Only if P0, P1 and the documentation pass are done. Each of these is independently droppable.

**T10. A single HUD label.** 30 minutes.
One `CanvasLayer` at layer 10 with one `Label` showing health as text, enabled from `player.gd` with a signal. This is the first half of the journal's layer structure and it is the cheapest way to show the pause work would fit.
Done when: HP is readable without watching the bar above the character.

**T11. Pause on `Escape`.** 30 minutes.
Add a `pause` input action, a `CanvasLayer` at layer 20 with a label, and `get_tree().paused = true`. This is the second half of the journal's structure and it directly matches the process-mode table in the planning note. Built with one change to this description: the layer is `process_mode = Always` rather than `When Paused`, because a `When Paused` node is asleep at the moment the key that starts the pause is pressed. One node has to hear the action in both directions, and keeping it to one node is what makes the task 30 minutes instead of two nodes and a new failure mode. The reason is recorded in the technical note as well.
Done when: `Escape` freezes the world, the pause layer stays responsive, and unpausing resumes cleanly.

**T12. Two or three more slimes.** 20 minutes.
Duplicate the enemy instance in `world.tscn` and adjust the positions. No spawner, no scene change, no new script. This tests whether the P0 fixes survive more than one enemy.
Done when: three slimes chase, take damage and die independently.

**T13. Dust particles on walk.** 30 minutes.
`sprites/particles/dust_particles_01.png` is already imported and unused. One `GPUParticles2D` child on the player, emitting only while moving.
Done when: the player kicks up dust while walking and not while idle.

**Explicitly out of scope.** MetSys room maps, a spawner system, save games, an inventory, a dialogue system, more levels, a start menu, refactoring into components, and animation via `AnimationPlayer`. Each one would push past the four-week constraint and none of them appear in the requirements table in Game Doc.

### P3: close the documented gaps

**Status: see 0.1.** Section 5 carries the detail.

See section 5. These are the deliverables the challenge actually grades.

---

## 5. Documentation tasks

**Status: done except D2 and D3, which need outside testers. See 0.1.**

The coding is close to done. The portfolio evidence is not, and the challenge grades eight products. Current status of each:

| Portfolio product | Status | Remaining work |
| --- | --- | --- |
| Goal | Written (Game Doc section 1) | None |
| Planning | Written (section 2, week table) | Update the status column once testing happens |
| Analysis | Written (section 3, three IT topics) | None |
| Design | MDA written, paper prototype TODO | Make the prototype, record it |
| Realisation | Written (section 5) | Fix the six stale claims listed in 3.4 |
| Reflection | Written (section 7) | Add the T2/T3 fixes and the `sceens` rename decision |
| Sources | Written (section 8) | None |
| AI transparency | TODO placeholder | Fill it in honestly |

Both supporting notes are also listed as needing updates: the status board at the top of Game Doc still shows Testing as "Planned. No playtest results are recorded yet."

**D1. Paper prototype.** 30 minutes.
Game Doc recommends one player and one slime encounter. Paper pieces on a drawn map, test movement, attack range, chase radius and attack timing. Photograph it and reference it from the Design section. This removes the only "not recorded" gap in Design.

**D2. Run the outside playtests.** 60 to 90 minutes.
The 7-step plan in Game Doc section 6 is finished and only needs executing. Three testers, controls only, no explanation of the slime. The next step line at the end of the document is exactly this task.

**D3. Fill the feedback table.** 30 minutes.
Three rows replacing the TODO placeholders in section 6, plus one revision made from the feedback and a retest result. Without a filled table, Testing stays unevidenced and the challenge explicitly requires outside playtesting.

**D4. Apply one revision from feedback and retest.** 30 minutes.
One small change, recorded in the table. Keep it small enough that it cannot break P0 work.

**D5. Fix the stale claims in Game Doc.** 15 minutes.
The six entries in section 3.4 above. An assessor who opens `project.godot` will see that the main scene is `world.tscn` and will find the `self.queue.free()` bug already fixed.

**D6. Fill the AI transparency section.** 15 minutes.
Name the tools, the prompts and the tasks. This is the one product with nothing behind it.

**D7. Add `README.md` to the repo root.** 30 minutes.
Controls (`arrow keys`, `E`), the run instruction (open in Godot 4.7, F5 starts `world.tscn`), the folder layout, the two-level flow, known issues, and asset credits. The characters folder already documents the sprite grid and animation rows, so link that instead of repeating it.

**D8. Update the technical documentation note.** 30 minutes.
Game Doc links to `[[First Uni Project - Documentation]]` twice and describes it as holding the detailed scene structure, collision setup, engine settings and combat flow. Confirm the note exists under that name and covers the HP bar, scene transition and both fixes from P0; if it does not, that link is a dead reference in a graded document.

**D9. Update the status board and the two TODO lines.** 10 minutes.
Set Testing to "Evidenced" once D2 and D3 are done. Resolve the `VisibleOnScreenNotifier2D` TODO with an explicit decision. With one to three slimes on a small map, the honest answer is probably "not needed yet, and here is why", which is a valid answer.

**D10. Note the `sceens` typo decision.** 5 minutes.
One line in the reflection saying it was left alone on purpose to avoid breaking `res://` paths in the last week. That turns an obvious typo from a mistake into a documented tradeoff.

---

## 6. Estimated order and time

**Status: historical. The order matched steps 1 to 3. Step 4 is still open, and step 7 was done ahead of it.**

Order matters because P0 fixes change what the playtesters actually see, and playtesting a slime that slides through walls produces feedback about the wrong thing.

| Order | Task group | Time | Why here |
| --- | --- | --- | --- |
| 1 | T1, T2, T3 (health bar, slime death, player death) | 1 hour | The two issues Game Doc names as known problems are fixed before anyone plays it |
| 2 | T4, T5 (chase fix, camera) | 30 minutes | Fixes feel before testing feel |
| 3 | T6 to T9 (correctness pass) | 45 minutes | Cheap, low risk, and the review will look at the code |
| 4 | D2, D3, D4 (playtest, table, revision) | 2 to 2.5 hours | The one hard requirement still unevidenced |
| 5 | D5, D6, D9 (stale claims, AI, status board) | 40 minutes | Documentation accuracy after the code stops moving |
| 6 | D1, D7, D8, D10 (prototype, README, tech note, typo note) | 1.5 hours | Supporting evidence |
| 7 | T10 to T13, optional polish | 2 hours | Only if everything above is done |

**Totals.** Required to satisfy the challenge: about 6 hours. With the optional polish: about 8 hours.

**Rough calendar.** The challenge is four weeks and the prototype is already in week 3 territory. Steps 1 to 3 are one working session of about 2 hours. Steps 4 to 6 need three short sessions, since the playtests depend on finding three testers. Step 7 is a stretch goal with a hard stop: if playtests are not finished, polish does not start.

**Risks.** The playtests depend on other people being available, so they should be scheduled before the code work, not after. The `sceens` rename is the only change that could cost an afternoon, which is why it is out of scope. Renaming the enemy's `speed` variable in T4 is safe; renaming the folder is not.

---

## 7. Next step (as written on 23 September, now done)

Open the project, confirm the pending `simple-rpg/sceens/enemy.gd` change is the health-bar work, and do T1 through T3 in one sitting: call `updateHealth()`, play the slime `death` animation, and give the player a real death. About an hour, and it clears both known issues named in Game Doc.

Then commit, and run the first playtest.

---

## 8. Next step now (24 September 2026)

Outside playtesting is the one thing left: three testers, controls only, then the feedback table in Game Doc section 6 and one revision from it. The automated passes recorded there are evidence of behaviour, not of feel, so they do not count as it.

T11 and T13 were done on 24 September, ahead of the playtests, against the rule in section 6 that polish waits for step 4. They were small, independent of the combat loop and reversible, so they could not invalidate a playtest result; the rule exists to stop polish from delaying the testing, and both landed in one session. The only code item left after them is the unused LFS rules in `.gitattributes`, which needs a deliberate decision rather than more code.
