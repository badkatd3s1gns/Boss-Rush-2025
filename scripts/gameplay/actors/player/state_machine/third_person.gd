extends Node3D

@onready var dad: CharacterBody3D = $"../.."
@onready var animation_player: AnimationPlayer = $"../../model/AnimationPlayer"
@onready var weapon_switcher: Node = $"../../WeaponSwitcher"

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
	#if Input.is_action_just_pressed("action_jump") and dad.is_on_floor():
		#dad.velocity.y = JUMP_FORCE
		
	# Soulslike Gravity
	#if dad.GRAVITY_ON and not dad.is_on_floor():
	

# //////////////////////////////////////////////////////////
# ///////////////////// MECHANICS //////////////////////////
# //////////////////////////////////////////////////////////
func CombatSystem() -> void:
	if Input.is_action_just_pressed("action_attack") and not animation_player.is_playing() and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		#var attack = attacks[attack_index]
		#var weapon_type = weapon_switcher.get_current_weapon_type()
		#var found_valid_attack = false
		#
		#for i in range(attack_index, attack_index + attacks.size()):
			#var index = i % attacks.size() # Allow the index to "rotate" in the array
			#
			## Checks if the attack is compatible with the current weapon
			#if attack[weapon_type]:
				#animation_player.play(attack.animation)
				#attack_index = (index + 1) % attacks.size()
				#found_valid_attack = true
		dad.attack()
				#break
		
		#if not found_valid_attack:
			#attack_index = 0
		
		# Defense
		if Input.is_action_pressed("action_defend") and dad.is_aiming:
			if not dad.is_defending:
				animation_player.play("defending")
				dad.is_defending = true
		else:
			dad.is_defending = false

func is_valid_weapon(attack: AttackResource, weapon_node: Node) -> bool:
	var weapon_type = weapon_node.name.to_lower()
	return (attack.hammer and weapon_type == "hammer") or (attack.greatsword and weapon_type == "greatsword") or (attack.guns and weapon_type == "guns") or (attack.guitar and weapon_type == "guitar")

# //////////////////////////////////////////////////////////
# ////////////////////// SIGNALS ///////////////////////////
# //////////////////////////////////////////////////////////
func _animation_finished(anim_name: StringName) -> void:
	pass
