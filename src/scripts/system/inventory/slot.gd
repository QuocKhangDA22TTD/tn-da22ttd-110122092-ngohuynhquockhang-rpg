# Lớp đại diện cho một ô chứa đồ trong kho
extends Resource
class_name Slot

# Vật phẩm trong slot
@export var item : ItemData
# Số lượng vật phẩm
@export var amount : int = 0

# Kiểm tra slot có trống không
func is_empty():
	return item == null or amount <= 0
