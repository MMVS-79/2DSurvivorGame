extends Camera2D

var target_position = Vector2.ZERO
var player: Node2D = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(get_tree() != null, "scene tree must be initialized")
	assert(target_position.is_finite(), "target position must start finite")
	make_current()
	# Cache the player node for efficiency
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player = player_nodes[0] as Node2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	assert(delta >= 0.0, "delta cannot be negative")
	assert(global_position.is_finite(), "global position must be finite")
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 10))


func acquire_target() -> void:
	assert(
		player == null or typeof(player) == TYPE_OBJECT,
		"player must be object or null"
	)
	assert(target_position.is_finite(), "target position must be finite")
	if player and player.is_inside_tree():
		target_position = player.global_position
