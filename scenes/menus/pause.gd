extends Container

@onready var main := self.get_node("/root/Main")
@onready var tilemap := self.main.find_child("TileMap")
@onready var recap := self.main.find_child("Recap")
@onready var options := self.main.find_child("Options")
@onready var tutorial := self.main.find_child("Tutorial")
@onready var black_overlay := self.main.find_child("BlackOverlay")
@onready var exit_game_button := self.find_child("ExitGameButton")

const title_scene := "res://scenes/title.tscn"


func _ready() -> void:
	self.exit_game_button.visible = OS.get_name() != "HTML5"


# Make pause menu appear when user presses pause (Escape)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") && recap.visible == false:
		self.visible = not self.visible


func _on_ResumeButton_pressed() -> void:
	self.hide()


func _on_ExitGameButton_pressed() -> void:
	self.get_tree().quit()


func _on_ReturnToTitleButton_pressed() -> void:
	self.get_tree().change_scene_to_file(title_scene)


func _on_OptionsButton_pressed() -> void:
	self.hide()
	self.options.show()


func _on_TutorialButton_pressed() -> void:
	self.hide()
	self.tutorial.open_tutorial()


func _on_Pause_visibility_changed() -> void:
	if self.black_overlay != null:
		self.black_overlay.visible = self.visible
	if self.tilemap != null:
		self.tilemap.in_menu = self.visible
