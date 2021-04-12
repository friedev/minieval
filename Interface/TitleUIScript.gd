extends Control

func _ready():
	TitleMusic.playing = true

func _on_NewGameButton_pressed():
	get_tree().change_scene("res://Interface/NewGameUI.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	var options_menu = get_node(@"/root/Control/OptionsMenu/Options")
	options_menu.visible = true
	visible = false
	Global.last_scene = "res://Interface/Title.tscn"
