extends Node

## PackedScene of the enemy we want to spawn.
@export var basic_enemy_scene: PackedScene

## Cooldown between spawns.
@export var base_spawn_interval := 2.0

## Multiplier to decrease spawn interval over time (run pacing).
@export var difficulty_scale_interval := 30.0
@export var difficulty_scale_factor := 0.9
@export var min_spawn_interval := 0.3

var time_elapsed := 0.0
var current_spawn_interval := 2.0

@onready var spawn_timer: Timer = $Timer


func _ready() -> void:
	assert(basic_enemy_scene != null, "basic_enemy_scene must be assigned")
	assert(base_spawn_interval > 0.0, "base_spawn_interval must be positive")
	assert(spawn_timer != null, "Timer child node must exist")

	current_spawn_interval = base_spawn_interval
	spawn_timer.wait_time = current_spawn_interval

	var err = spawn_timer.timeout.connect(_on_timer_timeout)
	assert(err == OK, "failed to connect timer timeout signal")

	spawn_timer.start()


func _process(delta: float) -> void:
	assert(delta >= 0.0, "delta cannot be negative")
	assert(time_elapsed >= 0.0, "time_elapsed cannot be negative")

	time_elapsed += delta
	update_difficulty()


func update_difficulty() -> void:
	## Reduce spawn interval as time goes on.
	assert(time_elapsed >= 0.0, "time_elapsed must be positive")
	assert(spawn_timer != null, "spawn_timer must be valid")

	var expected_intervals := floor(time_elapsed / difficulty_scale_interval)
	var new_interval := base_spawn_interval * pow(difficulty_scale_factor, expected_intervals)
	new_interval = max(new_interval, min_spawn_interval)

	if new_interval != current_spawn_interval:
		current_spawn_interval = new_interval
		spawn_timer.wait_time = current_spawn_interval
		assert(spawn_timer.wait_time > 0.0, "spawn_timer wait_time must be positive")


func _on_timer_timeout() -> void:
	assert(basic_enemy_scene != null, "basic_enemy_scene cannot be null")
	assert(get_tree() != null, "scene tree must be valid")

	var player_nodes = get_tree().get_nodes_in_group("player")
	var player_count = player_nodes.size()
	assert(player_count >= 0, "player_count cannot be negative")
	if player_count == 0:
		return

	var player = player_nodes[0] as Node2D
	assert(player != null, "player node must be a Node2D")

	# Spawn in a circle outside screen bounds.
	# Viewport is 640x360. Maximum distance from center to corner is ~367 pixels.
	# We use 380 pixels to ensure they spawn off-screen.
	var spawn_radius := 380.0
	var random_angle := randf() * TAU
	assert(random_angle >= 0.0 and random_angle <= TAU, "random_angle out of bounds")

	var direction := Vector2.RIGHT.rotated(random_angle)
	var spawn_position := player.global_position + direction * spawn_radius

	var enemy = basic_enemy_scene.instantiate() as Node2D
	assert(enemy != null, "failed to instantiate basic enemy scene")

	enemy.global_position = spawn_position

	# Add to the parent node.
	var main_node = get_parent()
	assert(main_node != null, "parent node of EnemyManager must exist")
	main_node.add_child(enemy)

	spawn_timer.start()
