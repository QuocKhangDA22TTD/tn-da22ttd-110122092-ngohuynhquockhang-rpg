extends Area2D

@export var speed: float = 300.0
@export var damage: float = 40.0
@export var exist_timer = 0.0
@export var max_exist_time = 3.0
@export var explosion_scene: PackedScene

var owner_entity: Node = null
var direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	if not area_entered.is_connected(_on_area_entered):
		area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	if rotation != direction.angle():
		rotation = direction.angle() # Cập nhật rotation của projectile để hướng về direction
	
	var velocity = direction * speed
	position += velocity * delta
	
	exist_timer += delta
	if exist_timer >= max_exist_time:
		queue_free() # Xóa projectile nếu tồn tại quá lâu mà không va chạm gì

func _on_area_entered(area: Area2D) -> void:
	if area == owner_entity:
		return # Tránh va chạm với chính mình
	
	if area is Hurtbox:
		if not explosion_scene:
			area.take_damage(damage, self) # Tìm hurtbox và gây damage trực tiếp
		else:
			call_deferred("spawn_explosion") # Tạo explosion

		queue_free() # Xóa projectile sau khi va chạm

func spawn_explosion() -> void:
	if explosion_scene:
		var exp_inst = explosion_scene.instantiate()
		exp_inst.explosion_damage = damage
		exp_inst.global_position = global_position
		exp_inst.owner_entity = owner_entity
		get_parent().add_child(exp_inst)
