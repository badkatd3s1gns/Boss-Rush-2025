extends Button

@onready var tween := get_tree().create_tween()
@export var normal_color: Color = Color(1, 1, 1)
@export var hover_color: Color = Color(1, 0.6, 0.3)
@export var pressed_color: Color = Color(1, 0.3, 0.1)
@export var normal_font_color: Color = Color(1, 1, 1)
@export var hover_font_color: Color = Color(1, 0.6, 0.3)
@export var pressed_font_color: Color = Color(1, 0.3, 0.1)
@export var hover_scale: float = 1.1
@export var press_scale: float = 0.95
@export var tween_time := 0.12

func _ready():
	get("theme_override_styles/normal").bg_color = normal_color
	#get("theme_override_colors").font_color = normal_font_color
	
	self.scale = Vector2.ONE
	
	connect("mouse_entered", _on_mouse_entered)
	connect("mouse_exited", _on_mouse_exited)
	connect("pressed", _on_pressed)
	connect("button_up", _on_button_up)
	
	pivot_offset = size/2

func _on_mouse_entered():
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * hover_scale, tween_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(get("theme_override_styles/normal"), "bg_color", hover_color, tween_time)
	tween.parallel().tween_property(get("theme_override_styles/hover"), "bg_color", hover_color, tween_time)
	tween.parallel().tween_property(get("theme_override_styles/pressed"), "bg_color", hover_color, tween_time)
	
	tween.parallel().tween_property(self, "theme_override_colors/font_color", hover_font_color, tween_time)
	tween.parallel().tween_property(self, "theme_override_colors/font_pressed_color", hover_font_color, tween_time)
	tween.parallel().tween_property(self, "theme_override_colors/font_hover_color", hover_font_color, tween_time)
	
	$HoverSound.play()

func _on_mouse_exited():
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, tween_time).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(get("theme_override_styles/normal"), "bg_color", normal_color, tween_time)
	tween.parallel().tween_property(get("theme_override_styles/hover"), "bg_color", normal_color, tween_time)
	tween.parallel().tween_property(get("theme_override_styles/pressed"), "bg_color", normal_color, tween_time)
	
	tween.parallel().tween_property(self, "theme_override_colors/font_color", normal_font_color, tween_time)
	tween.parallel().tween_property(self, "theme_override_colors/font_pressed_color", normal_font_color, tween_time)
	tween.parallel().tween_property(self, "theme_override_colors/font_hover_color", normal_font_color, tween_time)

func _on_pressed():
	tween.kill()
	tween = get_tree().create_tween()
	tween.tween_property(self, "scale", Vector2.ONE * press_scale, tween_time / 2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(get("theme_override_styles/normal"), "bg_color", pressed_color, tween_time/2)
	tween.parallel().tween_property(get("theme_override_styles/hover"), "bg_color", pressed_color, tween_time/2)
	tween.parallel().tween_property(get("theme_override_styles/pressed"), "bg_color", pressed_color, tween_time/2)
	tween.parallel().tween_property(self, "theme_override_colors/font_color", pressed_font_color, tween_time)
	
	$ClickSound.play(0.1)

func _on_button_up():
	# Return to hover state or normal depending on mouse position
	if get_rect().has_point(get_local_mouse_position()):
		_on_mouse_entered()
	else:
		_on_mouse_exited()
