extends CharacterBody2D

## UI and scene controllers listen to these signals instead of polling player state.
## A `signal` is Godot's event system: other nodes can connect to it and react when it emits.
signal health_changed(current_health: int, max_health: int)
signal died

const MAX_SPEED = 200

## Exported stats let us tune survivability from the inspector later if needed.
@export var max_health := 5
@export var invulnerability_duration := 0.6

## Health is stored separately from max_health so damage can mutate the current run state.
var health := max_health
## This timer prevents the player from getting hit every frame while overlapping an enemy.
var invulnerability_remaining := 0.0
## Once dead, movement and damage handling should stop responding.
var is_dead := false


# Called when the node enters the scene tree for the first time.
func _ready():
	health = max_health
	## Emit the opening health value so the HUD is correct on scene load.
	health_changed.emit(health, max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## `_process(delta)` runs every rendered frame, and `delta` is the time since the last frame.
	if is_dead:
		return

	## While invulnerable, count down and tint the player so the state is visible.
	if invulnerability_remaining > 0.0:
		invulnerability_remaining = max(invulnerability_remaining - delta, 0.0)
		modulate = Color(1.0, 0.6, 0.6) if invulnerability_remaining > 0.0 else Color.WHITE

	## Movement stays simple for now: read input, normalize, then move at fixed speed.
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	velocity = direction * MAX_SPEED
	move_and_slide()


func get_movement_vector():
	## Convert input strengths into a direction vector for keyboard and future gamepad input.
	## `Input.get_action_strength(...)` returns a number from 0 to 1 for an input action.
	var x_movement = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x_movement, y_movement)


func take_damage(amount: int):
	## `amount: int` means this function expects an integer damage value.
	## Dead players and invulnerable players should not take repeated contact damage.
	if is_dead or invulnerability_remaining > 0.0:
		return

	## Clamp to zero so downstream UI and death logic never see negative health.
	health = max(health - amount, 0)
	invulnerability_remaining = invulnerability_duration
	modulate = Color(1.0, 0.6, 0.6)
	health_changed.emit(health, max_health)
	print("Player hit for %s damage. HP left: %s" % [amount, health])

	if health <= 0:
		die()


func die():
	if is_dead:
		return

	## Freeze the run-facing player state before notifying the rest of the scene.
	is_dead = true
	velocity = Vector2.ZERO
	modulate = Color(0.4, 0.4, 0.4)
	died.emit()
