extends Area2D

const speed: int = 1000
var direction: Vector2 = Vector2.UP

func _ready():
	$SelfDestroyedTimer.start()

func _process(delta):
	position += direction * speed * delta
	

func _on_body_entered(body):
	if "hit" in body:
		body.hit()
	queue_free()


func _on_timer_timeout():
	queue_free()
