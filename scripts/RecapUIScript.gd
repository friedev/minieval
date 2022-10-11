extends Control


onready var tilemap := get_node("/root/Root/TileMap")
onready var palette := get_node("/root/Root/Palette/Menu")
onready var timer := get_node("/root/Root/UITextLayer/Timer/timeLeftLabel")
onready var turn_label := get_node("/root/Root/UITextLayer/TurnLabel")
onready var game_music := get_node("/root/Root/BackgroundMusic")
const title_scene := "res://scenes/Title.tscn"

var freeplay := false

func _process(delta: float) -> void:
	if not freeplay and (
		(
			tilemap.get_turns_remaining() == 0
			and Global.game_mode == Global.TURN_MODE
		) or (
			Global.timer_over == true
			and Global.game_mode == Global.TIME_MODE
		)
	):
		end_game()


func end_game() -> void:
	if game_music.playing:
		game_music.playing = false
	if not $EndGameMusic.playing:
		$EndGameMusic.playing = true
	if Global.game_mode == Global.TIME_MODE:
		$UndoButton.set_disabled(true)
	tilemap._clear_preview()
	tilemap._update_labels()
	visible = true
	palette.visible = false
	timer.visible = false
	turn_label.visible = false


func _on_FreeplayButton_pressed() -> void:
	game_music.playing = true
	$EndGameMusic.playing = false
	Global.game_mode = Global.ENDLESS_MODE
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
	timer.visible = true


func _on_TitleScreenButton_pressed():
	get_tree().change_scene(title_scene)
