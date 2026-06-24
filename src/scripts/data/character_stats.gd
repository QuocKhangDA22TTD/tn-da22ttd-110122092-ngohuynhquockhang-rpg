extends Resource

class_name CharacterStats

@export var max_health: float = 100.0
@export var max_mana: float = 100.0
@export var max_stamina: float = 100.0
@export var current_health: float = 100.0 :
	set(value):
		current_health = clamp(value, 0, max_health)
		emit_changed() # Thông báo khi máu thay đổi (để UI cập nhật)

@export var current_mana: float = 100.0 :
	set(value):
		current_mana = clamp(value, 0, max_mana)
		emit_changed() # Thông báo khi mana thay đổi (để UI cập nhật)

@export var current_stamina: float = 100.0 :
	set(value):
		current_stamina = clamp(value, 0, max_stamina)
		emit_changed() # Thông báo khi stamina thay đổi (để UI cập nhật)

@export var speed: float = 80.0
