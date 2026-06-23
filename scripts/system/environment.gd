extends Node2D

@export var spawn_list: Array[SpawnableObjectData] = [] # Danh sách các vật thể có thể spawn trong môi trường

@export var ground: TileMapLayer # Tham chiếu tới Node TileMapLayer tên là Ground

func _ready() -> void:
	randomize() # Khởi tạo seed ngẫu nhiên
	
	execute_global_spawning() # Chạy hệ thống rải vật thể tổng thể

func execute_global_spawning() -> void:
	var used_cells = ground.get_used_cells() # Lấy tất cả các ô đang được sử dụng trong TileMapLayer
	
	# Duyệt từng ô trên bản đồ
	for cell_coord in used_cells:
		var tile_data = ground.get_cell_tile_data(cell_coord) # Lấy TileData của ô hiện tại

		if not tile_data:
			continue # Nếu ô không có dữ liệu thì bỏ qua
			
		# Lấy loại địa hình của ô này từ Custom Data (Ví dụ: "grass", "dirt", "snow")
		var terrain_type: String = tile_data.get_custom_data("terrain_type")

		if terrain_type == "":
			continue # Nếu không có terrain_type thì bỏ qua
			
		# Kiểm tra từng loại vật thể trong danh sách spawn
		for object_data in spawn_list:

			# Xem vật thể này có được phép xuất hiện trên loại địa hình hiện tại không
			if object_data.is_allowed_on(terrain_type):
				# Tung xúc xắc cho vật thể này
				if randf() < object_data.spawn_chance:

					# Xác định số lượng vật thể sẽ spawn trên ô này
					var count = randi_range(
						object_data.min_per_tile,
						object_data.max_per_tile
					)

					# Spawn số lượng vật thể tương ứng
					for i in range(count):
						spawn_object(object_data.scene, cell_coord, object_data.offset_range)
					
					# Nếu vật thể này là loại độc quyền (exclusive)
					# thì không cho các vật thể khác spawn cùng ô
					if object_data.is_exclusive:
						break # Thoát vòng lặp, chuyển sang ô gạch tiếp theo

func spawn_object(object_scene: PackedScene, cell_coord: Vector2i, offset_range: float) -> void:
	
	if not object_scene: return # Không có scene thì thoát
	
	var instance = object_scene.instantiate() # Tạo instance từ scene
	var cell_world_pos = ground.map_to_local(cell_coord) # Chuyển tọa độ ô TileMap sang tọa độ local trong thế giới
	
	# Sinh độ lệch ngẫu nhiên để vật thể không nằm đúng tâm ô
	var random_offset = Vector2(
		randf_range(-offset_range, offset_range),
		randf_range(-offset_range, offset_range)
	)
	
	# Đặt vị trí vật thể
	instance.global_position = cell_world_pos + random_offset

	# Thêm vật thể vào scene tree
	add_child(instance)
