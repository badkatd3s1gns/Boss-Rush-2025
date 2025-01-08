extends Node3D

@onready var dad: CharacterBody3D = $"../.."
@onready var animation_player: AnimationPlayer = $"../../model/AnimationPlayer"

@export var JUMP_FORCE:int = 5

@export_group("Combat System")
@export var attacks:Array[AttackResource]

var attack_index:int = 0
var is_attacking:bool = false

func start(delta:float) -> void:
	movement_behavior(delta)
	CombatSystem()
	
	
func movement_behavior(delta:float) -> void:
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

func CombatSystem() -> void:
	if Input.is_action_just_pressed("action_attack") && not animation_player.is_playing():
		var i = attacks[attack_index]
		
		if not is_attacking:
			animation_player.play(i.animation)
			attack_index += 1
			
		if attack_index >= attacks.size():
			attack_index = 0
				
	if Input.is_action_pressed("action_defend"):
		if not dad.is_defending:
			animation_player.play("defending")
			dad.is_defending = true
	else:
		dad.is_defending = false
