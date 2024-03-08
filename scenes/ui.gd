extends CanvasLayer

@onready var laser_label = $HBoxContainer/VBoxContainer/Label
@onready var grenade_label = $HBoxContainer/VBoxContainer2/Label
@onready var laser_icon = $HBoxContainer/VBoxContainer/TextureRect
@onready var grenade_icon = $HBoxContainer/VBoxContainer2/TextureRect
@onready var health_bar = $HBoxContainer/MarginContainer/TextureProgressBar

var green: Color = Color("6bbfa3")
var red: Color = Color(0.9,0,0,1)

signal save_button
signal load_button


func _ready():
	Globals.connect("stats_change", update_stats)
	update_stats() 
	

func _on_save_pressed():
	save_button.emit()


func _on_load_pressed():
	load_button.emit()


func update_laser_count():
	laser_label.text = str(Globals.laser_count)
	laser_icon.modulate = green
	update_color(Globals.laser_count, laser_label, laser_icon)


func update_grenade_count():
	grenade_label.text = str(Globals.grenade_count)
	grenade_icon.modulate = green
	update_color(Globals.grenade_count, grenade_label, grenade_icon)
	

func update_health_count():
	health_bar.value = Globals.health
	
func update_stats():
	update_laser_count()
	update_grenade_count()
	update_health_count()
	
func update_color(amount: int, label: Label, icon: TextureRect) -> void:
	if amount <= 0:
		label.modulate = red
		icon.modulate = red
	else:
		label.modulate = green
		icon.modulate = green
