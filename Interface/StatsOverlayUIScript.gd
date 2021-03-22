extends Control

#Make score report overlay appear when user holds shift
func _input(event):
	if event.is_action_pressed("score_report"):
		update_currency()
		visible = true
	elif event.is_action_released("score_report"):
		visible = false

#update currency
func update_currency():
	var tilemap = get_node(@"/root/Root/TileMap")
	get_node("Stats/CurrencyCountLabel").text = "%d" % tilemap.currency
	get_node("Stats/VPCountLabel").text = "%d" % tilemap.vp
	get_node("Stats/BuildingsPlacedCountLabel").text = "%d" % tilemap.buildings_placed
