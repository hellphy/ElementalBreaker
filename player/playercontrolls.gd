class_name Player extends CharacterBody2D


@export var ball: Ball

var health := 3: set = set_health
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

const SPEED = 900.0
const ACCELARATION = 1800.0
const DECELERATION = 8000.0
const TURNING_ACC = 10000.0

#bools
var can_jump: bool = true
var can_walk: bool = true
var can_attack: bool = true

@onready var r_1: RayCast2D = $R1
@onready var r_2: RayCast2D = $R2
@onready var _hurt_box: HurtBox2D = %HurtBox2D
@onready var player_skin: PlayerSkin = %PlayerSkin
@onready var shoot_point: Node2D = %shoot_point
@onready var shoot_point_marker: Sprite2D = %ShootPointMarker
@onready var ground: StaticBody2D = %Ground

#timers
@onready var jump_buffer_timer: Timer = %JumpBufferTimer
@onready var coyote_timer: Timer = %CoyoteTimer
#states
enum States {
	IDLE,
 	MOVING,
 	AIR,
 	SLIDING,
 	ATTACKING,
	UP_ATTACKING,
	STAGGER,
	DIED,
	
}
var previous_state: States = States.IDLE

var current_state = States.IDLE:
	set = set_current_state

func set_current_state(new_state: States) -> void:
	previous_state = current_state
	current_state = new_state
	
	match current_state:
		
		States.IDLE:
			can_walk = true
			player_skin.set_animation_name(player_skin.Animations.IDLE)
			
		States.MOVING:
			player_skin.set_animation_name(player_skin.Animations.RUN)
			
		States.AIR:
			if previous_state == States.MOVING or previous_state == States.IDLE:
				if velocity.y > 0:
					player_skin.set_animation_name(player_skin.Animations.FALL)
					coyote_timer.start()
				if velocity.y < 0:
					player_skin.set_animation_name(player_skin.Animations.JUMP)
					
		States.SLIDING:
			velocity = Vector2.ZERO
			
		States.ATTACKING:
			if shoot_point_marker.global_position.direction_to(global_position).y > 0.99:
				player_skin.set_animation_name(player_skin.Animations.UP_ATTACK)
				
			else:
				player_skin.set_animation_name(player_skin.Animations.ATTACK)
				
		States.STAGGER:
			var skin_tween := create_tween()
			skin_tween.tween_property(player_skin,"modulate", Color.RED, 0.2)
			skin_tween.tween_property(player_skin,"modulate", Color.WHITE, 0.2)
			
			_hurt_box.set_deferred("monitorable", false)
			_hurt_box.set_deferred("monitoring", false)
			
			get_tree().create_timer(0.5).timeout.connect(func() -> void:
				set_current_state(States.IDLE)
			)
			get_tree().create_timer(stagger_amount).timeout.connect(func() -> void:
				_hurt_box.set_deferred("monitorable", true)
				_hurt_box.set_deferred("monitoring", true)
			)
			
		States.DIED:
			get_tree().reload_current_scene()



func set_health(new_health) -> void:
	health = new_health
	if health <= 0:
		set_current_state(States.DIED)


func _ready() -> void:
	_hurt_box.took_hit.connect(func _on_hurtbox_took_hit(hit_box: HitBox2D) -> void:
		take_damage(hit_box.damage)
	)
	coyote_timer.timeout.connect(func () -> void:
		can_jump = false
	)
	jump_buffer_timer.timeout.connect(func () -> void:
		can_jump = false
	)
	player_skin.finished_attacking.connect(func() -> void:
		set_current_state(States.IDLE)
	)
	ground.touched_ground.connect(func _on_ground_touched() -> void:
		health -= 1
	)


func _process(_delta: float) -> void:
	
	if shoot_point_marker.global_position.direction_to(global_position).y > 0.99:
		shoot_point_marker.modulate = Color.RED
	else:
		shoot_point_marker.modulate = Color.WHITE
	
	var mouse_to_player := get_global_mouse_position().direction_to(global_position)
	
	shoot_point.look_at(get_global_mouse_position())
	shoot_point.rotation_degrees -= 90
	
	set_direction(-1) if mouse_to_player.x > 0.0 else set_direction(1)


func _physics_process(delta: float) -> void:

	%rotation.text = str(health)

	match current_state:
		
		States.IDLE:
			
			_movement(delta)
			if velocity.x != 0 and is_on_floor():
				set_current_state(States.MOVING)
			
			if velocity.y != 0 and not is_on_floor():
				set_current_state(States.AIR)

		States.MOVING:
			_movement(delta)
			if velocity.x == 0:
				set_current_state(States.IDLE)
			
			if velocity.y != 0:
				set_current_state(States.AIR)

		States.AIR:
			_movement(delta)
			
			if velocity.y > 0:
				player_skin.set_animation_name(player_skin.Animations.FALL)
			if velocity.y < 0:
				player_skin.set_animation_name(player_skin.Animations.JUMP)
				
			if  is_on_floor() and velocity.x != 0:
				set_current_state(States.MOVING)
			
			if is_on_floor() and velocity.x == 0:
				set_current_state(States.IDLE)
			
			if !is_on_floor() and %R1.is_colliding() and %R2.is_colliding() and direction != 0:
				set_current_state(States.SLIDING)

		States.SLIDING:
			_movement(delta)
			if is_on_floor() and velocity.x == 0:
				set_current_state(States.IDLE)
				
			if is_on_floor() and velocity.x != 0:
				set_current_state(States.MOVING)
				
			if direction == 0 and is_on_wall_only():
				set_current_state(States.AIR)
				
			if !is_on_floor() and !is_on_wall():
				set_current_state(States.AIR)
				
		States.STAGGER:
				velocity = Vector2.ZERO
				
	if Input.is_action_just_pressed("attack") and can_attack:
		
		if current_state == States.STAGGER:
			return
			
		can_attack = false
		
		get_tree().create_timer(0.5).timeout.connect(func() -> void:
			can_attack = true
		)
		set_current_state(States.ATTACKING)
		
	jump()
	_apply_gravity(delta)
	move_and_slide()


func jump() -> void:
	if is_on_floor():
		can_jump = true
		
	if current_state == States.ATTACKING:
		can_jump = false
		
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start()
		
		if can_jump:
			velocity.y = -jump_force
			can_jump = false
	if Input.is_action_just_released("jump"):
		velocity.y *= 0.2


func take_damage(amount: float) -> void:
	stagger_amount = amount
	set_current_state(States.STAGGER)


func _movement(delta) -> void:
	if can_walk:
		direction = Input.get_axis("move_left", "move_right")
		if direction == 0:
			velocity.x = Vector2(velocity.x, 0).move_toward(Vector2(0,0), DECELERATION * delta).x
			return
	
		if abs(velocity.x) >= SPEED and sign(velocity.x) == direction:
			return
	
		var accel_rate : float = ACCELARATION if sign(velocity.x) == direction else TURNING_ACC
	
		velocity.x += direction * accel_rate * delta
	#
		#set_direction(direction)


func set_direction(hor_direction) -> void:
	if hor_direction == 0:
		return
	player_skin.apply_scale(Vector2(hor_direction * face_direction, 1))
	shoot_point.apply_scale(Vector2(hor_direction * face_direction, 1))
	face_direction = hor_direction


func _apply_gravity(delta) -> void:

	var applied_gravity : float = 0
	
	if velocity.y <= max_velocity:
		applied_gravity = gravity_acceleration * delta
		
	if velocity.y < 0 and velocity.y > jump_gravity_max:
		applied_gravity = 0
	
	if abs(velocity.y) < jump_hang_treshold:
		applied_gravity *= jump_hang_gravity_mult
		
	if current_state == States.SLIDING:
		applied_gravity = sliding_grav * delta

	velocity.y += applied_gravity
