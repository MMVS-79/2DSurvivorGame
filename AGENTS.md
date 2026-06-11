# Repo Working Notes

This repository uses [roadmap.md](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/roadmap.md) as the persistent project checkpoint across chats.

## Collaboration Expectations

When working in this repo:

- The agent should do every code, scene, documentation, and planning task it can do directly.
- The user should be treated as the owner of manual playtesting, in-editor visual review, and art-facing decisions.
- Only hand work back to the user when a task genuinely requires manual testing, editor-only setup, asset creation, or a subjective visual choice.
- When manual follow-up is needed, say exactly what needs to be checked or added so the user can do it quickly.
- Otherwise, keep moving autonomously and update the roadmap as progress is made.

The user is the right person for:

- Playtesting feel, difficulty, and pacing.
- Checking collision sizes and whether hits feel fair in motion.
- Sprite creation, replacement, alignment, and visual polish.
- Animation timing and readability.
- UI readability and layout judgment in the real game window.
- Audio, juice, and aesthetic choices that depend on taste.
- Confirming whether a system is fun, frustrating, too fast, too slow, too weak, or too strong.
- Doing editor-only adjustments that are faster or safer to do visually than by file editing alone.

The agent should still own:

- Gameplay code, scene wiring, and reusable systems.
- Data/config tuning passes when values can be changed directly in code or scene files.
- Documentation, task tracking, and roadmap maintenance.
- Turning user playtest feedback into concrete implementation changes.
- Clear intent-revealing comments in non-obvious gameplay code so future sessions can understand why a system works the way it does.

How to hand off manual work:

- Ask for manual help only after pushing the implementation as far as possible.
- Give the user a short checklist of exactly what to test, look at, or add.
- Prefer targeted requests like "check whether the enemy touch damage feels too frequent" over broad requests like "test the game."
- After the user reports results, fold the verified outcome back into the roadmap or working notes when it matters.

## Commenting Expectations

- Comments should explain intent, gameplay rules, and non-obvious decisions.
- Comments should also help the user learn GDScript when a language feature, Godot callback, or engine pattern may be unfamiliar.
- Prefer comments that help a future agent understand why a line or block exists, not comments that restate obvious syntax.
- Prefer short teaching comments for things like `@export`, `@onready`, signals, groups, scene-tree lookups, typed variables, and frame callbacks when they appear in new code.
- When adding new gameplay systems, err on the side of documenting signal flow, guard clauses, cooldown logic, and tuning assumptions.
- Comments are important for continuity across sessions, but they do not replace correctness, clarity, or working code.

## Roadmap Workflow

When working in this repo:

1. Read [roadmap.md](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/roadmap.md) before making plans or code changes.
2. Treat the roadmap as the source of truth for current milestone, next recommended ticket, and known gaps.
3. Update [roadmap.md](/Users/manujasenanayake/Documents/programming/2DSurvivorGame/roadmap.md) whenever progress changes the current state, milestone order, next recommended work, or acceptance criteria.
4. If a task is completed, reflect that in the roadmap during the same session unless the user explicitly asks not to.
5. If new systems are added, record only the durable project-level outcome in the roadmap, not a long changelog.

## Update Style

Keep roadmap updates lightweight and useful:

- Refresh dates when the "Current State" section becomes stale.
- Mark completed milestones or tickets clearly.
- Keep the "Next Recommended Ticket" actionable for a future chat handoff.
- Prefer short, high-signal edits over verbose notes.
