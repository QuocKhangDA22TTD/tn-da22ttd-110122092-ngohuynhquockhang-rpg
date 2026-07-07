extends Control

signal resume_pressed
signal main_menu_pressed

func _ready() -> void:
	hide()

func _on_resume_button_pressed() -> void:
	get_tree().paused = false
	hide()
	resume_pressed.emit()

func _on_main_menu_button_pressed() -> void:
	get_tree().paused = false
	hide()
	main_menu_pressed.emit()
