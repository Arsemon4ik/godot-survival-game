extends Node2D
class_name LevelParent

# preload scenes for ProjectTiles
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")
var grenade_scene: PackedScene = preload("res://scenes/grenade.tscn")
var item_scene: PackedScene = preload("res://scenes/item.tscn")
#var SQLite3 = preload("res://addons/godot-sqlite/gdsqlite.gdextension")

var db_name = "res://DataStore/db"
var db = SQLite.new() as SQLite

var save_file_path = "user://save/"
var save_file_name = "PlayerSave.tres"

var player_data = PlayerData.new()

func _ready():
	verify_save_directory(save_file_path)
	
	for container in get_tree().get_nodes_in_group("Container"):
		container.connect("open", _on_container_opened)
	
	for scout in get_tree().get_nodes_in_group("Scouts"):
		scout.connect("laser", _on_scout_laser)
		
func _on_scout_laser(laser_pos, direction):
	create_laser(laser_pos, direction)

func _on_container_opened(pos, direction):
	var item = item_scene.instantiate()
	item.position = pos
	item.direction = direction
	$Items.call_deferred("add_child", item)
	
	
func create_laser(laser_pos, direction):
	var laser = laser_scene.instantiate() as Area2D
	laser.position = laser_pos
	laser.rotation_degrees = rad_to_deg(direction.angle()) + 90
	laser.direction = direction
	$ProjectTiles.add_child(laser)

func verify_save_directory(path: String):
	DirAccess.make_dir_absolute(path)

# Event if player shoot from laser
func _on_player_laser(laser_pos, direction):
	create_laser(laser_pos, direction)

# Event if player shoot from grenade
func _on_player_grenade(grenade_pos, direction):
	var grenade = grenade_scene.instantiate() as RigidBody2D
	grenade.position = grenade_pos
	grenade.linear_velocity = direction * grenade.speed
	$ProjectTiles.add_child(grenade)


func get_player_position_from_db():
	db.path = db_name
	db.open_db()
	var table_name = "game_data"
	db.query('select * from ' + table_name + ' order by id desc limit 1')
	print(db.query_result)
	return { 
		"player_position" : Vector2(db.query_result[0]['player_x'], db.query_result[0]['player_y']) 
		}
	
		
func set_player_position_to_db(player_position: Dictionary):
	db = SQLite.new() as SQLite
	db.path = db_name
	db.open_db()
	db.insert_row("game_data", player_position)


func update_position(player_position: Vector2):
	%Player.position = player_position



func _on_ui_save_button():
#	player_data.player_position = %Player.global_position
	var player_position =  %Player.global_position
	var dict: Dictionary = {}
	dict["player_x"] = player_position[0]
	dict["player_y"] = player_position[1]
	set_player_position_to_db(dict)
#	ResourceSaver.save(player_data, save_file_path + save_file_name)
	

func _on_ui_load_button():
#	player_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	player_data = get_player_position_from_db()
	update_position(player_data.player_position)

