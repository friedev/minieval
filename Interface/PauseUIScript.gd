extends Control

#Make pause menu appear when user presses pause (Escape)
func _input(event):
	var Recap = get_node(@"/root/Root/RecapUI/Control")
	if event.is_action_pressed("pause") && Recap.game_over == false:
		var stats = get_node(@"/root/Root/StatsOverlay/Control")
		_node_input_pause(stats)
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state
		
#pauses input for a given node
func _node_input_pause(node):
	var nodeInput = node.is_processing_input()
	node.set_process_input(!nodeInput)

func _on_ResumeButton_pressed():
	var stats = get_node(@"/root/Root/StatsOverlay/Control")
	_node_input_pause(stats)
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
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	get_tree().change_scene("res://Interface/OptionsMenu.tscn")
