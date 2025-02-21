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
				$WorldEnvironment.environment = preload("res://ultra_graphics.tres")
		
		graphics_type = new_type
