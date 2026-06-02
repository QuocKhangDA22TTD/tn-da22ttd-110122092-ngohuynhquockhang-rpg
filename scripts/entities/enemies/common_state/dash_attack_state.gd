extends AttackState
class_name DashAttackState

var attack_dash_speed: float # Tốc độ lao đi khi tấn công, được lấy từ EnemyData
var charge_timer: float = 0.0 # Bộ đếm thời gian cho giai đoạn đứng yên gồng đòn
var attack_timer: float = 0.0 # Bộ đếm thời gian cho giai đoạn lao đi tấn công
var dash_direction: Vector2 = Vector2.ZERO # Hướng lao đi khi tấn công, được xác định ngay khi bắt đầu

func enter(enemy) -> void:
	# Gán giá trị từ EnemyData cho các biến để sử dụng trong quá trình tấn công
	charge_timer = enemy.data.charge_duration
	attack_timer = enemy.data.attack_duration
	attack_dash_speed = enemy.data.attack_dash_speed
	
	# ngừng di chuyển để đứng yên gồng đòn
	enemy.desired_velocity = Vector2.ZERO
	enemy.velocity = Vector2.ZERO
	
	# Tính hướng lao đi khi tấn công dựa trên vị trí hiện tại của player, nếu player không tồn tại thì không di chuyển
	var player = enemy.get_player()
	if player:
		# Tính hướng từ quái đến player ngay lúc này và khóa chặt nó lại
		dash_direction = enemy.global_position.direction_to(player.global_position)
	else:
		dash_direction = Vector2.ZERO
	
	enemy.sprite_2d.flip_h = dash_direction.x < 0 # Lật sprite dựa trên hướng lao đi
	enemy.play_anim("prepare_attack") # Phát hoạt ảnh chuẩn bị tấn công (gồng đòn)

func update(enemy, delta: float) -> void:
	# Nếu đang trong giai đoạn đứng yên gồng đòn, giảm timer cho giai đoạn gồng đòn và không di chuyển
	if charge_timer > 0:
		charge_timer -= delta
		enemy.desired_velocity = Vector2.ZERO
		enemy.velocity = Vector2.ZERO
		return

	attack_timer -= delta # Giảm timer cho giai đoạn lao đi tấn công

	# Nếu giai đoạn lao đi đã kết thúc, chuyển về trạng thái tuần tra
	if attack_timer <= 0:
		enemy.desired_velocity = Vector2.ZERO
		var patrol = enemy.get_state(PatrolState)
		if patrol:
			enemy.change_state(patrol)
		return
	
	# Nếu animation chưa chuyển sang "attack_dash", phát hoạt ảnh tấn công
	if enemy.animation_player.current_animation != "dash_attack":
		enemy.play_anim("dash_attack")

	# Lao thẳng theo hướng cũ đã chốt từ trước
	enemy.desired_velocity = Vector2.ZERO 
	enemy.velocity = dash_direction * attack_dash_speed
