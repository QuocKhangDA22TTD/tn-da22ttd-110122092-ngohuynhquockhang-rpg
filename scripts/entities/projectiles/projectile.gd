extends Area2D

@export var speed: float = 300.0
@export var damage: float = 40.0
@export var exist_timer = 0.0
@export var max_exist_time = 3.0

var owner_entity: Node = null # Biến để lưu reference đến entity sở hữu viên đạn, dùng để tránh va chạm với chính mình
var direction: Vector2 = Vector2.ZERO # Hướng di chuyển của viên đạn

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:

	if rotation != direction.angle():
		rotation = direction.angle() # Xoay projectile theo hướng di chuyển
	
	var velocity = direction * speed # Tính toán vận tốc dựa trên hướng và tốc độ
	position += velocity * delta # Cập nhật vị trí của viên đạn
	
	exist_timer += delta

	if exist_timer >= max_exist_time:
		queue_free()  # Xóa projectile nếu đã tồn tại quá lâu


func _on_area_entered(area: Area2D) -> void:
	if area == owner_entity:
		return  # Không va chạm với chính mình

	if area.is_in_group("enemy") and area.has_method("take_damage") and speed != 0.0:
		area.take_damage(damage, self) # Gọi hàm take_damage trên kẻ địch, truyền vào lượng sát thương
		queue_free()  # Xóa projectile sau khi va chạm
	
	elif area.is_in_group("player") and speed != 0.0:
		if area.has_method("take_damage"):
			area.take_damage(damage, self) # Gọi hàm take_damage trên player, truyền vào lượng sát thương
		queue_free() # Xóa projectile sau khi va chạm
