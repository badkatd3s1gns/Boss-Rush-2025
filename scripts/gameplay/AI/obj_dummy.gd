extends CharacterBody3D
class_name Enemy

@export var speed: float = 3.0

var health:int = 100

func _physics_process(delta: float) -> void:
	$State.text = "health: " + str(health)
	
	if not UserGlobal.PLAYER:
		return
	
	var direction = (UserGlobal.PLAYER.global_transform.origin - global_transform.origin).normalized()
	
	velocity = direction * speed
	move_and_slide()
				
	if not is_on_floor():
		velocity.y -= 9.8 * delta

#func simulate_attack():
	#if not UserGlobal.PLAYER.is_defending:
		#UserGlobal.PLAYER.player_damage(5)

func damage(num:int):
	health -= num
	if health <= 0:
		queue_free()
