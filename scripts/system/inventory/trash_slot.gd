# Script cho trash slot - kế thừa từ slot_ui.gd
extends "res://scripts/system/inventory/slot_ui.gd"

# Scene của item drop để spawn vào thế giới
@export var item_drop_scene: PackedScene


# Override hàm update_ui để trash slot không hiển thị item
func update_ui():
	# Trash slot luôn hiển thị icon thùng rác cố định
	# Không cần update gì cả, icon đã set sẵn trong scene
	pass 


# Override hàm _can_drop_data
func _can_drop_data(pos, data):
	# Chỉ chấp nhận drop từ slot UI có item
	if data is Control and data.has_method("update_ui"):
		if data.slot and not data.slot.is_empty():
			return true
	return false


func _get_drag_data(pos):
	return null


# Override hàm _drop_data để spawn item thay vì swap
func _drop_data(pos, data):
	# Lấy thông tin item từ slot nguồn
	var item_to_drop = data.slot.item
	var amount_to_drop = data.slot.amount
	
	# Spawn item vào thế giới game
	if item_drop_scene and item_to_drop:
		var drop = item_drop_scene.instantiate()
		drop.item = item_to_drop
		drop.amount = amount_to_drop
		
		# Lấy vị trí của player để spawn item
		var player = GameManager.player
		if player:
			# Thêm offset ngẫu nhiên để item không spawn chồng lên nhau
			var random_offset = Vector2(
				randf_range(-20, 20),
				randf_range(-20, 20)
			)
			drop.global_position = player.global_position + random_offset
		
		# Thêm item drop vào scene root
		GameManager.items_container.add_child(drop)
	
	# Xóa item khỏi slot nguồn
	data.slot.item = null
	data.slot.amount = 0
	data.update_ui()
	
	# Phát signal để cập nhật inventory
	InventoryManager.emit_signal("inventory_changed")
