extends Control

signal play_pressed

func _on_play_button_pressed() -> void:
	emit_signal("play_pressed") # Bắn tín hiệu ra ngoài để Scene cha xử lý

func _on_quit_button_pressed() -> void:
	get_tree().quit() # Thoát game
