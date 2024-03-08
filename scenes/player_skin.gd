extends Sprite2D


var skins = {
	0: preload("res://graphics/player/player.png"),
	1: preload("res://graphics/player/player2.png")
}

func _ready():
	Globals.connect("skin_change", skin_change)
	self.texture = skins[Globals.selected_skin]

func skin_change():
	self.texture = skins[Globals.selected_skin]
