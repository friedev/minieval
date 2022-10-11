extends Control

onready var recap := get_node("/root/Root/RecapUI/Control")
onready var options := get_node("/root/Root/OptionsMenu/Options")

const title_scene := "res://scenes/Title.tscn"
const main_scene := "res://scenes/Main.tscn"


func _ready():
	$Menu/ExitGameButton.disabled = OS.get_name() == "HTML5"


# Make pause menu appear when user presses pause (Escape)
func _input(event):
	if event.is_action_pressed("pause") && recap.visible == false:
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state


# Pauses or unpauses input for a given node
func _node_input_pause(node):
	node.set_process_input(not node.is_processing_input())


func _on_ResumeButton_pressed():
	var new_pause_state := not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state


func _on_ExitGameButton_pressed():
	get_tree().quit()


func _on_ReturnToTitleButton_pressed():
	var new_pause_state = not get_tree().paused
	get_tree().paused = new_pause_state
	get_tree().change_scene(title_scene)


func _on_OptionsButton_pressed():
	Global.last_scene = main_scene
	options.visible = true
	var new_pause_state := not get_tree().paused
	get_tree().paused = new_pause_state
	visible = new_pause_state
