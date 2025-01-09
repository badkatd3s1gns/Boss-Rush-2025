extends Area3D

@export var dad:Node3D

func _process(delta: float) -> void:
	if dad.visible:
		monitorable = true
	else:
		monitorable = false

func attack_collision_entered(body: Node3D) -> void:
	if body is Enemy:
		body.damage(10)
