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
	get_node("Stats/CurrencyCountLabel").text = get_node(@"/root/Root/StatsOverlay/CurrencyLabel").text
	get_node("Stats/VPCountLabel").text = get_node(@"/root/Root/StatsOverlay/VPLabel").text
	get_node("Stats/BuildingsPlacedCountLabel").text = get_node(@"/root/Root/StatsOverlay/BuildingsPlacedLabel").text
