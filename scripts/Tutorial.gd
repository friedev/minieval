extends Control

onready var info = get_node(@"/root/Root/InfoOverlay/Control")
onready var pause = get_node(@"/root/Root/PauseMenu/Pause")


func _ready():
	if Global.tutorial_seen:
		visible = false
	else:
		info.set_process_input(false)
		pause.set_process_input(false)
		get_tree().paused = true


func _on_PlayButton_pressed():
	info.set_process_input(true)
	pause.set_process_input(true)
	get_tree().paused = false
	visible = false
	Global.tutorial_seen = true
