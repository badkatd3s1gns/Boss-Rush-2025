extends TextureRect

var enable = false

var item = ""

func init(_item):
	#print(_item)
	show()
	enable = true
	item = _item
		
	var tex = null
	match item:
		"Hammer":
			tex = preload("res://assets/textures/hammer_icon.png")
		"Sword":
			tex = preload("res://assets/textures/sword_icon.png")
		"HealthPotion":
			tex = preload("res://assets/textures/heal_icon.webp")
		"Book":
			tex = preload("res://assets/textures/mana_icon.webp")
		"Lute":
			tex = preload("res://assets/textures/bass_icon.png")
		
	texture = tex

func _process(delta: float) -> void:
	if enable:
		position = lerp(position, get_global_mouse_position(), delta*50.0)

func drop_item():
	var t = item
	item = ""
	
	hide()
	enable = false
	return t
