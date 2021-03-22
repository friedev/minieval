extends Control

#Make score report overlay appear when user holds shift
func _input(event):
	var palette = get_node(@"/root/Root/Palette/Menu")
	var currencyLayer = get_node(@"/root/Root/CurrencyLayer/CurrencyLabel")
	if event.is_action_pressed("score_report"):
		#TODO: make palette and currency/vp label disappear
		palette.visible = false
		currencyLayer.visible = false
		update_currency()
		visible = true
	elif event.is_action_released("score_report"):
		palette.visible = true
		currencyLayer.visible = true
		visible = false

#update currency
func update_currency():
	var tilemap = get_node(@"/root/Root/TileMap")
	get_node("Stats/CurrencyCountLabel").text = str(tilemap.currency)
	get_node("Stats/VPCountLabel").text = str(tilemap.vp)
	get_node("Stats/BuildingsPlacedCountLabel").text = str(tilemap.buildings_placed)
