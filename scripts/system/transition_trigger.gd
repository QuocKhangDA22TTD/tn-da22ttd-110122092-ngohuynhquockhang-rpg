# TransitionTrigger.gd
extends Area2D
class_name TransitionTrigger

signal change_map

@export_file("*.tscn") var target_map_path: String # Đường dẫn tới map tiếp theo
@export var target_spawn_id: String = "Spawn_Default" # Tên Marker2D ở map mới

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		# Gọi Event Bus hoặc Hệ thống quản lý để đổi map
		change_map.emit(target_map_path, target_spawn_id)
