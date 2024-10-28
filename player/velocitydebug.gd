extends Label

class_name VelocityDebug

@export var player : Player

func _process(_delta: float) -> void:
	text = "velocity x: " + str(player.velocity.x)
