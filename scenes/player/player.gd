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
## Keep the last useful facing so abilities still know where to attack while standing still.
var facing_direction := Vector2.RIGHT
## Once dead, movement and damage handling should stop responding.
var is_dead := false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(max_health > 0, "max_health must be positive")
	assert(invulnerability_duration >= 0.0, "invulnerability_duration cannot be negative")
	health = max_health
	## Emit the opening health value so the HUD is correct on scene load.
	health_changed.emit(health, max_health)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	## `_process(delta)` runs every rendered frame, and `delta` is the time since the last frame.
	assert(delta >= 0.0, "delta cannot be negative")
	assert(invulnerability_remaining >= 0.0, "invulnerability_remaining cannot be negative")
	if is_dead:
		return

	## While invulnerable, count down and tint the player so the state is visible.
	if invulnerability_remaining > 0.0:
		invulnerability_remaining = max(invulnerability_remaining - delta, 0.0)
		modulate = Color(1.0, 0.6, 0.6) if invulnerability_remaining > 0.0 else Color.WHITE

	## Movement stays simple for now: read input, normalize, then move at fixed speed.
	var movement_vector = get_movement_vector()
	var direction = movement_vector.normalized()
	if direction != Vector2.ZERO:
		facing_direction = direction
	velocity = direction * MAX_SPEED
	var did_collide = move_and_slide()
	assert(typeof(did_collide) == TYPE_BOOL, "move_and_slide must return boolean")


func get_movement_vector() -> Vector2:
	## Convert input strengths into a direction vector for keyboard and future gamepad input.
	## `Input.get_action_strength(...)` returns a number from 0 to 1 for an input action.
	var x_movement = (
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	)
	var y_movement = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	assert(x_movement >= -1.0 and x_movement <= 1.0, "x_movement out of bounds")
	assert(y_movement >= -1.0 and y_movement <= 1.0, "y_movement out of bounds")
	return Vector2(x_movement, y_movement)


func get_aim_direction() -> Vector2:
	## Returning a cached facing direction keeps abilities stable when the player is not moving.
	assert(facing_direction != Vector2.ZERO, "facing_direction cannot be zero")
	assert(facing_direction.is_normalized(), "facing_direction must be normalized")
	return facing_direction


func get_attack_origin() -> Vector2:
	## `global_position` gives a node's world-space position instead of its local scene position.
	var attack_node = get_node_or_null("AttackOrigin")
	assert(attack_node != null, "AttackOrigin node is missing")
	assert(attack_node is Marker2D or attack_node is Node2D, "AttackOrigin must be a 2D node")
	return attack_node.global_position


func take_damage(amount: int) -> void:
	## `amount: int` means this function expects an integer damage value.
	## Dead players and invulnerable players should not take repeated contact damage.
	assert(amount >= 0, "damage amount cannot be negative")
	assert(max_health > 0, "max_health must be positive")
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


func die() -> void:
	assert(health <= 0, "player must have 0 or less health to die")
	assert(not is_dead, "player must not be already dead")
	if is_dead:
		return

	## Freeze the run-facing player state before notifying the rest of the scene.
	is_dead = true
	velocity = Vector2.ZERO
	modulate = Color(0.4, 0.4, 0.4)
	died.emit()
