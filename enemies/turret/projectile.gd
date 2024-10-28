extends HitBox2D

var travelled_distance := 0

func _physics_process(delta: float) -> void:
	const SPEED = 800
	const RANGE = 800
	
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * SPEED * delta
	
	travelled_distance += SPEED * delta
	if travelled_distance > RANGE:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	pass
