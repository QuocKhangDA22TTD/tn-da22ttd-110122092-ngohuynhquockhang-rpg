extends CharacterBody2D

@export var data: EnemyData
@export var states: Array[EnemyState]
@export var sprite_2d: Sprite2D
@export var animation_player: AnimationPlayer
@export var health_bar: TextureProgressBar
@export var damage_number_scene: PackedScene # Cảnh để hiển thị số sát thương khi Enemy bị tấn công
@export var navigation_agent_2d: NavigationAgent2D

var current_state: EnemyState
var current_health: int # Máu hiện tại của Enemy
var speed: float
var desired_velocity: Vector2 = Vector2.ZERO # Tốc độ mong muốn được tính toán từ state hiện tại, sẽ được gửi đến NavigationAgent2D để tránh va chạm

func _ready():
	current_health = data.max_hp # Khởi tạo máu hiện tại bằng máu tối đa từ EnemyData
	health_bar.max_value = data.max_hp # Thiết lập giá trị tối đa của thanh máu bằng máu tối đa từ EnemyData
	health_bar.value = current_health # Cập nhật giá trị của thanh máu bằng current_health để đảm bảo nó hiển thị đúng ngay từ đầu
	health_bar.visible = false # ẩn thanh máu khi chưa bị tấn công
	speed = data.speed # Khởi tạo tốc độ từ EnemyData

	# Tạo instance riêng cho mỗi state thay vì dùng resource chia sẻ
	for state_resource in data.states:
		var state_instance = state_resource.duplicate()  # Tạo copy riêng
		states.append(state_instance)
	
	# GÁN ANIMATION
	if data.animation_library:
		# Kiểm tra nếu animation library đã tồn tại trong animation player, nếu chưa thì thêm vào
		if not animation_player.has_animation_library(""):
			animation_player.add_animation_library("", data.animation_library)

	# bắt đầu state đầu tiên
	if states.size() > 0:
		change_state(states[0])
	
	# Kết nối signal velocity_computed từ NavigationAgent2D
	if navigation_agent_2d:
		navigation_agent_2d.velocity_computed.connect(_on_velocity_computed)


func _physics_process(delta):
	if current_state:
		current_state.update(self, delta)

	# Gửi desired velocity tới NavigationAgent2D để avoidance hoạt động
	if navigation_agent_2d:
		navigation_agent_2d.set_velocity(desired_velocity)
	
	# lật sprite dựa trên hướng di chuyển
	if velocity.x != 0:
		sprite_2d.flip_h = velocity.x < 0

	move_and_slide()


func _on_velocity_computed(safe_velocity: Vector2) -> void:
	# Nếu desired_velocity là Vector2.ZERO, có nghĩa là state hiện tại không muốn di chuyển,
	# nên giữ nguyên velocity bằng Vector2.ZERO để tránh va chạm không cần thiết
	if desired_velocity == Vector2.ZERO:
		velocity = Vector2.ZERO
	else:
		velocity = safe_velocity # Sử dụng safe_velocity được tính toán bởi NavigationAgent2D để tránh va chạm


func change_state(new_state):
	if current_state:
		current_state.exit(self)

	current_state = new_state

	if current_state:
		current_state.enter(self)


func play_anim(name):
	if animation_player.has_animation(name):
		animation_player.play(name)


func get_player():
	return GameManager.player


func get_state(state_type):
	for state in states:
		if is_instance_of(state, state_type):
			return state
	return null


func distance_to_player():
	var player = get_player()
	if player:
		return global_position.distance_to(player.global_position)
	return null


func take_damage(amount, source = null): # source là nguồn gây sát thương, có thể là player hoặc một cái gì đó khác
	current_health -= amount
	current_health = clampi(current_health, 0, data.max_hp) # Đảm bảo máu không vượt quá max_hp và không âm
	health_bar.value = current_health # Cập nhật giá trị của thanh máu sau khi bị tấn công
	health_bar.visible = true # hiện thanh máu khi bị tấn công

	spawn_damage_number(amount) # Hiển thị số sát thương
	
	var hit_state = get_state(HitState)
	hit_state.damage_source = source # Truyền nguồn gây sát thương vào hit state để có thể sử dụng nếu cần
	change_state(hit_state)


func spawn_damage_number(amount: int):
	if damage_number_scene:
		var damage_number = damage_number_scene.instantiate()
		# Đặt vị trí xuất hiện ngay tại tâm Enemy (hoặc lệch lên trên một chút)
		damage_number.global_position = global_position + Vector2(0, -20) 
		
		# Truyền dữ liệu vào node số sát thương
		damage_number.set_values(amount, false)
		
		# Thêm vào Main Scene để không bị di chuyển theo Enemy khi Enemy chạy
		get_tree().current_scene.add_child(damage_number)
