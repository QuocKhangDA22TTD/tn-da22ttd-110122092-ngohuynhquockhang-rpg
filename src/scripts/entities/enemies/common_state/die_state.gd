extends EnemyState
class_name DieState

var is_drop_item = false # Cờ để kiểm tra xem enemy đã spawn item ra ngoài môi trường hay chưa

func enter(enemy):
	enemy.velocity = Vector2.ZERO


func update(enemy, delta):
	enemy.play_anim("die")

	if not is_drop_item:
		spawn_loot(enemy) # Nếu enemy chưa spawn item thì chạy hàm spawn_loot

	await enemy.animation_player.animation_finished
	enemy.queue_free()

	return


func spawn_loot(enemy) -> void:
	if not enemy.loot_table and is_drop_item:
		return # Con quái này không rơi đồ
	
	is_drop_item = true

	var dropped_items = enemy.loot_table.get_dropped_items() # Lấy kết quả những đồ sẽ rơi ra
	
	for drop in dropped_items:
		var item_drop_instance = enemy.item_drop_scene.instantiate() # Tạo instance của scene item_drop

		# Gán item và số lượng cần spawn vào instance
		item_drop_instance.item = drop["item"]
		item_drop_instance.amount = drop["quantity"]

		# Random vị trí quanh Enemy trong bán kính 20 pixel
		var offset = Vector2(
			randf_range(-20, 20),
			randf_range(-20, 20)
		)
		
		# Đặt vị trí drop xung quanh vị trí Enemy chết
		item_drop_instance.global_position = enemy.global_position + offset
		
		GameManager.items_container.add_child(item_drop_instance) # Spawn item vào thế giới
