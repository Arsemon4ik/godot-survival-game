extends Node

var load_saved_game = false
var save_filename = "user://save_gave.save"
var Player = preload("res://scenes/player.tscn")

func _ready():
	load_data()
	
func save():
	var data = {
		"player": Player.get('to'),
	}
	print(data)
	
	var file = FileAccess.open(save_filename, FileAccess.WRITE)
	var json = JSON.new()
	var json_string = json.stringify(data)
	file.store_line(json_string)
	
func load_data():
	load_saved_game = true
	
	var file_check = FileAccess.file_exists(save_filename)
	
	if file_check:
		var file = FileAccess.open(save_filename, FileAccess.READ)
		var json = JSON.new()
		var data = JSON.parse_string(file.get_as_text())
		
		Player.from_dictionary(data.player)

func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST or \
	what == NOTIFICATION_WM_GO_BACK_REQUEST:
		save()
		
