extends Node

var dummy_scene = preload("res://assets/prefabs/actors/obj_dummy.tscn")
@onready var spawn_point: Marker3D = $SpawnPoint

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("debug_action_1"):
		spawn_dummy()
		
func spawn_dummy():
	var dummy_instance = dummy_scene.instantiate()
	
	if spawn_point:
		dummy_instance.global_transform = spawn_point.global_transform
		
	get_parent().add_child(dummy_instance)
