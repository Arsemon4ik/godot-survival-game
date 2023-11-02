extends CharacterBody2D

var active: bool = false
var vulnerable: bool = true
var speed: int = 220
var max_speed: int = 700
var speed_multiplyer: int = 1
var health: int = 20

var explosion_active: bool = false
var explosion_radius: int = 200


func _ready():
	$Sprite2D.show()
	$Explosion.hide()

func _physics_process(delta):
	if active:
		look_at(Globals.global_player_position)
		var direction = (Globals.global_player_position - position).normalized()
		velocity = direction * speed * speed_multiplyer
		var collision = move_and_collide(velocity * delta)
		
		
		if collision:
			$AnimationPlayer.play("explosion")
			explosion_active = true
			
		if explosion_active:
			look_at(Vector2.ZERO)
			var targets = get_tree().get_nodes_in_group("Container") + get_tree().get_nodes_in_group("Entity")
			for target in targets:
				var in_range = target.global_position.distance_to(global_position) < explosion_radius
				if "hit" in target and in_range:
					target.hit()
			
func stop_movement():
	speed_multiplyer = 0
	Globals.enemies_killed += 1
	
func hit():
	if vulnerable: 
		health -= 10
		vulnerable = false
		$Sprite2D.material.set_shader_parameter("progress", 1)
		$HitTimer.start()
	if health <= 0:
		$AnimationPlayer.play("explosion")

		explosion_active = true


func _on_notice_area_body_entered(_body):
	active = true
	var tween = create_tween()
	tween.tween_property(self, "speed", max_speed, 4)


func _on_hit_timer_timeout():
	$Sprite2D.material.set_shader_parameter("progress", 0)
	vulnerable = true
