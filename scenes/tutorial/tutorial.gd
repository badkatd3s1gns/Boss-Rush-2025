@tool
extends Node3D

@export_enum("Default", "Ultra") var graphics_type = "Default":
	set(new_type):
		match new_type:
			"Default":
				var env = Environment.new()
				env.background_mode = 2
				
				env.sky = Sky.new()
				env.sky.sky_material = ProceduralSkyMaterial.new()
				$WorldEnvironment.environment = env
			"Ultra":
				if !is_inside_tree(): return
				get_node("WorldEnvironment").environment = load("res://ultra_graphics.tres")
		
		graphics_type = new_type

var boss_fight = false

func show_dialog(body, ncp_name, duration):
	$HUD/Dialogues.show()
	$HUD/Dialogues/NCPLabel.text = str(ncp_name)
	$HUD/Dialogues/DialogueContainer/BodyLabel.text = ""
	
	var tween = create_tween()
	tween.tween_property($HUD/Dialogues/DialogueContainer/BodyLabel, "text", body, duration)
	await tween.finished
	$HUD/Dialogues/RadialMenu.init()
	#$HUD/Dialogues/DialogueContainer/BodyLabel.text = str(body)

func init_boss(bn, b):
	$HUD/BossHealthBar.show()
	$HUD/BossHealthBar/BossName.text = bn
	$HUD/BossHealthBar/ProgressBar.max_value = b
	$HUD/BossHealthBar.max_value = b
	$HUD/BossHealthBar/ProgressBar.value = b
	$HUD/BossHealthBar.value = b

func update_boss_health(h):
	$HUD/BossHealthBar/ProgressBar.value = h
	await get_tree().create_timer(0.8).timeout
	$HUD/BossHealthBar.value = h

func complete_fight():
	$HUD/BossHealthBar.hide()
	boss_fight = false
