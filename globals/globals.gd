extends Node

signal stats_change
signal skin_change
signal enemy_killed

var player_hit_sound: AudioStreamPlayer2D

var selected_skin: int = 0:
	set(value):
		selected_skin = value
		skin_change.emit()

var laser_count: int = 20:
	set(value):
		laser_count = value
		stats_change.emit()

var grenade_count: int = 3:
	set(value):
		grenade_count = value
		stats_change.emit()

var player_vulnerable: bool = true

var health: int = 20:
	set(value):
		if value > health:
			health = min(value, 100)
		else:
			if player_vulnerable:
				health = value
				player_vulnerable = false
				player_vulnerable_timer()
				player_hit_sound.play()
		stats_change.emit()
		
var enemies_killed: int = 0:
	set(value):
		print(value)
		enemies_killed = value
		enemy_killed.emit()

var max_score: int = 0:
	set(value):
		max_score = value
		
func player_vulnerable_timer():
	await get_tree().create_timer(0.5).timeout
	player_vulnerable = true
	
var global_player_position: Vector2
var global_player_scene: String:
	set(value):
		global_player_scene = value

func _ready():
	player_hit_sound = AudioStreamPlayer2D.new()
	player_hit_sound.stream = load("res://audio/solid_impact.ogg")
	add_child(player_hit_sound)
