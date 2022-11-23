extends Control

const title_scene := "res://scenes/Title.tscn"

onready var main := self.get_node("/root/Main")
onready var tilemap := self.main.find_node("TileMap")
onready var palette := self.main.find_node("Palette")
onready var turn_label := self.main.find_node("TurnLabel")
onready var game_music := self.main.find_node("BackgroundMusic")


func end_game() -> void:
	if game_music.playing:
		game_music.playing = false
	if not $EndGameMusic.playing:
		$EndGameMusic.playing = true
	visible = true
	palette.visible = false
	turn_label.visible = false
	tilemap.in_menu = true


func _on_FreeplayButton_pressed() -> void:
	game_music.playing = true
	$EndGameMusic.playing = false
	Global.endless = true
	visible = false
	palette.visible = true
	tilemap.in_menu = false


func _on_UndoButton_pressed() -> void:
	game_music.playing = true
	$EndGameMusic.playing = false
	tilemap.undo()
	visible = false
	palette.visible = true
	turn_label.visible = true
	tilemap.in_menu = false


func _on_TitleScreenButton_pressed():
	get_tree().change_scene(title_scene)
