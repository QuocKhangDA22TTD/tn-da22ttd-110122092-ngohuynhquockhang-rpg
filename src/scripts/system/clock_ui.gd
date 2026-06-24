extends Control

@export var label: Label # Tham chiếu tới node Label của scene clock_ui

func _process(_delta):
	label.text = TimeManager.get_time_string() # Cập nhật text của label bằng chuỗi thời gian từ TimeManager
