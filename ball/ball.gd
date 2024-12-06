class_name  Ball extends CharacterBody2D


const VELOCITY_LIMIT = 40
@export var ball_speed = 0.0

var ball_started := false
var starting_position: Vector2

var speed_up_factor = 1.01
var start_position: Vector2
var last_collider_id

@onready var guide: Sprite2D = $guide
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D 	
@onready var _hurt_box: HurtBox2D = %HurtBox2D


func _ready() -> void:
	starting_position = position
	
	_hurt_box.took_hit.connect(func _on_hurtbox_took_hit(hit_box: HitBox2D) -> void:
		bounce_ball(hit_box.shoot_point_angle, hit_box.attack_type)
	)


func _physics_process(delta: float) -> void:
	
	velocity = Vector2.RIGHT.rotated(rotation) * ball_speed * delta 
	
	var collision = move_and_collide(velocity * ball_speed * delta)
	
	if!collision:
		return
		
	var collider = collision.get_collider()
	if collider is Block:
		collider.decrease_level()
		velocity = velocity.bounce(collision.get_normal())
		#ball_collision(collider)
		rotation = velocity.angle()
		
		
	elif collider.is_in_group("Ground"):
		collider.emit_signal("touched_ground")
		velocity = velocity.bounce(collision.get_normal())
		rotation = velocity.angle()
	
	else:
		velocity = velocity.bounce(collision.get_normal())
		rotation = velocity.angle()


func ball_collision(collider) -> void:
	
	var ball_center_x = position.x
	var collider_width = collider.get_width()
	var collider_center_x = collider.position.x
	
	var velocity_xy = velocity.length()
	
	var collision_x = (ball_center_x - collider_center_x) / (collider_width / 2)
	
	var new_velocity = Vector2.ZERO
	
	new_velocity.x = velocity_xy * collision_x
	
	if collider.get_rid() == last_collider_id && collider is Block:
		new_velocity.x = new_velocity.rotated(deg_to_rad(randf_range(-45, 45))).x * 10
	else: 
		last_collider_id = collider.get_rid()
	
	new_velocity.y = sqrt(absf(velocity_xy* velocity_xy - new_velocity.x * new_velocity.x)) * (-1 if velocity.y > 0 else 1)
	
	velocity = new_velocity.limit_length(VELOCITY_LIMIT)


func reset_ball() -> void:
	position = starting_position
	ball_speed = 0.0


func bounce_ball(shoot_point_angle, attack_type) -> void:
	
	if velocity == Vector2.ZERO:
		rotation = guide.rotation
		ball_speed = 200.0
		guide.visible = !guide.visible
		
	set_physics_process(false)
	await get_tree().create_timer(0.05).timeout
	set_physics_process(true)
	match attack_type:
		#normal attack
		0:
			var random_angle := randf_range(1,1.2)
			rotation_degrees = shoot_point_angle + 90 * random_angle
			ball_speed += 2
		#up attack
		1:
			rotation = Vector2.UP.angle()
	
