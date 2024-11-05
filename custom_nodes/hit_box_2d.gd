@tool
class_name HitBox2D extends Area2D

signal hit_hurt_box(hurt_box: HurtBox2D)

const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10
const DAMAGE_SOURCE_BALL := 0b11

@export var damage := 1.0
@export_flags("Player", "Mob", "Ball") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source
@export_flags("Player", "Mob", "Ball") var detect_hurtboxes := DAMAGE_SOURCE_MOB: set = set_detected_hurtboxes

func set_detected_hurtboxes(new_value: int) -> void:
	detect_hurtboxes = new_value
	collision_mask = detect_hurtboxes

func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_layer = damage_source

func _init() -> void:
	area_entered.connect(func _on_area_entered(area: Area2D) -> void:
		if area is HurtBox2D:
			hit_hurt_box.emit(area)
	)
	
	body_entered.connect(func _on_body_entered(body: Node2D) -> void:
		if body is Ball:
			if body.velocity == Vector2.ZERO:
				body.ball_started = true
			
			print("knockback")
			var knockback : Vector2 = global_position.direction_to(body.global_position) * 3
			body.velocity = knockback
	)
	
	
