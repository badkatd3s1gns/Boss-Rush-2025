extends Node3D

@onready var pivot: Node3D = $Pivot
@onready var spring_arm: SpringArm3D = $Pivot/SpringArm
@onready var player: CharacterBody3D = $".."
@onready var camera_3d: Camera3D = $Pivot/SpringArm/Camera3D
@onready var enemy_detection: RayCast3D = $"../model/EnemyDetection"

@export var mouse_sens:float = 0.4 ## Mouse Sensibility
@export_group("Whatever")
@export var can_move_mouse:bool = true ## Player can use? Made to assist in cutscenes and the like.

@export_group("Perspective Positions")
@export var topDown_angle:Vector3
@export var platform_angle:Vector3

var gameplay_index:int = 0
var is_p:bool = false

var target_zoom = 4
var mouse_relative = Vector2.ZERO

var head_bob = Vector3.ZERO

#func _process(delta: float) -> void:
	#if gameplay_index == 1:
		#Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	#else:
		#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	
	if event is InputEventMouseMotion && can_move_mouse:
		$TargetRot.rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		$TargetRot.rotation.x += (deg_to_rad(-event.relative.y * mouse_sens))
		$TargetRot.rotation.x = clamp($TargetRot.rotation.x, -PI/3, PI/5) # Limits camera rotation
		mouse_relative = event.relative
	
	if event.is_action_released("change_camera"): # to change the perpesctive
		gameplay_index += 1
		print(gameplay_index) # 1 2 3 for perspectives
		if gameplay_index > (player.GameplayMode.size() - 1): # if bigger than 2
			gameplay_index = 0
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			target_zoom -= 0.15
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			target_zoom += 0.15

func _physics_process(delta):
	$Pivot/SpringArm.spring_length = lerpf($Pivot/SpringArm.spring_length, target_zoom, delta*10.0)
	#print("Pivot: ", pivot.rotation) # Testing
	match gameplay_index:
		player.GameplayMode.ThirdPerson: # 0 
			can_move_mouse = true
			pivot.rotation.y = 0
			pivot.rotation.z = 0
		player.GameplayMode.TopDown: # 1
			can_move_mouse = false
			transition_pespective(topDown_angle, false, 90)
		player.GameplayMode.Platform: # 2
			can_move_mouse = false
			transition_pespective(platform_angle, true, 75)
	
	rotation.y = lerp_angle(rotation.y, $TargetRot.rotation.y+head_bob.x, delta*15.0)
	pivot.rotation.x = lerp_angle(pivot.rotation.x, $TargetRot.rotation.x+head_bob.y, delta*15.0)
	
	mouse_relative = lerp(mouse_relative, Vector2.ZERO, delta*5.0)
	rotation.z = lerp_angle(rotation.z, mouse_relative.x*0.007 + head_bob.z/5, delta*5.0)
	
	if Input.is_action_pressed("sprint"):
		head_bob.x = cos(Time.get_ticks_msec() * 0.01) * 0.025
		head_bob.y = sin(Time.get_ticks_msec() * 0.01 / 2) * 0.025
		head_bob.z = sin(Time.get_ticks_msec() * 0.01 / 2) * 0.025
	else:
		head_bob = Vector3.ZERO
	
	if !Input.is_action_pressed("action_aiming"): $Pivot/SpringArm/Camera3D.fov = lerpf($Pivot/SpringArm/Camera3D.fov, 83.5 if Input.is_action_pressed("sprint") else 75, delta*7.0)

func transition_pespective(to:Vector3, is_platform:bool, fov):
	var tween = create_tween()
	pivot.rotation = Vector3.ZERO
	self.rotation.y = 0
	
	tween.tween_property(
		pivot, "rotation", to, 0.3
	)

	tween.tween_property(
		camera_3d, "fov", fov, 0.3
	)

	Tween.TransitionType.TRANS_SINE
	Tween.EaseType.EASE_IN_OUT
	
	tween.finished.connect(self._on_transition_finished)
	
	# For this stuff, its honestly just playing around with tween properties for animations

func _on_transition_finished():
	if player.GameplayMode.ThirdPerson or player.GameplayMode.TopDown: # 0 
		$PlatformCamera.current = false
		$Pivot/SpringArm/Camera3D.current = true
	elif player.GameplayMode.Platform: # 2
		$PlatformCamera.current = true
		$Pivot/SpringArm/Camera3D.current = false
