class_name OptionsMenu extends Menu

@export var music_bus_name: StringName
@export var sound_bus_name: StringName

@export_group("Internal Nodes")
@export var camera_speed_slider: Slider
@export var music_volume_slider: Slider
@export var sound_volume_slider: Slider

@onready var music_bus_index := AudioServer.get_bus_index(self.music_bus_name)
@onready var sound_bus_index := AudioServer.get_bus_index(self.sound_bus_name)


func _ready() -> void:
	self.camera_speed_slider.value = Global.speed
	self.sound_volume_slider.value = Global.sound_volume
	self.music_volume_slider.value = Global.music_volume


func _on_camera_speed_slider_value_changed(value: float) -> void:
	Global.speed = value


func _on_sound_volume_slider_value_changed(value: float) -> void:
	Global.sound_volume = value
	AudioServer.set_bus_volume_db(self.sound_bus_index, linear_to_db(Global.sound_volume))


func _on_music_volume_slider_value_changed(value: float) -> void:
	Global.music_volume = value
	AudioServer.set_bus_volume_db(self.music_bus_index, linear_to_db(Global.music_volume))


func _on_fullscreen_check_box_toggled(button_pressed: bool) -> void:
	self.get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (button_pressed) else Window.MODE_WINDOWED
