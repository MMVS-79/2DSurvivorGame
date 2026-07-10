# 2D Survivor Game Roadmap

This file is our running checkpoint so new chats can quickly recover context.

## Current State

As of July 10, 2026, the prototype has:

- A main scene with a tilemap, player, camera, and one placed enemy.
- Player movement with `WASD` and arrow keys.
- A camera that smoothly follows the player.
- A basic enemy that moves directly toward the player.
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
- A GitHub Actions workflow for linting/QA.
- Manual playtest confirmation that the placed enemy dies in one hit.
- Fully refactored codebase complying with NASA/JPL Power of 10 safety-critical code rules.

Files that define the current gameplay loop:

- [project.godot](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/project.godot)
- [scenes/main/main.tscn](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/main/main.tscn)
- [scenes/player/player.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/player/player.gd)
- [scenes/basic_enemy/basic_enemy.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/basic_enemy/basic_enemy.gd)
- [scenes/game_camera/game_camera.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/game_camera/game_camera.gd)
- [scenes/ability/sword_ability_controller/sword_ability_controller.gd](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/scenes/ability/sword_ability_controller/sword_ability_controller.gd)

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
- Manual verification on June 11, 2026 confirmed the current placed enemy dies after one sword hit.
- The main scene currently contains one manually placed enemy, not a spawning system.

## Next Recommended Ticket

Title:

`Implement enemy spawning and basic run pacing`

Acceptance criteria:

- Enemies can spawn repeatedly without manual placement.
- Spawns appear around the play space rather than directly on top of the player.
- The player can survive briefly at the start, then feel increasing pressure.
- The new pacing is easy to test in short runs.
