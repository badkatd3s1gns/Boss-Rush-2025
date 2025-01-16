extends CharacterBody3D

@onready var nav: NavigationAgent3D = $NavigationAgent3D

@export var current_behavior:state_behavior = state_behavior.IDLE
enum state_behavior { IDLE, CHASING, ATTACKING, DEFENDING, STAGGERED }

var state_feelings = {
	"anger": 0.0,
	"fear": 0.0,
	"confidence": 0.0,
	"despair": 0.0
}

func _physics_process(delta: float) -> void:
	pass

# //////////////////////////////////////////////////////////
# //////////////////// OLD SCRIPT /////////////////////////
# //////////////////////////////////////////////////////////

#
#@export_group("Boss Config")
#@export var MOVE_SPEED:int = 5
#
#var accel = 10
#var player_position
#var current_point_index: int
#
#var direction = Vector3()
#
#func _ready() -> void:
	#update_target()
#
#func _physics_process(delta: float) -> void:
	#player_position = UserGlobal.PLAYER.global_transform.origin
	#
	#match current_state:
		#state.IDLE:
			#pass
		#state.RETREAT:
			#pass
		#state.CIRCLE:
			#circle_controller(delta)
		#state.APPROACH:
			#approach_controller(delta)
	#
	#if direction.length() > 0:
		#velocity.x = lerp(velocity.x, direction.x * MOVE_SPEED, accel * delta)
		#velocity.z = lerp(velocity.z, direction.z * MOVE_SPEED, accel * delta)
	#else:
		#velocity.x = lerp(velocity.x, 0.0, accel * delta)
		#velocity.z = lerp(velocity.z, 0.0, accel * delta)
	#
	#if not is_on_floor():
		#velocity.y -= 9.8 * delta
			#
	#move_and_slide()
	#
## //////////////////////////////////////////////////////////
## //////////////////// CONTROLLERS /////////////////////////
## //////////////////////////////////////////////////////////
#
#func retreating_controller(delta):
	#pass
#
#func circle_controller(delta):
	#var point = UserGlobal.CircleMarked[current_point_index]
	#
	#nav.target_position = point.global_transform.origin
	#direction = nav.get_next_path_position() - global_position
	#direction.y = 0
	#direction = direction.normalized()
#
#func approach_controller(delta:float):
	#nav.target_position = UserGlobal.PLAYER.global_transform.origin
	#direction = nav.get_next_path_position() - global_position
	#direction.y = 0
	#direction = direction.normalized()
#
## //////////////////////////////////////////////////////////
## ////////////////////// RANDOM ///////////////////////////
## //////////////////////////////////////////////////////////
#
#func update_target():
	#var target_point = UserGlobal.CircleMarked[current_point_index]
	#if target_point:
		#nav.set_target_position(target_point.global_transform.origin)
#
## //////////////////////////////////////////////////////////
## ////////////////////// SIGNALS ///////////////////////////
## //////////////////////////////////////////////////////////
#
#func _on_approach_entered(body: Node3D) -> void:
	#if body is Player:
		#current_state = state.APPROACH
#func _on_approach_exited(body: Node3D) -> void:
	#if body is Player:
		#current_state = state.IDLE
#
#func _on_retreat_entered(body: Node3D) -> void:
	#if body is Player:
		#current_state = state.RETREAT
#func _on_retreat_exited(body: Node3D) -> void:
	#if body is Player:
		#if current_state == state.RETREAT:
			#current_state = state.CIRCLE
#
#func _on_circle_entered(body: Node3D) -> void:
	#if body is Player:
		#current_state = state.CIRCLE
#func _on_circle_exited(body: Node3D) -> void:
	#if body is Player:
		#if current_state == state.CIRCLE:
			#current_state = state.APPROACH
