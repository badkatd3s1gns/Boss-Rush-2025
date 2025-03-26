extends Control

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("toggle_inventory"):
		visible = !visible
		$"../../HUD/ScreenEffects".visible = visible
		
		if visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		
		if !visible and $HoldingObject.item != "":
			for i in $InventoryMain.get_children():
				if i.holding:
					i._on_button_pressed()
			$HoldingObject.drop_item()

func add_item(it):
	for i in $InventoryMain.get_children():
		if !i.item:
			i.add_item(it)
			break
