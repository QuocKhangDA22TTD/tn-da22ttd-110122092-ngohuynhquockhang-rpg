extends Area2D
class_name Hurtbox

var owner_entity: CharacterBody2D

func _ready() -> void:
	owner_entity = get_parent()
	# Thêm vào group player_hurtbox nếu parent là player
	if owner_entity.name == "Player" or owner_entity.is_in_group("player"):
		add_to_group("player_hurtbox")

# Hàm này sẽ được gọi bởi hitbox khi va chạm với hurtbox, truyền vào lượng sát thương và nguồn gây sát thương
func take_damage(amount: float, source = null) -> void:
	if owner_entity and owner_entity.has_method("take_damage"):
		owner_entity.take_damage(amount, source)
