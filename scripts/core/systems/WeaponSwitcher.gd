extends Node

@onready var weapons: Node3D = $"../Model/metarig/Skeleton3D/Hand/Weapons"
var current_weapon_index:int = 0
var weapon_list:Array[Node] = []

var slots = ["", ""]

func _ready() -> void:
	weapon_list = weapons.get_children()
	update_weapon_visibility()
	print("weapon_list: ", weapon_list)

# Well, I ended up making the system to change weapons with "Q" and "E", if you prefer to change using the numbers "1", "2", etc. let me know
func _input(event: InputEvent) -> void: 
	if Input.is_action_just_pressed("next_weapon"): 
		current_weapon_index += 1
		if current_weapon_index >= weapon_list.size():
			current_weapon_index = 0
		update_weapon_visibility()
	
	elif Input.is_action_just_pressed("previous_weapon"):
		current_weapon_index -= 1
		if current_weapon_index < 0:
			current_weapon_index = weapon_list.size() - 1
		update_weapon_visibility()

func update_weapon_visibility() -> void:
	$"..".combo = 0
	
	for i in range(weapon_list.size()):
		print(slots, i, current_weapon_index)
		weapon_list[i].visible = true if (weapon_list[i].name == slots[current_weapon_index]) else false

func get_current_weapon_type() -> String:
	for i in range(weapon_list.size()):
		if weapon_list[i].visible: return weapon_list[i].name
	#return weapon_list[current_weapon_index].name
	return "Melee"

func add_item_to_slot(it):
	if it not in slots: slots.append(it)
	update_weapon_visibility()

func remove_item_to_slot(it):
	if it in slots: slots.erase(it)
	update_weapon_visibility()

func set_item(it, id):
	slots[id] = it
	update_weapon_visibility()
