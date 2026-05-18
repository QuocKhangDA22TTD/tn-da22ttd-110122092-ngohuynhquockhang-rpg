extends AttackBehavior
class_name RangedAttack

var current_weapon_data: WeaponData
var is_drawing: bool = false
var is_releasing: bool = false
var current_projectile: Node = null
var is_ready: bool = false


func ensure_ready(user):
	if is_ready:
		return

	# Kết nối signal animation_finished một lần duy nhất
	if not user.animation_weapon.animation_finished.is_connected(_on_weapon_animation_finished):
		user.animation_weapon.animation_finished.connect(
			_on_weapon_animation_finished.bind(user)
		)

	is_ready = true


func handle_input(user, weapon_data, input_state):
	current_weapon_data = weapon_data

	ensure_weapon_visible(user)
	ensure_ready(user)
	update_bow_aim(user)

	if input_state.just_pressed:
		is_drawing = true
		is_releasing = false
		bow_draw(user)

		# Tạo projectile
		var projectile_scene = preload("res://scenes/Projectile.tscn")
		current_projectile = projectile_scene.instantiate()

		current_projectile.global_position = user.arrow_spawn_point.global_position
		current_projectile.rotation = user.weapon_pivot.global_rotation

		ProjectileManager.add_child(current_projectile)

	elif input_state.pressed and is_drawing:
		# Giữ projectile tại vị trí spawn khi đang kéo
		if current_projectile:
			current_projectile.global_position = user.arrow_spawn_point.global_position
			current_projectile.rotation = user.weapon_pivot.global_rotation

	elif input_state.just_released and is_drawing:
		# Bắn projectile
		if current_projectile:
			current_projectile.speed = 400.0
			current_projectile.direction = Vector2.RIGHT.rotated(
				user.weapon_pivot.global_rotation
			)
			current_projectile = null

		bow_release(user)
		is_releasing = true

	elif not is_drawing and not is_releasing:
		bow_idle(user)


func bow_idle(user):
	play_weapon_animation(user, "bow_idle")


func bow_draw(user):
	play_weapon_animation(user, "bow_draw")


func bow_release(user):
	play_weapon_animation(user, "bow_release")


func apply_bow_shake(user):
	var shake_amount: float = 0.25
	var shake_x: float = randf_range(-shake_amount, shake_amount)
	var shake_y: float = randf_range(-shake_amount, shake_amount)
	user.weapon_pivot.global_position += Vector2(shake_x, shake_y)


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


func _on_weapon_animation_finished(anim_name: StringName, user):
	if anim_name == "bow_release":
		bow_idle(user)
		is_releasing = false
		is_drawing = false


# Kiểm tra xem vũ khí có đang xử lý tấn công không
func is_attacking() -> bool:
	return is_drawing or is_releasing
