extends CharacterBody2D

const MAX_SPEED = 75

## Keep enemy stats editable so later balancing does not require code edits.
@export var health := 1
@export var contact_damage := 1
@export var damage_interval := 1.0

## The damage area handles overlap-based touch damage separately from movement.
## `@onready` waits until the node exists in the scene tree before reading `$DamageArea`.
@onready var damage_area: Area2D = $DamageArea

## This cooldown stops one enemy from deleting the player instantly on overlap.
var damage_cooldown_remaining := 0.0


# Called when the node enters the scene tree for the first time.
func _ready():
	## Group membership lets weapons and future systems target enemies generically.
	add_to_group("enemy")
	$Sprite2D.modulate = Color.WHITE


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	## Enemies currently use simple homing movement toward the player.
	var direction = get_direction_to_player()
	velocity = direction * MAX_SPEED
	move_and_slide()

	## Contact damage is processed after movement so overlaps reflect the latest position.
	process_contact_damage(delta)


func get_direction_to_player():
	## Pull the player from the shared group instead of storing a scene-specific reference.
	## Groups are a Godot feature that let us find related nodes without hard-coding paths.
	var player_node = get_tree().get_first_node_in_group("player") as Node2D
	if player_node != null:
		return (player_node.global_position - global_position).normalized()
	return Vector2.ZERO


func take_damage(amount: int):
	health -= amount

	## Tinting gives us a cheap visual hit confirmation until proper feedback is added.
	modulate = Color(1.4, 0.6, 0.6)
	$Sprite2D.modulate = Color(1.4, 0.6, 0.6)
	print("Enemy hit for %s damage. HP left: %s" % [amount, health])

	if health <= 0:
		die()


func die():
	print("Enemy defeated")
	queue_free()


func process_contact_damage(delta: float):
	## `delta: float` makes the time value explicit and reminds us it can be fractional.
	## Count down first so overlap checks only fire when the enemy is allowed to damage again.
	damage_cooldown_remaining = max(damage_cooldown_remaining - delta, 0.0)
	if damage_cooldown_remaining > 0.0:
		return

	## Damage the first valid overlapping body, then start the cooldown immediately.
	for body in damage_area.get_overlapping_bodies():
		if body.has_method("take_damage"):
			body.take_damage(contact_damage)
			damage_cooldown_remaining = damage_interval
			return
