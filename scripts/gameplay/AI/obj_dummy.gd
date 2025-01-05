extends CharacterBody3D

@export var attack_distance: float = 2.0
@export var speed: float = 3.0
@export var can_attack:bool = true

var attack_timer:float = 0
var attack_duration:int = 2
var is_attacking:bool = false

func _physics_process(delta: float) -> void:
	print("timer: ", attack_timer)
	print("is_attackin: ", is_attacking)
	if not UserGlobal.PLAYER:
		return
	
	var direction = (UserGlobal.PLAYER.global_transform.origin - global_transform.origin).normalized()
	var distance = global_transform.origin.distance_to(UserGlobal.PLAYER.global_transform.origin)
	
	if distance > attack_distance:
		velocity = direction * speed
		move_and_slide()
		$State.text = "chasing player"
	else:
		if can_attack and not is_attacking:
			is_attacking = true
			$State.text = "is attacking"
			simulate_attack()
		
	if is_attacking:
		attack_timer += 1 * delta
		if attack_timer >= attack_duration:
			is_attacking  = false
			$State.text = "is attacking"
			attack_timer = 0
				
	if not is_on_floor():
		velocity.y -= 9.8 * delta

func simulate_attack():
	if not UserGlobal.PLAYER.is_defending:
		UserGlobal.PLAYER.player_damage(5)
