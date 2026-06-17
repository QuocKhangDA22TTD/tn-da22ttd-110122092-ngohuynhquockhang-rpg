extends CharacterBody2D

@export var shop_goods: Array[ItemData] = [] # Danh sách vật phẩm trong shop

func _on_interaction_area_on_interact() -> void:
	var shop_ui = GameManager.shop_ui # Tham chiếu đến giao diện shop
	var player = GameManager.player # Tham chiếu đến player

	if shop_ui and player:
		shop_ui.open_shop(shop_goods, player) # Mở shop để bắt đầu mua vật phẩm
