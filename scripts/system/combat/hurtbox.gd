extends Area2D
class_name Hurtbox

@export var owner_entity: Node2D # Biến để lưu reference đến entity sở hữu hurtbox

func _ready() -> void:
	# Thêm vào group dựa trên parent
	if owner_entity.is_in_group("player"):
		add_to_group("player_hurtbox")
	elif owner_entity.is_in_group("enemy"):
		add_to_group("enemy_hurtbox")

# Nhận damage từ Hitbox signal
func _on_hitbox_hit(damage: float, source: Node) -> void:
	apply_damage(damage, source)

# Nhận damage trực tiếp từ các nguồn khác (ví dụ: projectile, explosion)
func take_damage(damage: float, source: Node = null) -> void:
	apply_damage(damage, source)

# Logic để áp dụng damage vào entity sở hữu hurtbox
func apply_damage(damage: float, source: Node) -> void:
	if owner_entity and owner_entity.has_method("take_damage"):
		owner_entity.take_damage(damage, source)
