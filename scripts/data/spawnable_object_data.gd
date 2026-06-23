extends Resource
class_name SpawnableObjectData

@export_category("Visual & Scene")
@export var name: String = "Vật thể"
@export var scene: PackedScene # File .tscn của Cỏ, Cây, Đá...

@export_category("Spawn Rules")
@export_range(0.0, 1.0) var spawn_chance: float = 0.2 # Xác suất để vật thể spawn ra thế giới
@export var min_per_tile: int = 1 # Số tượng tối thiểu có thể spawn trong một tile
@export var max_per_tile: int = 1 # Số tượng tối đa có thể spawn trong một tile

# Độ lệch ngẫu nhiên tính từ tâm ô (tile) khi spawn. Giúp các vật thể không nằm đúng một vị trí cố định,
# tạo cảm giác tự nhiên hơn.
@export var offset_range: float = 8.0

# Ô này đã mọc vật thể này rồi thì KHÔNG cho vật thể khác mọc đè lên nữa (Ví dụ: Cây to đã mọc thì không mọc thêm đá)
@export var is_exclusive: bool = true

# Danh sách các loại địa hình được phép mọc (Ví dụ: Cỏ mọc trên ["grass"], Đá mọc trên ["grass", "dirt"])
@export var allowed_terrains: Array[String] = ["grass"]

func is_allowed_on(terrain_type: String) -> bool:
	# Trả về true nếu loại địa hình được truyền vào tồn tại trong danh sách địa hình được phép spawn.
	return allowed_terrains.has(terrain_type)
