extends CharacterBody2D

var can_laser: bool = true
var player_nearby: bool = false
var right_gun_shoot: bool = true
var health: int = 30
var vulnerable: bool = true 

signal laser(laser_pos, direction)



func hit():
	if vulnerable:
		health -= 10
		vulnerable = false
		$Node/HitTimer.start()
		$Sprite2D.material.set_shader_parameter("progress", 1)
		$HitSound.play()
	if health <= 0:
		queue_free()
#
#func _process(_delta):
#	if player_nearby:
#		look_at(Globals.global_player_position)
#		if can_laser:
#			var marker_node = $LaserSpawnPositions.get_child(right_gun_shoot)
#			right_gun_shoot = not right_gun_shoot
#			var laser_pos: Vector2 = marker_node.global_position
#			var direction: Vector2 = (Globals.global_player_position - position).normalized()
#			laser.emit(laser_pos, direction)
#			can_laser = false
#			$Node/TimerCoolDown.start()

func _on_observing_state_processing(delta):
	rotate(1 * delta)

func _on_attack_state_processing(delta):
	look_at(Globals.global_player_position)

	if can_laser:
		print(Globals.global_player_position)
		var marker_node = $LaserSpawnPositions.get_child(right_gun_shoot)
		right_gun_shoot = not right_gun_shoot
		var laser_pos: Vector2 = marker_node.global_position
		var direction: Vector2 = (Globals.global_player_position - position).normalized()
		laser.emit(laser_pos, direction)
		can_laser = false
		$Node/TimerCoolDown.start()

func _on_attack_area_body_entered(_body):
#	player_nearby = true
	$ScoutStateMachine.send_event("player_entered")


func _on_attack_area_body_exited(_body):
#	player_nearby = false
	$ScoutStateMachine.send_event("player_exited")


func _on_timer_cool_down_timeout():
	can_laser = true


func _on_hit_timer_timeout():
	vulnerable = true
	$Sprite2D.material.set_shader_parameter("progress", 0)

