extends Area2D
class_name Hitbox

signal hit_hurtbox(hurtbox: Area2D) # Tín hiệu phát ra khi hitbox va chạm với một hurtbox, truyền vào instance của hurtbox đó

# Danh sách số lần enemy đã bị hit để tránh hit nhiều lần
var hit_enemies: Array = []

func _ready() -> void:
	# Dùng area_entered thay vì body_entered để phát hiện va chạm với enemy
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Node2D) -> void:
	# Kiểm tra xem area có phải là enemy không
	if area.is_in_group("enemy") and area not in hit_enemies:
		hit_enemies.append(area)
		hit_hurtbox.emit(area)

# Gọi hàm này khi animation tấn công kết thúc để reset danh sách
func reset_hit_list() -> void:
	hit_enemies.clear()
