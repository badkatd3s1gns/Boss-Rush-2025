extends Node

@onready var dad: CharacterBody3D = $"../.."
@onready var animation_player: AnimationPlayer = $"../../model/AnimationPlayer"

@export var JUMP_FORCE:int = 5

@export_group("Combat System")
@export var attacks:Array[AttackResource]

var attack_index:int = 0
var is_attacking:bool = false

func start(delta:float):
	movement_controller(delta)
	CombatSystem()


# //////////////////////////////////////////////////////////
# //////////////////// CONTROLLERS /////////////////////////
# //////////////////////////////////////////////////////////
func movement_controller(delta):
	# Direction of movement based on player direction
	dad.move_dir = Vector3(
		Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
		0.0,
		Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
	).normalized()
	
	# Makes the movement be relative to the camera
	var camera_rotation_y = $"../../CameraController/Pivot/SpringArm".global_transform.basis.get_euler().y
	dad.move_dir = dad.move_dir.rotated(Vector3.UP, camera_rotation_y)
	
	if dad.is_aiming: # Makes the player aim
		var target_position = dad.aim.global_transform.origin # Get the Marked3D position
		var look_at_position = Vector3(target_position.x, dad.mesh.global_transform.origin.y, target_position.z)
		dad.mesh.look_at(look_at_position) # Make the mesh look at Marked3D
	else:
		if dad.move_dir.length() > 0.1: # Rotates the mesh in the direction of movement with a smooth transition
			var target_rotation = atan2(-dad.move_dir.x, -dad.move_dir.z)
			dad.mesh.rotation.y = lerp_angle(dad.mesh.rotation.y, target_rotation, 5.0 * delta)
	
	#if Input.is_action_just_pressed("action_defend"): # Defense system
		#dad.is_defending = true
	#else:
		#dad.is_defending = false
	
	# Dodge mechanic
	if Input.is_action_just_pressed("action_dodge") and not dad.is_dodging:
		dad.is_dodging = true
		dad.velocity = dad.move_dir * 50.0
		dad.move_and_slide()
		
	# Jump Mechanic
	if Input.is_action_just_pressed("action_jump") and dad.is_on_floor():
		dad.velocity.y = JUMP_FORCE
		
	# Soulslike Gravity
	if dad.GRAVITY_ON and not dad.is_on_floor():
		dad.velocity.y -= 9.8 * delta

# //////////////////////////////////////////////////////////
# ///////////////////// MECHANICS //////////////////////////
# //////////////////////////////////////////////////////////
func CombatSystem() -> void:
	if dad.is_aiming:
		if Input.is_action_just_pressed("action_attack") && not animation_player.is_playing():
			var i = attacks[attack_index]
			
			if not is_attacking:
				animation_player.play(i.animation)
				attack_index += 1
				
			if attack_index >= attacks.size():
				attack_index = 0
				
	if Input.is_action_pressed("action_defend") and dad.is_aiming:
		if not dad.is_defending:
			animation_player.play("defending")
			dad.is_defending = true
	else:
		dad.is_defending = false
# //////////////////////////////////////////////////////////
# ////////////////////// SIGNALS ///////////////////////////
# //////////////////////////////////////////////////////////
func _animation_finished(anim_name: StringName) -> void:
	pass
