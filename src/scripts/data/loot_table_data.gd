extends Resource
class_name LootTableData

@export var loot_items: Array[LootItemData] = [] # Danh sách các vật phẩm sẽ rơi ra

# Hàm tính toán xem những item nào được chọn để rơi ra
func get_dropped_items() -> Array[Dictionary]:
	var drops: Array[Dictionary] = [] # Mảng kết quả cuối cùng trả về danh sách và số lượng đồ sẽ rơi ra
	
	# Duyệt qua từng item trong bảng loot
	for loot in loot_items:

		# Kiểm tra:
		# 1. Có dữ liệu item hay không
		# 2. Random từ 0 -> 100 có nhỏ hơn hoặc bằng tỉ lệ rơi không
		if loot.item_data and randf_range(0.0, 100.0) <= loot.drop_chance:
			
			#Chọn ngẫu nhiên số lượng trong khoảng min -> max
			var quantity = randi_range(loot.min_quantity, loot.max_quantity)
			
			# Thêm vào danh sách kết quả
			drops.append({
				"item": loot.item_data,
				"quantity": quantity
			})
			
	return drops # Trả về toàn bộ item đã được chọn để rơi
