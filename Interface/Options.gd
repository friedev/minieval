extends Control

onready var camera = get_node("OptionsHeader/CameraSpeedValue")
onready var volume = get_node("OptionsHeader/VolumeValue")
onready var sfx_value = get_node("OptionsHeader/SFXValue")
onready var music_value = get_node("OptionsHeader/MusicValue")
onready var sfx_slider = get_node("OptionsHeader/SFXVolume")
onready var game_slider = get_node("OptionsHeader/GameVolume")
onready var advanced_header = get_node("Advanced Header")
onready var options_header = get_node("OptionsHeader")

func _input(event):
	if Global.last_scene != "res://Interface/Title.tscn":
		if event.is_action_pressed("pause"):
			visible = false
			options_header.visible = true

func _on_ReturnToGame_pressed():
	var title_ui = get_node(@"/root/Control/TitleUI/Control")
	visible = false
	if Global.last_scene == "res://Interface/Title.tscn":
		title_ui.visible = true

func _on_CameraSpeed_value_changed(value):
	var value_text = get_node("OptionsHeader/CameraSpeedValue")
	Global.speed = value
	value_text.text = str(value)

func _on_Options_ready():
	camera.text = str(Global.speed)
	music_value.text = str(Global.music_volume)
	sfx_value.text = str(Global.sfx_volume)
	sfx_slider.value = Global.sfx_volume
	game_slider.value = Global.music_volume

func _on_GameVolume_value_changed(value):
	Global.music_volume = value
	var value_text = get_node("OptionsHeader/MusicValue")
	value_text.text = str(value)
	if value == 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), -80)
	elif value == 1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), -40)
	elif value == 2:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), -20)
	elif value == 3:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), -10)
	elif value == 4:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), -5)
	elif value == 5:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), 0)
	elif value == 6:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), 2)
	elif value == 7:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), 4)
	elif value == 8:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), 6)
	elif value == 9:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), 8)
	elif value == 10:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Background music"), 9)

func _on_SFXVolume_value_changed(value):
	Global.sfx_volume = value
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), value)
	var value_text = get_node("OptionsHeader/SFXValue")
	value_text.text = str(value)
	if value == 0:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), -80)
	elif value == 1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), -40)
	elif value == 2:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), -20)
	elif value == 3:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), -10)
	elif value == 4:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), -5)
	elif value == 5:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), 0)
	elif value == 6:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), 3)
	elif value == 7:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), 6)
	elif value == 8:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), 9)
	elif value == 9:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), 12)
	elif value == 10:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sound Effects"), 15)
