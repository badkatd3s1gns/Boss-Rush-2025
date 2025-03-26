extends CharacterBody3D

@export var stay_in_place = false

var can_walk = false

var target_rotation = 0
var talking_with_player = false

var appeared = false

func _ready() -> void:
	if !stay_in_place:
		$IdleTimer.start()

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		if !appeared:
			appeared = true
			$Model/OtherAnimations.play("pop_up")
	
	if stay_in_place:
		move_and_slide()
		handle_animations(delta)
		return
	
	var direction = transform.basis.z
	
	if can_walk:
		velocity.x = direction.x * 2.55
		velocity.z = direction.z * 2.55
		
		if !$FloorDetector.is_colliding():
			target_rotation = -target_rotation
			can_walk = false
	else:
		velocity.x = 0
		velocity.z = 0
	
	move_and_slide()
	
	rotation.y = lerp_angle(rotation.y, target_rotation, delta*7.0)
	
	handle_animations(delta)
	
	$Model/metarig/Skeleton3D/HeadIK.start()
	$Model/metarig/TargetRot.look_at(UserGlobal.PLAYER.position, Vector3.UP, true)
	
	$Model/metarig/TargetRot.rotation_degrees.x = clamp($Model/metarig/TargetRot.rotation_degrees.x, -15, 15)
	$Model/metarig/TargetRot.rotation_degrees.z = 0
	$Model/metarig/TargetRot.rotation_degrees.y = clamp($Model/metarig/TargetRot.rotation_degrees.y, -65, 65)
	
	#if $FOV.is_colliding():
	$Model/metarig/Marker3D.rotation.y = lerp_angle($Model/metarig/Marker3D.rotation.y, 0 if !$FOV.is_colliding() else $Model/metarig/TargetRot.rotation.y, delta*10.0)
	$Model/metarig/Marker3D.rotation.x = lerp_angle($Model/metarig/Marker3D.rotation.x, 0 if !$FOV.is_colliding() else $Model/metarig/TargetRot.rotation.x, delta*10.0)
	
	if talking_with_player:
		target_rotation = position.angle_to(UserGlobal.PLAYER.position)
		#rotation.y = lerp_angle(rotation.y, position.angle_to(UserGlobal.PLAYER.position), delta*10.0)

func interact():
	var dialogue = "Hi! How are you today?"
	get_parent().show_dialog("Hi! How are you today?", "Marie", dialogue.length()*0.07)
	talking_with_player = true

func patrol():
	if can_walk: return
	
	can_walk = true
	await get_tree().create_timer(5.0).timeout
	can_walk = false
	
	if randi() % 3 == 0:
		await get_tree().create_timer(randi_range(0.5, 2.0))
	
	rotate_to_random()
	
	if randi() % 5 != 0:
		$IdleTimer.start()
	else:
		patrol()

func _on_idle_timer_timeout() -> void:
	patrol()

func rotate_to_random():
	randomize()
	
	target_rotation = deg_to_rad(randi_range(-45, 45) if randi() % 3 != 0 else randi_range(-180, 180))
	
	#var tween = create_tween()
	#tween.tween_property(self, "rotation:y", deg_to_rad(target_rotation), target_rotation*0.05)
	#tween.play()
	#await tween.finished
	#tween.kill()

func handle_animations(delta):
	$AnimationTree.set("parameters/MovementBlend/blend_amount", lerpf($AnimationTree.get("parameters/MovementBlend/blend_amount"), 1 if can_walk else 0, delta*7.0))
