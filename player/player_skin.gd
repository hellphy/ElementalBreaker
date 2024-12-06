class_name PlayerSkin extends Node2D

signal finished_attacking

@onready var shoot_point: Node2D = %shoot_point
@onready var _animation_player: AnimationPlayer = %AnimationPlayer

@onready var main_attack_hit_box: HitBox2D = %MainAttackHitBox
@onready var up_attack_hit_box: HitBox2D = %UpAttackHitBox

enum Animations {
	IDLE,
	RUN,
	JUMP,
	FALL,
	ATTACK,
	UP_ATTACK,
}

@export var animation_name: Animations = Animations.IDLE: set = set_animation_name


func _ready() -> void:
	set_animation_name(Animations.IDLE)
	
	_animation_player.animation_finished.connect(func (anim_name: StringName) -> void:
		if anim_name == "attack" or anim_name == "up_attack":
			finished_attacking.emit()
	)


func _process(_delta: float) -> void:
	main_attack_hit_box.shoot_point_angle = shoot_point.rotation_degrees


func set_animation_name(new_animation: Animations) -> void:
	if animation_name == new_animation:
		return
	
	animation_name = new_animation
	match animation_name:
		Animations.IDLE:
			_animation_player.play("idle")
		Animations.RUN:
			_animation_player.play("run")
		Animations.JUMP:
			_animation_player.play("jump")
		Animations.FALL:
			_animation_player.play("fall")
		Animations.ATTACK:
			_animation_player.play("attack")
		Animations.UP_ATTACK:
			_animation_player.play("up_attack")
		Animations.RUN:
			pass
