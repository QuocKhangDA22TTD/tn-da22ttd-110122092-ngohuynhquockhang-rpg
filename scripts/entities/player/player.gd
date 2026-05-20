# Script điều khiển nhân vật người chơi
extends CharacterBody2D

@export var speed: float = 80.0 # Tốc độ di chuyển của nhân vật
@export var camera_2d: Camera2D # Tham chiếu đến camera theo dõi nhân vật
@export var animation_player: AnimationPlayer # Tham chiếu đến animation player để phát hoạt ảnh
@export var sprite_2d: Sprite2D # Tham chiếu đến sprite của nhân vật
@export var current_weapon: WeaponData # Tham chiếu đến vũ khí đang được cầm
@export var weapon_sprite_2d: Sprite2D # tham chiếu đến sprite cho vũ khí
@export var weapon_pivot: Node2D # tham chiếu đến điểm gốc để xoay vũ khí
@export var effect_sprite_2d: Sprite2D # Tham chiếu đến sprite hiệu ứng tấn công
@export var hitbox: Hitbox # Tham chiếu đến hitbox để xử lý va chạm tấn công
@export var animation_weapon: AnimationPlayer # Tham chiếu đến animation player để phát hoạt ảnh vũ khí
@export var arrow_spawn_point: Marker2D # Tham chiếu đến điểm spawn projectile cho tấn công tầm xa
@export var arm_sprite_2d: Sprite2D

# Hướng cuối cùng nhân vật đang quay mặt
var last_direction: String = "down"
# Vector chứa input từ bàn phím
var input_vector := Vector2.ZERO
# Hậu tố hoạt ảnh dựa trên loại vũ khí 
var animation_suffix: String = ""

func _ready() -> void:
	GameManager.player = self

# Xử lý vật lý và di chuyển mỗi frame
func _physics_process(delta: float) -> void:
	input_vector = _get_input_vector()
	
	velocity = input_vector * speed
	move_and_slide()
	
	_handle_attack_input() 

	# Cập nhật last_direction theo chuột nếu cầm ranged weapon
	if current_weapon and current_weapon.weapon_type == WeaponData.WeaponType.RANGED:
		_update_direction_from_mouse()
	
	_update_animation_and_direction()
	
	global_position = global_position.round()
	camera_2d.global_position = global_position


# Lấy vector input từ bàn phím (WASD hoặc mũi tên)
func _get_input_vector():
	if animation_player.current_animation.begins_with("melee_attack"):
		return Vector2.ZERO  # Không nhận input di chuyển nếu đang tấn công
	
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
	if animation_player.current_animation.begins_with("melee_attack"):
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
		return
		
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
