class_name Block extends StaticBody2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = %CollisionShape2D
@onready var detect_area: Area2D = %detect_area


var phases : Array = [
preload("res://enemies/blocks/glass.png"),
preload("res://enemies/blocks/wood.png"),
preload("res://enemies/blocks/stone.png"),
preload("res://enemies/blocks/metal.png"),
]

var current_level = phases.size()

func _ready() -> void:
	var random_type = phases.pick_random()
	sprite_2d.texture = random_type

func get_size():
	return collision_shape_2d.shape.get_rect().size

func decrease_level() -> void:
	if current_level > 1:
		current_level -= 1
		var new_level = phases[current_level]
		sprite_2d.texture = new_level
	else:
		queue_free()

func get_width():
	return get_size().x
