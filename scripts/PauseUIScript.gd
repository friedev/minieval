extends Control

onready var recap := get_node("/root/Root/RecapUI/Control")
onready var options := get_node("/root/Root/OptionsMenu/Options")
onready var tutorial := get_node("/root/Root/Tutorial/Tutorial")

const title_scene := "res://scenes/Title.tscn"
const main_scene := "res://scenes/Main.tscn"

var paused := false


func _ready():
	$Menu/ExitGameButton.disabled = OS.get_name() == "HTML5"


func set_paused(new_paused: bool) -> void:
	paused = new_paused
	visible = paused


# Make pause menu appear when user presses pause (Escape)
func _input(event):
	if event.is_action_pressed("pause") && recap.visible == false:
		set_paused(not paused)


func _on_ResumeButton_pressed():
	set_paused(false)


func _on_ExitGameButton_pressed():
	get_tree().quit()


func _on_ReturnToTitleButton_pressed():
	get_tree().change_scene(title_scene)


func _on_OptionsButton_pressed():
	Global.last_scene = main_scene
	options.visible = true
	set_paused(false)


func _on_TutorialButton_pressed():
	set_paused(false)
	tutorial.open_tutorial()
