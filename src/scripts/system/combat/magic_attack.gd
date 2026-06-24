extends AttackBehavior
class_name MagicAttack

var current_weapon: MagicWeaponData
var cooldown_timer: float = 0.0 # thời gian còn lại trước khi có thể tấn công lại
var cooldown: float = 0.1 # thời gian cooldown giữa các lần tấn công

func handle_input(user, weapon_data, input_state):
	current_weapon = weapon_data

	update_magic_aim(user)

	if cooldown_timer > 0:
		cooldown_timer -= user.get_physics_process_delta_time()

	if input_state.pressed and not user.is_dodging and cooldown_timer <= 0:
		if user.has_method("use_mana") and user.use_mana(current_weapon.mana_cost):
			execute(user, current_weapon)
	else:
		if user.animation_weapon.current_animation != "staff_idle":
			user.animation_weapon.play("staff_idle")


func execute(user, current_weapon):
	if current_weapon.spell_scene:
		var spell_instance = current_weapon.spell_scene.instantiate()

		var spawn_pos = user.projectile_spawn_point.global_position

		spell_instance.global_position = spawn_pos
		spell_instance.rotation = user.weapon_pivot.global_rotation
		spell_instance.owner_entity = user.hurtbox # Đặt owner_entity của projectile là hurtbox của player để tránh va chạm với chính mình
		
		var mouse_pos = user.get_global_mouse_position()
		var direction = (mouse_pos - user.weapon_pivot.global_position).normalized()

		spell_instance.direction = direction
		
		ProjectileManager.add_child(spell_instance)

		cooldown_timer = cooldown

func update_magic_aim(user):
	var mouse_pos = user.get_global_mouse_position()
	var direction = (mouse_pos - user.weapon_pivot.global_position).normalized()
	user.weapon_pivot.rotation = direction.angle()

	if direction != Vector2.ZERO:
		if direction.x < 0:
			user.arm_sprite_2d.scale.y = -1.0
		else:
			user.arm_sprite_2d.scale.y = 1.0
