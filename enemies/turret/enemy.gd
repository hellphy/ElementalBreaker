extends Area2D

@onready var shooting_point: Marker2D = %ShootingPoint
@onready var timer: Timer = $Timer
@export var player: Player = null

var stop_shooting = false

func _ready() -> void:
	timer.timeout.connect(_on_timer_timeout)

func _physics_process(delta: float) -> void:
	var player_in_range = get_overlapping_bodies()
	if player_in_range.size() > 0:
		stop_shooting = false
		var target_player = player_in_range.pop_front()
		look_at(target_player.global_position)
	else:
		stop_shooting = true

func shoot() -> void:
	if stop_shooting == false:
		const PROJECTILE = preload("res://enemies/turret/projectile.tscn")
		var new_projectile = PROJECTILE.instantiate()
		new_projectile.global_position = shooting_point.global_position
		new_projectile.global_rotation = shooting_point.global_rotation
		shooting_point.add_child(new_projectile)
	else:
		pass

func _on_timer_timeout():
	if overlaps_body(player):
		shoot()
