extends Control

@export var item_data: ItemData # Thông tin vật phẩm
@export var item_icon: TextureRect # Icon hiển thị vật phẩm

signal slot_pressed(data: ItemData) # Signal khi slot được nhấn

func setup(data: ItemData):
	# Kiểm tra xem dữ liệu có tồn tại không trước khi khi gán vào biến item_data
	if data:
		item_data = data # Gán dữ liệu vật phẩm vào biến item_data
		item_icon.texture = data.icon # Gán icon vật phẩm vào texture của node item_icon để hiển thị vật phẩm


func _on_pressed():
	slot_pressed.emit(item_data) # Gửi tín hiệu khi slot được nhấn
