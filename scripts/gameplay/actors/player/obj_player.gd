extends CharacterBody3D
#class_name Player

@onready var mesh: Node3D = $Model
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

var is_jumped = false
var jumping = false

var is_attacked = false
var combo = 0

func _ready() -> void:
	UserGlobal.PLAYER = self
	UserGlobal.CircleMarked.append($model/BossCombatSystem/CIRCLE_STATE/MarkerRight)
	UserGlobal.CircleMarked.append($model/BossCombatSystem/CIRCLE_STATE/MarkerLeft)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

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
	
	handle_animations(delta)
	
	if !is_on_floor() and GRAVITY_ON:
		velocity.y -= (9.8) * delta
	
	if is_jumped and is_on_floor():
		is_jumped = false
		velocity.y = 5.5
	
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
		
		if jumping or is_attacked:
			velocity.x = 0
			velocity.z = 0
		
		move_and_slide()
		
		if Input.get_vector("left", "right", "m_backward", "m_forward") and !Input.is_action_pressed("action_aiming"):
			mesh.rotation.z = lerp_angle(mesh.rotation.z, atan2(-velocity.x, -velocity.z) - mesh.rotation.y, delta*4.0)
			
			if Input.is_action_pressed("sprint"):
				mesh.rotation.z = clampf(mesh.rotation.z, deg_to_rad(-11), deg_to_rad(11))
			else:
				mesh.rotation.z = clampf(mesh.rotation.z, deg_to_rad(-0), deg_to_rad(0))
		
		else:
			mesh.rotation.z = lerp_angle(mesh.rotation.z, 0.0, delta*7.0)

# //////////////////////////////////////////////////////////
# /////////////////// MECHANICS ///////////////////////
# //////////////////////////////////////////////////////////

func player_damage(num:int) -> void:
	player_health -= num


func handle_animations(delta):
	var input_dir = Input.get_vector("left", "right", "m_backward", "m_forward")
	
	#if input_dir:
	$AnimationTree.set("parameters/MovementDir/blend_amount", lerpf($AnimationTree.get("parameters/MovementDir/blend_amount"), 0.0 if Input.is_action_pressed("action_aiming") else ((1.0 if Input.is_action_pressed("action_run") else 0.0) if input_dir else -1.0), delta*5.0))
	$AnimationTree.set("parameters/InAir/blend_amount", lerpf($AnimationTree.get("parameters/InAir/blend_amount"), 0.0 if is_on_floor() else 1.0, delta*7.0))
	$AnimationTree.set("parameters/Walk/blend_position", lerp($AnimationTree.get("parameters/Walk/blend_position"), Vector2(0.0, 1.0) if !Input.is_action_pressed("action_aiming") else input_dir.round(), delta*10.0))
	
	if Input.is_action_just_pressed("jump"):
		jumping = true
		$AnimationTree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if Input.is_action_just_pressed("action_attack") and is_attacked and $WeaponSwitcher.get_current_weapon_type() != "Melee":
		attack()
		$AnimationTree.set("parameters/AttackStyle/transition_request", $WeaponSwitcher.get_current_weapon_type() + str(combo+1))
		$AnimationTree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func jump():
	is_jumped = true
	jumping = false

func attack():
	if is_attacked: return
	
	is_attacked = true
	await get_tree().create_timer(3.0 if combo == 1 else 1.5).timeout
	is_attacked = false
	
	combo += 1
	
	if combo > 1: combo = 0
	make_bye()
	#await get_tree().create_timer(2.0).timeout
	#if !is_attacked: combo = 0

func make_bye():
	return
	await get_tree().create_timer(0.5).timeout
	combo = 0
