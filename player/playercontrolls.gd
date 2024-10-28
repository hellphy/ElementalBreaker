class_name Player extends CharacterBody2D

#gravity
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var wall_slide_grav = 120

var gravity_acceleration : float = 3840
var max_velocity = 1000
var sliding_grav = gravity_acceleration * 0.1

#jump variables
var jump_force : float = 1700
var jump_cut : float = 0.25
var jump_gravity_max : float = 500
var jump_hang_treshold : float = 2.0
var jump_hang_gravity_mult : float = 0.1

#player movement
var stagger_amount: float = 0

var face_direction = 1
var direction

const SPEED = 700.0
const ACCELARATION = 900.0
const DECELERATION = 5000.0
const TURNING_ACC = 3000.0

#bools
var can_move: bool = true
var can_jump: bool = true

@onready var r_1: RayCast2D = $R1
@onready var r_2: RayCast2D = $R2
@onready var _hurt_box: HurtBox2D = %HurtBox2D

#states
enum States {
	IDLE,
 	MOVING,
 	AIR,
 	SLIDING,
 	ATTACKING,
	STAGGER,
	DIED,
	
}
var current_state = States.IDLE:
	set = set_current_state


func set_current_state(new_state: States) -> void:
	current_state = new_state
	
	match current_state:
		
		States.IDLE:
			can_move = true
		States.MOVING:
			pass
		States.AIR:
			pass
		States.SLIDING:
			velocity = Vector2.ZERO
		States.ATTACKING:
			%Animations.play("swing_attack")
			velocity = Vector2.ZERO
			can_move = false
		States.STAGGER:
			velocity = Vector2.ZERO
			_hurt_box.set_deferred("monitorable", false)
			_hurt_box.set_deferred("monitoring", false)
			can_move = false
			get_tree().create_timer(stagger_amount).timeout.connect(func() -> void:
				_hurt_box.set_deferred("monitorable", true)
				_hurt_box.set_deferred("monitoring", true)
				set_current_state(States.IDLE)
			)
		States.DIED:
			pass

func _ready() -> void:
	_hurt_box.took_hit.connect(func _on_hurtbox_took_hit(hit_box: HitBox2D) -> void:
		take_damage(hit_box.damage)
	)

func _physics_process(delta: float) -> void:
	match current_state:
		
		States.IDLE:
			if velocity.x != 0 and is_on_floor():
				set_current_state(States.MOVING)
			
			if velocity.y != 0 and not is_on_floor():
				set_current_state(States.AIR)

		States.MOVING:
			if velocity.x == 0:
				set_current_state(States.IDLE)
			
			if velocity.y != 0:
				set_current_state(States.AIR)

		States.AIR:
			if  is_on_floor() and velocity.x != 0:
				set_current_state(States.MOVING)
			
			if is_on_floor() and velocity.x == 0:
				set_current_state(States.IDLE)
			
			if !is_on_floor() and %R1.is_colliding() and %R2.is_colliding() and direction != 0:
				set_current_state(States.SLIDING)

		States.SLIDING:
			if is_on_floor() and velocity.x == 0:
				set_current_state(States.IDLE)
				
			if is_on_floor() and velocity.x != 0:
				set_current_state(States.MOVING)
				
			if direction == 0 and is_on_wall_only():
				set_current_state(States.AIR)
				
			if !is_on_floor() and !is_on_wall():
				set_current_state(States.AIR)

	_movement(delta)
	_apply_gravity(delta)
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y += -jump_force
	if Input.is_action_just_released("jump"):
		velocity.y -= (jump_cut * velocity.y)
		
	if Input.is_action_just_pressed("attack"):
		set_current_state(States.ATTACKING)

func take_damage(amount: float) -> void:
	("print staggered")
	stagger_amount = amount
	set_current_state(States.STAGGER)
	

func _movement(delta) -> void:
	if !can_move:
		return
	
	direction = Input.get_axis("move_left", "move_right")
	if direction == 0:
		velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), DECELERATION * delta).x
		return

	if abs(velocity.x) >= SPEED and sign(velocity.x) == direction:
		return

	var accel_rate : float = ACCELARATION if sign(velocity.x) == direction else TURNING_ACC

	velocity.x += direction * accel_rate * delta

	set_direction(direction)

func set_direction(hor_direction) -> void:
	if hor_direction == 0:
		return
	apply_scale(Vector2(hor_direction * face_direction, 1))
	face_direction = hor_direction

func _apply_gravity(delta) -> void:
	if current_state == States.ATTACKING:
		return
	
	var applied_gravity : float = 0
	
	if velocity.y <= max_velocity:
		applied_gravity = gravity_acceleration * delta
		
	#if velocity.y < 0 and velocity.y > jump_gravity_max:
		#applied_gravity = 0
	#
	#if abs(velocity.y) < jump_hang_treshold:
		#applied_gravity *= jump_hang_gravity_mult
		
	if current_state == States.SLIDING:
		applied_gravity = sliding_grav * delta
		
		
	velocity.y += applied_gravity

func _on_weapon_body_entered(body: Node2D) -> void:
	if body.velocity == Vector2.ZERO:
		body.ball_started = true
	var knockback : Vector2 = global_position.direction_to(body.global_position) * 3
	body.velocity = knockback
