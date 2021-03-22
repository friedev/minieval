extends Control

var game_over = false

#Make end game recap report appear
#when game ends (TODO: make game endable/losable)
func _input(event):
	var palette = get_node(@"/root/Root/Palette/Menu")
	var currencyLayer = get_node(@"/root/Root/CurrencyLayer/CurrencyLabel")
	if game_over:
		visible = true
		palette.visible = false
		currencyLayer.visible = false

func update_labels():
	var tilemap = get_node(@"/root/Root/TileMap")
	get_node("Stats/CurrencyCountLabel").text = "%d" % tilemap.currency
	get_node("Stats/VPCountLabel").text = "%d" % tilemap.vp
	get_node("Stats/BuildingsPlacedCountLabel").text = "%d" % tilemap.buildings_placed
