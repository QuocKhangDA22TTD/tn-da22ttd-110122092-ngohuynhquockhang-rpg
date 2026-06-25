extends Control

@export var recipe_button_scene: PackedScene # Nút bấm chọn công thức bên trái
@export var ingredient_ui_scene: PackedScene # Prefab hiển thị nguyên liệu bên phải

@export var recipe_list_container: VBoxContainer # Chứa danh sách công thức
@export var ingredient_grid: GridContainer # Chứa các nguyên liệu yêu cầu
@export var result_icon: TextureRect # Icon thành phẩm
@export var result_name: Label # Tên thành phẩm
@export var craft_button: Button # Nút Chế tạo

# Danh sách tất cả công thức có trong game (hoặc nạp từ một thư mục)
@export var all_recipes: Array[RecipeData] = []

var selected_recipe: RecipeData

func _ready():
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	render_recipe_list()
	hide()

func _input(event):
	if event.is_action_pressed("toggle_crafting"): # Bạn tự cài Action này trong Input Map nhé
		visible = !visible
		if visible:
			update_detail_panel()

# Vẽ danh sách công thức bên trái
func render_recipe_list():
	# Xóa các nút cũ trước khi vẽ lại
	for child in recipe_list_container.get_children():
		child.queue_free()
		
	# Duyệt qua từng công thức để tạo nút bấm đẹp mắt
	for recipe in all_recipes:
		# Instatitate (sinh ra) cái nút thiết kế sẵn
		var btn = recipe_button_scene.instantiate() as RecipeButton
		recipe_list_container.add_child(btn)
		
		# Đổ dữ liệu công thức vào nút đó
		btn.setup(recipe)
		
		# Kết nối sự kiện: Khi người chơi click vào nút này -> Gọi hàm chọn công thức
		btn.pressed.connect(func(): select_recipe(recipe))

# Khi người chơi click chọn 1 công thức
func select_recipe(recipe: RecipeData):
	selected_recipe = recipe
	update_detail_panel()

# Cập nhật thông tin chi tiết bên phải
func update_detail_panel():
	# Xóa nguyên liệu cũ
	for child in ingredient_grid.get_children():
		child.queue_free()
		
	if selected_recipe == null:
		craft_button.disabled = true
		return
		
	# Hiển thị thông tin thành phẩm
	result_icon.texture = selected_recipe.result_item.icon
	result_name.text = selected_recipe.name
	
	# Hiển thị các nguyên liệu cần
	for ing in selected_recipe.required_ingredients:
		var ing_ui = ingredient_ui_scene.instantiate()
		ingredient_grid.add_child(ing_ui)
		ing_ui.set_ingredient(ing)
		
	# Bật/Tắt nút Chế tạo dựa trên việc đủ nguyên liệu hay không
	craft_button.disabled = !InventoryManager.has_ingredients(selected_recipe)

# Khi bấm nút Chế Tạo
func _on_craft_button_pressed():
	if selected_recipe:
		# Gọi lệnh chế tạo từ CraftingManager
		var success = CraftingManager.craft_item(selected_recipe)
		if success:
			update_detail_panel()

# Nếu người chơi đang mở bảng chế tạo mà nhặt thêm đồ/mất đồ, cập nhật lại giao diện ngay
func _on_inventory_changed():
	if visible:
		update_detail_panel()
