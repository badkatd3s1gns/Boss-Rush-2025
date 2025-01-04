extends CharacterBody3D

@onready var mesh: MeshInstance3D = $model
@onready var camera_controller: Node3D = $CameraController

enum GameplayMode {
	ThirdPerson,
	TopDown,
	Platform
}

@export_group("Player")
@export var SPEED_WALK = 4
@export var SPEED_RUN = 6
var SPEED_ACCEL = 30

@export_group("Flags")
@export var CAN_MOVE:bool = true
@export var CAN_RUN = true
@export var GRAVITY_ON:bool = true

var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

func _physics_process(delta: float) -> void: #func movement_controller(delta):
	match camera_controller.gameplay_index:
		GameplayMode.ThirdPerson:
			thirdPerson_movement(delta)
		GameplayMode.TopDown:
			topDown_movement(delta)
		GameplayMode.Platform:
			platform_movement(delta)
	
	# Player Movement
	if CAN_MOVE:
		if Input.get_action_strength("player_run") && Input.get_action_strength("m_forward") && CAN_RUN:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN, SPEED_ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK, SPEED_ACCEL * delta)
				
		move_and_slide()
	
	# Applie Gravity
	if GRAVITY_ON and not is_on_floor():
		velocity.y -= 9.8 * delta

# //////////////////////////////////////////////////////////
# /////////////////// MOVEMENT TYPES ///////////////////////
# //////////////////////////////////////////////////////////
func thirdPerson_movement(delta:float) -> void: # (1) Soulslike Movement
	# Direction of movement based on player direction
	move_dir = Vector3(
		Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
		0.0,
		Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
	).normalized()
	
	# Makes the movement be relative to the camera
	var camera_rotation_y = $CameraController/Pivot/SpringArm.global_transform.basis.get_euler().y
	move_dir = move_dir.rotated(Vector3.UP, camera_rotation_y)
		
	# Rotates the mesh in the direction of movement with a smooth transition
	if move_dir.length() > 0.1:
		var target_rotation = atan2(-move_dir.x, -move_dir.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, 5.0 * delta)

# //////////////////////////////////////////////////////////
func topDown_movement(delta:float) -> void: # (2) RPG Movement
	move_dir = Vector3(
		Input.get_action_strength("m_left") - Input.get_action_strength("m_right"),
		0.0,
		Input.get_action_strength("m_forward") - Input.get_action_strength("m_backward")
	).normalized()

	if move_dir.length() > 0.1:
		var target_rotation = atan2(-move_dir.x, -move_dir.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, 5.0 * delta)

# //////////////////////////////////////////////////////////
func platform_movement(delta:float) -> void: # (3) Smash Bros Movement
	move_dir = Vector3(
		0.0,
		0.0,
		Input.get_action_strength("m_right") - Input.get_action_strength("m_left")
	).normalized()
	
	if move_dir.length() > 0.1:
		var target_rotation = atan2(-move_dir.x, -move_dir.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, 5.0 * delta)
		
# I didn't know you could do this, assigning a function to a variable
# a6x: amazing
#func _test():
	#var hello = func test_2():
		#pass
