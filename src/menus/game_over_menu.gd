class_name GameOverMenu
extends Menu

signal last_move_undone

@export_file("*.tscn") var title_scene: String

@export_group("External Nodes")
@export var palette: Palette
@export var game_music: AudioStreamPlayer

@export_group("Internal Nodes")
@export var end_game_music: OffsetAudio


func open(previous: Menu = null) -> void:
	if game_music.playing:
		game_music.playing = false
	if not end_game_music.playing:
		end_game_music.play(end_game_music.from_position)
	palette.visible = false
	super.open(previous)


func close() -> void:
	super.close()
	game_music.playing = true
	end_game_music.playing = false
	palette.visible = true


func _on_freeplay_button_pressed() -> void:
	close()
	Global.endless = true


func _on_undo_button_pressed() -> void:
	close()
	last_move_undone.emit()


func _on_main_menu_button_pressed() -> void:
	Global.change_scene_to_file(title_scene)


func _on_city_map_game_over() -> void:
	open()
