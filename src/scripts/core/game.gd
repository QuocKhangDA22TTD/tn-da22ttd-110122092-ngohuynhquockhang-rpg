extends Node2D

@export var enemies_container: Node2D # Tham chiếu đến container chứa các enemy
@export var input_handler: InputHandler # Tham chiếu đến input handler để xử lý input
@export var hotbar_ui: Control # Tham chiếu đến hotbar UI
@export var shop_ui: Control # Tham chiếu đến hotbar UI
@export var maps_container: Node2D # Tham chiếu đến container chứa map
@export var entities_container: Node2D # Tham chiếu đến container chứa các entity
@export var items_container: Node2D # Tham chiếu tới container chứa các item
@export var crafting_table: Control # Tham chiếu tới crafting table
@export var ui_canvas_layer: CanvasLayer # Tham chiếu tới canvas layer chứa UI
@export var pause_menu_ui: Control # Tham chiếu tới pause menu UI

# Hàm sẽ được gọi 1 lần khi scene đã load xong tất cả node.
func _enter_tree() -> void:
	GameManager.enemies_container = enemies_container # gán container chứa enemy cho biến enemies_container của GameManager
	GameManager.input_handler = input_handler # gán input handler cho biến input_handler của GameManager
	GameManager.hotbar = hotbar_ui # gán hotbar UI cho biến hotbar của GameManager
	GameManager.shop_ui = shop_ui # gán shop UI cho biến shop_ui của GameManager
	GameManager.maps_container = maps_container # gán container chứa map cho biến maps_container của GameManager
	GameManager.entities_container = entities_container # gán container chứa entity cho biến entities_container của GameManager
	GameManager.items_container = items_container # gán container chứa item cho biến items_container của GameManager
	GameManager.crafting_table = crafting_table # gán crafting table cho biến crafting_table của GameManager
	GameManager.ui_canvas_layer = ui_canvas_layer # gán canvas layer chứa UI cho biến ui_canvas_layer của GameManager
	GameManager.pause_menu_ui = pause_menu_ui # gán pause menu UI cho biến pause_menu_ui của GameManager
	
