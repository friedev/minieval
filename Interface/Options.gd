extends Control

onready var title_ui_path = @"/root/Control/TitleUI/Control"
onready var title_scene = "res://Interface/Title.tscn"

onready var camera_speed = $CameraSpeed
onready var music_volume = $GameVolume
onready var sfx_volume = $SFXVolume

onready var background_music = AudioServer.get_bus_index("Background music")
onready var sound_effects = AudioServer.get_bus_index("Sound Effects")

const VOLUME_VALUES = [-80, -40, -20, -10, -5, 0, 2, 4, 6, 8, 9]

func _on_Options_ready():
	camera_speed.value = Global.speed
	sfx_volume.value = Global.sfx_volume
	music_volume.value = Global.music_volume

func _input(event):
	if Global.last_scene != title_scene:
		if event.is_action_pressed("pause"):
			visible = false

func _on_ReturnToGame_pressed():
	visible = false
	if Global.last_scene == title_scene:
		get_node(title_ui_path).visible = true

func _on_CameraSpeed_value_changed(value):
	Global.speed = value

func _on_GameVolume_value_changed(value):
	Global.music_volume = value
	AudioServer.set_bus_volume_db(background_music, VOLUME_VALUES[value])

func _on_SFXVolume_value_changed(value):
	Global.sfx_volume = value
	AudioServer.set_bus_volume_db(sound_effects, VOLUME_VALUES[value])

func _on_Options_visibility_changed():
	$BlackOverlay.visible = Global.last_scene != title_scene
