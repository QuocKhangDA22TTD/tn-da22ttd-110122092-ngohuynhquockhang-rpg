extends EnemyState
class_name PatrolState

var patrol_radius: float # bán kính mà kẻ địch sẽ di chuyển xung quanh
var max_patrol_duration: float # Thời gian tối đa cho một lượt đi tuần
var chase_distance: float # Khoảng cách mà kẻ địch sẽ bắt đầu đuổi theo người chơi
var rng := RandomNumberGenerator.new() # bộ sinh số ngẫu nhiên để chọn mục tiêu tuần tra ngẫu nhiên
var patrol_timer: float = 0.0 # Biến đếm thời gian

func enter(enemy):
	rng.randomize() # khởi tạo bộ sinh số ngẫu nhiên

	# Lấy thông số từ EnemyData để sử dụng trong quá trình tuần tra
	patrol_radius = enemy.data.patrol_radius
	max_patrol_duration = enemy.data.max_patrol_duration
	chase_distance = enemy.data.chase_distance

	_move_to_random_target(enemy) # gọi hàm để chọn một mục tiêu ngẫu nhiên

	enemy.play_anim("patrol") # phát animation đi bộ


func update(enemy, delta):
	var distance_to_player = enemy.distance_to_player() # tính khoảng cách đến người chơi

	# Nếu người chơi ở trong khoảng cách đuổi theo, chuyển sang trạng thái Chase
	if distance_to_player != null and distance_to_player < chase_distance:
		var chase = enemy.get_state(ChaseState)
		if chase:
			enemy.change_state(chase)

	patrol_timer -= delta # giảm timer theo thời gian

	# Nếu timer hết hoặc đã đi đến đích, chọn một mục tiêu mới
	if patrol_timer <= 0 or enemy.navigation_agent_2d.is_navigation_finished():
		var idle = enemy.get_state(IdleState)
		if idle:
			enemy.change_state(idle)
		return
	
	# di chuyển đến vị trí tiếp theo trên đường đi
	var next_path_pos: Vector2 = enemy.navigation_agent_2d.get_next_path_position()
	enemy.desired_velocity = enemy.global_position.direction_to(next_path_pos) * enemy.speed


func _move_to_random_target(enemy):
	# chọn một hướng ngẫu nhiên và một khoảng cách ngẫu nhiên
	var random_direction: Vector2 = Vector2.LEFT.rotated(rng.randf_range(0, TAU))
	var random_distance: float = rng.randf_range(0, patrol_radius)

	# tính toán vị trí cần di chuyển đến
	var target: Vector2 = enemy.global_position + (random_direction * random_distance)

	# giao mục tiêu cho navigation agent để di chuyển
	enemy.navigation_agent_2d.target_position = target

	# reset timer
	patrol_timer = max_patrol_duration
