extends CanvasModulate

@export var gradient: Gradient


func _process(_delta):

	var t := float(TimeManager.total_minutes) / 1440.0 # Chuyển thời gian hiện tại thành giá trị từ 0 -> 1

	color = gradient.sample(t) # Lấy màu tương ứng trong Gradient rồi áp dụng cho toàn bộ scene
