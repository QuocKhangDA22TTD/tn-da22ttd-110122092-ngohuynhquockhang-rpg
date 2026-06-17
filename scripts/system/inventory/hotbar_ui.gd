extends Control

@export var slot_scene : PackedScene # Scene prefab của slot UI (dùng chung với inventory)
@export var container: HBoxContainer # Container chứa các slot hotbar
@export var hotbar_size: int = 6 # Số lượng slot trong hotbar
@export var normal_slot_texture: Texture # Texture mặc định cho slot bình thường
@export var select_slot_texture: Texture # Texture cho slot được chọn

# Mảng chứa các node slot UI của hotbar
var hotbar_slots = []
# Index của slot đang được chọn (highlight)
var selected_slot_index: int = 0

func _ready():
	var inventory_manager = InventoryManager
	
	# Tạo các slot UI cho hotbar, liên kết với các slot đầu tiên của inventory
	for i in hotbar_size:
		var slot = slot_scene.instantiate()
		container.add_child(slot)
		
		# Liên kết với slot thứ i trong inventory (0-5)
		slot.slot = inventory_manager.slots[i]
		hotbar_slots.append(slot)
	
	# Kết nối signal để cập nhật UI khi inventory thay đổi
	inventory_manager.inventory_changed.connect(update_hotbar)
	inventory_manager.inventory_changed.connect(_on_inventory_changed)
	
	update_hotbar()
	highlight_selected_slot()

# Cập nhật hiển thị tất cả các slot trong hotbar
func update_hotbar():
	for slot in hotbar_slots:
		slot.update_ui()

# Xử lý input cho hotbar (phím số 1-6 để chọn slot)
func _input(event):
	# Kiểm tra xem vũ khí hiện tại có đang tấn công không
	if GameManager.player.current_weapon and GameManager.player.current_weapon.attack_behavior:
		if GameManager.player.current_weapon.attack_behavior.is_attacking():
			return  # Không cho phép chuyển đổi vũ khí khi đang tấn công
	
	# Phím số 1-6 để chọn slot
	for i in range(hotbar_size):
		if event.is_action_pressed("hotbar_" + str(i + 1)):
			selected_slot_index = i
			highlight_selected_slot()
			GameManager.player.hotbar_execute_action()
			break
	
	# Scroll chuột để chuyển slot
	if event.is_action_pressed("hotbar_next"):
		selected_slot_index = (selected_slot_index + 1) % hotbar_size
		highlight_selected_slot()
		GameManager.player.hotbar_execute_action()
	elif event.is_action_pressed("hotbar_previous"):
		selected_slot_index = (selected_slot_index - 1 + hotbar_size) % hotbar_size
		highlight_selected_slot()
		GameManager.player.hotbar_execute_action()

# Highlight slot đang được chọn
func highlight_selected_slot():
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i]

		var texture_rect = slot.texture_rect # Tham chiếu tới texture_rect của instance scene slot
		
		if i == selected_slot_index:
			texture_rect.texture = select_slot_texture # Nếu slot được chọn, gán texture bằng select_slot_texture
		else:
			texture_rect.texture = normal_slot_texture # Nếu không được chọn, gán texture bằng normal_slot_texture


func _on_inventory_changed():
	var selected_slot = InventoryManager.slots[selected_slot_index]
	
	# Kiểm tra slot rỗng trước khi truy cập item
	if selected_slot.is_empty():
		GameManager.player.unequip_weapon()
		return
	
	# Chỉ kiểm tra loại item nếu slot không rỗng
	if selected_slot.item.type == ItemData.ItemType.WEAPON:
		GameManager.player.equip_weapon(selected_slot)
	else:
		GameManager.player.unequip_weapon()
