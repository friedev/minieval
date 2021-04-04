extends Control

var tilemap
var game_over = false
var freeplay = false

func _unhandled_input(event):
	tilemap = get_node(@"/root/Root/TileMap")
	if tilemap.get_turns_remaining() == 0 && Global.game_mode == 0 && game_over == false:
		end_game()
	elif Global.timer_over == true && Global.game_mode == 1:
		end_game()

func end_game():
	if Global.game_mode == 1:
		var undo_button = get_node("UndoButton")
		undo_button.set_disabled(true)
	game_over = true
	tilemap._clear_preview()
	tilemap._update_labels()
	get_tree().paused = true
	update_labels()
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	var timer = get_node(@"/root/Root/UITextLayer/Timer/timeLeftLabel")
	visible = true
	palette.visible = false
	timer.visible = false
	for child in ui_text_layer.get_children():
		if child.name != "Timer":
				child.visible = false

func update_labels():
	var currencyCount = str(tilemap.currency)
	if(currencyCount == "69"):
		currencyCount = "69 (nice.)"
	get_node("Stats/CurrencyCountLabel").text = currencyCount
	var VPCount = str(tilemap.vp)
	if(VPCount == "69"):
		VPCount = "69 (nice.)"
	get_node("Stats/VPCountLabel").text = VPCount
	var BuildingCount = str(tilemap.buildings_placed)
	if(BuildingCount == "69"):
		BuildingCount = "69 (nice.)"
	get_node("Stats/BuildingsPlacedCountLabel").text = BuildingCount


func _on_FreeplayButton_pressed():
	game_over = false
	Global.game_mode = 2
	get_tree().paused = false
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
	visible = false
	palette.visible = true
	for child in ui_text_layer.get_children():
		if child.name != "Timer":
			child.visible = true
	turn_label.visible = false


func _on_UndoButton_pressed():
	get_tree().paused = false
	var undo = InputEventAction.new()
	undo.action = "undo"
	undo.pressed = true
	Input.parse_input_event(undo)
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
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
