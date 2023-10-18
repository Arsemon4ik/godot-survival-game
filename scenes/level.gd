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

@onready var last_id: int 

func _ready():
	verify_save_directory(save_file_path)
	Globals.global_player_scene = get_tree().current_scene.scene_file_path
	print(Globals.global_player_scene)
	last_id = get_last_id_from_db()
	Globals.max_score = get_player_max_score_from_db()
	
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
	var table_name = "player_data"
	db.query('select * from ' + table_name + ' order by id desc limit 1')
	printerr(db.query_result)
	return { 
		"player_position" : Vector2(db.query_result[0]['player_x'], db.query_result[0]['player_y']), 
		"player_health" : int(db.query_result[0]['player_health']), 
		"player_path_to_scene" : str(db.query_result[0]['player_scene']), 
		"player_laser_bullets" : int(db.query_result[0]['player_laser_bullets']), 
		"player_grenade_bullets" : int(db.query_result[0]['player_grenade_bullets']),
		}

func get_player_max_score_from_db():
	db.path = db_name
	db.open_db()
	var table_name = "player_data"
	db.query('select player_max_score from ' + table_name + ' order by id desc limit 1')
	print("MAX SCORE: " + str(db.query_result[0]['player_max_score']))
	var output = int(db.query_result[0]['player_max_score'])
	if output != 0: 
		return output
	else:
		return 0

func get_last_id_from_db():
	db.path = db_name
	db.open_db()
	var table_name = "player_data"
	db.query('select id from ' + table_name + ' order by id desc limit 1')
	print("LAST ID: " + str(db.query_result[0]['id']))
	var id = int(db.query_result[0]['id'])
	if id != 0: 
		return id
	else:
		return 0
	
	
func set_player_position_to_db(player_position: Dictionary):
	db = SQLite.new() as SQLite
	db.path = db_name
	db.open_db()
	db.insert_row("player_data", player_position)

func set_player_max_score_to_db(player_max_score: int):
	db = SQLite.new() as SQLite
	db.path = db_name
	db.open_db()
	var table_name = "player_data"
#	db.query_with_bindings('update player_max_score from ' + table_name + ' SET player_max_score=? WHERE id = (SELECT MAX(id) FROM + ' + table_name +')', [player_max_score])
#	db.get_autocommit()
	db.update_rows(table_name, "id=" + str(last_id), {'player_max_score': str(player_max_score)})
#	db.close_db()

func update_stats(player_position: Vector2, player_health: int, player_path_to_scene: String,
player_laser_bullets: int, player_grenade_bullets: int):
	%Player.position = player_position
	Globals.health = player_health
	Globals.laser_count = player_laser_bullets
	Globals.grenade_count = player_grenade_bullets
	Globals.global_player_scene = player_path_to_scene



func _on_ui_save_button():
#	player_data.player_position = %Player.global_position
	var player_position = Globals.global_player_position
	var dict: Dictionary = {}
	dict["player_x"] = player_position[0]
	dict["player_y"] = player_position[1]
	dict["player_scene"] = Globals.global_player_scene
	dict["player_laser_bullets"] = Globals.laser_count
	dict["player_grenade_bullets"] = Globals.grenade_count
	dict["player_health"] = Globals.health
	dict["player_max_score"] = Globals.health
	set_player_position_to_db(dict)
#	ResourceSaver.save(player_data, save_file_path + save_file_name)
	

func _on_ui_load_button():
#	player_data = ResourceLoader.load(save_file_path + save_file_name).duplicate(true)
	player_data = get_player_position_from_db()
#	update_position(player_data.player_position)



func _on_pause_menu_canvas_toggle_game_paused(is_paused: bool):
	if is_paused:
		$PauseMenuCanvas.show()
	else:
		$PauseMenuCanvas.hide()


func _on_pause_menu_canvas_save_game():
	var player_position = Globals.global_player_position
	var dict: Dictionary = {}
	dict["player_x"] = player_position[0]
	dict["player_y"] = player_position[1]
	dict["player_scene"] = Globals.global_player_scene
	dict["player_laser_bullets"] = Globals.laser_count
	dict["player_grenade_bullets"] = Globals.grenade_count
	dict["player_health"] = Globals.health
	dict["player_max_score"] = Globals.max_score
	set_player_position_to_db(dict)


func _on_pause_menu_canvas_load_game():
	player_data = get_player_position_from_db()
#	TransitionLayer.change_scene_on_load(Globals.global_player_scene)
	update_stats(player_data.player_position, player_data.player_health, 
	player_data.player_path_to_scene, player_data.player_laser_bullets, 
	player_data.player_grenade_bullets)
	load(Globals.global_player_scene)
#	get_tree().paused = false



func _on_pause_menu_canvas_exit_game():
	get_tree().quit()


func _on_player_player_dead():
	if Globals.enemies_killed > Globals.max_score:
		Globals.max_score = Globals.enemies_killed
		set_player_max_score_to_db(Globals.max_score)
	$"Game over".set_score(Globals.enemies_killed)
	$"Game over".set_max_score(Globals.max_score)
	await get_tree().create_timer(1).timeout
	$"Game over".show()
	


#func _on_game_over_retry_game():
#	get_tree().reload_current_scene()
