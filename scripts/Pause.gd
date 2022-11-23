extends Popup

onready var main := self.get_node("/root/Main")
onready var recap := self.main.find_node("Recap")
onready var options := self.main.find_node("Options")
onready var tutorial := self.main.find_node("Tutorial")
onready var black_overlay := self.main.find_node("BlackOverlay")
onready var exit_game_button := self.find_node("ExitGameButton")

const title_scene := "res://scenes/Title.tscn"

var paused := false


func _ready():
	self.exit_game_button.disabled = OS.get_name() == "HTML5"


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
	set_paused(false)
	options.popup()


func _on_TutorialButton_pressed():
	set_paused(false)
	tutorial.open_tutorial()


func _on_Pause_visibility_changed():
	black_overlay.visible = self.visible
