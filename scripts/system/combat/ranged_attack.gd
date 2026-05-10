extends AttackBehavior
class_name RangedAttack

var current_weapon_data: WeaponData # Lưu trữ WeaponData hiện tại để sử dụng trong hàm xử lý va chạm
var is_drawing: bool = false


func handle_input(user, weapon_data, input_state):
	current_weapon_data = weapon_data

	ensure_weapon_visible(user) # Đảm bảo sprite vũ khí được hiển thị khi bắt đầu tấn công
	update_bow_aim(user) # Cập nhật hướng bắn ngay khi bắt đầu

	if input_state.just_pressed:
		is_drawing = true
		bow_draw(user) # Phát animation kéo cung khi bắt đầu giữ nút

	elif input_state.pressed and is_drawing:
		pass # Giữ nguyên animation bow_draw và cập nhật hướng bắn liên tục trong khi giữ nút

	elif input_state.just_released and is_drawing:
		is_drawing = false # Khi thả nút, thực hiện bắn tên và quay về animation idle

		# spawn arrow ở đây

		bow_idle(user) # Quay về trạng thái idle sau khi bắn

	elif not is_drawing:
		bow_idle(user) # Nếu không đang kéo cung, đảm bảo ở trạng thái idle


func bow_idle(user):
	play_weapon_animation(user, "bow_idle")


func bow_draw(user):
	play_weapon_animation(user, "bow_draw")


func ensure_weapon_visible(user):
	if not user.weapon_sprite_2d.visible:
		user.weapon_sprite_2d.visible = true


func play_weapon_animation(user, animation_name: String):
	if user.animation_weapon.current_animation != animation_name:
		user.animation_weapon.play(animation_name)


func update_bow_aim(user):
	var mouse_pos: Vector2 = user.get_global_mouse_position()
	var pivot_pos: Vector2 = user.weapon_pivot.global_position
	var direction: Vector2 = (mouse_pos - pivot_pos).normalized()
	var angle: float = direction.angle()

	# Xoay toàn bộ weapon pivot theo chuột
	user.weapon_pivot.rotation = angle

	# Xác định hướng animation
	var attack_direction: String = get_attack_direction(angle)

	match attack_direction:
		"left":
			user.sprite_2d.flip_h = true
			user.last_direction = "side"

		"right":
			user.sprite_2d.flip_h = false
			user.last_direction = "side"

		"up":
			user.sprite_2d.flip_h = false
			user.last_direction = "up"

		"down":
			user.sprite_2d.flip_h = false
			user.last_direction = "down"


func get_attack_direction(angle: float) -> String:
	if angle >= -PI / 4 and angle <= PI / 4:
		return "right"

	elif angle > PI / 4 and angle <= 3 * PI / 4:
		return "down"

	elif angle >= -3 * PI / 4 and angle < -PI / 4:
		return "up"

	else:
		return "left"
