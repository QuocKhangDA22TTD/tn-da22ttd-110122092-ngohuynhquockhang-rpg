extends Node
class_name InputHandler

signal primary_action_pressed
signal interact_pressed
signal skill_primary_pressed

func _process(delta: float):
	if Input.is_action_just_pressed("primary_action"):
		primary_action_pressed.emit()
	
	if Input.is_action_just_pressed("interact"):
		interact_pressed.emit()
