extends ItemData
class_name WeaponData

@export var damage: float = 10.0		# sát thương cơ bản của vũ khí
@export var attack_speed: float = 1.0	# tốc độ tấn công (số lần tấn công mỗi giây)

@export var weapon_texture: Texture2D	# texture của vũ khí

@export var attack_behavior: AttackBehavior	# hành vi tấn công của vũ khí
