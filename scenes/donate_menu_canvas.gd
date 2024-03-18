extends CanvasLayer

signal skin1
signal skin2
signal exit_donate
	

func _ready():
	if Globals.player_has_skin:
		$Control/Panel/VBoxContainer/skin1.text = 'ПРИДБАНО'
	

func _on_skin_1_pressed():
	skin1.emit()


func _on_skin_2_pressed():
	skin2.emit()


func _on_exit_pressed():
	exit_donate.emit()
