extends Node2D

@export var animation_player: AnimationPlayer

func _ready() -> void:
	hide() # Mặc định ẩn đi khi game bắt đầu

func show_prompt() -> void:
	animation_player.play("ui_key_e_pressed")
	show()

func hide_prompt() -> void:
	hide()
