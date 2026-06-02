extends ChaseState
class_name SlimeChaseState

var attack_distance: float

func enter(enemy):
	# Lấy thông số từ EnemyData để sử dụng trong quá trình tuần tra
	chase_distance = enemy.data.chase_distance
	reaction_delay = enemy.data.reaction_delay
	attack_distance = enemy.data.attack_distance

	enemy.play_anim("chase") # Phát hoạt ảnh đuổi theo

	update_timer = 0.0 # reset timer khi vào trạng thái Chase

func update(enemy, delta):
	var distance_to_player = enemy.distance_to_player() # tính khoảng cách đến người chơi

	if distance_to_player != null and distance_to_player < attack_distance:
		var attack_state = enemy.get_state(AttackState)
		if attack_state:
			enemy.change_state(attack_state)
		return

	# Nếu người chơi nằm trong khoảng cách đuổi theo và timer đã hết, cập nhật mục tiêu đến vị trí người chơi
	if distance_to_player != null and distance_to_player < chase_distance:
		update_timer -= delta

		if update_timer <= 0:
			enemy.navigation_agent_2d.target_position = GameManager.player.global_position
			update_timer = reaction_delay # Reset lại bộ đếm
	
	# Nếu người chơi ra khỏi khoảng cách đuổi theo và kẻ địch đã hoàn thành việc di chuyển đến mục tiêu hiện tại, chuyển sang trạng thái Idle
	elif distance_to_player != null and distance_to_player >= chase_distance and enemy.navigation_agent_2d.is_navigation_finished():
		var idle = enemy.get_state(IdleState)
		if idle:
			enemy.change_state(idle)
		return
	
	# Đặc điểm riêng của Slime: nếu animation chưa chạy được 0.2 giây, không di chuyển (để tạo hiệu ứng "chậm chạp của Slime")
	if enemy.animation_player.current_animation_position < 0.2:
		enemy.desired_velocity = Vector2.ZERO
		return
	
	# Lấy vị trí tiếp theo trên đường đi đến mục tiêu
	var next_path_pos: Vector2 = enemy.navigation_agent_2d.get_next_path_position()

	# Tính toán vận tốc mong muốn để di chuyển về phía vị trí tiếp theo trên đường đi
	enemy.desired_velocity = enemy.global_position.direction_to(next_path_pos) * enemy.speed
