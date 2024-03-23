extends CanvasLayer

signal toggle_game_paused
signal save_game
signal load_game
signal exit_game
signal donate

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


func _on_exit_btn_pressed():
	game_paused = false
	TransitionLayer.change_scene('res://scenes/main_menu_canvas.tscn')



#func _on_donate_pressed():
#	donate.emit()
