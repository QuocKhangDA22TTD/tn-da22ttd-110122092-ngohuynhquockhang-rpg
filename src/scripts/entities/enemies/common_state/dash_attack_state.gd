extends AttackState
class_name DashAttackState

var attack_dash_speed: float
var charge_timer: float = 0.0
var attack_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var is_active: bool = false

func enter(enemy) -> void:
	charge_timer = enemy.data.charge_duration
	attack_timer = enemy.data.attack_duration
	attack_dash_speed = enemy.data.attack_dash_speed
	is_active = false # Đánh dấu chưa bắt đầu lao đi, sẽ được set true khi charge xong và bắt đầu dash
	
	# Kết nối signal hitbox khi enter state
	if enemy.hitbox and not enemy.hitbox.hit_hurtbox.is_connected(_on_hitbox_hit.bind(enemy)):
		enemy.hitbox.hit_hurtbox.connect(_on_hitbox_hit.bind(enemy))
	
	enemy.desired_velocity = Vector2.ZERO
	enemy.velocity = Vector2.ZERO
	
	var player = enemy.get_player()
	if player:
		dash_direction = enemy.global_position.direction_to(player.global_position)
	else:
		dash_direction = Vector2.ZERO
	
	enemy.sprite_2d.flip_h = dash_direction.x < 0
	enemy.play_anim("prepare_attack")

func update(enemy, delta: float) -> void:
	# Giai đoạn gồng đòn
	if charge_timer > 0:
		charge_timer -= delta
		enemy.velocity = Vector2.ZERO
		is_active = false
		return
	
	attack_timer -= delta
	
	# Kết thúc tấn công
	if attack_timer <= 0:
		is_active = false
		enemy.velocity = Vector2.ZERO
		if enemy.hitbox:
			enemy.hitbox.reset_hit_list()
		
		var patrol = enemy.get_state(PatrolState)
		if patrol:
			enemy.change_state(patrol)
		return
	
	# Bắt đầu lao đi
	if not is_active:
		enemy.play_anim("dash_attack")
		is_active = true
	
	enemy.velocity = dash_direction * attack_dash_speed

func exit(enemy) -> void:
	is_active = false
	if enemy.hitbox:
		enemy.hitbox.reset_hit_list()

func _on_hitbox_hit(area: Area2D, enemy: CharacterBody2D) -> void:
	if area.is_in_group("player"):
		var player = GameManager.player
		if player and player.has_method("take_damage"):
			player.take_damage(enemy.data.damage)
