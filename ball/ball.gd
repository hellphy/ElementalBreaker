extends CharacterBody2D
class_name  Ball

var ball_max_speed : = 500
var ball_speed := 200
var ball_started := false
var last_collider_id


@onready var guide: Sprite2D = $guide
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _physics_process(delta: float) -> void:
	if ball_started == true:
		ball_start(delta)
		
	var collision = move_and_collide(velocity * ball_speed * delta)
	if!collision:
		return
	var collider = collision.get_collider()
	if collider is Structures:
		collider.decrease_level()
		velocity = velocity.bounce(collision.get_normal())
	else:
		velocity = velocity.bounce(collision.get_normal())



func ball_start(delta) -> void:
	rotation = guide.rotation
	velocity = Vector2(1,0).rotated(rotation) * ball_speed * delta
	move_and_collide(velocity)
	ball_started = false
	
func ball_collision(collider) -> void:
	
	var ball_width = collision_shape_2d.shape.get_rect().size.x
	var ball_center_x = position.x
	var collider_width = collider.get_width()
	var collider_center_x = collider.position.x
	
	var velocity_xy = velocity.length()
	var collision_x = (ball_center_x - collider_center_x) / (collider_width / 2)
	
	var new_velocity = Vector2.ZERO
	
	new_velocity.x = velocity_xy * collision_x
	
	if collider.get_rid() == last_collider_id and collider is Structures:
		new_velocity.x = new_velocity.rotated(deg_to_rad(randf_range(-45, -45))) * 10
	
	else:
		last_collider_id == collider.get_rid()
	
	new_velocity.y = sqrt(absf(velocity_xy* velocity_xy - new_velocity.x * new_velocity.x)) * (-1 if velocity.y > 0 else 1)
	var speed_multiplier = 1
	
	velocity = (new_velocity * speed_multiplier).limit_length(ball_max_speed)
	
	
