extends Node2D

func _on_interaction_area_on_interact() -> void:
	var crafting_ui = GameManager.crafting_table # Tham chiếu đến giao diện crafting
	var player = GameManager.player # Tham chiếu đến player

	if crafting_ui and player:
		crafting_ui.open_crafting() # Mở crafting để bắt đầu chế tạo vật phẩm
