extends CanvasLayer

signal continue_game
const SERVER_HOST = "http://127.0.0.1:8000"
const PLAYER_STATE_URL = '/player_state/'


func _ready():
	
	Ui.hide()
	if not Globals.game_started:
		get_player_data_from_server()

func get_player_data_from_server():
	$HTTPRequestPlayerData.timeout = 2
	$HTTPRequestPlayerData.use_threads = true
	$HTTPRequestPlayerData.request(SERVER_HOST + PLAYER_STATE_URL)

func _on_http_request_player_data_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
	if response_code != 200:
		print("JSON Parse Error: ", json.get_error_message(), " in ", result, " at line ", json.get_error_line())
		print("START WEB SERVER !!!")
		get_tree().quit()
		return
		
	if not parsed_data_from_server.is_empty():
		var latest_save = parsed_data_from_server[-1]
		var player_position:Vector2 = Vector2(latest_save['player_x'], latest_save['player_y'])
		update_stats(player_position, latest_save['player_health'], latest_save['player_max_score'],
		latest_save['player_scene'], latest_save['player_laser_bullets'], 
		latest_save['player_grenade_bullets'], latest_save['player_last_selected_skin'], 
		latest_save['player_has_skin'])

func update_stats(player_position: Vector2, player_health: int, player_max_score: int, 
player_path_to_scene: String, player_laser_bullets: int, player_grenade_bullets: int, 
latest_skin: int, player_has_skin: bool):
	TransitionLayer.change_scene_on_load(player_path_to_scene)
	Globals.global_player_position = player_position
	Globals.health = player_health
	Globals.laser_count = player_laser_bullets
	Globals.grenade_count = player_grenade_bullets
	Globals.global_player_scene = player_path_to_scene
	Globals.max_score = player_max_score
	Globals.selected_skin = latest_skin
	Globals.player_has_skin = player_has_skin
	
	Globals.game_started = true
	


func _on_start_pressed():
	self.hide()
	TransitionLayer.change_scene(Globals.global_player_scene)


#func _on_continue_pressed():
#	continue_game.emit()


func _on_donate_pressed():
	get_tree().change_scene_to_file("res://scenes/donate_menu_canvas.tscn")


func _on_exit_pressed():
	get_tree().quit()


func _on_timer_timeout():
	$ProgressBar.value += randi_range(10, 20)
#	print($HTTPRequestPlayerData.get_downloaded_bytes())
