extends CanvasLayer

signal retry_game

func _ready():
	hide()
	
func set_score(value: int) -> void:
	$Control/Panel/VBoxContainer/Label_killed.text = "Enemies killed: " + str(value)

func set_max_score(value: int) -> void:
	$Control/Panel/VBoxContainer/MaxScore.text = "Max Score: " + str(value)


func _on_restart_btn_pressed():
	get_tree().reload_current_scene()
	Globals.health = 20
	Globals.laser_count = 20
