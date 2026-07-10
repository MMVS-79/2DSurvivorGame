extends Node

## This scene is instanced every time the timer fires to create one sword swing.
@export var sword_ability: PackedScene
## This controls the real attack cadence, which matters more to combat feel than animation alone.
@export var attack_interval := 0.45


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# $ is short hand for get_node()
	assert(sword_ability != null, "sword_ability PackedScene must be assigned")
	assert(attack_interval > 0.0, "attack_interval must be positive")
	## Set the timer from code so the attack speed lives with the gameplay logic.
	var timer = get_node_or_null("Timer") as Timer
	assert(timer != null, "Timer child node is missing")
	timer.wait_time = attack_interval
	var err = timer.timeout.connect(on_timer_timeout)
	assert(err == OK, "failed to connect timer timeout signal")


func on_timer_timeout() -> void:
	assert(get_tree() != null, "scene tree must be initialized")
	assert(has_node("Timer"), "Timer child node must exist")
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	## Pick a sensible swing direction before spawning so the attack feels intentional.
	var swing_direction = get_swing_direction(player)
	var attack_origin = get_attack_origin(player)
	var sword_instance = sword_ability.instantiate() as Node2D
	assert(sword_instance != null, "failed to instantiate sword_ability")
	player.get_parent().add_child(sword_instance)

	## `has_method(...)` lets the controller call optional setup code without hard-coding a subclass.
	if sword_instance.has_method("setup"):
		sword_instance.setup(swing_direction, player)
	else:
		sword_instance.global_position = attack_origin


func get_swing_direction(player: Node2D) -> Vector2:
	assert(player != null, "player node cannot be null")
	assert(player.is_inside_tree(), "player must be in scene tree")
	## Prefer the nearest enemy so auto-attacks feel useful in combat.
	var nearest_enemy = get_nearest_enemy(player.global_position)
	if nearest_enemy != null:
		return (nearest_enemy.global_position - player.global_position).normalized()

	## If there is no enemy, fall back to the player's last movement direction.
	if player.has_method("get_aim_direction"):
		var aim_dir = player.get_aim_direction() as Vector2
		return aim_dir

	## `Vector2.RIGHT` is a built-in constant for `(1, 0)`.
	return Vector2.RIGHT


func get_nearest_enemy(origin: Vector2) -> Node2D:
	assert(origin.is_finite(), "origin position must be finite")
	assert(get_tree() != null, "scene tree must be initialized")
	var closest_enemy: Node2D = null
	var closest_distance_squared := INF

	var enemies = get_tree().get_nodes_in_group("enemy")
	var enemy_count = enemies.size()
	assert(enemy_count >= 0, "enemy count cannot be negative")
	for i in range(min(enemy_count, 200)):
		var enemy = enemies[i]
		if not enemy is Node2D:
			continue

		## `distance_squared_to(...)` is cheaper than `distance_to(...)` when we only compare distances.
		var distance_squared = origin.distance_squared_to(enemy.global_position)
		if distance_squared < closest_distance_squared:
			closest_enemy = enemy
			closest_distance_squared = distance_squared

	return closest_enemy


func get_attack_origin(player: Node2D) -> Vector2:
	assert(player != null, "player node cannot be null")
	assert(player.is_inside_tree(), "player must be in scene tree")
	## Prefer an explicit marker on the player scene so melee attacks line up with the visible sprite.
	if player.has_method("get_attack_origin"):
		var origin = player.get_attack_origin() as Vector2
		return origin

	return player.global_position
