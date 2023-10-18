extends CanvasLayer

signal toggle_game_paused
signal save_game
signal load_game
signal exit_game

var game_paused: bool = false:
	set(value):
		game_paused = value
		get_tree().paused = game_paused
		emit_signal("toggle_game_paused", game_paused)


func _ready():
	hide()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		game_paused = !game_paused
	

func _on_save_btn_pressed():
	save_game.emit()


func _on_load_btn_pressed():
	load_game.emit()


func _on_exit_btn_pressed():
	exit_game.emit()
