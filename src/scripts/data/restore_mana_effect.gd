extends ConsumableEffect
class_name RestoreManaEffect

@export var mana_amount: int = 80 # Lượng máu được hồi khi sử dụng bình hồi máu

func apply_effect(entity: Node2D) -> bool:
	if entity.stats.current_mana >= entity.stats.max_mana:
		return false # Nếu máu đã đầy thì không cho sử dụng bình hồi máu
	
	# Hồi máu nhưng không vượt quá máu tối đa
	entity.stats.current_mana = min(entity.stats.current_mana + mana_amount, entity.stats.max_mana)

	return true # Sử dụng thành công
