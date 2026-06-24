extends WeaponData
class_name MagicWeaponData

enum CastType {
	PROJECTILE,
	AREA_EFFECT,
	SELF_BUFF
}

@export var mana_cost: float = 10.0 # lượng mana tiêu thụ mỗi lần tấn công
@export var cast_type: CastType = CastType.PROJECTILE # loại phép thuật
@export var spell_scene: PackedScene # cảnh của phép thuật (dùng để tạo instance khi tấn công)
