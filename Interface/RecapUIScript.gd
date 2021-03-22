extends Control

var game_over = false

#Make end game recap report appear
#when game ends (TODO: make game endable/losable)
func _input(event):
	var palette = get_node(@"/root/Root/Palette/Menu")
	var ui_text_layer = get_node(@"/root/Root/UITextLayer")
	if game_over:
		visible = true
		palette.visible = false
		for child in ui_text_layer.get_children():
			child.visible = false

func update_labels():
	var tilemap = get_node(@"/root/Root/TileMap")
	get_node("Stats/CurrencyCountLabel").text = str(tilemap.currency)
	get_node("Stats/VPCountLabel").text = str(tilemap.vp)
	get_node("Stats/BuildingsPlacedCountLabel").text = str(tilemap.buildings_placed)
