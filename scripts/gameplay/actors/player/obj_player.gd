extends CharacterBody3D
#class_name Player

@onready var mesh: Node3D = $Model
@onready var camera_controller: Node3D = $CameraController
@onready var aim: Marker3D = $CameraController/Pivot/Aim
@onready var camera_animations: AnimationPlayer = $CameraController/CameraAnimations

enum GameplayMode {
	ThirdPerson,
	TopDown,
	Platform
}

var move_dir = Vector3.ZERO
var motion = Vector3.ZERO

@export_group("Player Config")
@export var player_health:int = 80
@export var player_mana:int = 80
@export var SPEED_WALK:int = 4
@export var SPEED_RUN:int = 6

var SPEED_ACCEL = 30

@export_subgroup("Player Debug")
@export var CAN_MOVE:bool = true
@export var CAN_RUN:bool = true
@export var GRAVITY_ON:bool = true

var is_aiming:bool = false
var is_defending:bool = false
var is_attacking:bool = false
var is_dodging:bool = false

var dodge_timer:float = 0
var dodge_duration:int = 1

var enemy_focus = null

var is_jumped = false
var jumping = false

var is_attacked = false
var combo = 0

var is_rolling = false
var rolling_amount = 0.0

var tween = null
var tween2 = null

var main_attack_delay = [0.5/1.5, 1.0/1.2, 2.0, 1.0]
var attack_durations = [3.542, 1.3, 0.9/1.5 + 1.0, 1.15/1.2 + 0.7]

var is_consuming = false

var starter_rotation_y = 0

var aiming_amount = 0.0

func _ready() -> void:
	$AnimationTree.active = true
	
	$Model/AnimationPlayer.speed_scale = 0.1
	starter_rotation_y = rotation.y
	mesh.rotation.y = rotation.y
	rotation.y = 0
	
	UserGlobal.PLAYER = self
	UserGlobal.CircleMarked.append($model/BossCombatSystem/CIRCLE_STATE/MarkerRight)
	UserGlobal.CircleMarked.append($model/BossCombatSystem/CIRCLE_STATE/MarkerLeft)
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	$UI/RadialMenu.set_items([])
	$UI/RadialMenu.add_icon_item(preload("res://assets/textures/hammer_icon.png"), "2D", 1)
	$UI/RadialMenu.add_icon_item(preload("res://assets/textures/sword_icon.png"), "2D", 1)
	$UI/RadialMenu.add_icon_item(preload("res://assets/textures/heal_icon.webp"), "2D", 1)
	$UI/RadialMenu.add_icon_item(null, "2D", 1)
	$UI/RadialMenu.add_icon_item(null, "2D", 1)
	#$UI/RadialMenu.show()
	#$UI/RadialMenu.add_icon_item(POINTS_TEXTURE, "Points", 2)
	#$UI/RadialMenu.add_icon_item(GRID_TEXTURE, "Grid", 3)
	#$UI/RadialMenu.add_icon_item(SCALE_TEXTURE, "Scale", 4)
	
	#update_health()
	#update_mana()
	#$Model/metarig/Skeleton3D/SpineIK.start()

func _input(event: InputEvent) -> void:
	if camera_controller.gameplay_index == 0:
		if event.is_action_pressed("action_aiming"):
			if not is_aiming:
				is_aiming = true
				camera_animations.play("player_aiming")
		if event.is_action_released("action_aiming"):
			if is_aiming:
				is_aiming = false
				camera_animations.play_backwards("player_aiming")

func heal():
	player_health += 20
	update_health()
	update_bars()
	
	$Model/metarig_001/Skeleton3D/Hand/Weapons.hide()
	
	is_consuming = true
	await get_tree().create_timer(0.9).timeout
	$Healing.play()
	await get_tree().create_timer(3.125-0.9).timeout
	is_consuming = false
	
	$Model/metarig_001/Skeleton3D/Hand/Weapons.show()

func heal_mana():
	player_mana += 20
	update_mana()
	
	$Model/metarig_001/Skeleton3D/Hand/Weapons.hide()
	
	is_consuming = true
	await get_tree().create_timer(4.58).timeout
	is_consuming = false
	
	$Model/metarig_001/Skeleton3D/Hand/Weapons.show()

func update_health():
	await get_tree().create_timer(0.5).timeout
	update_bars()
	
	if tween: tween.kill()
	
	tween = get_tree().create_tween()
	tween.tween_property($SubViewport/HealthBar, "value", player_health, 1.0)
	tween.play()

func update_mana():
	await get_tree().create_timer(1.0).timeout
	update_bars()
	
	if tween: tween.kill()
	
	tween = create_tween()
	tween.tween_property($SubViewport/ManaBar, "value", player_mana, 1.0)
	tween.play()

func update_bars():
	if tween2: tween2.kill()
	
	tween2 = create_tween()
	tween2.tween_property($Model/metarig_001/Skeleton3D/BoneAttachment3D/UI2, "transparency", 0.0, 0.7)
	await get_tree().create_timer(4.0).timeout
	tween2.kill()
	tween2 = create_tween()
	tween2.tween_property($Model/metarig_001/Skeleton3D/BoneAttachment3D/UI2, "transparency", 1.0, 0.7)
	#tween2.play()

func _physics_process(delta: float) -> void:
	$Model/metarig_001/Skeleton3D/SpineIK.influence = lerp($Model/metarig_001/Skeleton3D/SpineIK.influence, aiming_amount, delta*8.0)
	$AnimationTree.set("parameters/GunHolding/blend_amount", lerp($Model/metarig_001/Skeleton3D/SpineIK.influence, aiming_amount, delta*8.0))
	
	movement_controller(delta)
	
	match camera_controller.gameplay_index: # Gameplay Type Controller
		GameplayMode.ThirdPerson:
			CAN_MOVE = true
			$StateMachine/ThirdPerson.start(delta)
		
	# Dodge mechanics timer
	if is_dodging:
		dodge_timer += 1 * delta
		if dodge_timer > dodge_duration:
			is_dodging  = false
			dodge_timer = 0
	
	handle_animations(delta)
	
	if !is_on_floor() and GRAVITY_ON:
		velocity.y -= (9.8) * delta
	
	if is_jumped and is_on_floor():
		is_jumped = false
		velocity.y = 5.5
	
	if $InteractionDetector.is_colliding():
		if Input.is_action_just_pressed("action_interact"):
			if $InteractionDetector.get_collider(0).has_method("interact"): $InteractionDetector.get_collider(0).interact()
	
	if Input.is_action_just_pressed("3"):
		for i in $UI/Inventory/InventoryMain.get_children():
			if i.item == "HealthPotion":
				$AnimationTree.set("parameters/ConsumeType/transition_request", "potion")
				$AnimationTree.set("parameters/Consume/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				i.remove_item()
				heal()
				break
	elif Input.is_action_just_pressed("4"):
		for i in $UI/Inventory/InventoryMain.get_children():
			if i.item == "Book":
				$AnimationTree.set("parameters/ConsumeType/transition_request", "book")
				$AnimationTree.set("parameters/Consume/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
				i.remove_item()
				
				heal_mana()
				break
	
	$Model/metarig_001/SpineIKTarget.rotation.x = -$CameraController/Pivot.rotation.x
	#$Model/metarig_001/SpineIKTarget.rotation.y = -0.5
	
	
	aiming_amount = 1.0 if Input.is_action_pressed("action_aiming") else 0.0
	
	if Input.is_action_just_pressed("action_roll") and !is_rolling:
		is_rolling = true
		rolling_amount = 1.0
		$AnimationTree.set("parameters/IsRoll/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
		
		$CollisionShape3D.disabled = true
		$CollisionShape3D2.disabled = false
	
	if Input.is_action_just_pressed("toggle_inventory") and get_tree().current_scene.boss_fight:
		return
		$UI/RadialMenu.open_menu(Vector2(810, 428.868))
	# Health bar
	#$UI/HealthBar.value = player_health
	#$UI/ManaBar.value = player_mana


# //////////////////////////////////////////////////////////
# //////////////////// CONTROLLERS /////////////////////////
# //////////////////////////////////////////////////////////
func movement_controller(delta:float):
	if CAN_MOVE:
		if Input.get_action_strength("action_run") && Input.get_action_strength("m_forward") && CAN_RUN && not is_defending or get_tree().current_scene.boss_fight:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_RUN * (1.3 if get_tree().current_scene.boss_fight else 1), SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_RUN * (1.3 if get_tree().current_scene.boss_fight else 1), SPEED_ACCEL * delta)
			
			$AnimationTree.set('parameters/RunningType/transition_request', "sprinting" if get_tree().current_scene.boss_fight and Input.is_action_pressed("action_run") else "running")
		else:
			velocity.x = lerp(velocity.x, move_dir.x * SPEED_WALK * (1.1 if get_tree().current_scene.boss_fight else 1), SPEED_ACCEL * delta)
			velocity.z = lerp(velocity.z, move_dir.z * SPEED_WALK * (1.1 if get_tree().current_scene.boss_fight else 1), SPEED_ACCEL * delta)
		
		if is_defending:
			SPEED_WALK = 2
		else:
			SPEED_WALK = 4
		
		if jumping or is_attacked or $AnimationTree.get("parameters/Consume/active") == true or is_consuming:
			velocity.x = 0
			velocity.z = 0
		
		if rolling_amount > 0.0:
			rolling_amount -= delta/1.45
			velocity = -$Model.global_transform.basis.z*9.0 * 1.1
			
			if rolling_amount < 0.0:
				is_rolling = false
				$CollisionShape3D.disabled = false
				$CollisionShape3D2.disabled = true
		
		move_and_slide()
		
		if Input.get_vector("left", "right", "m_backward", "m_forward") and !Input.is_action_pressed("action_aiming") and !is_attacked:
			$Model/metarig_001/Skeleton3D/SpineIK.start()
			
			mesh.rotation.z = lerp_angle(mesh.rotation.z, atan2(-velocity.x, -velocity.z) - mesh.rotation.y, delta*4.0)
			
			if Input.is_action_pressed("sprint"):
				mesh.rotation.z = clampf(mesh.rotation.z, deg_to_rad(-11), deg_to_rad(11))
			else:
				mesh.rotation.z = clampf(mesh.rotation.z, deg_to_rad(-0), deg_to_rad(0))
		
		else:
			mesh.rotation.z = lerp_angle(mesh.rotation.z, 0.0, delta*7.0)
		
		if Input.get_vector("left", "right", "m_backward", "m_forward") and !is_rolling:
			if !$Footstep.playing: $Footstep.play()
			if Input.is_action_pressed("sprint"):
				$Footstep.pitch_scale = 1.32
			else:
				$Footstep.pitch_scale = 0.85
		else:
			if $Footstep.playing: $Footstep.stop()

# //////////////////////////////////////////////////////////
# /////////////////// MECHANICS ///////////////////////
# //////////////////////////////////////////////////////////

func player_damage(num:int) -> void:
	player_health -= num


func handle_animations(delta):
	var input_dir = Input.get_vector("left", "right", "m_backward", "m_forward")
	
	#if input_dir:
	$AnimationTree.set("parameters/MovementDir/blend_amount", lerpf($AnimationTree.get("parameters/MovementDir/blend_amount"), 0.0 if Input.is_action_pressed("action_aiming") else ((1.0 if (Input.is_action_pressed("action_run") or get_tree().current_scene.boss_fight) else 0.0) if input_dir else -1.0), delta*5.0))
	if !is_rolling: $AnimationTree.set("parameters/InAir/blend_amount", lerpf($AnimationTree.get("parameters/InAir/blend_amount"), 0.0 if is_on_floor() else 1.0, delta*7.0))
	$AnimationTree.set("parameters/Walk/blend_position", lerp($AnimationTree.get("parameters/Walk/blend_position"), Vector2(0.0, 1.0) if !Input.is_action_pressed("action_aiming") else input_dir.round(), delta*10.0))
	
	if Input.is_action_just_pressed("jump"):
		jumping = true
		$AnimationTree.set("parameters/Jump/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
	
	if Input.is_action_just_pressed("action_attack") and !is_attacked and $WeaponSwitcher.get_current_weapon_type() != "Melee" and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and not $WeaponSwitcher.get_current_weapon_type() == "Melee":
		attack()
		$AnimationTree.set("parameters/AttackStyle/transition_request", $WeaponSwitcher.get_current_weapon_type() + str(combo+1))
		$AnimationTree.set("parameters/Attack/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)

func jump():
	is_jumped = true
	jumping = false

func attack():
	if is_attacked: return
	#hit_enemy()
	is_attacked = true
	await get_tree().create_timer(attack_durations[$Model/metarig_001/Skeleton3D/Hand/Weapons.get_node($WeaponSwitcher.get_current_weapon_type()).get_index()*2 + combo]).timeout
	is_attacked = false
	combo += 1
	
	if combo > 1: combo = 0
	make_bye()
	#await get_tree().create_timer(2.0).timeout
	#if !is_attacked: combo = 0

func make_bye():
	return
	await get_tree().create_timer(0.5).timeohiut
	combo = 0

func pick_item(it):
	$UI/Inventory.add_item(it)

func hit_enemy():
	$Attack.play()
	#await get_tree().create_timer(main_attack_delay[$WeaponSwitcher.current_weapon_index*2 + combo])
	
	if $Model/EnemyDetector.is_colliding():
		for i in $Model/EnemyDetector.get_collision_count():
			var b = $Model/EnemyDetector.get_collider(i)
			if b.is_in_group("Boss"):
				b.take_damage(UserGlobal.weapon_data[$WeaponSwitcher.get_current_weapon_type()][combo])

func take_damage(d):
	player_health -= d
	update_health()
	
	$AnimationTree.set('parameters/Hit/request', AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)
