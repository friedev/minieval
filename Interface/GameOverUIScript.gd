extends Control

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Main.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_TitleScreenButton_pressed():
	get_tree().change_scene("res://Interface/Title.tscn")
