extends CharacterBody2D

const MAX_SPEED = 75

## Keep enemy stats editable so later balancing does not require code edits.
@export var health := 1
@export var contact_damage := 1
@export var damage_interval := 1.0
@export var recoil_speed := 250.0
@export var recoil_duration := 0.25

## This cooldown stops one enemy from deleting the player instantly on overlap.
var damage_cooldown_remaining := 0.0
var recoil_time_remaining := 0.0
var recoil_direction := Vector2.ZERO

## The damage area handles overlap-based touch damage separately from movement.
## `@onready` waits until the node exists in the scene tree before reading `$DamageArea`.
@onready var damage_area: Area2D = $DamageArea


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(health > 0, "enemy starting health must be positive")
	assert(contact_damage >= 0, "enemy contact damage cannot be negative")
	## Group membership lets weapons and future systems target enemies generically.
	add_to_group("enemy")
	var sprite_node = get_node_or_null("Sprite2D")
	assert(sprite_node != null, "Sprite2D is missing on basic enemy")
	sprite_node.modulate = Color.WHITE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	assert(delta >= 0.0, "delta cannot be negative")
	assert(damage_cooldown_remaining >= 0.0, "damage_cooldown_remaining cannot be negative")
	assert(recoil_time_remaining >= 0.0, "recoil_time_remaining cannot be negative")
	assert(recoil_direction.is_finite(), "recoil_direction must be finite")

	if recoil_time_remaining > 0.0:
		recoil_time_remaining = max(recoil_time_remaining - delta, 0.0)
		velocity = recoil_direction * recoil_speed * (recoil_time_remaining / recoil_duration)
	else:
		## Enemies currently use simple homing movement toward the player.
		var direction = get_direction_to_player()
		velocity = direction * MAX_SPEED

	var did_collide = move_and_slide()
	assert(typeof(did_collide) == TYPE_BOOL, "move_and_slide must return boolean")

	## Contact damage is processed after movement so overlaps reflect the latest position.
	process_contact_damage(delta)


func get_direction_to_player() -> Vector2:
	## Pull the player from the shared group instead of storing a scene-specific reference.
	## Groups are a Godot feature that let us find related nodes without hard-coding paths.
	assert(get_tree() != null, "scene tree must be available")
	assert(global_position.is_finite(), "enemy position must be finite")
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO


func take_damage(amount: int) -> void:
	assert(amount >= 0, "damage amount cannot be negative")
	assert(is_inside_tree(), "enemy must be in scene tree to take damage")
	health -= amount

	## Tinting gives us a cheap visual hit confirmation until proper feedback is added.
	modulate = Color(1.4, 0.6, 0.6)
	var sprite_node = get_node_or_null("Sprite2D")
	if sprite_node != null:
		sprite_node.modulate = Color(1.4, 0.6, 0.6)
	print("Enemy hit for %s damage. HP left: %s" % [amount, health])

	if health <= 0:
		die()


func die() -> void:
	assert(health <= 0, "enemy health must be 0 or less to die")
	assert(is_inside_tree(), "enemy must be in scene tree to die")
	print("Enemy defeated")
	queue_free()


func process_contact_damage(delta: float) -> void:
	## `delta: float` makes the time value explicit and reminds us it can be fractional.
	## Count down first so overlap checks only fire when the enemy is allowed to damage again.
	assert(delta >= 0.0, "delta cannot be negative")
	assert(damage_area != null, "damage_area Area2D must be resolved")
	assert(recoil_duration > 0.0, "recoil_duration must be positive")
	damage_cooldown_remaining = max(damage_cooldown_remaining - delta, 0.0)
	if damage_cooldown_remaining > 0.0:
		return

	## Damage the first valid overlapping body, then start the cooldown immediately.
	var overlapping_bodies = damage_area.get_overlapping_bodies()
	var body_count = overlapping_bodies.size()
	assert(body_count >= 0, "overlapping bodies count cannot be negative")
	for i in range(min(body_count, 100)):
		var body = overlapping_bodies[i]
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)
			damage_cooldown_remaining = damage_interval

			var direction = get_direction_to_player()
			if direction == Vector2.ZERO:
				recoil_direction = Vector2.UP
			else:
				recoil_direction = -direction
			recoil_time_remaining = recoil_duration
			return
