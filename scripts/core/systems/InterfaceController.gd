extends Node
class_name InterfaceController

@onready var obj_player: CharacterBody3D = $".."
@onready var camera_controller: Node3D = $"../CameraController"
@onready var third_person: Node = $"../StateMachine/ThirdPerson"

@onready var top_down_ui: Control = $"../UI/TopDownUI"

func _ready() -> void:
	top_down_ui.hide()
	
func _process(delta: float) -> void:
	if camera_controller.gameplay_index == 1:
		top_down_ui.visible = true
	else:
		top_down_ui.visible = false
		
	$"../UI/Debug/BoxContainer/FPS".text = "FPS: " + str(Engine.get_frames_per_second())
