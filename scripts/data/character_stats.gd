extends Resource

class_name CharacterStats

@export var max_health: float = 100.0
@export var current_health: float = 100.0 :
	set(value):
		current_health = clamp(value, 0, max_health)
		emit_changed() # Thông báo khi máu thay đổi (để UI cập nhật)

@export var speed: float = 150.0
@export var attack_power: float = 10.0