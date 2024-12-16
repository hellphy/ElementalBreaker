class_name Trail extends Line2D

const MAX_POINTS := 400

@onready var curve := Curve2D.new()


func _process(_delta: float) -> void:
	curve.add_point(get_parent().position)
	
	if curve.get_baked_points().size() > MAX_POINTS:
		curve.remove_point(0)
	points = curve.get_baked_points()
	
func stop() -> void:
	set_process(false)
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 3.0)
	await  tween.finished
	queue_free()


static func create() -> Trail:
	var scene = preload("res://ball/trail.tscn")
	return scene.instantiate()
