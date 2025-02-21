extends Button

@export var item = ""

@export var holding_obj: TextureRect

@export var special_slot: bool
@export var id = 0

var holding = false

var tex = null

var is_hovered = false

func _ready() -> void:
	init(item)
	
	self.pressed.connect(_on_button_pressed)
	self.mouse_entered.connect(_on_mouse_entered)
	self.mouse_exited.connect(_on_mouse_exited)
	
	pivot_offset = size / 2
	#self.gui_input.connect(_gui_input)

func _on_mouse_entered():
	is_hovered = true
	animate_slot()

func _on_mouse_exited():
	is_hovered = false
	animate_slot()

func animate_slot():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * (0.9 if is_hovered else 1.0), 0.2)

func _on_button_pressed():
	if holding: return
	
	if holding_obj.enable and item == "":
		var a = holding_obj.drop_item()
		item = a
		change_tex()
		holding = false
		#init(.drop_item())
		return
	
	if item != "":
		#holding_obj.drop_item()
		holding_obj.init(item)
		$Icon.texture = null
		#holding = true
		if special_slot: $"../../../../WeaponSwitcher".set_item("", id)
		#if special_slot: $"../../../../WeaponSwitcher".remove_item_to_slot(item)
		item = ""


func init(_item):
	if _item != "":
		#icon = preload("res://icon.svg")
		#tex = preload("res://icon.svg")
		change_tex()
		#if _item == "Empty": tex = preload("res://The Bosses/Frog/FrogAnim_Body.png")
		#get_node("Icon").texture = tex
		item = _item
		#print(item, " + ", name)

func change_tex():
	tex = null
	match item:
		"Hammer":
			tex = preload("res://assets/textures/hammer_icon.png")
		"Sword":
			tex = preload("res://assets/textures/sword_icon.png")
		
	get_node("Icon").texture = tex
	
	if special_slot: $"../../../../WeaponSwitcher".set_item(item, id)
