@tool
extends Control

@export var outer_radius = 64
@export var inner_radius = 48

@export var bg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var options: PackedStringArray

func _ready() -> void:
	scale = Vector2.ZERO

func _draw() -> void:
	draw_circle(Vector2.ZERO, outer_radius, bg_color)
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, 4, true)
	
	if len(options) >= 3:
		for i in range(len(options) - 1):
			var rads = TAU * i / ((len(options)+1))
			if i > 3: rads = (TAU * 20)
			var point = Vector2.from_angle(rads-1.42)
			draw_line(point*inner_radius, point*outer_radius, line_color, 4, true)
	
	for i in range(1, len(options)):
		var start_rads = (TAU * (i-1)) / (len(options) + 1.5)
		var end_rads = (TAU * i) / (len(options) + 1.5)
		var mid_rads = (start_rads + end_rads)/2.0 * -1
		
		var a = 1
		if a == i:
			var points_per_arc = 32
			var points_inner = PackedVector2Array()
			var points_outer = PackedVector2Array()
			
			for j in range(points_per_arc+1):
				var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
				angle += 0.55
				points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
				points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
				
			points_outer.reverse()
			draw_polygon(
				points_inner + points_outer,
				PackedColorArray([highlight_color])
			)

func _process(delta: float) -> void:
	queue_redraw()

func init():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.5)
