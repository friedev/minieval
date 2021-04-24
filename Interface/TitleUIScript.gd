extends Control

onready var options_menu = get_node(@"/root/Control/OptionsMenu/Options")

func _ready():
	if not TitleMusic.playing:
		TitleMusic.play()

func _on_PlayButton_pressed():
	Global.reset_game_parameters()
	get_tree().change_scene("res://Main.tscn")

func _on_CustomGameButton_pressed():
	get_tree().change_scene("res://Interface/CustomGameUI.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	options_menu.visible = true
	visible = false
	Global.last_scene = "res://Interface/Title.tscn"
