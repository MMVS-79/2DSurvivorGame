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


func _ready():
	## `_ready()` is a built-in Godot callback that runs once when this node enters the scene tree.
	## Position the pivoted blade parts after exported values are available.
	$Pivot/Sprite2D.position = Vector2(blade_offset, 0.0)
	$Pivot/HitArea.position = Vector2(blade_offset, 0.0)

	## Listen for overlap events from the sword's hit area.
	$Pivot/HitArea.body_entered.connect(_on_hit_area_body_entered)


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
