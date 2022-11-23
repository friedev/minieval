extends Popup

onready var main := self.get_node("/root/Main")
onready var tilemap := self.main.find_node("TileMap")
onready var recap := self.main.find_node("Recap")
onready var options := self.main.find_node("Options")
onready var tutorial := self.main.find_node("Tutorial")
onready var black_overlay := self.main.find_node("BlackOverlay")
onready var exit_game_button := self.find_node("ExitGameButton")

const title_scene := "res://scenes/Title.tscn"


func _ready():
	self.exit_game_button.visible = OS.get_name() != "HTML5"


# Make pause menu appear when user presses pause (Escape)
func _input(event):
	if event.is_action_pressed("pause") && recap.visible == false:
		self.visible = not self.visible


func _on_ResumeButton_pressed():
	self.hide()


func _on_ExitGameButton_pressed():
	get_tree().quit()


func _on_ReturnToTitleButton_pressed():
	get_tree().change_scene(title_scene)


func _on_OptionsButton_pressed():
	self.hide()
	options.popup()


func _on_TutorialButton_pressed():
	self.hide()
	tutorial.open_tutorial()


func _on_Pause_visibility_changed():
	black_overlay.visible = self.visible
	self.tilemap.in_menu = self.visible
