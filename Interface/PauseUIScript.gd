extends Control

onready var recap = get_node(@"/root/Root/RecapUI/Control")
onready var stats = get_node(@"/root/Root/StatsOverlay/Control")
onready var info = get_node(@"/root/Root/InfoOverlay/Control")
onready var options = get_node(@"/root/Root/OptionsMenu/Options")

# Make pause menu appear when user presses pause (Escape)
func _input(event):
	if event.is_action_pressed("pause") && recap.game_over == false:
		_node_input_pause(stats)
		_node_input_pause(info)
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state
		
# Pauses input for a given node
func _node_input_pause(node):
	var nodeInput = node.is_processing_input()
	node.set_process_input(!nodeInput)

func _on_ResumeButton_pressed():
	_node_input_pause(stats)
	_node_input_pause(info)
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state

func _on_ExitGameButton_pressed():
	get_tree().quit()

func _on_ReturnToTitleButton_pressed():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	get_tree().change_scene("res://Interface/Title.tscn")

func _on_OptionsButton_pressed():
	options.visible = true
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
	Global.last_scene = "res://Main.tscn"
