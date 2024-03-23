extends LevelParent


func _on_area_2d_body_entered(_body):
	var tween = create_tween()
	tween.tween_property($Player, "speed", 0, 0.5)
	await tween.finished
	TransitionLayer.change_scene("res://scenes/outside.tscn")

#func _ready():
#	TransitionLayer.black_screen()
#	get_player_data_from_server()
#	return super._ready()

#func get_player_data_from_server():
#	$HTTPRequestPlayerData.timeout = 2
#	$HTTPRequestPlayerData.request(SERVER_HOST + PLAYER_STATE_URL)
#
#func _on_http_request_player_data_request_completed(result, response_code, headers, body):
#	var json = JSON.new()
#	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
#	if response_code != 200:
#		print("JSON Parse Error: ", json.get_error_message(), " in ", result, " at line ", json.get_error_line())
#		print("START WEB SERVER !!!")
#		get_tree().quit()
#		return
#
#	if parsed_data_from_server.is_empty():
#		Globals.last_id = 1
#	else:
#		var latest_save = parsed_data_from_server[-1]
#		var player_position:Vector2 = Vector2(latest_save['player_x'], latest_save['player_y'])
#		update_stats(player_position, latest_save['player_health'], latest_save['player_max_score'],
#		latest_save['player_scene'], latest_save['player_laser_bullets'], 
#		latest_save['player_grenade_bullets'], latest_save['player_last_selected_skin'], 
#		latest_save['player_has_skin'])
