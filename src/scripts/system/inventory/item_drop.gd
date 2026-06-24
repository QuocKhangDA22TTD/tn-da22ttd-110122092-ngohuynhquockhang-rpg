extends Node2D

# Dữ liệu vật phẩm
@export var item : ItemData
# Số lượng vật phẩm
@export var amount : int = 1
@export var pickup_delay : float = 0.5
@export var move_speed : float = 160.0

# Tham chiếu đến các Node
@onready var sprite = $Sprite2D
@onready var area = $Area2D

var can_pickup : bool = false
var target_player = null

func _ready():
	# 1. Thiết lập hiển thị hình ảnh
	if item and item.icon:
		sprite.texture = item.icon
		if item.world_scale > 0:
			sprite.scale = Vector2(item.world_scale, item.world_scale)
		
	# 2. Kết nối signal NGAY LẬP TỨC từ đầu để tránh bỏ sót va chạm
	area.body_entered.connect(_on_body_entered)
	
	# 3. Đợi hết thời gian delay rồi mới cho phép nhặt
	await get_tree().create_timer(pickup_delay).timeout
	can_pickup = true
	
	# 4. QUAN TRỌNG: Kiểm tra nếu Player đã đứng sẵn trong Area2D từ trước
	_check_overlapping_bodies()


func _process(delta):
	# Chỉ di chuyển nếu có mục tiêu và túi đồ còn chỗ (hoặc có thể nhặt được)
	if target_player and can_pickup:
		# Kiểm tra lại xem túi đồ còn chỗ chứa vật phẩm này không, nếu ĐẦY thì hủy mục tiêu
		if not InventoryManager.has_space_for(item, amount):
			target_player = null
			return

		# Di chuyển về phía player
		var direction = (target_player.global_position - global_position).normalized()
		global_position += direction * move_speed * delta
		
		# Kiểm tra đã chạm player chưa
		if global_position.distance_to(target_player.global_position) <= 5.0:
			if InventoryManager.add_item(item, amount):
				queue_free()


# Hàm xử lý khi Player bước vào vùng hút
func _on_body_entered(body):
	if can_pickup and body.name == "Player" and target_player == null:
		# Chỉ hút nếu túi đồ còn chỗ
		if InventoryManager.has_space_for(item, amount):
			target_player = body


# Hàm quét các vật thể đang đứng sẵn bên trong Area2D
func _check_overlapping_bodies():
	if not can_pickup: return
	
	var overlapping_bodies = area.get_overlapping_bodies()
	for body in overlapping_bodies:
		if body.name == "Player":
			_on_body_entered(body)
			break
