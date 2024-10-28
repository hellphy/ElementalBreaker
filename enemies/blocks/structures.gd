extends StaticBody2D

class_name Structures

@onready var sprite_2d: Sprite2D = $Sprite2D


var phases : Array = ["red", "plum", "black", "blue",]

var current_level = phases.size()

func decrease_level() -> void:
	if current_level > 1:
		current_level -= 1
		var new_level = phases[current_level]
		sprite_2d.set_self_modulate(new_level)
	else:
		queue_free()
