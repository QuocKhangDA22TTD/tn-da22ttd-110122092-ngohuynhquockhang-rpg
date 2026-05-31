extends Resource
class_name EnemyData

# thông tin cơ bản
@export var id: String
@export var display_name: String

# thông số chiến đấu
@export var max_hp: int = 10
@export var speed: float = 50
@export var damage: int = 1

# thông số hành vi
@export var patrol_radius: float = 150.0 # bán kính mà kẻ địch sẽ di chuyển xung quanh khi ở trạng thái tuần tra
@export var max_patrol_duration: float = 3.0 # Thời gian tối đa cho mỗi lượt đi tuần tra
@export var chase_distance: float = 100.0 # Khoảng cách mà kẻ địch sẽ bắt đầu đuổi theo người chơi
@export var attack_distance: float = 20.0 # Khoảng cách mà kẻ địch sẽ bắt đầu tấn công người chơi
@export var reaction_delay: float = 1.0 # Thời gian cập nhật lại mục tiêu sau khi phát hiện người chơi

# thông tin hoạt ảnh
@export var animation_library: AnimationLibrary
# các trạng thái có thể có
@export var states: Array[EnemyState]
