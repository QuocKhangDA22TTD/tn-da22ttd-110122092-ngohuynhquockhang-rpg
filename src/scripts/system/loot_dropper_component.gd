# loot_dropper_component.gd
extends Node2D
class_name LootDropperComponent

@export var loot_table: LootTableData # Xuất biến để kéo thả file LootTableData (.tres) từ Inspector

@export var drop_item_scene: PackedScene # Kéo thả Scene của đối tượng rơi đồ ngoài thế giới vào đây

func _ready() -> void:
	var parent = get_parent() # Lấy node gốc
	
	if parent:
		# Kết nối với tín hiệu tree_exiting (kích hoạt ngay trước khi đối tượng cha bị queue_free)
		parent.tree_exiting.connect(_on_parent_tree_exiting)

func _on_parent_tree_exiting() -> void:
	# Kiểm tra điều kiện an toàn
	if not loot_table or not drop_item_scene:
		return
		
	# 1. Gọi chính xác hàm của bạn để lấy danh sách các Dictionary [{ "item": ..., "quantity": ... }]
	var drops = loot_table.get_dropped_items() 
	
	# Lưu lại vị trí của đối tượng trước khi bị xóa
	var drop_position = global_position
	
	# Lấy node dùng để chứa item rơi ra
	var items_container = GameManager.items_container
	
	# 2. Duyệt qua danh sách dữ liệu được trả về và sinh ra vật phẩm
	for drop_data in drops:
		var item_res = drop_data["item"]
		var item_amount = drop_data["quantity"]
		
		if item_res and item_amount > 0:
			# Khởi tạo node vật phẩm rơi ngoài thế giới
			var new_drop = drop_item_scene.instantiate()
			
			# Gán chính xác vào 2 biến `item` và `amount` trong script item_drop
			new_drop.item = item_res
			new_drop.amount = item_amount

			# Random vị trí quanh Enemy trong bán kính 20 pixel
			var offset = Vector2(
				randf_range(-20, 20),
				randf_range(-20, 20)
			)
			
			# Đặt vị trí xuất hiện trùng với vị trí đối tượng vừa bị phá hủy
			new_drop.global_position = drop_position + offset
			
			# Thêm vào scene tree bằng call_deferred để tránh lỗi xung đột thread khi cha đang bị giải phóng
			items_container.add_child.call_deferred(new_drop)
