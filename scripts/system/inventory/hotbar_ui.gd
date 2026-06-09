extends Control

# Scene prefab của slot UI (dùng chung với inventory)
@export var slot_scene : PackedScene
# Container chứa các slot hotbar
@export var container: HBoxContainer
# Số lượng slot trong hotbar
@export var hotbar_size: int = 6

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
			use_selected_item()
			break
	
	# Scroll chuột để chuyển slot
	if event.is_action_pressed("hotbar_next"):
		selected_slot_index = (selected_slot_index + 1) % hotbar_size
		highlight_selected_slot()
		use_selected_item()
	elif event.is_action_pressed("hotbar_previous"):
		selected_slot_index = (selected_slot_index - 1 + hotbar_size) % hotbar_size
		highlight_selected_slot()
		use_selected_item()

# Highlight slot đang được chọn
func highlight_selected_slot():
	for i in range(hotbar_slots.size()):
		var slot = hotbar_slots[i]
		var panel = slot.get_node("Panel")
		
		if i == selected_slot_index:
			panel.self_modulate = Color(1.5, 1.5, 0.5) * 4  # Vàng sáng
		else:
			panel.self_modulate = Color(1.0, 1.0, 1.0)  # Bình thường


# Sử dụng item trong slot đang chọn
func use_selected_item():
	var slot = InventoryManager.slots[selected_slot_index]
	
	if slot.is_empty():
		unequip_weapon()
		return
	
	# Xử lý sử dụng item dựa trên loại
	match slot.item.type:
		ItemData.ItemType.WEAPON:
			equip_weapon(slot)
		_:
			unequip_weapon()

# Sử dụng vật phẩm tiêu hao
func use_consumable(slot: Slot) -> bool:
	var consumable = slot.item
	if not consumable or not consumable.effect:
		return false
	
	var success = consumable.effect.apply_effect(GameManager.player)
	if success:
		print("Đã sử dụng: ", consumable.name)
		InventoryManager.remove_item(selected_slot_index, 1)
		return true
	
	return false


# Trang bị vũ khí
func equip_weapon(slot: Slot):
	# Validation
	if not slot.item is WeaponData:
		push_error("Item không phải WeaponData: ", slot.item.name)
		return
	
	print("Đã trang bị: ", slot.item.name)
	# Cập nhật vũ khí hiện tại của player
	GameManager.player.current_weapon = slot.item
	# Cập nhật sprite vũ khí của player
	GameManager.player.weapon_sprite_2d.texture = slot.item.weapon_texture
	# Cập nhật texture hiệu ứng tấn công nếu có
	if slot.item.attack_behavior is MeleeAttack:
		GameManager.player.effect_sprite_2d.texture = slot.item.slash_effect_texture


func unequip_weapon():
	# Dừng animation vũ khí nếu đang phát
	GameManager.player.animation_weapon.stop()

	# gán null cho vũ khí hiện tại của player
	GameManager.player.current_weapon = null

	# gán null cho texture của weapon_sprite_2d và effect_sprite_2d và ẩn chúng đi
	GameManager.player.weapon_sprite_2d.texture = null
	GameManager.player.effect_sprite_2d.texture = null
	GameManager.player.weapon_sprite_2d.visible = false
	GameManager.player.effect_sprite_2d.visible = false

	# gán null cho texture của arm_sprite_2d và ẩn nó đi
	GameManager.player.arm_sprite_2d.texture = null
	GameManager.player.arm_sprite_2d.visible = false


func _on_inventory_changed():
	var selected_slot = InventoryManager.slots[selected_slot_index]
	
	if selected_slot.is_empty():
		unequip_weapon()
	else:
		use_selected_item()
