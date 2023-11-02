extends Node2D
class_name LevelParent

# preload scenes for ProjectTiles
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")
var grenade_scene: PackedScene = preload("res://scenes/grenade.tscn")
var item_scene: PackedScene = preload("res://scenes/item.tscn")

var player_data = PlayerData.new()

@onready var last_id = 0;

func _ready():
	Globals.global_player_scene = get_tree().current_scene.scene_file_path
	get_player_max_score_from_server()

	
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

# Event if player shoot from laser
func _on_player_laser(laser_pos, direction):
	create_laser(laser_pos, direction)

# Event if player shoot from grenade
func _on_player_grenade(grenade_pos, direction):
	var grenade = grenade_scene.instantiate() as RigidBody2D
	grenade.position = grenade_pos
	grenade.linear_velocity = direction * grenade.speed
	$ProjectTiles.add_child(grenade)

func update_stats(player_position: Vector2, player_health: int, player_path_to_scene: String,
player_laser_bullets: int, player_grenade_bullets: int):
	%Player.position = player_position
	Globals.health = player_health
	Globals.laser_count = player_laser_bullets
	Globals.grenade_count = player_grenade_bullets
	Globals.global_player_scene = player_path_to_scene


func _on_pause_menu_canvas_toggle_game_paused(is_paused: bool):
	if is_paused:
		$PauseMenuCanvas.show()
	else:
		$PauseMenuCanvas.hide()


func _on_pause_menu_canvas_save_game():
	var dict: Dictionary = {}
	var player_position = Globals.global_player_position
	dict["player_x"] = player_position[0]
	dict["player_y"] = player_position[1]
	dict["player_scene"] = Globals.global_player_scene
	dict["player_laser_bullets"] = Globals.laser_count
	dict["player_grenade_bullets"] = Globals.grenade_count
	dict["player_health"] = Globals.health
	dict["player_max_score"] = Globals.max_score
	var json = JSON.new()
	var data_to_send = json.stringify(dict)
	var headers = ["Content-Type: application/json"]
	var url = 'http://127.0.0.1:8000/player/'
	$HTTPRequestPOST.request(url, headers, HTTPClient.METHOD_POST, data_to_send)

func set_new_max_score():
	var dict: Dictionary = {}
	dict["player_max_score"] = Globals.max_score
	var json = JSON.new()
	var data_to_send = json.stringify(dict)
	var headers = ["Content-Type: application/json"]
	var url = 'http://127.0.0.1:8000/player/'+str(last_id)+'/'
	$HTTPRequestPOST.request(url, headers, HTTPClient.METHOD_PATCH, data_to_send)


func _on_pause_menu_canvas_load_game():
	$HTTPRequest.request("http://127.0.0.1:8000/player/")

func get_player_max_score_from_server():
	$HTTPRequestMaxScore.request("http://127.0.0.1:8000/player/")


func _on_pause_menu_canvas_exit_game():
	get_tree().quit()


func _on_player_player_dead():
	if Globals.enemies_killed > Globals.max_score:
		Globals.max_score = Globals.enemies_killed
		set_new_max_score()
	$"Game over".set_score(Globals.enemies_killed)
	$"Game over".set_max_score(Globals.max_score)
	await get_tree().create_timer(1).timeout
	$"Game over".show()
	


#func _on_game_over_retry_game():
#	get_tree().reload_current_scene()


func _on_http_request_get_player_info_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
	var latest_save = parsed_data_from_server[-1]

	var player_position:Vector2 = Vector2(latest_save['player_x'], latest_save['player_y'])
	update_stats(player_position, latest_save['player_health'], 
	latest_save['player_scene'], latest_save['player_laser_bullets'], 
	latest_save['player_grenade_bullets'])
	load(Globals.global_player_scene)
#	var error = json.parse(result)
#	if error == OK:
#		var data_received = json.data
#		if typeof(data_received) == TYPE_ARRAY:
#			print(data_received) # Prints array
#		else:
#			print("Unexpected data")
#	else:
#		print("JSON Parse Error: ", json.get_error_message(), " in ", result, " at line ", json.get_error_line())


func _on_http_request_max_score_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
	var latest_save = parsed_data_from_server[-1]
	Globals.max_score = latest_save.player_max_score
	last_id = latest_save.id
