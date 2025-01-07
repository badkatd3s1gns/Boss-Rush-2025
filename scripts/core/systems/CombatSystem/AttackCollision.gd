extends Area3D

func attack_collision_entered(body: Node3D) -> void:
	if body is Enemy:
		body.damage(10)
