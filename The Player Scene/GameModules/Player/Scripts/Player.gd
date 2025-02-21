extends CharacterBody3D
class_name Player

signal pressed_primary_fire
signal pressed_secondary_fire
signal pressed_jump(jump_state : JumpState)
signal set_movement_state(_movement_state: MovementState)
signal set_movement_direction(_movement_direction: Vector3)

@export var weapon_switcher : WeaponSwitcher
@export var max_air_jump : int = 1
@export var jump_states : Dictionary
@export var movement_states : Dictionary # same thing as stances

@onready var skills_container: SkillsContainer = $MeshRoot/protagonist_model/metarig/Skeleton3D/sword/SkillsContainer


enum GameplayMode {
	ThirdPerson,
	TopDown,
	Platform
}

var air_jump_counter : int = 0
var movement_direction : Vector3

var is_attacking : bool = false 

func _ready():
	set_movement_state.emit(movement_states["stand"])

func _input(event): 
	if event.is_action_pressed("primary_fire"):
		if can_attack():
			pressed_primary_fire.emit()
	
	if event.is_action_pressed("secondary_fire"):
		if can_attack():
			pressed_secondary_fire.emit()	
			
	if event.is_action("movement"):
		movement_direction.x = Input.get_action_strength("left") - Input.get_action_strength("right")
		movement_direction.z = Input.get_action_strength("forward") - Input.get_action_strength("back")
		
		if is_movement_ongoing(): 
			if Input.is_action_pressed("sprint"):
				set_movement_state.emit(movement_states["sprint"])
			else:
				if Input.is_action_pressed("walk"):
					set_movement_state.emit(movement_states["walk"])
				else:
					set_movement_state.emit(movement_states["run"])
		else:
			set_movement_state.emit(movement_states["stand"])
	
func _physics_process(_delta):
	if is_movement_ongoing():
		set_movement_direction.emit(movement_direction)
		
	# For Jump
	if is_on_floor():
		air_jump_counter = 0
	elif air_jump_counter == 0:
		air_jump_counter = 1
	
	if air_jump_counter <= max_air_jump:
		if Input.is_action_just_pressed("jump"):
			var jump_name = "ground_jump"
			if air_jump_counter > 0:
				jump_name = "air_jump"
				
			pressed_jump.emit(jump_states[jump_name]) # This was important for jumping
			air_jump_counter += 1
	
func can_attack():
	var value = true
		
	if weapon_switcher.get_current_weapon().weapon_name == "no_weapon":
		value = false
	
	if weapon_switcher.is_switching():
		value = false
		
	if skills_container.delivery_timer.time_left > 0:
		value = false

	return value

func is_movement_ongoing() -> bool:
	return abs(movement_direction.x) > 0 or abs (movement_direction.z) > 0
	
func _set_movement_state(state : String):
	set_movement_state.emit(movement_states[state])
