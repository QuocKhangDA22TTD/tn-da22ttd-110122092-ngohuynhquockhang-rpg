extends TextureButton
class_name RecipeButton

@export var icon_rect : TextureRect

var recipe_data: RecipeData

# Hàm này dùng để nạp dữ liệu từ ngoài vào khi sinh ra nút
func setup(recipe: RecipeData):
	recipe_data = recipe
	icon_rect.texture = recipe.result_item.icon
