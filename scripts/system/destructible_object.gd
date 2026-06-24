extends Node2D
class_name DestructibleObject

@export var max_health: float = 1.0 # Lượng máu tối đa của đối tượng
@export var current_health: float = 0.0 # Lượng máu hiện tại của đối tượng

func _ready() -> void:
	current_health = max_health

# Hàm này sẽ được Hurtbox gọi sang khi bị trúng đòn
func take_damage(damage: float, _source: Node = null) -> void:
	current_health -= damage
	
	if current_health <= 0:
		destroy() # Nếu máu của đối tượng giảm về 0, gọi hàm destroy

func destroy() -> void:
	# Kích hoạt hiệu ứng nổ/vỡ nếu có (vẽ hạt particle, âm thanh...)
	# ...
	
	# Xóa đối tượng (LootDropperComponent sẽ tự động bắt sự kiện này để rơi đồ)
	queue_free()
