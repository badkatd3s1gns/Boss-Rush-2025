extends Node3D

@onready var pivot: Node3D = $Pivot
@onready var spring_arm: SpringArm3D = $Pivot/SpringArm

enum GameplayMode {
	ThirdPerson,
	TopDown,
	Platform
}
@export var mouse_sens:float = 0.4
@export_group("Whatever")
@export var can_move_mouse:bool = true

@export_group("Perspective Positions")
@export var topDown_angle:Vector3
@export var platform_angle:Vector3

var pespective_index:int = 0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion && can_move_mouse:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		pivot.rotation.x = clamp(pivot.rotation.x, -PI/3, PI/3) # Limits camera rotation
		
	if event.is_action_released("change_camera"):
		pespective_index += 1
		if pespective_index > (GameplayMode.size() - 1):
			pespective_index = 0

func _physics_process(delta: float) -> void:
	print("Pivot: ", pivot.rotation)
	match pespective_index:
		GameplayMode.ThirdPerson:
			can_move_mouse = true
			pivot.rotation.y = 0
			pivot.rotation.z = 0
		GameplayMode.TopDown:
			can_move_mouse = false
			transition_pespective(topDown_angle)
		GameplayMode.Platform:
			can_move_mouse = false
			transition_pespective(platform_angle)

func transition_pespective(to:Vector3):
	var tween = create_tween()
	
	pivot.rotation = Vector3.ZERO
	self.rotation.y = 0
	
	tween.tween_property(
		pivot, "rotation", to, 0.3
	)
	
	Tween.TransitionType.TRANS_SINE
	Tween.EaseType.EASE_IN_OUT
