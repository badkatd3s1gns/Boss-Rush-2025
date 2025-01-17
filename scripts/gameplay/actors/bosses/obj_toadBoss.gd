extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var behavior_timer: Timer = $BehaviorTimer

enum state_behavior { IDLE, CHASING, ATTACKING, DEFENDING, END }
enum movement { WALK, RUN}

@export var current_behavior:state_behavior = state_behavior.IDLE
var current_movement:movement
@export_group("AI Config")
@export var MOVE_SPEED:int = 5
@export var MOVE_RUN:int = 10
@export var attack_interval: float = 3.0 # Intervalo de tempo para atacar
@export var idle_interval: float = 2.0 # Intervalo de tempo para ficar parado
@export var random_behavior_chance: float = 0.3 # Chance de escolher comportamento aleatório (30%)
@export_group("Fight Config")
var attack_index:int = 0
var attack_attempts:int = 0
@export var attacks:Array[EnemyAttackResource]
@export var second_phase:bool = false

var accel:int = 10
var direction:Vector3

func _physics_process(delta: float) -> void:
	movement_controller(delta)
	
	match current_behavior:
		state_behavior.IDLE:
			velocity.x = lerp(velocity.x, 0.0, accel * delta)
		state_behavior.CHASING:
			chasing_controller(delta)
		state_behavior.ATTACKING:
			pass
		state_behavior.DEFENDING:
			pass
		state_behavior.END:
			pass
			
	
	direction.y = 0 # he won't fly

# //////////////////////////////////////////////////////////
# //////////////////// CONTROLLERS /////////////////////////
# //////////////////////////////////////////////////////////

# -- main

func movement_controller(delta:float): # General AI movement
	if direction.length() > 0:
		match current_movement:
			movement.WALK:
				velocity.x = lerp(velocity.x, direction.x * MOVE_SPEED, accel * delta)
				velocity.z = lerp(velocity.z, direction.z * MOVE_SPEED, accel * delta)
			movement.RUN:
				velocity.x = lerp(velocity.x, direction.x * MOVE_RUN, accel * delta)
				velocity.z = lerp(velocity.z, direction.z * MOVE_RUN, accel * delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, accel * delta)
		velocity.z = lerp(velocity.z, 0.0, accel * delta)
	
	if not is_on_floor():
		velocity.y -= 9.8 * delta
			
	move_and_slide()

# -- secondary

func chasing_controller(delta:float):
	var distance_to_player
	distance_to_player = global_transform.origin.distance_to(UserGlobal.PLAYER.global_transform.origin)
	
	if distance_to_player > 10:
		current_movement = movement.RUN
	else:
		current_movement = movement.WALK
	
	nav.target_position = UserGlobal.PLAYER.global_transform.origin
	direction = (nav.get_next_path_position() - global_position).normalized()

func attacking_controller(delta:float):
	var found_valid_attack = false
	while not found_valid_attack and attack_attempts < attacks.size():
		var attack = attacks[attack_index]
		
		if attack.second_phase_attack == second_phase: # Checks if the boss is in the second phase. If so, it will only reproduce attacks from the second phase.
			animation_player.play(attack.animation)
			attack_index = (attack_index + 1) % attacks.size()
			found_valid_attack = true
		else:
			attack_index = (attack_index + 1) % attacks.size()
		
	if not found_valid_attack:
		attack_index = 0

# //////////////////////////////////////////////////////////
# 	//////////////////// RANDOM /////////////////////////
# //////////////////////////////////////////////////////////
