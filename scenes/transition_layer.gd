extends CanvasLayer

func change_scene(scene: String) -> void:
	$AnimationPlayer.play("fade_to_black")
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(scene)
	$AnimationPlayer.play_backwards("fade_to_black")


func change_scene_on_load(scene: String) -> void:
	$AnimationPlayer.play("fade_to_black")
	print("HERE")
	await $AnimationPlayer.animation_finished
	print("HERE2")
	load(scene)
	print("LOADED")
	$AnimationPlayer.play_backwards("fade_to_black")
