extends Control

onready var tilemap = get_node(@"/root/Root/TileMap")
onready var palette = get_node(@"/root/Root/Palette/Menu")
onready var ui_text_layer = get_node(@"/root/Root/UITextLayer")
onready var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
onready var timer = get_node(@"/root/Root/UITextLayer/Timer/timeLeftLabel")
var game_over = false
var freeplay = false
onready var gameMusic = get_node(@"/root/Root/BackgroundMusic")

func _unhandled_input(event):
	if tilemap.get_turns_remaining() == 0 && Global.game_mode == 0 && game_over == false:
		end_game()
	elif Global.timer_over == true && Global.game_mode == 1:
		end_game()

func end_game():
	if gameMusic.playing:
		gameMusic.playing = false
	if not $EndGameMusic.playing:
		$EndGameMusic.playing = true
	if Global.game_mode == 1:
		var undo_button = $UndoButton
		undo_button.set_disabled(true)
	game_over = true
	tilemap._clear_preview()
	tilemap._update_labels()
	get_tree().paused = true
	update_labels()
	visible = true
	palette.visible = false
	timer.visible = false
	for child in ui_text_layer.get_children():
		if child.name != "Timer":
				child.visible = false

func update_labels():
	var currencyCount = str(tilemap.currency)
	if currencyCount == "69":
		currencyCount = "69 (nice.)"
	$Stats/CurrencyCountLabel.text = currencyCount
	var VPCount = str(tilemap.vp)
	if VPCount == "69":
		VPCount = "69 (nice.)"
	$Stats/VPCountLabel.text = VPCount
	var BuildingCount = str(tilemap.buildings_placed)
	if BuildingCount == "69":
		BuildingCount = "69 (nice.)"
	$Stats/BuildingsPlacedCountLabel.text = BuildingCount


func _on_FreeplayButton_pressed():
	gameMusic.playing = true
	$EndGameMusic.playing = false
	game_over = false
	Global.game_mode = 2
	get_tree().paused = false
	visible = false
	palette.visible = true
	for child in ui_text_layer.get_children():
		if child.name != "Timer":
			child.visible = true
	turn_label.visible = false


func _on_UndoButton_pressed():
	gameMusic.playing = true
	$EndGameMusic.playing = false
	get_tree().paused = false
	var undo = InputEventAction.new()
	undo.action = "undo"
	undo.pressed = true
	Input.parse_input_event(undo)
	visible = false
	palette.visible = true
	for child in ui_text_layer.get_children():
		if child.name != "Timer":
			child.visible = true
	game_over = false


func _on_TitleScreenButton_pressed():
	game_over = false
	get_tree().paused = false
	get_tree().change_scene("res://Interface/Title.tscn")


func _on_ExitGameButton_pressed():
	get_tree().quit()