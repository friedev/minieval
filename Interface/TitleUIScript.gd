extends Control

func _on_PlayButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	get_tree().change_scene("res://Interface/OptionsMenu.tscn")
