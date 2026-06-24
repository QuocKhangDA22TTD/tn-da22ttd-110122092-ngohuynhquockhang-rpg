extends Resource
class_name ConsumableEffect

# Hàm ảo để các hiệu ứng cụ thể ghi đè (override)
func apply_effect(player: CharacterBody2D) -> bool:
	return false # Trả về true nếu dùng thành công
