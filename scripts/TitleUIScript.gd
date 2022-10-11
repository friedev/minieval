extends Control

onready var options_menu := get_node("/root/Control/OptionsMenu/Options")

const title_scene := "res://scenes/Title.tscn"
const main_scene := "res://scenes/Main.tscn"
const custom_game_scene :="res://scenes/CustomGameUI.tscn"

func _ready() -> void:
	if not TitleMusic.playing:
		TitleMusic.play()
	$Menu/ExitGameButton.disabled = OS.get_name() == "HTML5"


func _on_PlayButton_pressed() -> void:
	Global.reset_game_parameters()
	get_tree().change_scene(main_scene)


func _on_CustomGameButton_pressed() -> void:
	get_tree().change_scene(custom_game_scene)


func _on_ExitGameButton_pressed() -> void:
	get_tree().quit()


func _on_OptionsButton_pressed() -> void:
	Global.last_scene = title_scene
	visible = false
	options_menu.visible = true
