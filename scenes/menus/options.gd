extends Container

signal menu_closed

@onready var main := self.get_node("/root/Main")

@onready var camera_speed := %CameraSpeedSlider
@onready var music_volume := %MusicVolumeSlider
@onready var sound_volume := %SoundVolumeSlider

@onready var music_bus := AudioServer.get_bus_index("Music")
@onready var sound_bus := AudioServer.get_bus_index("Sound")


# TODO use linear_to_db
const VOLUME_VALUES := [-80, -40, -20, -10, -5, 0, 2, 4, 6, 8, 9]


func _ready() -> void:
	self.camera_speed.value = Global.speed
	self.sound_volume.value = Global.sound_volume
	self.music_volume.value = Global.music_volume


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
	AudioServer.set_bus_volume_db(self.sound_bus, self.VOLUME_VALUES[value])


func _on_music_volume_slider_value_changed(value: float) -> void:
	Global.music_volume = value
	AudioServer.set_bus_volume_db(self.music_bus, self.VOLUME_VALUES[value])


func _on_fullscreen_check_box_toggled(button_pressed: bool) -> void:
	self.get_window().mode = Window.MODE_EXCLUSIVE_FULLSCREEN if (button_pressed) else Window.MODE_WINDOWED


func _on_back_button_pressed() -> void:
	self.hide()
	self.menu_closed.emit()


func _on_visibility_changed() -> void:
	if self.main != null:
		var tilemap := self.main.find_child("TileMap")
		var black_overlay := self.main.find_child("BlackOverlay")
		tilemap.in_menu = self.visible
		black_overlay.visible = self.visible
