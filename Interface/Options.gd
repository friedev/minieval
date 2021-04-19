extends Control

onready var title_ui = get_node(@"/root/Control/TitleUI/Control")
onready var title_scene = "res://Interface/Title.tscn"

onready var camera = $OptionsHeader/CameraSpeedValue
onready var volume = $OptionsHeader/VolumeValue
onready var sfx_value = $OptionsHeader/SFXValue
onready var music_value = $OptionsHeader/MusicValue
onready var sfx_slider = $OptionsHeader/SFXVolume
onready var game_slider = $OptionsHeader/GameVolume
onready var options_header = $OptionsHeader

onready var background_music = AudioServer.get_bus_index("Background music")
onready var sound_effects = AudioServer.get_bus_index("Sound Effects")

var volume_values = [-80, -40, -20, -10, -5, 0, 2, 4, 6, 8, 9]

func _input(event):
	if Global.last_scene != title_scene:
		if event.is_action_pressed("pause"):
			visible = false
			options_header.visible = true

func _on_ReturnToGame_pressed():
	visible = false
	if Global.last_scene == title_scene:
		title_ui.visible = true

func _on_CameraSpeed_value_changed(value):
	Global.speed = value

func _on_Options_ready():
	sfx_slider.value = Global.sfx_volume
	game_slider.value = Global.music_volume

func _on_GameVolume_value_changed(value):
	Global.music_volume = value
	AudioServer.set_bus_volume_db(background_music, volume_values[value])

func _on_SFXVolume_value_changed(value):
	Global.sfx_volume = value
	AudioServer.set_bus_volume_db(sound_effects, volume_values[value])
