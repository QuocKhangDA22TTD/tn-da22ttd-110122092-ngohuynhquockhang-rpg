extends ItemData
class_name ConsumableData

@export var effect: ConsumableEffect # Hiệu ứng của vật phẩm tiêu hao

func _init():
	type = ItemType.CONSUMABLE # Gán loại vật phẩm là Consumable khi vừa khởi tạo resource.
