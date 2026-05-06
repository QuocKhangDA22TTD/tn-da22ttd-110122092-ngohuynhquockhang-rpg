extends AttackBehavior
class_name MeleeAttack

var current_weapon_data: WeaponData # Lưu trữ WeaponData hiện tại để sử dụng trong hàm xử lý va chạm
var is_executing: bool = false # Biến để kiểm tra xem đang trong quá trình thực hiện tấn công hay không
var is_ready: bool = false # Biến để kiểm tra xem đã kết nối tín hiệu hit_enemy của hitbox hay chưa, tránh kết nối nhiều lần

func ensure_ready(user):
	if is_ready:
		return
	
	var hitbox = user.hitbox
	if not hitbox.hit_enemy.is_connected(_on_hitbox_hit_enemy):
		hitbox.hit_enemy.connect(_on_hitbox_hit_enemy) # Kết nối tín hiệu hit_enemy của hitbox với hàm xử lý _on_hitbox_hit_enemy

	is_ready = true

func execute(user, weapon_data):
	if is_executing:
		return
	
	is_executing = true
	current_weapon_data = weapon_data
	# Lấy vị trí chuột trong world space thông qua user (Player)
	var mouse_pos = user.get_global_mouse_position()
	var player_pos = user.global_position
	
	# Tính vector từ nhân vật đến chuột
	var direction = (mouse_pos - player_pos).normalized()
	
	# Xác định hướng tấn công dựa trên góc
	var attack_direction: String
	var angle = atan2(direction.y, direction.x)
	
	# Chia thành 4 hướng: up, down, side (left/right)
	if angle > -PI/4 and angle < PI/4:
		# Hướng phải
		attack_direction = "side"
		user.sprite_2d.flip_h = false
		user.weapon_pivot.scale.x = 1
	elif angle > PI/4 and angle < 3*PI/4:
		# Hướng xuống
		attack_direction = "down"
		user.sprite_2d.flip_h = false
		user.weapon_pivot.scale.x = 1
	elif angle < -PI/4 and angle > -3*PI/4:
		# Hướng lên
		attack_direction = "up"
		user.sprite_2d.flip_h = false
		user.weapon_pivot.scale.x = 1
	else:
		# Hướng trái
		attack_direction = "side"
		user.sprite_2d.flip_h = true
		user.weapon_pivot.scale.x = -1
	
	# Cập nhật vị trí hiệu ứng tấn công dựa trên weapon_data
	user.effect_sprite_2d.offset = weapon_data.effect_offset
	
	# Hiển thị vũ khí
	user.weapon_sprite_2d.visible = true
	
	# Phát animation tấn công theo hướng
	var animation_name = "melee_attack_" + attack_direction
	user.animation_player.play(animation_name)

	var hitbox = user.hitbox # Lấy tham chiếu đến hitbox của player
	
	# Chờ animation kết thúc
	await user.animation_player.animation_finished
	
	# Reset danh sách enemy đã hit
	hitbox.reset_hit_list()

	# Cập nhật hướng cuối cùng của nhân vật
	user.last_direction = attack_direction
	
	# Ẩn vũ khí sau khi tấn công kết thúc
	user.weapon_sprite_2d.visible = false
	
	# Cho phép tấn công tiếp theo
	is_executing = false

func handle_input(user, weapon_data, input_state):
	ensure_ready(user) # Đảm bảo đã kết nối tín hiệu hit_enemy của hitbox trước khi xử lý input

	if input_state.just_pressed:
		execute(user, weapon_data)

# Hàm xử lý khi Hitbox va chạm với enemy
func _on_hitbox_hit_enemy(enemy: Node2D) -> void:
	enemy.take_damage(current_weapon_data.damage, GameManager.player) # Gọi hàm take_damage trên enemy với lượng damage và nguồn tấn công (source)
