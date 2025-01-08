extends CharacterBody3D

@onready var mesh: Node3D = $model
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

var enemy_focus = null

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
				
func _physics_process(delta: float) -> void:
	movement_controller(delta)
	
	match camera_controller.gameplay_index: # Gameplay Type Controller
		GameplayMode.ThirdPerson:
			CAN_MOVE = true
			$StateMachine/ThirdPerson.start(delta)
		GameplayMode.TopDown:
			CAN_MOVE = false
			$StateMachine/TopDown.start(delta)
		GameplayMode.Platform:
			CAN_MOVE = true
			$StateMachine/Platform.start(delta)
		
	# Dodge mechanics timer
	if is_dodging:
		dodge_timer += 1 * delta
		if dodge_timer > dodge_duration:
			is_dodging  = false
			dodge_timer = 0
			
	# Health bar
	#$UI/HealthBar.value = player_health

# //////////////////////////////////////////////////////////
# //////////////////// CONTROLLERS /////////////////////////
# //////////////////////////////////////////////////////////
func movement_controller(delta:float):
	if CAN_MOVE:
		if Input.get_action_strength("action_run") && Input.get_action_strength("m_forward") && CAN_RUN && not is_defending:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN, SPEED_ACCEL * delta)
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK, SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK, SPEED_ACCEL * delta)
			
		if is_defending:
			SPEED_WALK = 2
		else:
			SPEED_WALK = 4
				
		move_and_slide()

# //////////////////////////////////////////////////////////
# /////////////////// MECHANICS ///////////////////////
# //////////////////////////////////////////////////////////

func player_damage(num:int) -> void:
	player_health -= num
	
# I didn't know you could do this, assigning a function to a variable
# a6x: amazing
#func _test():
	#var hello = func test_2():
		#pass
	
