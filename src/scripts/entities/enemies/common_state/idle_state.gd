extends EnemyState
class_name IdleState

@export var wait_time: float = 2.0

var timer := 0.0

func enter(enemy):
	timer = 0
	enemy.play_anim("idle")

func update(enemy, delta):
	timer += delta
	enemy.velocity = Vector2.ZERO

	var distance_to_player = enemy.distance_to_player()

	if distance_to_player != null and distance_to_player < 100:
		var chase = enemy.get_state(ChaseState)
		if chase:
			enemy.change_state(chase)
			return
	
	if timer >= wait_time:
		var patrol = enemy.get_state(PatrolState)
		if patrol:
			enemy.change_state(patrol)
			return
