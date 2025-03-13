extends Node

@onready var weapons: Node3D = $"../Model/metarig/Skeleton3D/Hand/Weapons"
var current_weapon_index:int = 0

var weapon_list:Array[Node] = []

var total_weapons = 2

var slots = ["", ""]

var switch_speed = 0.2

func _ready() -> void:
	weapon_list = weapons.get_children()
	for i in weapon_list: i.scale = Vector3.ZERO
	update_weapon_visibility()
	#print("weapon_list: ", weapon_list)

# Well, I ended up making the system to change weapons with "Q" and "E", if you prefer to change using the numbers "1", "2", etc. let me know
func _input(event: InputEvent) -> void: 
	if Input.is_action_just_pressed("next_weapon"): 
		current_weapon_index += 1
		if current_weapon_index >= total_weapons:
			current_weapon_index = 0
		update_weapon_visibility()
	
	elif Input.is_action_just_pressed("previous_weapon"):
		current_weapon_index -= 1
		if current_weapon_index < 0:
			current_weapon_index = total_weapons - 1
		update_weapon_visibility()

func update_weapon_visibility() -> void:
	$"..".combo = 0
	var current_weapon = get_current_weapon_type()
	var next_weapon = ""
	
	for i in range(weapon_list.size()):
		if i > weapon_list.size(): return
		if current_weapon_index > slots.size(): return
		#if current_weapon_index == 2 or i == 2: 
			#current_weapon_index = 0
			#continue
		
		weapon_list[i].visible = true
		
		if str(weapon_list[i].name) != current_weapon: ready_pop(weapon_list[i])
		
		#weapon_list[i].visible = true if (weapon_list[i].name == slots[current_weapon_index]) else false
		if (weapon_list[i].name == slots[current_weapon_index]):
			next_weapon = str(weapon_list[i].name)
			if current_weapon != next_weapon: ready_pop(weapon_list[i])
			break
	
	if next_weapon != "" and next_weapon != current_weapon:
		if current_weapon == "Melee":
			pop(weapons.get_node(next_weapon), 1.0)
		else:
			pop(weapons.get_node(current_weapon), 0)
			await get_tree().create_timer(switch_speed).timeout
			pop(weapons.get_node(next_weapon), 1.0)
	
	if current_weapon != "Melee" and next_weapon == "":
		pop(weapons.get_node(current_weapon), 0)

func ready_pop(node):
	node.scale = Vector3.ZERO

func pop(node, val):
	var tween = create_tween()
	tween.tween_property(node, "scale", Vector3.ONE * val, switch_speed)

func get_current_weapon_type() -> String:
	for i in range(weapon_list.size()):
		if weapon_list[i].scale.x > 0.9: return weapon_list[i].name
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
