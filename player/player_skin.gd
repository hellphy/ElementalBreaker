class_name PlayerSkin extends Node2D

signal finished_attacking

@onready var _animation_player: AnimationPlayer = %AnimationPlayer

enum Animations {
	IDLE,
	RUN,
	JUMP,
	FALL,
	GROUND_ATTACK,
}

@export var animation_name: Animations = Animations.IDLE: set = set_animation_name

func _ready() -> void:
	set_animation_name(Animations.IDLE)
	
	_animation_player.animation_finished.connect(func (anim_name: StringName) -> void:
		if anim_name == "ground_attack":
			finished_attacking.emit()
	)



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
		Animations.GROUND_ATTACK:
			_animation_player.play("ground_attack")
		Animations.RUN:
			pass
