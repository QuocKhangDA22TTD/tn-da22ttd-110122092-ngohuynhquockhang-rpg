# TransitionTrigger.gd
extends Area2D
class_name TransitionTrigger

@export_file("*.tscn") var target_map_path: String # Đường dẫn tới map tiếp theo
@export var target_spawn_id: String = "Spawn_Default" # Tên Marker2D ở map mới

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("player"):
		# Gọi Event Bus hoặc Hệ thống quản lý để đổi map
		MapManager.change_map.emit(target_map_path, target_spawn_id)
