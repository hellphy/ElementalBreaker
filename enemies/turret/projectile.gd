extends HitBox2D

var travelled_distance := 0.0
@export var speed = 900.0
@export var max_range = 2000.0

func _physics_process(delta: float) -> void:

	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	
	travelled_distance += speed * delta
	if travelled_distance > max_range:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	pass
