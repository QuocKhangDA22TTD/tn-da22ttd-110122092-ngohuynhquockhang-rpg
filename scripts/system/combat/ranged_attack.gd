extends AttackBehavior
class_name RangedAttack

var current_weapon_data: WeaponData
var current_projectile: Node = null

var is_drawing := false
var is_releasing := false
var is_ready := false


func ensure_ready(user):
	if is_ready:
		return

	if not user.animation_weapon.animation_finished.is_connected(_on_weapon_animation_finished):
		user.animation_weapon.animation_finished.connect(
			_on_weapon_animation_finished.bind(user)
		)

	is_ready = true


func handle_input(user, weapon_data, input_state):
	current_weapon_data = weapon_data

	ensure_ready(user)
	update_bow_aim(user)

	# Nếu đang trong trạng thái dodge, xử lý ẩn hiện vũ khí và hủy bỏ projectile nếu có, sau đó bỏ qua các input tấn công
	if handle_dodge_state(user):
		return

	# just_pressed để bắt đầu quá trình kéo dây cung
	if input_state.just_pressed:
		start_draw(user)

	# pressed để cập nhật vị trí và hướng của projectile trong khi kéo dây cung
	elif input_state.pressed and is_drawing:
		update_draw(user)

	# just_released để bắn tên và kết thúc quá trình tấn công
	elif input_state.just_released and is_drawing:
		release_attack(user)

	# Nếu không có input nào và không đang tấn công, chuyển về trạng thái idle của cung
	elif not is_attacking():
		bow_idle(user)


func handle_dodge_state(user) -> bool:
	if not user.is_dodging:
		show_weapon(user)
		return false

	hide_weapon(user)

	cancel_projectile()

	is_drawing = false
	is_releasing = false

	return true


func show_weapon(user):
	user.weapon_sprite_2d.visible = true
	user.arm_sprite_2d.visible = true

	if current_projectile:
		current_projectile.visible = true


func hide_weapon(user):
	user.weapon_sprite_2d.visible = false
	user.arm_sprite_2d.visible = false

	if current_projectile:
		current_projectile.visible = false


func start_draw(user):
	is_drawing = true
	is_releasing = false

	bow_draw(user)
	spawn_projectile(user)


func update_draw(user):
	if not current_projectile:
		return

	current_projectile.global_position = user.projectile_spawn_point.global_position
	current_projectile.rotation = user.weapon_pivot.global_rotation


func release_attack(user):
	fire_projectile(user)

	bow_release(user)

	is_drawing = false
	is_releasing = true


func spawn_projectile(user):
	var projectile_scene = current_weapon_data.default_projectile

	current_projectile = projectile_scene.instantiate()

	current_projectile.global_position = user.projectile_spawn_point.global_position
	current_projectile.rotation = user.weapon_pivot.global_rotation
	current_projectile.owner_entity = user.hurtbox # Gán hurtbox của user làm owner_entity để tránh va chạm với chính mình

	ProjectileManager.add_child(current_projectile)


func fire_projectile(user):
	if not current_projectile:
		return

	current_projectile.direction = Vector2.RIGHT.rotated(
		user.weapon_pivot.global_rotation
	)

	current_projectile = null


func cancel_projectile():
	if current_projectile:
		current_projectile.queue_free()
		current_projectile = null


func bow_idle(user):
	play_weapon_animation(user, "bow_idle")


func bow_draw(user):
	play_weapon_animation(user, "bow_draw")


func bow_release(user):
	play_weapon_animation(user, "bow_release")


func play_weapon_animation(user, animation_name: String):
	if user.animation_weapon.current_animation != animation_name:
		user.animation_weapon.play(animation_name)


func apply_bow_shake(user):
	var shake_amount := 0.25

	user.weapon_pivot.global_position += Vector2(
		randf_range(-shake_amount, shake_amount),
		randf_range(-shake_amount, shake_amount)
	)


func update_bow_aim(user):
	var mouse_pos = user.get_global_mouse_position()
	var pivot_pos = user.weapon_pivot.global_position

	var direction = (mouse_pos - pivot_pos).normalized()
	var angle = direction.angle()

	user.weapon_pivot.rotation = angle

	match get_attack_direction(angle):
		"left":
			user.sprite_2d.flip_h = true
			user.last_direction = "side"
			user.arm_sprite_2d.scale.y = -1.0

		"right":
			user.sprite_2d.flip_h = false
			user.last_direction = "side"
			user.arm_sprite_2d.scale.y = 1.0

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

	return "left"


func _on_weapon_animation_finished(anim_name: StringName, user):
	if anim_name == "bow_release":
		bow_idle(user)
		is_releasing = false


func is_attacking() -> bool:
	return is_drawing or is_releasing
