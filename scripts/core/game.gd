extends Node2D

@export var enemies_container: Node2D # Tham chiếu đến container chứa các enemy
@export var input_handler: InputHandler # Tham chiếu đến input handler để xử lý input
@export var hotbar_ui: Control # Tham chiếu đến hotbar UI
@export var shop_ui: Control # Tham chiếu đến hotbar UI

# Hàm sẽ được gọi 1 lần khi scene đã load xong tất cả node.
func _enter_tree() -> void:
	GameManager.enemies_container = enemies_container # gán container chứa enemy cho biến enemies_container của GameManager
	GameManager.input_handler = input_handler # gán input handler cho biến input_handler của GameManager
	GameManager.hotbar = hotbar_ui # gán hotbar UI cho biến hotbar của GameManager
	GameManager.shop_ui = shop_ui # gán shop UI cho biến shop_ui của GameManager
