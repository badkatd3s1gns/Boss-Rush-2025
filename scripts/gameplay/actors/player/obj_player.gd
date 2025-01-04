extends CharacterBody3D

@onready var mesh: MeshInstance3D = $model

@export_group("Player")
@export var SPEED_WALK = 4
@export var SPEED_RUN = 6
@export var JUMP_FORCE = 5
var SPEED_ACCEL = 30

@export_group("Flags")
@export var CAN_MOVE:bool = true
@export var CAN_RUN = true
@export var GRAVITY_ON:bool = true

var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

func _process(delta): #func movement_controller(delta):
	if CAN_MOVE:
		# Direction of movement based on player direction
		move_dir = Vector3(
			Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
			0.0,
			Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
		).normalized()
		
		move_dir = move_dir.rotated(Vector3.UP, $CameraThirdPerson/Pivot/SpringArm.rotation.y)
		
		#if Input.is_action_just_pressed("player_jump") && is_on_floor():
			#velocity.y += JUMP_FORCE
			
		# Rotates the mesh in the direction of movement with a smooth transition
		if move_dir.length() > 0.1:
			var target_rotation = mesh.global_transform.basis.get_euler().y
			var move_direction_rotation = atan2(-move_dir.x, -move_dir.z)
			target_rotation = lerp_angle(target_rotation, move_direction_rotation, 5.0 * delta)
			
			mesh.rotation.y = target_rotation
		
		# Player Movement
		if Input.get_action_strength("player_run") && Input.get_action_strength("player_forward") && CAN_RUN:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN, SPEED_ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK, SPEED_ACCEL * delta)
				
		move_and_slide()
		
		# Applie Gravity
		if GRAVITY_ON and not is_on_floor():
			velocity.y -= 9.8 * delta
	
	
# I didn't know you could do this, assigning a function to a variable	
#func _test():
	#var hello = func test_2():
		#pass
