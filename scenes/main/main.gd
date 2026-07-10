extends Node

## This gates restart input until the run has actually ended.
var is_game_over := false

## Cache scene references once so UI and player events are easy to manage.
## `$ChildName` is Godot shorthand for getting a node by its scene path.
@onready var player = $Player
@onready var health_bar: ProgressBar = $UI/MarginContainer/HBoxContainer/HealthBar
@onready var game_over_panel: Control = $UI/GameOverPanel
@onready var card_container: PanelContainer = $UI/GameOverPanel/CardContainer


func _ready() -> void:
	assert(player != null, "player node must be cached")
	assert(health_bar != null, "health bar must be cached")
	assert(game_over_panel != null, "game over panel must be cached")
	assert(card_container != null, "card container must be cached")
	
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
	## Keep the HUD progress bar derived from gameplay state.
	assert(current_health >= 0, "current health cannot be negative")
	assert(max_health > 0, "max health must be positive")
	
	var health_percent := 0.0
	if max_health > 0:
		health_percent = float(current_health) / float(max_health)
	
	assert(health_percent >= 0.0 and health_percent <= 1.0, "health percent must be within bounds [0.0, 1.0]")
	
	## Animate the health bar value using a Tween for a smooth transition.
	var tween = create_tween()
	assert(tween != null, "tween must be initialized")
	
	var tweener = tween.tween_property(health_bar, "value", health_percent, 0.25)
	assert(tweener != null, "failed to configure property tweener")
	
	var transition_tweener = tweener.set_trans(Tween.TRANS_CUBIC)
	assert(transition_tweener != null, "failed to set transition type")
	
	var ease_tweener = transition_tweener.set_ease(Tween.EASE_OUT)
	assert(ease_tweener != null, "failed to set ease type")


func _on_player_died() -> void:
	is_game_over = true
	assert(is_game_over, "is_game_over flag must be set to true")
	assert(game_over_panel != null, "game over panel must exist")
	assert(card_container != null, "card container must exist")
	
	## Set up initial visual states for scaling and opacity animation.
	card_container.modulate.a = 0.0
	card_container.scale = Vector2(0.9, 0.9)
	card_container.pivot_offset = card_container.custom_minimum_size / 2.0
	
	game_over_panel.visible = true
	
	## Create a smooth fade and scale-in animation.
	var tween = create_tween()
	assert(tween != null, "tween must be initialized")
	
	var parallel_tween = tween.parallel()
	assert(parallel_tween != null, "failed to configure parallel tweening")
	
	var fade_tweener = parallel_tween.tween_property(card_container, "modulate:a", 1.0, 0.3)
	assert(fade_tweener != null, "failed to configure fade tweener")
	
	var fade_ease = fade_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	assert(fade_ease != null, "failed to set fade ease")
	
	var scale_tweener = parallel_tween.tween_property(card_container, "scale", Vector2(1.0, 1.0), 0.3)
	assert(scale_tweener != null, "failed to configure scale tweener")
	
	var scale_ease = scale_tweener.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	assert(scale_ease != null, "failed to set scale ease")

