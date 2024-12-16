extends Area2D

@onready var shooting_point: Marker2D = %ShootingPoint
@onready var timer: Timer = $Timer
@export var player: Player = null

var can_shoot = false
@onready var hurt_box_2d: HurtBox2D = %HurtBox2D


func _ready() -> void:
	hurt_box_2d.took_hit.connect(func _on_hurtbox_took_hit(hit_box: HitBox2D) -> void:
		queue_free()
	)
	
	SignalBus.ball_started.connect(func() -> void:
		can_shoot = !can_shoot
	)
	
	timer.timeout.connect(func() -> void:
		shoot()
	)


func _process(delta: float) -> void:
	look_at(player.global_position)


func shoot() -> void:
	if can_shoot == true:
		const PROJECTILE = preload("res://enemies/turret/projectile.tscn")
		var new_projectile = PROJECTILE.instantiate()
		new_projectile.global_position = shooting_point.global_position
		new_projectile.global_rotation = shooting_point.global_rotation
		shooting_point.add_child(new_projectile)
	else:
		pass
