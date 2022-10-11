extends Control

onready var pause := get_node("/root/Root/PauseMenu/Pause")


func _ready() -> void:
	if Global.tutorial_seen:
		visible = false
	else:
		pause.set_process_input(false)
		get_tree().paused = true


func close_tutorial() -> void:
	pause.set_process_input(true)
	get_tree().paused = false
	visible = false
	Global.tutorial_seen = true


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		close_tutorial()


func _on_PlayButton_pressed() -> void:
	close_tutorial()
