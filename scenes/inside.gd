extends LevelParent


func _on_area_2d_body_entered(_body):
	var tween = create_tween()
	tween.tween_property($Player, "speed", 0, 0.5)
	await tween.finished
	TransitionLayer.change_scene("res://scenes/outside.tscn")
