# Script điều khiển nhân vật người chơi
extends CharacterBody2D

@export var camera_2d: Camera2D # Tham chiếu đến camera theo dõi nhân vật
@export var animation_player: AnimationPlayer # Tham chiếu đến animation player để phát hoạt ảnh
@export var sprite_2d: Sprite2D # Tham chiếu đến sprite của nhân vật
@export var current_weapon: WeaponData # Tham chiếu đến vũ khí đang được cầm
@export var weapon_sprite_2d: Sprite2D # tham chiếu đến sprite cho vũ khí
@export var weapon_pivot: Node2D # tham chiếu đến điểm gốc để xoay vũ khí
@export var effect_sprite_2d: Sprite2D # Tham chiếu đến sprite hiệu ứng tấn công
@export var hitbox: Hitbox # Tham chiếu đến hitbox để xử lý va chạm tấn công
@export var animation_weapon: AnimationPlayer # Tham chiếu đến animation player để phát hoạt ảnh vũ khí
@export var animation_body_effect: AnimationPlayer
@export var arrow_spawn_point: Marker2D # Tham chiếu đến điểm spawn projectile cho tấn công tầm xa
@export var arm_sprite_2d: Sprite2D
@export var stats: CharacterStats
@export var hurtbox: Hurtbox # Tham chiếu đến hurtbox để nhận damage từ enemy

# Dodge settings
@export var dodge_speed: float = 200.0 # Tốc độ dodge
@export var dodge_duration: float = 0.3 # Thời gian dodge
@export var dodge_cooldown: float = 0.8 # Thời gian chờ giữa các dodge

# Hướng cuối cùng nhân vật đang quay mặt
var last_direction: String = "down"
# Vector chứa input từ bàn phím
var input_vector := Vector2.ZERO
# Hậu tố hoạt ảnh dựa trên loại vũ khí
var animation_suffix: String = ""

# Dodge state
var is_dodging: bool = false # Biến trạng thái để kiểm tra nếu nhân vật đang trong quá trình dodge
var dodge_timer: float = 0.0 # Bộ đếm thời gian để theo dõi thời gian còn lại của dodge
var dodge_cooldown_timer: float = 0.0 # Bộ đếm thời gian chờ giữa các dodge
var dodge_direction: Vector2 = Vector2.ZERO # Vector hướng của dodge, được xác định khi bắt đầu dodge

# Knockback state
var knockback_direction: Vector2 = Vector2.ZERO # Vector hướng của knockback, được xác định khi bị tấn công
var knockback_timer: float = 0.0 # Bộ đếm thời gian để theo dõi thời gian còn lại của knockback
var knockback_duration: float = 0.0 # Thời gian knockback, được xác định khi bị tấn công

func _ready() -> void:
	GameManager.player = self

	if stats:
		stats = stats.duplicate() # Tạo instance riêng cho stats để mỗi player có stats riêng biệt

# Xử lý vật lý và di chuyển mỗi frame
func _physics_process(delta: float) -> void:
	input_vector = _get_input_vector()
	
	# Cập nhật dodge cooldown
	if dodge_cooldown_timer > 0:
		dodge_cooldown_timer -= delta
	
	# Xử lý knockback
	if knockback_timer > 0:
		knockback_timer -= delta
		velocity = knockback_direction
	# Xử lý dodge
	elif is_dodging:
		_update_dodge(delta)
	else:
		velocity = input_vector * stats.speed
	
	move_and_slide()
	
	_handle_attack_input()
	_handle_dodge_input()

	# Cập nhật last_direction theo chuột nếu cầm ranged weapon
	if current_weapon and current_weapon.weapon_type == WeaponData.WeaponType.RANGED:
		_update_direction_from_mouse()
	
	_update_animation_and_direction()
	
	global_position = global_position.round()
	camera_2d.global_position = global_position


# Lấy vector input từ bàn phím (WASD hoặc mũi tên)
func _get_input_vector():
	if animation_player.current_animation.begins_with("melee_attack") or is_dodging:
		return Vector2.ZERO  # Không nhận input di chuyển nếu đang tấn công hoặc dodge
	
	return Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	)


func _update_direction_from_mouse():
	var mouse_pos = get_global_mouse_position()
	var weapon_pivot = weapon_pivot.global_position
	var direction = (mouse_pos - weapon_pivot).normalized()
	var angle = atan2(direction.y, direction.x)
	
	if angle > -PI/4 and angle < PI/4:
		last_direction = "side"
		sprite_2d.flip_h = false
	elif angle > PI/4 and angle < 3*PI/4:
		last_direction = "down"
		sprite_2d.flip_h = false
	elif angle < -PI/4 and angle > -3*PI/4:
		last_direction = "up"
		sprite_2d.flip_h = false
	else:
		last_direction = "side"
		sprite_2d.flip_h = true


func _update_animation_and_direction():
	if animation_player.current_animation.begins_with("melee_attack") or is_dodging:
		return
	
	_update_animation_suffix()

	if input_vector != Vector2.ZERO:
		# Nếu cầm ranged weapon, phát animation move dựa trên last_direction (từ chuột)
		if current_weapon and current_weapon.weapon_type == WeaponData.WeaponType.RANGED:
			match last_direction:
				"side":   animation_player.play("move_side" + animation_suffix)
				"up":     animation_player.play("move_up" + animation_suffix)
				"down":   animation_player.play("move_down" + animation_suffix)
		else:
			# Nếu cầm melee weapon, phát animation move dựa trên input_vector
			if input_vector.x != 0:
				animation_player.play("move_side" + animation_suffix)
				sprite_2d.flip_h = input_vector.x < 0
				last_direction = "side"
			else:
				if input_vector.y > 0:
					animation_player.play("move_down" + animation_suffix)
					last_direction = "down"
				else:
					animation_player.play("move_up" + animation_suffix)
					last_direction = "up"
	else:
		match last_direction:
			"side":   animation_player.play("idle_side" + animation_suffix)
			"up":     animation_player.play("idle_up" + animation_suffix)
			_:        animation_player.play("idle_down" + animation_suffix)



func _handle_attack_input():
	if current_weapon == null or current_weapon.attack_behavior == null:
		return  # Không có vũ khí hoặc vũ khí không có hành vi tấn công, bỏ qua xử lý tấn công
		
	var input_state = AttackInputState.new()
	input_state.pressed = Input.is_action_pressed("attack")
	input_state.just_pressed = Input.is_action_just_pressed("attack")
	input_state.just_released = Input.is_action_just_released("attack")
	
	current_weapon.attack_behavior.handle_input(self, current_weapon, input_state)


# Cập nhật hậu tố hoạt ảnh dựa trên loại vũ khí
func _update_animation_suffix():
	if current_weapon and current_weapon.weapon_type == WeaponData.WeaponType.RANGED:
		animation_suffix = "_" + current_weapon.name
	else:
		animation_suffix = ""


func _handle_dodge_input():
	if animation_player.current_animation.begins_with("melee_attack"):
		return # Không thể dodge nếu đang tấn công melee
	
	if Input.is_action_just_pressed("ui_accept") and not is_dodging and dodge_cooldown_timer <= 0:
		_start_dodge()


func _start_dodge():
	is_dodging = true
	dodge_timer = dodge_duration
	dodge_cooldown_timer = dodge_cooldown
	
	# Xác định hướng dodge
	if input_vector != Vector2.ZERO:
		dodge_direction = input_vector.normalized()
	else:
		# Nếu không có input, dodge theo hướng nhân vật đang quay mặt
		match last_direction:
			"side":
				dodge_direction = Vector2(-1 if sprite_2d.flip_h else 1, 0)
			"up":
				dodge_direction = Vector2(0, -1)
			"down":
				dodge_direction = Vector2(0, 1)
	
	animation_player.play("dodge_side")


func _update_dodge(delta: float):
	dodge_timer -= delta
	
	if dodge_timer <= 0:
		is_dodging = false
		velocity = Vector2.ZERO
	else:
		velocity = dodge_direction * dodge_speed
		
		spawn_ghost_effect()


func spawn_ghost_effect():
	# 1. Tạo một Sprite2D mới bản sao
	var ghost = Sprite2D.new()
	ghost.texture = sprite_2d.texture
	ghost.hframes = sprite_2d.hframes
	ghost.vframes = sprite_2d.vframes
	ghost.frame = sprite_2d.frame
	ghost.global_position = global_position
	ghost.flip_h = sprite_2d.flip_h
	ghost.offset = sprite_2d.offset
	
	# Giữ bộ lọc pixel không bị mờ
	ghost.texture_filter = 1
	
	# Đổi màu bóng ma thành màu xám đục giống khói bụi
	# ghost.modulate = Color(0.6, 0.6, 0.6, 0.7) 
	
	# Thêm vào thế giới game
	get_parent().add_child(ghost)
	
	# 2. Dùng TWEEN để làm mờ và tự xóa bóng ma
	var tween = create_tween()
	# Làm mờ Alpha về 0 trong 0.3 giây
	tween.tween_property(ghost, "modulate:a", 0.0, 0.3)
	# Xóa Node ghost ngay sau khi tween chạy xong
	tween.tween_callback(ghost.queue_free)


func take_damage(amount: float, source = null):
	print("Player takes damage: ", amount)
	if stats:
		stats.current_health -= amount
		stats.current_health = clampi(stats.current_health, 0, stats.max_health)
		animation_body_effect.play("hit_flash")
		# TODO: Cập nhật UI thanh máu player ở đây nếu có

func apply_knockback(direction: Vector2, force: float, duration: float):
	knockback_direction = direction.normalized() * force
	knockback_timer = duration
	knockback_duration = duration
