extends Resource
class_name LootItemData

@export var item_data: Resource # Kéo script item_data của bạn vào đây
@export_range(0.0, 100.0) var drop_chance: float = 50.0 # Tỉ lệ rơi (%)
@export var min_quantity: int = 1 # Số lượng tối thiểu rơi ra
@export var max_quantity: int = 1 # Số lượng tối đa rơi ra
