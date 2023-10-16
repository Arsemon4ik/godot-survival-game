extends Node

signal stats_change

var player_hit_sound: AudioStreamPlayer2D

var laser_count: int = 20:
	set(value):
		laser_count = value
		stats_change.emit()

var grenade_count: int = 3:
	set(value):
		grenade_count = value
		stats_change.emit()

var player_vulnerable: bool = true

var health: int = 60:
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
