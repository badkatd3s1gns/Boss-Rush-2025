extends Node

@onready var dad: CharacterBody3D = $"../.."

@export var JUMP_FORCE:int = 5

func start(delta:float) -> void:
	dad.move_dir = Vector3(
		0.0,
		0.0,
		Input.get_action_strength("m_right") - Input.get_action_strength("m_left")
	).normalized()
	
	if dad.move_dir.length() > 0.1: # Rotation mesh to the move_dir
		var target_rotation = atan2(-dad.move_dir.x, -dad.move_dir.z)
		dad.mesh.rotation.y = lerp_angle(dad.mesh.rotation.y, target_rotation, 5.0 * delta)
		
	if Input.is_action_just_pressed("action_jump") and dad.is_on_floor():
		dad.velocity.y = JUMP_FORCE
		
	if Input.is_action_just_pressed("action_dodge") and not dad.is_dodging: # Dodge System
		dad.is_dodging = true
		dad.velocity = dad.move_dir * 50.0
		dad.move_and_slide()
	
	# Platform gravity
	if dad.GRAVITY_ON and not dad.is_on_floor():
		dad.velocity.y -= 15.0 * delta
