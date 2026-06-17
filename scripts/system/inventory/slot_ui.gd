extends Control

@export var texture_rect: TextureRect # Tham chiếu đến node TextureRect của slot
@export var icon: TextureRect # Tham chiếu đến icon hiển thị vật phẩm
@export var amount: Label # Tham chiếu đến label hiển thị số lượng

var slot : Slot # Tham chiếu đến dữ liệu slot

# Cập nhật hiển thị UI của slot
func update_ui():
	# Nếu slot trống, xóa icon và số lượng
	if slot == null or slot.is_empty():
		icon.texture = null
		amount.text = ""
		return
	
	# Hiển thị icon vật phẩm
	icon.texture = slot.item.icon
	
	# Chỉ hiển thị số lượng nếu > 1
	if slot.amount > 1:
		amount.text = str(slot.amount)
	else:
		amount.text = ""


# Bắt đầu kéo vật phẩm
func _get_drag_data(pos):
	if slot.is_empty():
		return
	
	# Tạo preview hiển thị khi kéo
	var preview = TextureRect.new()
	preview.texture = slot.item.icon
	set_drag_preview(preview)
	
	return self


# Kiểm tra có thể thả vật phẩm vào slot này không
func _can_drop_data(pos, data):
	return data is Control and data.has_method("update_ui") and data.slot != null


# Xử lý khi thả vật phẩm - hoán đổi 2 slot
func _drop_data(pos, data):
	# Lưu tạm dữ liệu slot hiện tại
	var temp_item = slot.item
	var temp_amount = slot.amount
	
	# Gán dữ liệu từ slot được kéo vào slot hiện tại
	slot.item = data.slot.item
	slot.amount = data.slot.amount
	
	# Gán dữ liệu tạm vào slot được kéo
	data.slot.item = temp_item
	data.slot.amount = temp_amount
	
	# Cập nhật UI của cả 2 slot
	update_ui()
	data.update_ui()
	
	InventoryManager.emit_signal("inventory_changed")
