extends CanvasLayer

func change_scene(scene: String) -> void:
	$AnimationPlayer.play("fade_to_black", -1, 1.5)
	await $AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(scene)
	$AnimationPlayer.play_backwards("fade_to_black")

func black_screen():
	$AnimationPlayer.play_backwards("fade_to_black")
	await $AnimationPlayer.animation_finished
	await get_tree().create_timer(1).timeout

func change_scene_on_load(scene: String) -> void:	
	load(scene)
