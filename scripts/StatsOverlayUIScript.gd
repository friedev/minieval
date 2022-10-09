extends Control

onready var tilemap = get_node(@"/root/Root/TileMap")
onready var palette = get_node(@"/root/Root/Palette/Menu")
onready var ui_text_layer = get_node(@"/root/Root/UITextLayer")
onready var turn_label = get_node(@"/root/Root/UITextLayer/TurnLabel")
onready var recap = get_node(@"/root/Root/RecapUI/Control")
onready var pauseMenu = get_node(@"/root/Root/PauseMenu/Pause")
onready var info = get_node(@"/root/Root/InfoOverlay/Control")

var isPaused = false

# Make score report overlay appear when user holds shift
func _input(event):
	if event.is_action_pressed("score_report") && recap.game_over == false:
		tilemap._clear_preview()
		isPaused = true
		get_tree().paused = isPaused
		palette.visible = false
		if Global.game_mode != 3:
			for child in ui_text_layer.get_children():
				if child.name != "Timer":
					child.visible = false
		update_currency()
		_node_input_pause(pauseMenu)
		_node_input_pause(info)
		visible = true
	elif event.is_action_released("score_report") && recap.game_over == false:
		isPaused = false
		get_tree().paused = isPaused
		palette.visible = true
		if Global.game_mode != 3:
			for child in ui_text_layer.get_children():
				if child.name != "Timer":
					child.visible = true
		if Global.game_mode > 0:
			turn_label.visible = false
		_node_input_pause(pauseMenu)
		_node_input_pause(info)
		visible = false

func update_currency():
	if Global.game_mode != 3:
		var currencyCount = str(tilemap.currency)
		if currencyCount == "69":
			currencyCount = "69 (nice.)"
		$Stats/CurrencyCountLabel.text = currencyCount
		var VPCount = str(tilemap.vp)
		if VPCount == "69":
			VPCount = "69 (nice.)"
		$Stats/VPCountLabel.text = VPCount
	else:
		$Stats/CurrencyCountLabel.text = "inf"
		$Stats/VPCountLabel.text = "inf"

#pauses input for a given node
func _node_input_pause(node):
	var nodeInput = node.is_processing_input()
	node.set_process_input(!nodeInput)
