extends CharacterBody3D

#I was going to use this for the tutorial but it ended up being a 
#huge waste of time (I spent the afternoon racking my brains and 
# finally discovered that cube collision doesn't work :(
#but it will be interesting to use in other AIs

@onready var nav: NavigationAgent3D = $NavigationAgent3D

var speed = 5
var accel = 10

func _process(delta: float) -> void:
	var direction = Vector3()
	nav.target_position = UserGlobal.PLAYER.global_transform.origin
	direction = nav.get_next_path_position() - global_position
	direction.y = 0
	direction = direction.normalized()

	if direction.length() > 0:
		velocity.x = lerp(velocity.x, direction.x * speed, accel * delta)
		velocity.z = lerp(velocity.z, direction.z * speed, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	
	move_and_slide()
