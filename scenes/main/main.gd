extends Node

## This gates restart input until the run has actually ended.
var is_game_over := false

## Cache scene references once so UI and player events are easy to manage.
## `$ChildName` is Godot shorthand for getting a node by its scene path.
@onready var player = $Player
@onready var health_label: Label = $UI/HealthLabel
@onready var game_over_panel: Control = $UI/GameOverPanel


func _ready() -> void:
	assert(player != null, "player node must be cached")
	assert(health_label != null, "health label must be cached")
	assert(game_over_panel != null, "game over panel must be cached")
	## The main scene reacts to player signals and updates UI accordingly.
	## `connect(...)` hooks a signal to a function so this node can respond to player events.
	var err1 = player.health_changed.connect(_on_player_health_changed)
	assert(err1 == OK, "failed to connect player health_changed signal")
	var err2 = player.died.connect(_on_player_died)
	assert(err2 == OK, "failed to connect player died signal")

	## Force an initial HUD refresh in case the player emitted before UI was ready.
	_on_player_health_changed(player.health, player.max_health)
	game_over_panel.visible = false


func _unhandled_input(event: InputEvent) -> void:
	## `_unhandled_input` is a built-in callback for input that was not consumed elsewhere first.
	assert(event != null, "unhandled input event cannot be null")
	assert(get_tree() != null, "scene tree must be initialized")
	if not is_game_over:
		return

	## A simple full-scene reload is enough for the current prototype restart loop.
	if event.is_pressed():
		var err = get_tree().reload_current_scene()
		assert(err == OK, "failed to reload current scene")


func _on_player_health_changed(current_health: int, max_health: int) -> void:
	## Keep the HUD text derived from gameplay state rather than storing duplicate values here.
	assert(current_health >= 0, "current health cannot be negative")
	assert(max_health > 0, "max health must be positive")
	health_label.text = "HP: %s/%s" % [current_health, max_health]


func _on_player_died() -> void:
	is_game_over = true
	assert(is_game_over, "is_game_over flag must be set to true")
	assert(game_over_panel != null, "game over panel must exist")
	## Reveal the restart prompt only after the run is over.
	game_over_panel.visible = true
