extends Area2D
class_name Hitbox

signal hit_hurtbox(hurtbox: Area2D) # Tín hiệu phát ra khi hitbox va chạm với một hurtbox

# Danh sách để tránh hit nhiều lần trong cùng 1 lần tấn công
var hit_entities: Array = []

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Node2D) -> void:
	# Tránh hit cùng entity nhiều lần
	if area in hit_entities:
		return
	
	# Detect enemy hoặc player hurtbox
	if area.is_in_group("enemy") or area.is_in_group("player"):
		hit_entities.append(area)
		hit_hurtbox.emit(area)

# Reset danh sách khi animation tấn công kết thúc
func reset_hit_list() -> void:
	hit_entities.clear()
