# Lớp dữ liệu cho vật phẩm trong game
extends Resource
class_name ItemData

@export var id : String # ID duy nhất của vật phẩm
@export var name : String # Tên hiển thị của vật phẩm
@export var icon : Texture2D # Icon hiển thị trong UI
@export var max_stack : int = 99 # Số lượng tối đa có thể xếp chồng trong 1 slot
@export var world_scale : float = 0. # Tỷ lệ kích thước khi hiển thị trên bản đồ
@export var price: int = 10

# Enum định nghĩa các loại vật phẩm
enum ItemType {
	CONSUMABLE,  # Vật phẩm tiêu hao (thuốc, thức ăn...)
	MATERIAL,    # Nguyên liệu
	WEAPON,      # Vũ khí
	ARMOR        # Giáp
	}

@export var type : ItemType # Loại vật phẩm
