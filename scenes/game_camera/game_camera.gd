extends Camera2D

var target_position = Vector2.ZERO
var player: Node2D = null

# Called when the node enters the scene tree for the first time.
func _ready():
	make_current()
	# Cache the player node for efficiency
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		player = player_nodes[0] as Node2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-delta * 10))

func acquire_target():
	if player and player.is_inside_tree():
		target_position = player.global_position
