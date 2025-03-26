extends Area3D

@export var boss_path: PackedScene

var boss_already_spawn = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body: Node3D) -> void:
	if boss_already_spawn or !boss_path: return
	
	if body == UserGlobal.PLAYER:
		var boss = boss_path.instantiate()
		boss.position = self.position + Vector3(0, 1, 0)
		get_parent().add_child(boss)
		
		boss.appear()
		
		boss_already_spawn = true
		
		get_parent().init_boss(boss.boss_name, boss.health)
		
		#var boss = preload("snail")
