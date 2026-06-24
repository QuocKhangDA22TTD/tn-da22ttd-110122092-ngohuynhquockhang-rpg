extends Area2D

@export var explosion_damage: float = 40.0
@export var animation_player: AnimationPlayer

var owner_entity: Node = null # Biến để lưu reference đến entity sở hữu explosion
var hit_entities: Array = []

func _ready() -> void:
	animation_player.play("explosion")
	await animation_player.animation_finished
	queue_free()

func _on_area_entered(area: Area2D) -> void:
	# Tránh double damage
	if area == owner_entity or area in hit_entities:
		return

	# Tìm hurtbox và gây damage trực tiếp
	if area is Hurtbox:
		area.take_damage(explosion_damage, self)
			
		hit_entities.append(area)
