extends ConsumableEffect
class_name HealEffect

@export var heal_amount: int = 80 # Lượng máu được hồi khi sử dụng bình hồi máu

func apply_effect(entity: Node2D) -> bool:
	if entity.stats.current_health >= entity.stats.max_health:
		return false # Nếu máu đã đầy thì không cho sử dụng bình hồi máu
	
	# Hồi máu nhưng không vượt quá máu tối đa
	entity.stats.current_health = min(entity.stats.current_health + heal_amount, entity.stats.max_health)

	return true # Sử dụng thành công
