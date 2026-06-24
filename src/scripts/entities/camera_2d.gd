extends Camera2D

func _physics_process(delta: float) -> void:
	global_position = GameManager.player.global_position.round()
