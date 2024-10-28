extends Sprite2D

func _ready():
	var tween = create_tween()
	tween.chain() #// Turn on Chain mode (one after the other)
	tween.set_loops() #// enables infinite looping (no arguments)
	tween.tween_property(self, "rotation", 0, 2).from(-PI) #// rotates from -180 to 0 degrees over 3 seconds
	tween.tween_property(self, "rotation", -PI, 2) #// rotates from last position (0 degrees) back to -180 over 3 seconds
