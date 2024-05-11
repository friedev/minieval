class_name Recap extends Control

@export var title_scene: PackedScene

@export_group("External Nodes")
@export var city_map: CityMap
@export var palette: Palette
@export var turn_label: Label
@export var game_music: AudioStreamPlayer

@export_group("Internal Nodes")
@export var end_game_music: AudioStreamPlayer


func end_game() -> void:
	if self.game_music.playing:
		self.game_music.playing = false
	if not self.end_game_music.playing:
		self.end_game_music.playing = true
	self.visible = true
	self.palette.visible = false
	self.turn_label.visible = false
	self.city_map.in_menu = true


func _on_FreeplayButton_pressed() -> void:
	self.game_music.playing = true
	self.end_game_music.playing = false
	Global.endless = true
	self.visible = false
	self.palette.visible = true
	self.city_map.in_menu = false


func _on_UndoButton_pressed() -> void:
	self.game_music.playing = true
	self.end_game_music.playing = false
	self.city_map.undo()
	self.visible = false
	self.palette.visible = true
	self.turn_label.visible = true
	self.city_map.in_menu = false


func _on_TitleScreenButton_pressed() -> void:
	self.get_tree().change_scene_to_packed(self.title_scene)
