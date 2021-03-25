extends Control

var tilemap
var game_over = false

func _input(event):
	tilemap = get_node(@"/root/Root/TileMap")
	if tilemap.get_turn() == 50 && game_over == false:
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
	var tilemap = get_node(@"/root/Root/TileMap")
	get_node("Stats/CurrencyCountLabel").text = str(tilemap.currency)
	get_node("Stats/VPCountLabel").text = str(tilemap.vp)
	get_node("Stats/BuildingsPlacedCountLabel").text = str(tilemap.buildings_placed)


func _on_FreeplayButton_pressed():
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
	get_tree().paused = false
	get_tree().change_scene("res://Interface/Title.tscn")


func _on_ExitGameButton_pressed():
	get_tree().quit()
