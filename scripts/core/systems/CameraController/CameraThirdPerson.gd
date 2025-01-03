extends Node3D

@onready var spring_arm: SpringArm3D = $SpringArm
@onready var platform_camera: Camera3D = $PlatformCamera

@export var gameplay_mode:Mode
enum Mode {
	ThirdPerson,
	TopDown,
	Platform
}
@export var can_move_mouse:bool = true
@export var mouse_sens:float = 0.4

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion && can_move_mouse:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		spring_arm.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/3, PI/3) # Limits camera rotation
