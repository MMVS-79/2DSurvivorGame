extends Node

## This gates restart input until the run has actually ended.
var is_game_over := false

## Cache scene references once so UI and player events are easy to manage.
## `$ChildName` is Godot shorthand for getting a node by its scene path.
@onready var player = $Player
@onready var health_label: Label = $UI/HealthLabel
@onready var game_over_panel: Control = $UI/GameOverPanel


func _ready():
	## The main scene reacts to player signals and updates UI accordingly.
	## `connect(...)` hooks a signal to a function so this node can respond to player events.
	player.health_changed.connect(_on_player_health_changed)
	player.died.connect(_on_player_died)

	## Force an initial HUD refresh in case the player emitted before UI was ready.
	_on_player_health_changed(player.health, player.max_health)
	game_over_panel.visible = false


func _unhandled_input(event: InputEvent):
	## `_unhandled_input` is a built-in callback for input that was not consumed elsewhere first.
	if not is_game_over:
		return

	## A simple full-scene reload is enough for the current prototype restart loop.
	if event.is_pressed():
		get_tree().reload_current_scene()


func _on_player_health_changed(current_health: int, max_health: int):
	## Keep the HUD text derived from gameplay state rather than storing duplicate values here.
	health_label.text = "HP: %s/%s" % [current_health, max_health]


func _on_player_died():
	is_game_over = true
	## Reveal the restart prompt only after the run is over.
	game_over_panel.visible = true
