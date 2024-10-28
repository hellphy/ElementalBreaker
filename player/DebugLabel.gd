extends Label

class_name Debug_label

@export var player : Player

func _process(_delta: float) -> void:
	text = "state is : " + player.States.keys()[player.current_state]
