extends Popup

export var is_title := false

var title: Node
var title_ui: Node
var main: Node
var black_overlay: Node
var tilemap: Node

onready var camera_speed := self.find_node("CameraSpeedSlider")
onready var music_volume := self.find_node("MusicVolumeSlider")
onready var sound_volume := self.find_node("SoundVolumeSlider")

onready var music_bus := AudioServer.get_bus_index("Music")
onready var sound_bus := AudioServer.get_bus_index("Sound")


const VOLUME_VALUES := [-80, -40, -20, -10, -5, 0, 2, 4, 6, 8, 9]


func _ready() -> void:
	if self.is_title:
		self.title = self.get_node("/root/Title")
		self.title_ui = self.title.find_node("TitleUI")
	else:
		self.main = self.get_node("/root/Main")
		self.black_overlay = self.main.find_node("BlackOverlay")
		self.tilemap = self.main.find_node("TileMap")
	camera_speed.value = Global.speed
	sound_volume.value = Global.sound_volume
	music_volume.value = Global.music_volume


func _go_back() -> void:
	self.hide()
	if self.is_title:
		self.title_ui.popup()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		self._go_back()


func _on_ReturnToGame_pressed() -> void:
	self._go_back()


func _on_CameraSpeed_value_changed(value: float) -> void:
	Global.speed = value


func _on_GameVolume_value_changed(value: int) -> void:
	Global.music_volume = value
	AudioServer.set_bus_volume_db(music_bus, VOLUME_VALUES[value])


func _on_SFXVolume_value_changed(value: int) -> void:
	Global.sound_volume = value
	AudioServer.set_bus_volume_db(sound_bus, VOLUME_VALUES[value])


func _on_Fullscreen_toggled(button_pressed: bool) -> void:
	OS.window_fullscreen = button_pressed


func _on_Options_visibility_changed():
	if not self.is_title:
		black_overlay.visible = self.visible
		self.tilemap.in_menu = self.visible
