extends Node2D
class_name LevelParent

# preload scenes for ProjectTiles
var laser_scene: PackedScene = preload("res://scenes/laser.tscn")
var grenade_scene: PackedScene = preload("res://scenes/grenade.tscn")
var item_scene: PackedScene = preload("res://scenes/item.tscn")

var player_data = PlayerData.new()

@onready var last_id = 0;
@onready var last_transaction_id = '';
const SERVER_HOST = "http://127.0.0.1:8000"
const PLAYER_STATE_URL = '/player_state/'
const PAYMENT_URL = '/payment/'
#@onready var player_id = 0;

func _ready():
	Globals.global_player_scene = get_tree().current_scene.scene_file_path
#	get_player_id_from_server()
#	generate_uuid()
	
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

func update_stats(player_position: Vector2, player_health: int, player_max_score: int, 
player_path_to_scene: String, player_laser_bullets: int, player_grenade_bullets: int, 
latest_skin: int, player_has_skin: bool):
	TransitionLayer.change_scene_on_load(player_path_to_scene)
	%Player.position = player_position
	Globals.health = player_health
	Globals.laser_count = player_laser_bullets
	Globals.grenade_count = player_grenade_bullets
	Globals.global_player_scene = player_path_to_scene
	Globals.max_score = player_max_score
	Globals.selected_skin = latest_skin
	Globals.player_has_skin = player_has_skin


func _on_pause_menu_canvas_toggle_game_paused(is_paused: bool):
	if is_paused:
		$PauseMenuCanvas.show()
	else:
		$PauseMenuCanvas.hide()
		
func prepare_post_data_player(player_x: float, player_y: float, player_health: int, player_path_to_scene: String,
player_laser_bullets: int, player_grenade_bullets: int, player_last_selected_skin: int, player_max_score: int,
player_has_skin: bool): 
	var dict: Dictionary = {}
	dict["player_x"] = player_x
	dict["player_y"] = player_y
	dict["player_scene"] = player_path_to_scene
	dict["player_laser_bullets"] = player_laser_bullets
	dict["player_grenade_bullets"] = player_grenade_bullets
	dict["player_health"] = player_health
	dict["player_max_score"] = player_max_score
	dict["player_last_selected_skin"] = player_last_selected_skin
	dict["player_has_skin"] = player_has_skin
	var json = JSON.new()
	var data_to_send = json.stringify(dict)
	return data_to_send

func _on_pause_menu_canvas_save_game():
	set_new_data_player()


func set_new_data_player():
	var player_position = Globals.global_player_position
	var data_to_send = prepare_post_data_player(player_position[0], player_position[1], 
	Globals.health, Globals.global_player_scene, Globals.laser_count, Globals.grenade_count, 
	Globals.selected_skin, Globals.max_score, Globals.player_has_skin)
	var headers = ["Content-Type: application/json"]
	var url = SERVER_HOST + PLAYER_STATE_URL
	$HTTPRequestPOST.request(url, headers, HTTPClient.METHOD_POST, data_to_send)
	

func set_data_player_on_death():
	var data_to_send = prepare_post_data_player(893, -228, 
	100, Globals.global_player_scene, 20, 3, 
	Globals.selected_skin, Globals.max_score, Globals.player_has_skin)
	var headers = ["Content-Type: application/json"]
	var url = SERVER_HOST + PLAYER_STATE_URL
	$HTTPRequestPOST.request(url, headers, HTTPClient.METHOD_POST, data_to_send)


func _on_pause_menu_canvas_load_game():
	$HTTPRequest.request(SERVER_HOST + PLAYER_STATE_URL)



#func get_player_id_from_server():
#	$HTTPRequestPlayerInfo.request(SERVER_HOST + "/player/")


func _on_pause_menu_canvas_exit_game():
	get_tree().quit()


func _on_player_player_dead():
	if Globals.enemies_killed > Globals.max_score:
		Globals.max_score = Globals.enemies_killed
		set_data_player_on_death()
	$"Game over".set_score(Globals.enemies_killed)
	$"Game over".set_max_score(Globals.max_score)
	await get_tree().create_timer(1).timeout
	$"Game over".show()



#func _on_http_request_get_player_info_request_completed(result, response_code, headers, body):
#	var json = JSON.new()
#	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
#	var latest_save = parsed_data_from_server[-1]
#
#	var player_position:Vector2 = Vector2(latest_save['player_x'], latest_save['player_y'])
#	update_stats(player_position, latest_save['player_health'], 
#	latest_save['player_scene'], latest_save['player_laser_bullets'], 
#	latest_save['player_grenade_bullets'], latest_save['player_last_selected_skin'], 
#	latest_save['player_has_skin'])
#	load(Globals.global_player_scene)




#
func _on_pause_menu_canvas_donate():
	$PauseMenuCanvas.hide()
	$DonateCanvas.show()

func quit_pause():
	$PauseMenuCanvas.hide()
	$DonateCanvas.hide()
	get_tree().paused = false

func _on_donate_canvas_exit_donate():
	quit_pause()


func _on_donate_canvas_skin_2():
	Globals.selected_skin = 0
	quit_pause()
	

func _on_donate_canvas_skin_1():
#	await get_tree().create_timer(3).timeout 
	if Globals.player_has_skin == true:
		Globals.selected_skin = 1
		Globals.laser_count = 50
		Globals.grenade_count = 5
		quit_pause()
		return
	print("REQUEST")
	var dict: Dictionary = {}
#	dict['player_id'] = player_id
	dict['amount'] = 20 
	last_transaction_id = generate_uuid()
	dict['transaction_id'] = last_transaction_id
	var url = SERVER_HOST + PAYMENT_URL
	var json = JSON.new()
	var data_to_send = json.stringify(dict)
	var headers = ["Content-Type: application/json"]
	$HTTPRequestPayment.request(url, headers, HTTPClient.METHOD_POST, data_to_send)


func _on_http_request_payment_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
	OS.shell_open(parsed_data_from_server)
#	await get_tree().create_timer(15).timeout 



func _on_http_request_check_payment_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
	if parsed_data_from_server.is_empty():
		print('PAYMENT PROCESS')
		return
	if Globals.selected_skin != 0:
		print('PAYEMTN ALREADY PROCESSED')
		return
	var latest_payment = parsed_data_from_server[-1]
	print(latest_payment)
	if latest_payment['transaction_id'] == last_transaction_id and latest_payment['is_success'] == true:
		print("YES SUCCESS")
		Globals.selected_skin = 1
		Globals.laser_count += 50
		Globals.grenade_count += 5
		Globals.health = 100
		quit_pause()
		

func generate_uuid():
	var timestamp = Time.get_unix_time_from_datetime_string(Time.get_time_string_from_system())
	var random = generate_random_string(6)

	var uuid = "%s-%s" % [timestamp, random]
	return uuid


func generate_random_string(length):
	var chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
	var random_str = ""

	for __ in range(length):
		random_str += chars[randi() % chars.length()]

	return random_str


func _on_http_request_check_skin_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
	if response_code != 200:
		print("JSON Parse Error: ", json.get_error_message(), " in ", result, " at line ", json.get_error_line())
		print("START WEB SERVER !!!")
		get_tree().quit()
		return
	if parsed_data_from_server.is_empty():
		print('PLAYER SKINS EMPTY')
		return
	var latest_skin = parsed_data_from_server[-1]
	if latest_skin['skin_name'] == 1:
		Globals.player_has_skin = true
		Globals.selected_skin = 1
		Globals.laser_count += 50
		Globals.grenade_count += 5
		Globals.health = 100
		
