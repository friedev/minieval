extends Control

var isPaused = false

# Make score report overlay appear when user holds shift
func _input(event):
	var tilemap = get_node(@"/root/Root/TileMap")
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
	var Recap = get_node(@"/root/Root/RecapUI/Control")
	if event.is_action_pressed("score_report") && Recap.game_over == false:
		tilemap._clear_preview()
		isPaused = true
		get_tree().paused = isPaused
		palette.visible = false
		for child in ui_text_layer.get_children():
			if child.name != "Timer":
				child.visible = false
		update_currency()
		visible = true
	elif event.is_action_released("score_report") && Recap.game_over == false:
		isPaused = false
		get_tree().paused = isPaused
		palette.visible = true
		for child in ui_text_layer.get_children():
			if child.name != "Timer":
				child.visible = true
		if Global.game_mode > 0:
			turn_label.visible = false
		visible = false

func update_currency():
	var tilemap = get_node(@"/root/Root/TileMap")
	if Global.game_mode != 3:
		var currencyCount = str(tilemap.currency)
		if(currencyCount == "69"):
			currencyCount = "69 (nice.)"
		get_node("Stats/CurrencyCountLabel").text = currencyCount
		var VPCount = str(tilemap.vp)
		if(VPCount == "69"):
			VPCount = "69 (nice.)"
		get_node("Stats/VPCountLabel").text = VPCount
	else:
		get_node("Stats/CurrencyCountLabel").text = "inf"
		get_node("Stats/VPCountLabel").text = "inf"
	var BuildingCount = str(tilemap.buildings_placed)
	if(BuildingCount == "69"):
		BuildingCount = "69 (nice.)"
	get_node("Stats/BuildingsPlacedCountLabel").text = BuildingCount
