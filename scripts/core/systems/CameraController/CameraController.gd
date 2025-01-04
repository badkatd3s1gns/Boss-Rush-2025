extends Node3D

@onready var pivot: Node3D = $Pivot
@onready var spring_arm: SpringArm3D = $Pivot/SpringArm
@onready var mom: CharacterBody3D = $".."

@export var mouse_sens:float = 0.4 ## Mouse Sensibility
@export_group("Whatever")
@export var can_move_mouse:bool = true ## Player can use? Made to assist in cutscenes and the like.

@export_group("Perspective Positions")
@export var topDown_angle:Vector3
@export var platform_angle:Vector3

var gameplay_index:int = 0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion && can_move_mouse:
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		pivot.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		pivot.rotation.x = clamp(pivot.rotation.x, -PI/3, PI/3) # Limits camera rotation
		
	if event.is_action_released("change_camera"): # to change the perpesctive
		gameplay_index += 1
		print(gameplay_index) # 1 2 3 for perspectives
		if gameplay_index > (mom.GameplayMode.size() - 1): # if bigger than 2
			gameplay_index = 0

func _physics_process(delta):
	#print("Pivot: ", pivot.rotation) # Testing
	match gameplay_index:
		mom.GameplayMode.ThirdPerson: # 0 
			can_move_mouse = true
			pivot.rotation.y = 0
			pivot.rotation.z = 0
		mom.GameplayMode.TopDown: # 1
			can_move_mouse = false
			transition_pespective(topDown_angle)
		mom.GameplayMode.Platform: # 2
			can_move_mouse = false
			transition_pespective(platform_angle)

func transition_pespective(to:Vector3):
	var tween = create_tween()
	
	pivot.rotation = Vector3.ZERO
	self.rotation.y = 0
	
	tween.tween_property(
		pivot, "rotation", to, 0.3 # The "to" here is the variable in the function (final value)
	)
	
	# For this stuff, its honestly just playing around with tween properties for animations
	Tween.TransitionType.TRANS_SINE
	Tween.EaseType.EASE_IN_OUT
