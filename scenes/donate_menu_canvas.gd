extends CanvasLayer

signal skin1
signal skin2
signal exit_donate
const SERVER_HOST = "http://127.0.0.1:8000"
const PAYMENT_URL = '/payment/'
@onready var last_transaction_id = '';

func _ready():
#	await get_tree().create_timer(1).timeout
	if Globals.player_has_skin == true:
		$Control/Panel/VBoxContainer/skin1.text = 'PURCHASED'
	

func _on_skin_1_pressed():
	_on_donate_skin_1()

func _on_skin_2_pressed():
	_on_donate_skin_2()
	
	
func _on_donate_skin_2():
	Globals.selected_skin = 0

func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu_canvas.tscn")

func _on_donate_skin_1():
#	await get_tree().create_timer(3).timeout 
	if Globals.player_has_skin == true:
		Globals.selected_skin = 1
		Globals.laser_count = 50
		Globals.grenade_count = 5
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



#func _on_http_request_check_payment_request_completed(result, response_code, headers, body):
#	var json = JSON.new()
#	var parsed_data_from_server = json.parse_string(body.get_string_from_utf8())
#	if parsed_data_from_server.is_empty():
#		print('PAYMENT PROCESS')
#		return
#	if Globals.selected_skin != 0:
#		print('PAYEMTN ALREADY PROCESSED')
#		return
#	var latest_payment = parsed_data_from_server[-1]
#	print(latest_payment)
#	if latest_payment['transaction_id'] == last_transaction_id and latest_payment['is_success'] == true:
#		print("YES SUCCESS")
#		Globals.selected_skin = 1
#		Globals.laser_count = 50
#		Globals.grenade_count = 5
#		Globals.health = 100
		

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
