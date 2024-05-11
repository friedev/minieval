class_name PauseMenu extends Control

@export_file("*.tscn") var title_scene: String

@export_group("External Nodes")
@export var city_map: CityMap
@export var recap: RecapMenu
@export var options: OptionsMenu
@export var tutorial: TutorialMenu
@export var black_overlay: ColorRect


# Make pause menu appear when user presses pause (Escape)
func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"pause") && self.recap.visible == false:
		self.visible = not self.visible


func _on_ResumeButton_pressed() -> void:
	self.hide()


func _on_ReturnToTitleButton_pressed() -> void:
	self.get_tree().change_scene_to_file(self.title_scene)


func _on_OptionsButton_pressed() -> void:
	self.hide()
	self.options.show()


func _on_TutorialButton_pressed() -> void:
	self.hide()
	self.tutorial.open_tutorial()


func _on_Pause_visibility_changed() -> void:
	if self.black_overlay != null:
		self.black_overlay.visible = self.visible
	if self.city_map != null:
		self.city_map.in_menu = self.visible
