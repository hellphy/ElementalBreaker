@tool
class_name HurtBox2D extends Area2D

signal took_hit(hit_box: HitBox2D)

const DAMAGE_SOURCE_PLAYER := 0b01
const DAMAGE_SOURCE_MOB := 0b10
const DAMAGE_SOURCE_BALL := 0b11

@export_flags("Player", "Mob", "Ball") var damage_source := DAMAGE_SOURCE_PLAYER: set = set_damage_source
@export_flags("Player", "Mob", "Ball") var hurtbox_type := DAMAGE_SOURCE_PLAYER: set = set_hurtbox_type

func set_damage_source(new_value: int) -> void:
	damage_source = new_value
	collision_mask = damage_source

func set_hurtbox_type(new_value: int) -> void:
	hurtbox_type = new_value
	collision_layer = hurtbox_type

func _init() -> void:
	monitoring = true
	monitorable = true
	area_entered.connect(func _on_area_entered(area: Area2D) -> void:
		if area is HitBox2D:
			took_hit.emit(area)
			print("took_hit", area.name)
	)
	
