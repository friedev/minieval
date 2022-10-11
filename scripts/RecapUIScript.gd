extends Control


onready var tilemap := get_node("/root/Root/TileMap")
onready var palette := get_node("/root/Root/Palette/Menu")
onready var turn_label := get_node("/root/Root/UITextLayer/TurnLabel")
onready var game_music := get_node("/root/Root/BackgroundMusic")
const title_scene := "res://scenes/Title.tscn"

func _process(delta: float) -> void:
	if not Global.endless and tilemap.get_turns_remaining() == 0:
		end_game()


func end_game() -> void:
	if game_music.playing:
		game_music.playing = false
	if not $EndGameMusic.playing:
		$EndGameMusic.playing = true
	tilemap._clear_preview()
	tilemap._update_labels()
	visible = true
	palette.visible = false
	turn_label.visible = false


func _on_FreeplayButton_pressed() -> void:
	game_music.playing = true
	$EndGameMusic.playing = false
	Global.endless = true
	visible = false
	palette.visible = true


func _on_UndoButton_pressed() -> void:
	game_music.playing = true
	$EndGameMusic.playing = false

	var undo := InputEventAction.new()
	undo.action = "undo"
	undo.pressed = true
	Input.parse_input_event(undo)

	visible = false
	palette.visible = true
	turn_label.visible = true


func _on_TitleScreenButton_pressed():
	get_tree().change_scene(title_scene)
