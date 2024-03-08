extends CharacterBody2D

# variables for shooting
var can_laser: bool = true
var can_grenade: bool = true
var speed: int = 600

# signals
signal laser(pos, direction)
signal grenade(pos, direction)
signal player_dead

func hit():
	Globals.health -= 10
	if Globals.health <= 0:
		player_dead.emit()
		queue_free()

# manage phycics process every frame
func _physics_process(delta):
	var direction = Input.get_vector("left", "right", "up", "down")
	velocity = direction * speed * delta
	Globals.global_player_position = position
	
	# move and collision script
#	move_and_slide()
	move_and_collide(velocity)
	
	# rotate
	look_at(get_global_mouse_position())
	
	# get player_direction (mouse)
	var player_direction = (get_global_mouse_position() - position).normalized()
	
	# left mouse clicked event
	if Input.is_action_pressed("primary_action") and can_laser and Globals.laser_count > 0:
		Globals.laser_count -= 1
#		$Control/MarginContainer/Label.text = "fire"
		var laser_markers = $Projectiles.get_children()
		var selected_marker = laser_markers[randi() % laser_markers.size()]
		can_laser = false
		$ShotParticles.emitting = true
		
		$Timer.start()
		laser.emit(selected_marker.global_position, player_direction)
		
	# right mouse clicked event
	if Input.is_action_pressed("secondary_action") and can_grenade and Globals.grenade_count > 0:
		Globals.grenade_count -= 1
		var grenade_markers = $Projectiles.get_children()
		var selected_marker = grenade_markers[1]
		can_grenade = false
		
		$Timer.start()
		grenade.emit(selected_marker.global_position, player_direction)
		


# player can shoot every ... sec
func _on_timer_timeout():
	can_laser = true
	can_grenade = true
	
#func _input(event: InputEvent):
#	if event.is_action_pressed("ui_cancel"):
#		print("ESC PL")

