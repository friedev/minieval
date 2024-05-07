extends Control

const title_scene := "res://scenes/Title.tscn"

@onready var main := self.get_node("/root/Main")
@onready var tilemap := self.main.find_child("TileMap")
@onready var palette := self.main.find_child("Palette")
@onready var turn_label := self.main.find_child("TurnLabel")
@onready var game_music := self.main.find_child("BackgroundMusic")


func end_game() -> void:
	if self.game_music.playing:
		self.game_music.playing = false
	if not $EndGameMusic.playing:
		$EndGameMusic.playing = true
	self.visible = true
	self.palette.visible = false
	self.turn_label.visible = false
	self.tilemap.in_menu = true


func _on_FreeplayButton_pressed() -> void:
	self.game_music.playing = true
	$EndGameMusic.playing = false
	self.Global.endless = true
	self.visible = false
	self.palette.visible = true
	self.tilemap.in_menu = false


func _on_UndoButton_pressed() -> void:
	self.game_music.playing = true
	$EndGameMusic.playing = false
	self.tilemap.undo()
	self.visible = false
	self.palette.visible = true
	self.turn_label.visible = true
	self.tilemap.in_menu = false


func _on_TitleScreenButton_pressed() -> void:
	self.get_tree().change_scene_to_file(title_scene)
