extends Node2D

## Damage is kept editable in the inspector so weapon tuning stays cheap.
## In GDScript, `@export` makes a variable show up in the Godot editor inspector.
@export var damage := 1

## Track already-hit bodies so one swing does not multi-hit the same enemy.
var hit_targets := {}


func _ready():
	## `_ready()` is a built-in Godot callback that runs once when this node enters the scene tree.
	## Listen for overlap events from the sword's hit area.
	$Sprite2D/HitArea.body_entered.connect(_on_hit_area_body_entered)


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
