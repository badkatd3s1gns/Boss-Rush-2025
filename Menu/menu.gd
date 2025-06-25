extends Node3D


func _on_exit_button_pressed() -> void:
	$HUD/FadeScreen/AnimationPlayer.play_backwards("fade_out")
	await $HUD/FadeScreen/AnimationPlayer.animation_finished
	get_tree().quit()
#7b1d64

func _on_new_button_pressed() -> void:
	$HUD/FadeScreen/AnimationPlayer.play_backwards("fade_out")
	await $HUD/FadeScreen/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/tutorial/tutorial.tscn")


func _on_option_button_pressed() -> void:
	$Options/AnimationPlayer.play("appear")


func _on_button_pressed() -> void:
	$Options/AnimationPlayer.play_backwards("appear")
