extends CanvasLayer

signal skin_1
signal skin_2
signal exit_game

var game_paused: bool = false:
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)
# Called when the node enters the scene tree for the first time.
func _ready():
	hide()


func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		game_paused = !game_paused


