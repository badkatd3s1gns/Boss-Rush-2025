extends Control

func _ready():
	hide()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = !visible
		$"../../HUD/ScreenEffects".visible = visible
		
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
