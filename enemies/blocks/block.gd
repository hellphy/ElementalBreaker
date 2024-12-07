class_name Block extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D


var phases : Array = ["red", "plum", "black", "blue",]

var current_level = phases.size()

func get_size():
	return collision_shape_2d.shape.get_rect().size

func decrease_level() -> void:
	if current_level > 1:
		current_level -= 1
		var new_level = phases[current_level]
		sprite_2d.set_self_modulate(new_level)
	else:
		queue_free()

func get_width():
	return get_size().x
