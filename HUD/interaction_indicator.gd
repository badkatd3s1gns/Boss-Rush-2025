extends Area3D

var transition_tween: Tween

func _ready() -> void:
	transition_tween = create_tween()

func do_fade(value):
	if transition_tween != null:
		transition_tween.kill()
		transition_tween = create_tween()
	
	transition_tween.tween_property($UISprite, "modulate:a", value, 0.5)
	transition_tween.play()
	await transition_tween.finished
	transition_tween.kill()

func _on_body_entered(body: Node3D) -> void:
	if body == UserGlobal.PLAYER:
		do_fade(1.0)

func _on_body_exited(body: Node3D) -> void:
	if body == UserGlobal.PLAYER:
		do_fade(0)
