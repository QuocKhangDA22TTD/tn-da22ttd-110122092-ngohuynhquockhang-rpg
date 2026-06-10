extends EnemyState
class_name HitState

var damage_source = null
var is_knockback = false
var knockback_velocity = Vector2.ZERO

func enter(enemy):
	enemy.velocity = Vector2.ZERO
	enemy.play_anim("hit")

	if damage_source:
		print("kẻ địch %s bị đánh trúng bởi %s" % [enemy.data.display_name, damage_source])
		apply_knockback(enemy, damage_source.global_position)

	# Ngắt kết nối trước để tránh lỗi nếu enter được gọi nhiều lần
	if enemy.animation_player.animation_finished.is_connected(_on_anim_finished):
		enemy.animation_player.animation_finished.disconnect(_on_anim_finished)
	
	# Lắng nghe animation kết thúc (chỉ 1 lần)
	enemy.animation_player.animation_finished.connect(_on_anim_finished.bind(enemy), CONNECT_ONE_SHOT)


func update(enemy, delta):
	# Knockback chạy song song với animation
	if is_knockback:
		enemy.velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 4000 * delta)

		if knockback_velocity.length() < 10:
			is_knockback = false
			enemy.velocity = Vector2.ZERO


func _on_anim_finished(anim_name, enemy):
	if anim_name != "hit":
		return

	# Sau khi animation hit xong mới quyết định state tiếp theo
	if enemy.current_health <= 0:
		enemy.change_state(enemy.get_state(DieState))
	else:
		enemy.change_state(enemy.get_state(IdleState))


func apply_knockback(enemy, attacker_position):
	is_knockback = true
	var direction = (enemy.global_position - attacker_position).normalized()
	knockback_velocity = direction * 500
