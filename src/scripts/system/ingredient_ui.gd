# ingredient_ui.gd
extends Control
class_name IngredientUI

@export var icon: TextureRect
@export var amount_label: Label

# Hàm này được gọi từ CraftingUI để nạp dữ liệu nguyên liệu vào ô này
func set_ingredient(ingredient: Ingredient):
	# 1. Hiển thị ảnh nguyên liệu
	icon.texture = ingredient.item.icon
	
	# 2. Hỏi CraftingManager xem trong túi người chơi đang có bao nhiêu cái này
	var current_owned = CraftingManager.get_item_count_in_inventory(ingredient.item)
	
	# 3. Hiển thị chữ dạng: "Số lượng đang có / Số lượng công thức cần"
	amount_label.text = str(current_owned) + "/" + str(ingredient.amount)
	
	# 4. Đổi màu chữ để người chơi dễ nhìn: Thiếu thì màu Đỏ, Đủ thì màu Trắng/Xanh
	if current_owned < ingredient.amount:
		amount_label.modulate = Color.RED
	else:
		amount_label.modulate = Color.WHITE
