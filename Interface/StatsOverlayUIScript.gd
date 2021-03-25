extends Control

# Make score report overlay appear when user holds shift
func _input(event):
	var tilemap = get_node(@"/root/Root/TileMap")
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	if event.is_action_pressed("score_report"):
		tilemap._clear_preview()
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		palette.visible = false
		for child in ui_text_layer.get_children():
			child.visible = false
		update_currency()
		visible = true
	elif event.is_action_released("score_report"):
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		palette.visible = true
		for child in ui_text_layer.get_children():
			child.visible = true
		visible = false

func update_currency():
	var tilemap = get_node(@"/root/Root/TileMap")
	get_node("Stats/CurrencyCountLabel").text = str(tilemap.currency)
	get_node("Stats/VPCountLabel").text = str(tilemap.vp)
	get_node("Stats/BuildingsPlacedCountLabel").text = str(tilemap.buildings_placed)
