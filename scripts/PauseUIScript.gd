extends Control

onready var recap = get_node(@"/root/Root/RecapUI/Control")
onready var stats = get_node(@"/root/Root/StatsOverlay/Control")
onready var info = get_node(@"/root/Root/InfoOverlay/Control")
onready var options = get_node(@"/root/Root/OptionsMenu/Options")

func _ready():
	$Menu/ExitGameButton.disabled = OS.get_name() == "HTML5"

# Make pause menu appear when user presses pause (Escape)
func _input(event):
	if event.is_action_pressed("pause") && recap.game_over == false:
		_node_input_pause(stats)
		_node_input_pause(info)
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state

# Pauses or unpauses input for a given node
func _node_input_pause(node):
	node.set_process_input(not node.is_processing_input())

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
	get_tree().change_scene("res://scenes/Title.tscn")

func _on_OptionsButton_pressed():
	Global.last_scene = "res://scenes/Main.tscn"
	options.visible = true
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state