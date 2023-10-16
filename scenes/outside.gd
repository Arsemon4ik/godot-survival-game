extends LevelParent


func _on_area_2d_body_entered(_body):
	var tween = create_tween()
	tween.tween_property($Player, "speed", 0, 0.5)
	TransitionLayer.change_scene("res://scenes/inside.tscn")

# Event if player entered the house
#func _on_house_player_entered(_body):
#	var tween = get_tree().create_tween()
#	tween.tween_property($Player/Camera2D, "zoom", Vector2(0.8, 0.8), 1)
#
## Event if player exited the house
#func _on_house_player_exit(_body):
#	var tween = get_tree().create_tween()
#	tween.tween_property($Player/Camera2D, "zoom", Vector2(0.6, 0.6), 1)
