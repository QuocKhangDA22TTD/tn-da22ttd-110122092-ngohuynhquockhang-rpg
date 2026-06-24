extends Node

# Signal phát ra khi có thay đổi trong kho đồ
signal inventory_changed

# Số lượng ô chứa đồ tối đa
@export var size : int = 30

# Vàng có trong kho đồ
@export var gold: int = 0

# Mảng chứa các slot (ô đồ)
var slots : Array = []

# Khởi tạo các slot trống khi bắt đầu
func _ready():
	for i in size:
		slots.append(Slot.new())


# Thêm vật phẩm vào kho đồ
# Trả về true nếu thêm thành công, false nếu kho đầy
func add_item(item: ItemData, amount: int = 1):
	# Ưu tiên xếp chồng vào slot đã có vật phẩm cùng loại
	for slot in slots:
		if slot.item == item and slot.amount < item.max_stack:
			var space = item.max_stack - slot.amount
			var add = min(space, amount)
			
			slot.amount += add
			amount -= add
			
			if amount <= 0:
				emit_signal("inventory_changed")
				return true
	
	# Nếu không xếp chồng được, tìm slot trống
	for slot in slots:
		if slot.is_empty():
			slot.item = item
			slot.amount = amount
			emit_signal("inventory_changed")
			return true
	
	# Kho đầy, không thể thêm
	return false


# Xóa vật phẩm khỏi slot tại vị trí index
func remove_item(index:int, amount:int):
	var slot = slots[index]
	slot.amount -= amount
	
	# Nếu số lượng <= 0, xóa hoàn toàn vật phẩm khỏi slot
	if slot.amount <= 0:
		slot.item = null
		slot.amount = 0
		
	emit_signal("inventory_changed")


# Kiểm tra xem kho đồ còn đủ chỗ để chứa số lượng vật phẩm này không
func has_space_for(item: ItemData, amount: int = 1) -> bool:
	var remaining_amount = amount
	
	# 1. Kiểm tra xem có xếp chồng được vào slot cũ không
	for slot in slots:
		if slot.item == item and slot.amount < item.max_stack:
			var space = item.max_stack - slot.amount
			remaining_amount -= min(space, remaining_amount)
			if remaining_amount <= 0:
				return true
				
	# 2. Nếu vẫn còn dư, kiểm tra xem có slot trống nào không
	for slot in slots:
		if slot.is_empty():
			return true
			
	return false