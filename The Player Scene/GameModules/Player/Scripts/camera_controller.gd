extends Node3D
class_name CameraController

signal set_cam_rotation(_cam_rotation : float)

@export var player: Player

@onready var yaw_node: Node3D = $CamYaw
@onready var pitch_node: Node3D = $CamYaw/CamPitch
@onready var camera: Camera3D = $CamYaw/CamPitch/SpringArm3D/Camera3D

var yaw : float = 0
var pitch : float = 0
var yaw_sensitivity : float = 0.07
var pitch_sensitivity : float = 0.07
var yaw_acceleration : float = 15
var pitch_acceleration : float = 15
var pitch_max : float = 75
var pitch_min : float = -55
var tween : Tween 

var gameplay_index:int = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		yaw += -event.relative.x * yaw_sensitivity
		pitch += event.relative.y * pitch_sensitivity
		
func _physics_process(delta):

	pitch = clamp(pitch, pitch_min, pitch_max)
	yaw_node.rotation_degrees.y = lerp(yaw_node.rotation_degrees.y, yaw, yaw_acceleration * delta)
	pitch_node.rotation_degrees.x = lerp(pitch_node.rotation_degrees.x, pitch, pitch_acceleration * delta)

	set_cam_rotation.emit(yaw_node.rotation.y)
	
func set_fov(value : float):
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(camera, "fov", value, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)


func _on_set_movement_state(_movement_state : MovementState):
	if player.is_attacking:
		return
		
	set_fov(_movement_state.camera_fov)
		
	if tween:
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(
		camera, "fov", _movement_state.camera_fov, 0.5
		).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
