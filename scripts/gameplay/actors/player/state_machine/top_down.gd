extends Node3D

@onready var enemy_marked: Marker3D = $EnemyMarked

@onready var dad: CharacterBody3D = $"../.."
@onready var enemy_detection: RayCast3D = $"../../model/EnemyDetection"
@onready var mesh: MeshInstance3D = $"../../model/mesh"

var enemy_obj
var enemy_focus = null

func start(delta:float) -> void:
	CombatSystem()

func _physics_process(delta: float) -> void:
	if enemy_detection.is_colliding():
		var enemy = enemy_detection.get_collider()
		if enemy is Enemy:
			enemy_focus = enemy
			enemy_obj = enemy
			
# still doesn't have animations for combat system
func CombatSystem() -> void:
	if enemy_focus:
		enemy_obj.global_transform.origin = enemy_marked.global_transform.origin
		dad.mesh.look_at(enemy_obj.global_transform.origin, Vector3.UP)
	
