extends Control

@export var hp_bar: TextureProgressBar # Biến để lưu trữ tham chiếu đến TextureProgressBar hiển thị HP của người chơi

var player_stats: CharacterStats = null # Biến để lưu trữ tham chiếu đến CharacterStats của người chơi


func _ready() -> void:
	# Lấy tham chiếu đến CharacterStats của người chơi từ GameManager
	player_stats = GameManager.player.stats if GameManager.player else null
	
	if player_stats:
		hp_bar.max_value = player_stats.max_health # Đặt giá trị tối đa của thanh HP dựa trên max_health của người chơi
		hp_bar.value = player_stats.current_health # Đặt giá trị hiện tại của thanh HP dựa trên current_health của người chơi
		
	if player_stats:
		# Kết nối tín hiệu changed của CharacterStats để cập nhật thanh HP khi máu thay đổi
		player_stats.changed.connect(_on_health_changed)

func _on_health_changed() -> void:
	if player_stats:
		hp_bar.value = player_stats.current_health # Cập nhật giá trị của thanh HP khi máu của người chơi thay đổi
