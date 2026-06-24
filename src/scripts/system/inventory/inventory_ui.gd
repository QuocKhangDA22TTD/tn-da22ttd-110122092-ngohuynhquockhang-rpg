# Script quản lý giao diện kho đồ
extends Control

# Scene prefab của slot UI
@export var slot_scene : PackedScene
# Container chứa các slot theo dạng lưới
@export var grid: GridContainer

# Mảng chứa các node slot UI
var slot_nodes = []

# Khởi tạo giao diện kho đồ
func _ready():
	var inventory_manager = InventoryManager

	# Tạo các slot UI tương ứng với số lượng slot trong inventory
	for i in inventory_manager.size:
		var slot = slot_scene.instantiate()
		grid.add_child(slot)
	
		# Liên kết slot UI với slot data
		slot.slot = inventory_manager.slots[i]
		slot_nodes.append(slot)
		
	# Kết nối signal để cập nhật UI khi inventory thay đổi
	inventory_manager.inventory_changed.connect(update_inventory)
	
	update_inventory()
	
	# Ẩn UI khi bắt đầu
	hide()


# Xử lý input để bật/tắt giao diện kho đồ
func _input(event):
	if event.is_action_pressed("toggle_inventory"):
		visible = !visible


# Cập nhật hiển thị tất cả các slot
func update_inventory():
	for slot in slot_nodes:
		slot.update_ui()
