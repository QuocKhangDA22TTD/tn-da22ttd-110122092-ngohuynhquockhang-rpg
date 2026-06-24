extends Area2D
class_name Hitbox

signal hit_hurtbox(hurtbox: Hurtbox) # Signal này sẽ được phát khi hitbox va chạm với một hurtbox

var hit_entities: Array = [] # Mảng để lưu các hurtbox đã bị hit trong lần va chạm hiện tại

func _ready() -> void:
	area_entered.connect(_on_area_entered) # Kết nối signal area_entered để phát hiện va chạm với hurtbox

func _on_area_entered(area: Node2D) -> void:
	if area in hit_entities:
		return # Tránh hit cùng entity nhiều lần
	
	# Chỉ phát hiện hurtbox
	if area is Hurtbox:
		hit_entities.append(area) # Thêm hurtbox vào danh sách đã hit để tránh hit lại trong cùng một lần va chạm
		hit_hurtbox.emit(area) # Phát signal với hurtbox đã bị hit để các hệ thống khác có thể xử lý sát thương

func reset_hit_list() -> void:
	hit_entities.clear()
