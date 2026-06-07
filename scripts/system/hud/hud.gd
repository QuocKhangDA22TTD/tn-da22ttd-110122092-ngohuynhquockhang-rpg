extends Control

@export var hp_bar: TextureProgressBar # Biến để lưu trữ tham chiếu đến TextureProgressBar hiển thị HP của người chơi
@export var mana_bar: TextureProgressBar

var player_stats: CharacterStats = null # Biến để lưu trữ tham chiếu đến CharacterStats của người chơi


func _ready() -> void:
	# Lấy tham chiếu đến CharacterStats của người chơi từ GameManager
	player_stats = GameManager.player.stats if GameManager.player else null
	
	if player_stats:

		# Khởi tạo giá trị máu ban đầu cho hp_bar
		hp_bar.max_value = player_stats.max_health
		hp_bar.value = player_stats.current_health
		
		# Khởi tạo giá trị mana ban đầu cho mana_bar
		mana_bar.max_value = player_stats.max_mana
		mana_bar.value = player_stats.current_mana

	if player_stats:
		# Kết nối tín hiệu changed của CharacterStats để cập nhật thanh HP khi máu thay đổi
		player_stats.changed.connect(_on_health_changed)
		player_stats.changed.connect(_on_mana_changed)


func _on_health_changed() -> void:
	if player_stats:
		hp_bar.value = player_stats.current_health # Cập nhật giá trị của thanh HP khi máu của người chơi thay đổi


func _on_mana_changed() -> void:
	if player_stats:
		mana_bar.value = player_stats.current_mana # Cập nhật giá trị của thanh mana
