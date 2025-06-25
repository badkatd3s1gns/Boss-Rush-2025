extends CharacterBody3D

@export_group("Movement") # Movement-related properties
@export var speed: float = 5.0 # Maximum movement speed
@export var acceleration: float = 10.0 # Speed increase rate
@export var deacceleration: float = 8.0 # Speed decrease rate, longer values means less slide when stopped
@export var rotation_speed: float = 5.0 # Turning speed (basically for looking at player)

@export_group("Attack") # Attack-related properties
@export var min_attack_damage: int = 5 # Minimum attack damage or power
@export var max_attack_damage: int = 20 # Maximum attack damage
@export var attack_speed: float = 1.5 # Attack animation speed
@export var attack_cooldown: float = 2.0 # Time between attacks, aka idle after attack
@export var randomized_attack_cooldown: float = 1.0 # Randomized cooldown variation
@export var attack_range: float = 6.44 # Distance within which attacks hit and stops
@export var extra_attack_power: int = 5 # Additional attack strength
@export var automatically_trigger_attack: bool = true  # Auto-triggers attack mid-animation if true; otherwise, requires a specific attack frame.
@export var trigger_attack_cooldown: float = 1.0  # Time interval (seconds) before checking if attack can trigger automatically.

@export_group("Defense") # Defense-related properties
@export var defensive_power: int = 10 # Base defense value
@export var defensive_range: int = 4.5
@export var defense_delay: int = 2.0
@export var defense_cooldown: int = 1.1
@export var extra_defense_power: int = 5 # Randomized defense power
@export var health: int = 200 # Boss health amount

@export_group("Stage 2")
@export var speed_2: float = 1.5 # Maximum movement speed

@export_group("Boss Info") # General boss information
@export var boss_name: String = "" # Name of the boss

@onready var nav: NavigationAgent3D = $NavigationAgent3D

var player

var is_player_in = false
var is_player_close = false

var can_take_damage = true

var can_attack = true

var tween = null

var alive = true

var current_health = 200

var is_on_defend = false
var is_defending = false

var can_defend = true

func _ready() -> void:
	current_health = health
	
	tween = create_tween()
	tween.stop()
	
	player = UserGlobal.PLAYER

func appear():
	$AnimationTree.set("parameters/Spawning/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	show()
	
	get_tree().current_scene.boss_fight = true

func _physics_process(delta: float) -> void:
	if !visible or !alive: return
	
	if !is_on_floor():
		velocity.y -= 9.8 * delta
	
	var direction = Vector3.ZERO #(global_position - player.position).normalized()
	nav.target_position = UserGlobal.PLAYER.position
	
	direction = nav.get_next_path_position() - global_position
	direction = direction.normalized()
	
	if is_player_in: direction = Vector3.ZERO
	
	if direction:
		velocity.x = lerpf(velocity.x, direction.x * speed, delta*acceleration)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta*acceleration)
	else:
		velocity.x = lerpf(velocity.x, direction.x * speed, delta*deacceleration)
		velocity.z = lerpf(velocity.z, direction.z * speed, delta*deacceleration)
	
	move_and_slide()
	
	$MovementDir.look_at(player.global_position, Vector3.UP, true)
	$MovementDir.rotation.y += rotation.y
	
	if can_attack and !is_defending: rotation.y = lerp_angle(rotation.y, $MovementDir.rotation.y, delta*rotation_speed)
	
	handle_animations(delta)
	
	is_player_in = global_position.distance_to(player.global_position) < attack_range and global_position.distance_to(player.global_position) > -attack_range
	is_player_close = global_position.distance_to(player.global_position) < defensive_range and global_position.distance_to(player.global_position) > -defensive_range
	
	if can_attack and !$PlayerDetector.is_colliding() and can_defend:
		if is_player_close and !is_on_defend and not speed == speed_2:
			is_on_defend = true
			start_defending()
		
		elif !is_player_close and is_on_defend:
			is_on_defend = false
			$AnimationTree.set("parameters/State/transition_request", "attack")
			is_defending = false
	
	if can_attack and $PlayerDetector.is_colliding():
		attack()

func handle_animations(delta):
	$AnimationTree.set("parameters/MovementBlend/blend_amount", lerpf($AnimationTree.get("parameters/MovementBlend/blend_amount"), 1.0 if int(velocity.length()) > 0 else 0.0, delta*6.2525364978))

func take_damage(val):
	if !can_take_damage or !alive: return
	#val -= 6
	
	$Hurt.play(0.155)
	
	var dp = ((defensive_power+randf_range(0, extra_defense_power)) if is_defending else 0)
	
	if val < dp: 
		dp = defensive_power - (val/2)
	
	current_health -= val - dp
	
	#$AnimationTree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT)
	
	if !tween.is_running():
		tween.kill()
		tween = create_tween()
		
		tween.tween_property(self, "scale", Vector3.ONE * 0.9, 0.165)
		tween.tween_property(self, "scale", Vector3.ONE * 1.0, 0.165)
		tween.play()
	
	#$AnimationTree.set("parameters/Hit/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	get_tree().current_scene.update_boss_health(current_health)
	
	if current_health <= 0:
		alive = false
		$AnimationTree.set("parameters/Die/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		get_parent().complete_fight()
		return
	elif current_health <= health/2 and speed != speed_2:
		$AnimationTree.set("parameters/Stages/transition_request", "stage_2")
		speed = speed_2
		if is_defending and can_defend:
			is_on_defend = false
			$AnimationTree.set("parameters/State/transition_request", "attack")
			is_defending = false

func attack():
	if is_on_defend: return
	
	if automatically_trigger_attack: trigger_hit()
	
	$AnimationTree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	can_attack = false
	await get_tree().create_timer(attack_cooldown+randf_range(0, randomized_attack_cooldown)).timeout
	can_attack = true
	can_defend = true

func trigger_hit():
	if is_on_defend: return
	
	await get_tree().create_timer(trigger_attack_cooldown).timeout
	
	if is_player_in and $PlayerDetector.is_colliding():
		UserGlobal.PLAYER.take_damage(randi_range(min_attack_damage, max_attack_damage))

func start_defending():
	can_defend = false
	
	await get_tree().create_timer(randf_range(defense_delay, defense_delay*1.4)).timeout
	if !is_on_defend or $PlayerDetector.is_colliding():
		is_on_defend = false
		can_defend = true
		is_defending = false
		return
	
	$AnimationTree.set("parameters/State/transition_request", "defensize")
	
	is_defending = true
	
	await get_tree().create_timer(defense_cooldown+1.0).timeout
	can_defend = true
