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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # Phím Escape (Esc) mặc định của Godot
		# Nếu game đang pause thì hủy, nếu chưa thì pause
		var new_pause_state = !get_tree().paused
		get_tree().paused = new_pause_state
		
		# Ẩn hiện menu tương ứng với trạng thái pause
		if new_pause_state:
			GameManager.pause_menu_ui.show()
		else:
			GameManager.pause_menu_ui.hide()
