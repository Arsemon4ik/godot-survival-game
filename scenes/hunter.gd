extends CharacterBody2D

@onready var HUNTER: NavigationAgent2D = $NavigationAgent2D
var active: bool = false
var speed: int = 250
var player_near: bool = false
var vulnerable: bool = true
var health: int = 40

func _ready():
	HUNTER.path_desired_distance = 4.0
	HUNTER.target_desired_distance = 4.0
	HUNTER.target_position = Globals.global_player_position
	

func _physics_process(_delta):
	if active:
		var next_path_position: Vector2 = HUNTER.get_next_path_position()
		var direction: Vector2 = (next_path_position - global_position).normalized()
		velocity = direction * speed
		move_and_slide()
		
		var angle = direction.angle()
		rotation = angle + PI / 2
		

func attack():
	if player_near:
		Globals.health -= 10
		

func hit():
	if vulnerable:
		health -= 10
		vulnerable = false
		$Timers/HitTimer.start()
		$Particles/HitParticles.emitting = true
		
	if health <= 0:
		await get_tree().create_timer(0.2).timeout
		Globals.enemies_killed += 1
		queue_free()
		

func _on_notice_area_body_entered(_body):
	active = true
	$AnimationPlayer.play("walk")


func _on_notice_area_body_exited(_body):
	active = false
	

func _on_navigation_timer_timeout():
	if active:
		HUNTER.target_position = Globals.global_player_position


func _on_attack_area_body_entered(_body):
	player_near = true
	$AnimationPlayer.play("attack")
	

func _on_attack_area_body_exited(_body):
	player_near = false
	

func _on_hit_timer_timeout():
	vulnerable = true
		
