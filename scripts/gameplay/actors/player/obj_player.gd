extends CharacterBody3D

@onready var mesh: MeshInstance3D = $model
@onready var camera_controller: Node3D = $CameraController
@onready var aim: Marker3D = $CameraController/Pivot/Aim
@onready var camera_animations: AnimationPlayer = $CameraController/CameraAnimations

enum GameplayMode {
	ThirdPerson,
	TopDown,
	Platform
}

var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

@export_group("Player Config")
@export var player_health:int = 100
@export var SPEED_WALK:int = 4
@export var SPEED_RUN:int = 6
@export var JUMP_FORCE:int = 5

var SPEED_ACCEL = 30

@export_subgroup("Player Debug")
@export var CAN_MOVE:bool = true
@export var CAN_RUN:bool = true
@export var GRAVITY_ON:bool = true

var is_aiming:bool = false
var is_defending:bool = false
var is_attacking:bool = false
var is_dodging:bool = false

var dodge_timer:float = 0
var dodge_duration:int = 1

func _ready() -> void:
	UserGlobal.PLAYER = self

func _input(event: InputEvent) -> void:
	if camera_controller.gameplay_index == 0:
		if event.is_action_pressed("action_aiming"):
			if not is_aiming:
				is_aiming = true
				camera_animations.play("player_aiming")
		if event.is_action_released("action_aiming"):
			if is_aiming:
				is_aiming = false
				camera_animations.play_backwards("player_aiming")

func _physics_process(delta: float) -> void: #func movement_controller(delta):
	#print("dodge timer: ", dodge_timer)
	match camera_controller.gameplay_index:
		GameplayMode.ThirdPerson:
			CAN_MOVE = true
			thirdPerson_controller(delta)
		GameplayMode.TopDown:
			CAN_MOVE = false
		GameplayMode.Platform:
			CAN_MOVE = true
			platform_controller(delta)
	
	# Player Movement
	if CAN_MOVE:
		if Input.get_action_strength("action_run") && Input.get_action_strength("m_forward") && CAN_RUN:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN, SPEED_ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK, SPEED_ACCEL * delta)
				
		move_and_slide()
		
	# Dodge mechanics timer
	if is_dodging:
		dodge_timer += 1 * delta
		if dodge_timer > dodge_duration:
			is_dodging  = false
			dodge_timer = 0
			
	# Health bar
	$UI/HealthBar.value = player_health

# //////////////////////////////////////////////////////////
# /////////////////// MECHANICS ///////////////////////
# //////////////////////////////////////////////////////////

func player_damage(num:int) -> void:
	player_health -= num

# //////////////////////////////////////////////////////////
# /////////////////// GAMEPLAY CONTROLLER ///////////////////////
# //////////////////////////////////////////////////////////

# //// Soulslike Movement ////
func thirdPerson_controller(delta:float) -> void: # (1) Soulslike Movement
	# Direction of movement based on player direction
	move_dir = Vector3(
		Input.get_action_strength("m_right") - Input.get_action_strength("m_left"),
		0.0,
		Input.get_action_strength("m_backward") - Input.get_action_strength("m_forward")
	).normalized()
	
	# Makes the movement be relative to the camera
	var camera_rotation_y = $CameraController/Pivot/SpringArm.global_transform.basis.get_euler().y
	move_dir = move_dir.rotated(Vector3.UP, camera_rotation_y)
	
	if is_aiming: # Makes the player aim
		var target_position = aim.global_transform.origin # Get the Marked3D position
		var look_at_position = Vector3(target_position.x, mesh.global_transform.origin.y, target_position.z)
		mesh.look_at(look_at_position) # Make the mesh look at Marked3D
	else:
		if move_dir.length() > 0.1: # Rotates the mesh in the direction of movement with a smooth transition
			var target_rotation = atan2(-move_dir.x, -move_dir.z)
			mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, 5.0 * delta)
	
	if Input.is_action_pressed("action_attack"):
		is_attacking = true
	else:
		is_attacking = false
	
	if Input.is_action_just_pressed("action_defend"): # Defense system
		is_defending = true
	else:
		is_defending = false
	
	if Input.is_action_just_pressed("action_dodge") and not is_dodging: # Dodge System
		is_dodging = true
		velocity = move_dir * 50.0
		move_and_slide()
		
	# Soulslike Gravity
	if GRAVITY_ON and not is_on_floor():
		velocity.y -= 9.8 * delta

# //// Smash Bros Movement ////
func platform_controller(delta:float) -> void:
	move_dir = Vector3(
		0.0,
		0.0,
		Input.get_action_strength("m_right") - Input.get_action_strength("m_left")
	).normalized()
	
	if move_dir.length() > 0.1: # Rotation mesh to the move_dir
		var target_rotation = atan2(-move_dir.x, -move_dir.z)
		mesh.rotation.y = lerp_angle(mesh.rotation.y, target_rotation, 5.0 * delta)
		
	if Input.is_action_just_pressed("action_jump") and is_on_floor():
		velocity.y = JUMP_FORCE
		
	if Input.is_action_just_pressed("action_dodge") and not is_dodging: # Dodge System
		is_dodging = true
		velocity = move_dir * 50.0
		move_and_slide()
	
	# Platform gravity
	if GRAVITY_ON and not is_on_floor():
		velocity.y -= 15.0 * delta
		
# I didn't know you could do this, assigning a function to a variable
# a6x: amazing
#func _test():
	#var hello = func test_2():
		#pass
