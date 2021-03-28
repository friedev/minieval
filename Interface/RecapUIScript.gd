extends Control

var tilemap
var game_over = false
var freeplay = false

func _input(event):
	tilemap = get_node(@"/root/Root/TileMap")
	if tilemap.get_turn() == 50 && freeplay == false && game_over == false:
		end_game()

func end_game():
	game_over = true
	tilemap._clear_preview()
	get_tree().paused = true
	update_labels()
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	visible = true
	palette.visible = false
	for child in ui_text_layer.get_children():
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
	freeplay = true
	game_over = false
	get_tree().paused = false
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	visible = false
	palette.visible = true
	for child in ui_text_layer.get_children():
		child.visible = true


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
		child.visible = true
	game_over = false


func _on_TitleScreenButton_pressed():
	game_over = false
	get_tree().paused = false
	get_tree().change_scene("res://Interface/Title.tscn")


func _on_ExitGameButton_pressed():
	get_tree().quit()
