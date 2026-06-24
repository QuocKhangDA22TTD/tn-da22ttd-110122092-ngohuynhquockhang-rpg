extends Marker2D

@export var enemy_scene: PackedScene # Scene của quái cần đẻ ra
@export var enemy_data: EnemyData # Chứa thông tin máu, tốc độ, loại quái...
@export var max_enemies: int = 10 # Số quái tối đa cùng lúc do spawner này quản lý
@export var activation_distance: float = 800.0 # Bán kính kích hoạt quanh Player
@export var spawn_cooldown: float = 1.0 # Thời gian giữa các lần đẻ quái (giây)

var current_enemies: int = 0 # Số quái hiện tại do spawner này quản lý
var spawn_timer: Timer # Timer để quản lý thời gian đẻ quái

func _ready():
	# Tạo Timer bằng code để Scene Tree gọn gàng
	spawn_timer = Timer.new()
	spawn_timer.wait_time = spawn_cooldown
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	add_child(spawn_timer)

func _physics_process(_delta):
	# Kiểm tra Player có ở gần không
	var player = GameManager.player
	if not player:
		return
	
	var dist = global_position.distance_to(player.global_position) # Khoảng cách từ spawner đến Player
	
	# Bật timer nếu Player vào gần, tắt nếu Player đi xa
	if dist <= activation_distance and spawn_timer.is_stopped():
		spawn_timer.start()
	elif dist > activation_distance and not spawn_timer.is_stopped():
		spawn_timer.stop()

func _on_spawn_timer_timeout():
	if current_enemies < max_enemies and enemy_scene:
		spawn_enemy()

func spawn_enemy():
	var enemy = enemy_scene.instantiate()
	
	# Nạp data cho quái (để 1 scene Enemy dùng được cho nhiều loại quái)
	if enemy_data:
		enemy.data = enemy_data
	
	# Random vị trí một chút để quái không đẻ đè lên nhau
	var random_offset = Vector2(randf_range(-40, 40), randf_range(-40, 40))
	enemy.global_position = global_position + random_offset
	
	# Theo dõi khi quái chết hoặc bị xóa
	enemy.tree_exiting.connect(_on_enemy_died)
	current_enemies += 1
	
	# Tìm thư mục "Enemies" trên Map để thả quái vào
	var enemy_container = GameManager.enemies_container
	if enemy_container:
		enemy_container.add_child(enemy)
	else:
		get_tree().current_scene.add_child(enemy)

func _on_enemy_died():
	current_enemies -= 1
