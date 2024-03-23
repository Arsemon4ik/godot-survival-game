extends CanvasLayer

func _ready():
	Ui.hide()
	set_score(Globals.enemies_killed)
	set_max_score(Globals.max_score)
	
func set_score(value: int) -> void:
	$Control/Panel/VBoxContainer/Label_killed.text = "Enemies killed: " + str(value)

func set_max_score(value: int) -> void:
	$Control/Panel/VBoxContainer/MaxScore.text = "Max Score: " + str(value)


func _on_restart_btn_pressed():
	TransitionLayer.change_scene(Globals.global_player_scene)
	
