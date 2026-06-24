extends Marker2D

@export var label: Label

func set_values(amount: int, is_critical: bool = false):
	label.text = str(amount)

	if label.label_settings == null:
		label.label_settings = LabelSettings.new() # Khởi tạo LabelSettings nếu chưa tồn tại để tránh lỗi khi thiết lập font_color

	label.label_settings.font_color = Color.WHITE # Thiết lập màu chữ mặc định

	# Tạo hiệu ứng Tween
	var tween = create_tween().set_parallel(true)
	
	# 1. Bay lên bay ngang ngẫu nhiên một chút (Tạo cảm giác tự nhiên)
	var random_x = randf_range(-20, 20)
	var target_position = position + Vector2(random_x, -40)
	tween.tween_property(self, "position", target_position, 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	# 2. Mờ dần (Fade out)
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.2)
	
	# Tự hủy sau khi chạy xong hiệu ứng
	tween.chain().tween_callback(queue_free)
