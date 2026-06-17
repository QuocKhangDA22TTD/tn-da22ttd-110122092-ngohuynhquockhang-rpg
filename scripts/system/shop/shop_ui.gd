extends Control

@export var info_panel: TextureRect
@export var item_grid: GridContainer # Grid chứa các slot shop
@export var buy_button: TextureButton # Button mua vật phẩm
@export var close_button: TextureButton # Button đóng shop
@export var shop_slot_scene: PackedScene # tham chiếu tới scene shop_slot
@export var item_name_label: Label # Label hiển thị tên vật phẩm được chọn trong shop
@export var item_price_label: Label # Label hiển thị giá vật phẩm được chọn trong shop
@export var item_type_label: Label # Label hiển thị loại vật phẩm được chọn trong shop
@export var item_image: TextureRect # TextureRect hiển thị icon vật phẩm được chọn trong shop

var current_shop_items: Array[ItemData] = [] # Danh sách vật phẩm trong shop
var selected_item: ItemData = null # Vật phẩm được chọn trong shop
var player_inventory = null # túi đồ của player

func _ready():
	hide() # Ẩn shop khi mới lần đầu vào scene
	info_panel.hide() # Ẩn panel thông tin khi mới lần đầu vào scene


func open_shop(shop_items: Array[ItemData], player_ref):
	show() # Hiển thị shop

	current_shop_items = shop_items
	player_inventory = InventoryManager

	reset_info_panel() # Xoá thông tin cũ trong InfoPanel
	
	# Xóa các slot cũ
	for child in item_grid.get_children():
		child.queue_free()
		
	# Sinh ra các slot mới
	for item in shop_items:
		var slot = shop_slot_scene.instantiate()
		item_grid.add_child(slot)
		slot.setup(item)
		slot.slot_pressed.connect(_on_item_selected)

func _on_item_selected(item: ItemData):
	if item:
		selected_item = item # Gán vật phẩm được chọn vào biến selected_item
		
		item_image.texture = item.icon # Hiển thị icon vật phẩm trong InfoPanel
		item_name_label.text = "ITEM NAME: " + item.name.capitalize() # Hiển thị tên vật phẩm trong InfoPanel
		item_price_label.text = "PRICE: " + str(item.price) + " Gold" # Hiển thị giá vật phẩm trong InfoPanel

		var item_type = "" # Loại vật phẩm
		
		match item.type:
			0:
				item_type = "CONSUMABLE"
			1:
				item_type = "MATERIAL"
			2:
				item_type = "WEAPON"
			3:
				item_type = "ARMOR"
			_:
				item_type = "UNKNOWN"
		
		item_type_label.text = "TYPE: " + item_type # Hiển thị loại vật phẩm trong InfoPanel
		
		# Tắt vô hiệu hóa nút mua khi có vật phẩm được chọn để người dùng có thể bắt đầu mua vật phẩm
		buy_button.disabled = false

		info_panel.show() # Hiển thị panel thông tin khi có vật phẩm được chọn

		return

	info_panel.hide() # Ẩn panel thông tin khi slot không có vật phẩm được chọn


func _on_buy_button_pressed():
	if selected_item and player_inventory:
		if player_inventory.gold >= selected_item.price:
			player_inventory.gold -= selected_item.price
			player_inventory.add_item(selected_item)
			print("Mua thành công: ", selected_item.name)
		else:
			print("Không đủ tiền!")


func _on_close_button_pressed() -> void:
	hide() # Ẩn shop


func reset_info_panel():
	item_name_label.text = ""
	item_price_label.text = ""
	item_type_label.text = ""
	item_image.texture = null
	buy_button.disabled = true # Bật vô hiệu hóa nút mua
	info_panel.hide() # Ẩn panel thông tin
