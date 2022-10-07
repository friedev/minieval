extends Control

onready var options_menu = get_node(@"/root/Control/OptionsMenu/Options")

func _ready():
	if not TitleMusic.playing:
		TitleMusic.play()
	$Menu/ExitGameButton.disabled = OS.get_name() == "HTML5"

func _on_PlayButton_pressed():
	Global.reset_game_parameters()
	get_tree().change_scene("res://scenes/Main.tscn")

func _on_CustomGameButton_pressed():
	get_tree().change_scene("res://scenes/CustomGameUI.tscn")

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_OptionsButton_pressed():
	Global.last_scene = "res://scenes/Title.tscn"
	visible = false
	options_menu.visible = true
