class_name GameOverMenu extends Menu

@export_file("*.tscn") var title_scene: String

@export_group("External Nodes")
@export var city_map: CityMap
@export var palette: Palette
@export var turn_label: Label
@export var game_music: AudioStreamPlayer

@export_group("Internal Nodes")
@export var end_game_music: AudioStreamPlayer


func open(previous: Menu = null) -> void:
	if self.game_music.playing:
		self.game_music.playing = false
	if not self.end_game_music.playing:
		self.end_game_music.playing = true
	self.palette.visible = false
	self.turn_label.visible = false
	super.open(previous)


func close() -> void:
	super.close()
	self.game_music.playing = true
	self.end_game_music.playing = false
	self.palette.visible = true
	self.turn_label.visible = true


func _on_freeplay_button_pressed() -> void:
	self.close()
	Global.endless = true
	self.turn_label.visible = false


func _on_undo_button_pressed() -> void:
	self.close()
	self.city_map.undo()


func _on_main_menu_button_pressed() -> void:
	Global.change_scene_to_file(self.title_scene)


func _on_city_map_game_over() -> void:
	self.open()
