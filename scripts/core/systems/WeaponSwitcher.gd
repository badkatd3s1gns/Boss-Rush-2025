extends Node

@onready var weapons: Node3D = $"../model/weapons"
var current_weapon_index:int = 0
var weapon_list:Array[Node] = []

func _ready() -> void:
	weapon_list = weapons.get_children()
	update_weapon_visibility()
	print("weapon_list: ", weapon_list)

# Well, I ended up making the system to change weapons with "Q" and "E", if you prefer to change using the numbers "1", "2", etc. let me know
func _input(event: InputEvent) -> void: 
	if event.is_action_pressed("next_weapon"): 
		current_weapon_index += 1
		if current_weapon_index >= weapon_list.size():
			current_weapon_index = 0
		update_weapon_visibility()

	elif event.is_action_pressed("previous_weapon"):
		current_weapon_index -= 1
		if current_weapon_index < 0:
			current_weapon_index = weapon_list.size() - 1
		update_weapon_visibility()

func update_weapon_visibility() -> void:
	for i in range(weapon_list.size()):
		weapon_list[i].visible = (i == current_weapon_index)
		
func get_current_weapon_type() -> String:
	return weapon_list[current_weapon_index].weapon_type
