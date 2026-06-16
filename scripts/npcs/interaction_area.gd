class_name InteractionArea extends Area2D

# Tín hiệu phát ra khi Player nhấn E vào vùng này
signal on_interact

@export var interactable_ui: Node2D # Tham chiếu đến UI hiển thị nút bấm tương tác
@export var action_name: String # Tên hành động 

# Hàm này sẽ được gọi từ Player khi nhấn nút
func interact() -> void:
	on_interact.emit() # Gửi tín hiệu on_interact
	interactable_ui.hide_prompt() # Ẩn nút tương tác
