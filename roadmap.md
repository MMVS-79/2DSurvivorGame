# 2D Survivor Game Roadmap

This file is our running checkpoint so new chats can quickly recover context.

## Current State

As of July 11, 2026, the prototype has:

- A main scene with a tilemap, player, camera, and dynamic enemy spawner.
- Player movement with `WASD` and arrow keys.
- A camera that smoothly follows the player.
- Homing enemies that continuously spawn off-screen and walk toward the player.
- A sword ability controller that spawns a sword swing on manual Spacebar/Left-Click activation, rate-limited by a cooldown timer.
- A snappy, arc-based sword slash animation (using easing, rapid sweep, and scale-out) that plays and frees itself.
- Sword hit detection that can damage enemies on overlap.
- Sword swing logic that now aims toward the nearest enemy or player facing.
- Sword attack cadence tuned faster so combat no longer waits `1.5` seconds between swings.
- Player root, collision, and attack origin aligned so enemy tracking and melee placement match the visible sprite.
- Basic enemy health and death handling.
- Player health with temporary invulnerability after being hit.
- Enemy contact damage and bounce-back recoil on hitting the player.
- A Material Design 3 styled HP HUD with animated progress bar and card-elevated Game Over state.
- A top-center HUD run timer displaying elapsed time (`MM:SS`).
- Dynamic spawn difficulty scaling (spawn interval reduces by 10% every 30 seconds).
- A GitHub Actions workflow for linting/QA.
- Fully refactored codebase complying with NASA/JPL Power of 10 safety-critical code rules.

Files that define the current gameplay loop:

- [project.godot](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/project.godot)
- [scenes/main/main.tscn](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/main/main.tscn)
- [scenes/main/main.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/main/main.gd)
- [scenes/player/player.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/player/player.gd)
- [scenes/basic_enemy/basic_enemy.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/basic_enemy/basic_enemy.gd)
- [scenes/game_camera/game_camera.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/game_camera/game_camera.gd)
- [scenes/ability/sword_ability_controller/sword_ability_controller.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/ability/sword_ability_controller/sword_ability_controller.gd)
- [scenes/manager/enemy_manager/enemy_manager.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/manager/enemy_manager/enemy_manager.gd)

## What Is Missing

The prototype is moving, but it does not yet have a real game loop.

Missing core systems:

- Enemy spawning over time.
- Win/lose pressure and session pacing.
- A more complete HUD for run timer and kill count.
- Progression such as XP, levels, or ability upgrades.

## Recommended Next Milestone

Build the first complete combat loop.

Goal:

- The player attacks enemies.
- Enemies can be damaged and die.
- New enemies keep spawning.
- The player can lose from taking damage.

Why this is next:

- It turns the prototype into an actual game.
- It unlocks tuning, juice, UI, progression, and content work.
- It reduces the risk of building lots of systems on top of an unproven loop.

## Milestone Plan

### Milestone 1: Combat Loop Foundation

Priority order:

1. Add an enemy spawner that creates enemies around the player or map edges.
2. Add a simple kill count or run timer to the HUD.
3. Tune the current damage, health, and restart flow through playtesting.

Definition of done:

- The player can survive for at least 30 seconds.
- Sword hits are visible and actually kill enemies.
- Enemies continuously spawn.
- The player can die and restart the run.

### Milestone 2: Survivor Feel

After the combat loop works:

1. Add XP gems or auto-awarded XP on enemy death.
2. Add leveling and a simple upgrade choice.
3. Add at least one more ability or weapon variant.
4. Add spawn scaling over time.
5. Add feedback: flashes, knockback, particles, sound hooks, and screen shake.

Definition of done:

- A run gets meaningfully harder over time.
- The player gets stronger over time.
- Combat feels responsive, not just functional.

### Milestone 3: Content and Polish

Once the loop is fun:

1. Add more enemy types.
2. Expand the map and environment readability.
3. Add menus, pause, and run summary.
4. Add balancing passes for speed, spawn rate, damage, and cooldowns.
5. Clean up project structure and shared gameplay components.

## Suggested Task Breakdown For The Next Chat

If we want the best next coding session, we should do this first:

1. Add an enemy spawner.
2. Add a kill count or run timer to the HUD.
3. Tune survival pacing with playtesting.

That gives us the first satisfying feedback loop quickly.

## Nice-To-Have Backlog

- Enemy knockback when hit.
- Invulnerability frames for the player after taking damage.
- Camera limits and better framing.
- Better enemy movement than direct homing.
- Animation states for player and enemies.
- A debug overlay for spawn counts and DPS testing.

## Working Notes

A few current implementation notes to remember:

- The player and enemy both use `CharacterBody2D`.
- The player is found through the `"player"` group.
- The sword currently swings on a much faster timer and is aimed by controller logic.
- The player scene now uses an explicit attack anchor near the sprite instead of relying on a far-offset root setup.
- The sword scene now applies overlap damage to enemies during the swing.
- The sword now orients toward the nearest enemy and swings from the player's pivot instead of spinning in place.
- The player now has health, invulnerability frames, and a game over state.
- The main scene now includes a simple UI layer for HP and restart messaging.
- Manual verification on July 11, 2026 confirmed that the spawner continuously spawns enemies off-screen and the timer displays and halts correctly on death.
- The main scene now spawns enemies continuously instead of a single placed enemy.

## Next Recommended Ticket

Title:

`Implement XP collection and leveling mechanics`

Acceptance criteria:

- Defeated enemies spawn/drop an XP gem at their death position.
- Walking close to an XP gem pulls it toward the player to collect it.
- Collecting XP gems increments the player's XP.
- Reaching maximum XP triggers a level-up, displaying a Material Design 3 upgrade selection panel to boost stats.
