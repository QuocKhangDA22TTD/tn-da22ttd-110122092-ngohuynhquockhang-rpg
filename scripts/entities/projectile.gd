extends Area2D

@export var exist_timer = 0.0
@export var max_exist_time = 3.0

var speed: float = 0.0
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	# Di chuyển projectile về phía trước
	var velocity = direction * speed
	position += velocity * delta

	if rotation != direction.angle():
		rotation = direction.angle()  # Xoay projectile theo hướng di chuyển
	
	exist_timer += delta

	if exist_timer >= max_exist_time:
		queue_free()  # Xóa projectile nếu đã tồn tại quá lâu

# Xử lý va chạm với kẻ địch
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemy") and body.has_method("take_damage") and speed != 0.0:
		body.take_damage(2.0, self) # Gọi hàm take_damage trên kẻ địch, truyền vào lượng sát thương
		queue_free()  # Xóa projectile sau khi va chạm
