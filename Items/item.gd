extends Area3D

@export var item_name = ""
@export var rotation_speed = 20

func _physics_process(delta: float) -> void:
	rotation_degrees.y += rotation_speed * delta

func _on_body_entered(body: Node3D) -> void:
	if body == UserGlobal.PLAYER:
		if body.has_method("pick_item"): 
			body.pick_item(item_name)
			$AnimationPlayer.play("disappear")
			await $AnimationPlayer.animation_finished
			queue_free()
