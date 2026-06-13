extends Node2D

## Damage is kept editable in the inspector so weapon tuning stays cheap.
## In GDScript, `@export` makes a variable show up in the Godot editor inspector.
@export var damage := 1

## This controls how far the visible blade sits from the player's pivot point.
@export var blade_offset := 5.0

## Track already-hit bodies so one swing does not multi-hit the same enemy.
var hit_targets := {}
## Keep a reference to the spawning actor so the sword can follow while animating.
var follow_target: Node2D = null
## Cache whichever sword scene layout is present so both old and new setups still work.
var sprite_node: Node2D = null
var hit_area: Area2D = null


func _ready():
	## `_ready()` is a built-in Godot callback that runs once when this node enters the scene tree.
	resolve_scene_nodes()

	## If the scene structure is broken, fail quietly instead of crashing the whole run.
	if sprite_node == null or hit_area == null:
		push_warning("Sword scene is missing its visual or hit area nodes.")
		return

	## Position the pivoted blade parts after exported values are available.
	sprite_node.position = Vector2(blade_offset, 0.0)
	hit_area.position = Vector2(blade_offset, 0.0)

	## Listen for overlap events from the sword's hit area.
	hit_area.body_entered.connect(_on_hit_area_body_entered)


func _process(_delta):
	## Following each frame keeps the swing attached if the player moves during the animation.
	if follow_target == null or not is_instance_valid(follow_target):
		return

	global_position = get_follow_origin()


func setup(direction: Vector2, source_node: Node2D):
	## Store the spawning actor so the sword can keep using that actor's attack anchor.
	follow_target = source_node
	global_position = get_follow_origin()
	rotation = direction.angle()


func get_follow_origin():
	## If the source node exposes a custom attack origin, use that instead of the node root.
	if follow_target != null and follow_target.has_method("get_attack_origin"):
		return follow_target.get_attack_origin()

	if follow_target != null:
		return follow_target.global_position

	return global_position


func resolve_scene_nodes():
	## Prefer the newer pivot-based structure, but support the older direct-node layout too.
	sprite_node = get_node_or_null("Pivot/Sprite2D") as Node2D
	hit_area = get_node_or_null("Pivot/HitArea") as Area2D

	if sprite_node != null and hit_area != null:
		return

	sprite_node = get_node_or_null("Sprite2D") as Node2D
	hit_area = get_node_or_null("Sprite2D/HitArea") as Area2D


func _on_hit_area_body_entered(body: Node2D):
	## `body: Node2D` is a typed parameter, which makes the expected object type explicit.
	## Ignore anything that is not part of the damageable gameplay contract.
	if not body.has_method("take_damage"):
		return

	## Instance IDs give us a stable per-node key for this swing.
	var target_id = body.get_instance_id()
	if hit_targets.has(target_id):
		return

	## Remember the target before applying damage so duplicate overlap events are harmless.
	hit_targets[target_id] = true
	body.take_damage(damage)
