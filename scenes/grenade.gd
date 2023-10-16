extends RigidBody2D

const speed: int = 500

var exposion_active: bool = false
var explosion_radius: int = 200



func explode():
	$AnimationPlayer.play("Explosion")
	exposion_active = true
	
func _process(_delta):
	if exposion_active:
		var targets = get_tree().get_nodes_in_group("Container") + get_tree().get_nodes_in_group("Entity")
		for target in targets:
			var in_range = target.global_position.distance_to(global_position) < explosion_radius
			
			if "hit" in target and in_range:
				print(target)
				target.hit()
