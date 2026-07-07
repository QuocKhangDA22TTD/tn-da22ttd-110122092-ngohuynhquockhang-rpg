extends Node2D

signal change_map(map_path: String, spawn_id: String)

@export var maps_container: Node2D # Tham chiếu đến container chứa map
@export var entities_container: Node2D # Tham chiếu đến container chứa các entity
@export var player: CharacterBody2D # Tham chiếu đến player

func _ready() -> void:
	change_map.connect(_on_change_map)


func _on_change_map(map_path: String, spawn_id: String):
	maps_container = GameManager.maps_container
	entities_container = GameManager.entities_container
	
	call_deferred("switch_map", map_path, spawn_id)


func switch_map(map_path: String, spawn_id: String) -> void:
	# Bước 1: (Tùy chọn) Kích hoạt hiệu ứng Fade Out của UI (màn hình đen)
	
	# Bước 2: Xóa Map cũ đang có trong nút Maps
	for child in maps_container.get_children():
		child.queue_free()
	
	# Bước 2.5: Xóa tất cả Enemies
	if entities_container.has_node("Enemies"):
		var enemies_node = entities_container.get_node("Enemies")
		for enemy in enemies_node.get_children():
			enemy.queue_free()
		
	# Bước 3: Tải (Load) và Khởi tạo (Instance) Map mới
	var new_map_scene = load(map_path)
	if new_map_scene:
		var new_map_instance = new_map_scene.instantiate()
		maps_container.add_child(new_map_instance)
		
		# Bước 4: Tìm vị trí Spawn trên Map mới và dịch chuyển Player
		var spawn_points = new_map_instance.get_node_or_null("SpawnPoints")
		if spawn_points:
			var target_spawn = spawn_points.get_node_or_null(spawn_id)
			var player = GameManager.player

			if target_spawn and player:
				player.global_position = target_spawn.global_position
	
	# Bước 5: Chờ 1 frame để map được render, rồi xóa tất cả Items
	await get_tree().process_frame
	
	var items_container = GameManager.items_container
	for item in items_container.get_children():
		items_container.remove_child(item)
		item.queue_free()
				
	# Bước 6: (Tùy chọn) Kích hoạt hiệu ứng Fade In của UI để chơi tiếp
