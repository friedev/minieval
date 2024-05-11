class_name OptionsMenu extends Control

signal menu_closed

@export var music_bus_name: StringName
@export var sound_bus_name: StringName

@export_group("External Nodes")
@export var city_map: CityMap
@export var black_overlay: ColorRect

@export_group("Internal Nodes")
@export var camera_speed_slider: Slider
@export var music_volume_slider: Slider
@export var sound_volume_slider: Slider

@onready var music_bus_index := AudioServer.get_bus_index(self.music_bus_name)
@onready var sound_bus_index := AudioServer.get_bus_index(self.sound_bus_name)


# TODO use linear_to_db
const VOLUME_VALUES := [-80, -40, -20, -10, -5, 0, 2, 4, 6, 8, 9]


func _ready() -> void:
	self.camera_speed_slider.value = Global.speed
	self.sound_volume_slider.value = Global.sound_volume
	self.music_volume_slider.value = Global.music_volume


func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause"):
		self.hide()
		self.menu_closed.emit()


func _on_title_ui_options_menu_opened() -> void:
	self.show()


func _on_camera_speed_slider_value_changed(value: float) -> void:
	Global.speed = value


func _on_sound_volume_slider_value_changed(value: float) -> void:
	Global.sound_volume = value
	AudioServer.set_bus_volume_db(self.sound_bus_index, self.VOLUME_VALUES[value])


func _on_music_volume_slider_value_changed(value: float) -> void:
	Global.music_volume = value
	AudioServer.set_bus_volume_db(self.music_bus_index, self.VOLUME_VALUES[value])


func _on_fullscreen_check_box_toggled(button_pressed: bool) -> void:
	self.get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (button_pressed) else Window.MODE_WINDOWED


func _on_back_button_pressed() -> void:
	self.hide()
	self.menu_closed.emit()


func _on_visibility_changed() -> void:
	if self.city_map != null:
		self.city_map.in_menu = self.visible
	if self.black_overlay != null:
		self.black_overlay.visible = self.visible
