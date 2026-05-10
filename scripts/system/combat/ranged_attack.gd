extends AttackBehavior
class_name RangedAttack

var current_weapon_data: WeaponData # Lưu trữ WeaponData hiện tại để sử dụng trong hàm xử lý va chạm
var is_drawing: bool = false # Biến để kiểm tra xem đang trong quá trình kéo cung hay không
var current_projectile: Node = null # Tham chiếu đến projectile hiện tại đang được tạo ra, để cập nhật vị trí khi kéo và set hướng khi bắn


func handle_input(user, weapon_data, input_state):
	current_weapon_data = weapon_data # Cập nhật WeaponData hiện tại mỗi khi tấn công, để sử dụng trong hàm xử lý va chạm

	ensure_weapon_visible(user) # Đảm bảo sprite vũ khí hiển thị khi tấn công
	update_bow_aim(user) # Cập nhật hướng bắn mỗi frame dựa trên vị trí chuột

	if input_state.just_pressed:
		is_drawing = true
		bow_draw(user) # Phát animation kéo cung
		
		# Tạo projectile và add vào scene tree ngay lập tức
		var projectile_scene = preload("res://scenes/Projectile.tscn") # Thay bằng đường dẫn thực tế đến scene projectile của bạn
		current_projectile = projectile_scene.instantiate() # Tạo instance của projectile
		current_projectile.global_position = user.arrow_spawn_point.global_position # Đặt vị trí ban đầu của projectile tại điểm spawn trên người chơi
		current_projectile.rotation = user.weapon_pivot.global_rotation # Đặt hướng ban đầu của projectile theo hướng vũ khí
		ProjectileManager.add_child(current_projectile)# Add vào ProjectileManager trước khi set hướng và tốc độ để tránh lỗi nếu projectile có logic trong _ready hoặc _process phụ thuộc vào việc đã có trong scene tree hay chưa

	elif input_state.pressed and is_drawing:
		# Cập nhật vị trí projectile theo arrow_spawn_point khi đang kéo
		if current_projectile:
			current_projectile.global_position = user.arrow_spawn_point.global_position
			current_projectile.rotation = user.weapon_pivot.global_rotation

	elif input_state.just_released and is_drawing:
		is_drawing = false

		# Khi buông chuột, set speed và direction để projectile bay
		if current_projectile:
			current_projectile.speed = 400.0
			current_projectile.direction = Vector2.RIGHT.rotated(user.weapon_pivot.global_rotation)
			current_projectile = null

		bow_idle(user)

	elif not is_drawing:
		bow_idle(user)


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

	user.weapon_pivot.rotation = angle

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
