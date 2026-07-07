extends Node
class_name UIManager

@export var main_menu: Control
@export var game_scene: Node2D

func _ready() -> void:
	main_menu.play_pressed.connect(_on_start_game)
	game_scene.pause_menu_ui.resume_pressed.connect(_on_resume_game)
	game_scene.pause_menu_ui.main_menu_pressed.connect(_on_go_to_main_menu)
	
	game_scene.visible = false
	game_scene.ui_canvas_layer.visible = false
	game_scene.process_mode = PROCESS_MODE_DISABLED

func _on_start_game() -> void:
	# Thêm sword vào inventory khi bắt đầu game
	_initialize_starting_inventory()
	
	main_menu.visible = false
	game_scene.visible = true
	game_scene.ui_canvas_layer.visible = true
	game_scene.process_mode = PROCESS_MODE_INHERIT


func _initialize_starting_inventory() -> void:
	# Load sword item data
	var sword = load("res://data/items/sword.tres")
	if sword:
		InventoryManager.add_item(sword, 1)
	
	# Thêm gold trực tiếp vào biến gold
	InventoryManager.gold += 100

func _on_resume_game() -> void:
	# Pause menu tự động ẩn trong pause_menu.gd
	pass

func _on_go_to_main_menu() -> void:
	game_scene.visible = false
	game_scene.ui_canvas_layer.visible = false
	game_scene.process_mode = PROCESS_MODE_DISABLED
	main_menu.visible = true
