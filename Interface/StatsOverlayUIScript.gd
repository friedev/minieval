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
