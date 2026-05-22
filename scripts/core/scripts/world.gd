extends Node2D

@export var enemies_container: Node2D

func _ready() -> void:
	GameManager.enemies_container = enemies_container # Lưu tham chiếu đến container quái để các spawner dễ dàng thêm quái vào
